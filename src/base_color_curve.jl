# SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
# Copyright (c) 2021-2026 Neal McKee. All rights reserved.

using Colors: XYZ, xyY, RGB, hex
using StaticArrays: @SMatrix, SVector

include("cam16revised.jl")
include("color_loci.jl")

const T_D65 = 6503.616143942142
const MIRED_D65 = 1e6 / T_D65
const _DL_D65 = daylight_locus(T_D65, 1.0)
const _WP_D65 = xyY(VE.WP_xyz)

# Offset between CIE daylight parabola and sRGB D65 display whitepoint
const _DX_D65 = _WP_D65.x - _DL_D65.x
const _DY_D65 = _WP_D65.y - _DL_D65.y

const _XYZ_TO_LRGB = @SMatrix [
    3.2404542 -1.5371385 -0.4985314;
    -0.9692660 1.8760108 0.0415560;
    0.0556434 -0.2040259 1.0572252
]

"""
    daylight_chromaticity(T::Real)

CIE daylight locus chromaticity (x, y) anchored to display whitepoint at T = T_D65.
"""
function daylight_chromaticity(T::Real)
    dl = daylight_locus(T, 1.0)
    return dl.x + _DX_D65, dl.y + _DY_D65
end

"""
    luminance_for_cam16ucs_j(x::Real, y::Real, J_prime::Real, env::ViewingEnvironment=VE)

Inverts CAM16-UCS lightness J' to find the exact luminance factor Y for chromaticity (x, y).
"""
function luminance_for_cam16ucs_j(x::Real, y::Real, J_prime::Real, env::ViewingEnvironment=VE)
    J_target = sign(J_prime) * abs(J_prime) / (1.7 - 0.007 * abs(J_prime))
    c_100 = oftype(J_target, 100)
    A_target = env.A_w * (abs(J_target / c_100) ^ (one(J_target) / (env.c * env.z)))

    inv_y = inv(y)
    xyz1 = SVector(x * inv_y * 100.0, 100.0, (1.0 - x - y) * inv_y * 100.0)
    R1, G1, B1 = M16 * xyz1

    lo = 0.0
    hi = 2.0  # Luminance ceiling: provides headroom for chromatic adaptation in non-fluorescent media
    while true
        mid = 0.5 * (lo + hi)
        (mid == lo || mid == hi) && break
        R_c = env.D_RGB[1] * R1 * mid
        G_c = env.D_RGB[2] * G1 * mid
        B_c = env.D_RGB[3] * B1 * mid
        R_a = _adapt(R_c, env.F_L)
        G_a = _adapt(G_c, env.F_L)
        B_a = _adapt(B_c, env.F_L)
        A = 2.0 * R_a + G_a + 0.05 * B_a
        if A < A_target
            lo = mid
        else
            hi = mid
        end
    end
    return 0.5 * (lo + hi)
end

function _eval_linear_rgb(T::Real, J_prime::Real, env::ViewingEnvironment)
    x, y = daylight_chromaticity(T)
    Y = luminance_for_cam16ucs_j(x, y, J_prime, env)
    xyz = convert(XYZ, xyY(x, y, Y))
    return _XYZ_TO_LRGB * SVector(xyz.x, xyz.y, xyz.z)
end

function _solve_gamut_max_lightness(J_sky::Real, k_mu::Real, env::ViewingEnvironment)
    J_t4000 = J_sky + (MIRED_DAYLIGHT_MAX - MIRED_D65) / k_mu
    lo = float(J_sky)
    hi = min(100.0, J_t4000)

    while true
        mid = 0.5 * (lo + hi)
        (mid == lo || mid == hi) && break
        mu = MIRED_D65 + k_mu * (mid - J_sky)
        T = 1e6 / mu
        rgb_lin = _eval_linear_rgb(T, mid, env)
        if maximum(rgb_lin) <= 1.0
            lo = mid
        else
            hi = mid
        end
    end
    return 0.5 * (lo + hi)
end

function _solve_gamut_min_lightness(J_sky::Real, k_mu::Real)
    J_t25000 = J_sky + (MIRED_DAYLIGHT_MIN - MIRED_D65) / k_mu
    return max(0.0, J_t25000)
end

"""
    BaseColorCurve{T<:Real, E<:ViewingEnvironment}

Continuous 1D base color curve mapping CAM16-UCS lightness J' to daylight locus colors.
"""
struct BaseColorCurve{T<:Real,E<:ViewingEnvironment}
    J_sky::T
    k_mu::T
    env::E
    J_min::T
    J_max::T
end

function BaseColorCurve(J_sky::Real, k_mu::Real, env::ViewingEnvironment=VE)
    if k_mu <= 0
        throw(DomainError(k_mu, "Slope k_mu must be strictly positive"))
    end
    T = promote_type(typeof(float(J_sky)), typeof(float(k_mu)))
    J_max = T(_solve_gamut_max_lightness(J_sky, k_mu, env))
    J_min = T(_solve_gamut_min_lightness(J_sky, k_mu))
    if J_sky < J_min || J_sky > J_max
        throw(DomainError(J_sky, "Anchor J_sky=$J_sky is outside computed gamut bounds [$J_min, $J_max]"))
    end
    return BaseColorCurve{T,typeof(env)}(T(J_sky), T(k_mu), env, J_min, J_max)
end

function mired(curve::BaseColorCurve, J_prime::Real)
    if J_prime < curve.J_min || J_prime > curve.J_max
        throw(DomainError(J_prime, "Lightness J'=$J_prime is outside valid curve domain [$(curve.J_min), $(curve.J_max)]"))
    end
    return oftype(curve.k_mu, MIRED_D65) + curve.k_mu * (J_prime - curve.J_sky)
end

function temperature(curve::BaseColorCurve, J_prime::Real)
    return 1e6 / mired(curve, J_prime)
end

function (curve::BaseColorCurve)(J_prime::Real)
    T = temperature(curve, J_prime)
    x, y = daylight_chromaticity(T)
    Y = luminance_for_cam16ucs_j(x, y, J_prime, curve.env)
    xyz = convert(XYZ, xyY(x, y, Y))
    return convert(CAM16UCSJab, xyz, curve.env)
end

"""
    solve_in_env(curve::BaseColorCurve, target_j_env::Real, env::ViewingEnvironment)

Inverts the viewing environment adaptation to find J'_base on `curve` that produces
target J' under `env`.
"""
function solve_in_env(curve::BaseColorCurve, target_j_env::Real, env::ViewingEnvironment)
    lo = curve.J_min
    hi = curve.J_max
    for _ in 1:45
        mid = 0.5 * (lo + hi)
        xyz = convert(XYZ, curve(mid))
        j_env = convert(CAM16UCSJCh, xyz, env).j
        if j_env < target_j_env
            lo = mid
        else
            hi = mid
        end
    end
    return 0.5 * (lo + hi)
end

"""
    solve_base_palette(; T_top=5772.0, N_dark=12.0, n_main=7.0, n_surf=1.0, env_base=VE, max_iters=40)

Solves the self-consistent harmonic base color lattice:
- `T_top`: Top-end CCT at the sRGB gamut boundary J'_max (default: 5772.0 K, IAU 2015 nominal solar photosphere).
- `N_dark`: Integer steps from black (J'=0) to sky in ENV_DARK (default: 12.0).
- `n_main`: Main canvas-to-text contrast steps (default: 7.0, so 7*Δ).
- `n_surf`: Surface elevation steps (default: 1.0, so 1*Δ).
"""
function solve_base_palette(;
    T_top::Real=5772.0,
    N_dark::Real=12.0,
    n_main::Real=7.0,
    n_surf::Real=1.0,
    env_base::ViewingEnvironment=VE,
    max_iters::Integer=40,
)
    x_top, y_top = daylight_chromaticity(T_top)
    xyz1 = convert(XYZ, xyY(x_top, y_top, 1.0))
    Y_max = 1.0 / maximum(_XYZ_TO_LRGB * SVector(xyz1.x, xyz1.y, xyz1.z))
    J_sun_plus = convert(CAM16UCSJCh, convert(XYZ, xyY(x_top, y_top, Y_max)), env_base).j

    J_sky = 61.0
    J_sun = J_sun_plus - 4.5
    J_shade = 21.0
    k_mu = 0.53
    dJ = 5.5

    for _ in 1:max_iters
        k_mu = (1e6 / T_top - MIRED_D65) / (J_sun_plus - J_sky)
        c = BaseColorCurve(J_sky, k_mu, env_base)
        xyz_sun = convert(XYZ, c(J_sun))
        xyz_sh = convert(XYZ, c(J_shade))
        env_l = ViewingEnvironment(whitepoint=env_base.WP_xyz, adapting_luminance=24.0, relative_background_luminance=xyz_sun.y, surround=:average, discounting=true)
        env_d = ViewingEnvironment(whitepoint=env_base.WP_xyz, adapting_luminance=24.0, relative_background_luminance=xyz_sh.y, surround=:average, discounting=true)

        lo, hi = 45.0, 75.0
        for _ in 1:45
            mid = 0.5 * (lo + hi)
            Y_s = luminance_for_cam16ucs_j(_WP_D65.x, _WP_D65.y, mid, env_base)
            xyz_s = convert(XYZ, xyY(_WP_D65.x, _WP_D65.y, Y_s))
            jd_s = convert(CAM16UCSJCh, xyz_s, env_d).j
            jl_s = convert(CAM16UCSJCh, xyz_s, env_l).j
            jl_top = convert(CAM16UCSJCh, convert(XYZ, c(J_sun_plus)), env_l).j
            if (jl_top - jl_s) / (n_main + n_surf) < jd_s / N_dark
                hi = mid
            else
                lo = mid
            end
        end
        J_sky = 0.5 * (lo + hi)
        xyz_sky = convert(XYZ, c(J_sky))
        dJ = convert(CAM16UCSJCh, xyz_sky, env_d).j / N_dark

        jl_top = convert(CAM16UCSJCh, convert(XYZ, c(J_sun_plus)), env_l).j
        target_sun_l = jl_top - n_surf * dJ
        lo, hi = 70.0, J_sun_plus
        for _ in 1:45
            mid = 0.5 * (lo + hi)
            if convert(CAM16UCSJCh, convert(XYZ, c(mid)), env_l).j < target_sun_l
                lo = mid
            else
                hi = mid
            end
        end
        J_sun = 0.5 * (lo + hi)

        target_shade_d = (N_dark - n_main) * dJ
        lo, hi = 1.0, 45.0
        for _ in 1:45
            mid = 0.5 * (lo + hi)
            if convert(CAM16UCSJCh, convert(XYZ, c(mid)), env_d).j < target_shade_d
                lo = mid
            else
                hi = mid
            end
        end
        J_shade = 0.5 * (lo + hi)
    end

    curve = BaseColorCurve(J_sky, k_mu, env_base)
    xyz_shade = convert(XYZ, curve(J_shade))
    xyz_sun = convert(XYZ, curve(J_sun))
    env_dark = ViewingEnvironment(whitepoint=env_base.WP_xyz, adapting_luminance=24.0, relative_background_luminance=xyz_shade.y, surround=:average, discounting=true)
    env_light = ViewingEnvironment(whitepoint=env_base.WP_xyz, adapting_luminance=24.0, relative_background_luminance=xyz_sun.y, surround=:average, discounting=true)
    return (curve=curve, dJ=dJ, env_dark=env_dark, env_light=env_light, J_sun_plus=J_sun_plus, J_sun=J_sun, J_sky=J_sky, J_shade=J_shade)
end

"""
    BaseTone{T<:Real, C<:AbstractCAM16UCS}

Representation of a single base palette tone with both colorimetric coordinates and perceptual metadata.
"""
struct BaseTone{T<:Real,C<:AbstractCAM16UCS}
    tier::Symbol
    name::String
    J_base::T
    Y::T
    T_cct::T
    J_dark::T
    J_light::T
    cam16ucs::C
    rgb::RGB{T}
    hex::String
end

"""
    base_palette_tones(sol)

Generates the complete set of 9 base tones across `:balanced`, `:contrast_plus`, and `:contrast_plus_plus`.
"""
function base_palette_tones(sol)
    c = sol.curve
    dJ = sol.dJ
    env_d = sol.env_dark
    env_l = sol.env_light

    jb_sun_plus = sol.J_sun_plus
    jb_sun = sol.J_sun
    jb_sun_minus = solve_in_env(c, convert(CAM16UCSJCh, convert(XYZ, c(jb_sun)), env_l).j - dJ, env_l)
    jb_sky_plus = solve_in_env(c, convert(CAM16UCSJCh, convert(XYZ, c(jb_sun)), env_l).j - 4.0 * dJ, env_l)
    jb_sky = sol.J_sky
    jb_sky_minus = solve_in_env(c, 9.0 * dJ, env_d)

    # Shadow steps in env_d
    jb_sh6 = solve_in_env(c, 6.0 * dJ, env_d)
    jb_sh5 = sol.J_shade
    jb_sh4 = solve_in_env(c, 4.0 * dJ, env_d)

    function make_tone(tier_sym::Symbol, name::AbstractString, curve_t::BaseColorCurve, env_t::ViewingEnvironment, jb::Real)
        T = typeof(sol.dJ)
        cam = curve_t(jb)
        xyz = convert(XYZ, cam)
        jd = convert(CAM16UCSJCh, xyz, env_t).j
        jl = convert(CAM16UCSJCh, xyz, env_l).j
        rgb = convert(RGB, xyz)
        r = clamp(rgb.r, zero(rgb.r), one(rgb.r))
        g = clamp(rgb.g, zero(rgb.g), one(rgb.g))
        b = clamp(rgb.b, zero(rgb.b), one(rgb.b))
        hex_str = string(hex(RGB(r, g, b)))
        return BaseTone(
            tier_sym,
            string(name),
            T(jb),
            T(xyz.y),
            T(temperature(curve_t, jb)),
            T(jd),
            T(jl),
            cam,
            RGB{T}(T(r), T(g), T(b)),
            hex_str,
        )
    end

    C_TYPE = typeof(c(jb_sky))
    tones = BaseTone{typeof(sol.dJ),C_TYPE}[]

    bal_list = [
        ("sun+", jb_sun_plus), ("sun", jb_sun), ("sun-", jb_sun_minus),
        ("sky+", jb_sky_plus), ("sky", jb_sky), ("sky-", jb_sky_minus),
        ("shade+", jb_sh6), ("shade", jb_sh5), ("shade-", jb_sh4)
    ]
    for (name, jb) in bal_list
        push!(tones, make_tone(:balanced, name, c, env_d, jb))
    end

    for (tier_sym, sh_step, sk_step) in ((:contrast_plus, 4.0, 13.0), (:contrast_plus_plus, 3.0, 14.0))
        res = solve_contrast_tier_base(sol, sh_step, sk_step)
        for (name, jb) in res.jb_specs
            push!(tones, make_tone(tier_sym, name, res.curve, res.env, jb))
        end
    end

    return tones
end

function _xyz_to_hex(xyz::XYZ)
    rgb = convert(RGB, xyz)
    r = clamp(rgb.r, zero(rgb.r), one(rgb.r))
    g = clamp(rgb.g, zero(rgb.g), one(rgb.g))
    b = clamp(rgb.b, zero(rgb.b), one(rgb.b))
    return string(hex(RGB(r, g, b)))
end

"""
    solve_contrast_tier_base(sol, sh_step::Real, sk_step::Real; T_top::Real=5772.0)

Builds a dark contrast-tier 9-tone base dictionary by re-anchoring `BaseColorCurve` so
`shade` sits at `sh_step * dJ`, `sky` remains at D65 (6504 K) at `sk_step * dJ`, and
`sun+` stays pinned at `T_top`.
"""
function solve_contrast_tier_base(sol, sh_step::Real, sk_step::Real; T_top::Real=5772.0)
    dJ = sol.dJ
    env_base = sol.curve.env
    jb_sun_minus_ref = solve_in_env(
        sol.curve,
        convert(CAM16UCSJCh, convert(XYZ, sol.curve(sol.J_sun)), sol.env_light).j - dJ,
        sol.env_light,
    )
    xyz_sun_ref = convert(XYZ, sol.curve(sol.J_sun))
    xyz_sunm_ref = convert(XYZ, sol.curve(jb_sun_minus_ref))

    jb_sh = solve_in_env(sol.curve, sh_step * dJ, sol.env_dark)
    Y_sh = convert(XYZ, sol.curve(jb_sh)).y
    c_t = sol.curve
    env_t = sol.env_dark

    for _ in 1:30
        env_t = ViewingEnvironment(
            whitepoint=env_base.WP_xyz,
            adapting_luminance=24.0,
            relative_background_luminance=Y_sh,
            surround=:average,
            discounting=true,
        )
        Y_sk = luminance_for_cam16ucs_j(_WP_D65.x, _WP_D65.y, sk_step * dJ, env_t)
        xyz_sk = convert(XYZ, xyY(_WP_D65.x, _WP_D65.y, Y_sk))
        J_sky_base = convert(CAM16UCSJCh, xyz_sk, env_base).j
        k_mu_t = (1e6 / T_top - MIRED_D65) / (sol.J_sun_plus - J_sky_base)
        c_t = BaseColorCurve(J_sky_base, k_mu_t, env_base)
        jb_sh = solve_in_env(c_t, sh_step * dJ, env_t)
        Y_sh = convert(XYZ, c_t(jb_sh)).y
    end
    env_t = ViewingEnvironment(
        whitepoint=env_base.WP_xyz,
        adapting_luminance=24.0,
        relative_background_luminance=Y_sh,
        surround=:average,
        discounting=true,
    )

    j_sunp = convert(CAM16UCSJCh, convert(XYZ, c_t(sol.J_sun_plus)), env_t).j
    j_sun = convert(CAM16UCSJCh, xyz_sun_ref, env_t).j
    j_sunm = convert(CAM16UCSJCh, xyz_sunm_ref, env_t).j
    j_sk = sk_step * dJ
    j_skyp = 0.5 * (j_sk + j_sunm)
    j_skym = 0.5 * ((sh_step + 1.0) * dJ + j_sk)

    specs = (
        ("sun+", j_sunp), ("sun", j_sun), ("sun-", j_sunm),
        ("sky+", j_skyp), ("sky", j_sk), ("sky-", j_skym),
        ("shade+", (sh_step + 1.0) * dJ), ("shade", sh_step * dJ), ("shade-", (sh_step - 1.0) * dJ),
    )
    jb_specs = [
        (name, solve_in_env(c_t, jt, env_t))
        for (name, jt) in specs
    ]
    dict = Dict{String,String}(
        name => _xyz_to_hex(convert(XYZ, c_t(jb)))
        for (name, jb) in jb_specs
    )
    return (dict=dict, env=env_t, J_sky_dark=j_sk, curve=c_t, jb_specs=jb_specs)
end
