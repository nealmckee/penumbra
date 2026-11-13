# SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
# Copyright (c) 2021-2026 Neal McKee. All rights reserved.

using Colors: XYZ, xyY, RGB, hex
using StaticArrays: @SMatrix, SVector

include("base_color_curve.jl")

const CANONICAL_ACCENT_NAMES = Dict{Int, Vector{String}}(
    6 => ["red", "yellow", "green", "cyan", "blue", "magenta"],
    7 => ["red", "orange", "yellow", "green", "cyan", "blue", "purple"],
    8 => ["red", "orange", "yellow", "green", "cyan", "blue", "purple", "magenta"]
)

"""
    in_srgb(xyz::XYZ)

Checks whether linear sRGB coordinates converted from XYZ lie strictly within [0, 1]^3.
"""
@inline function in_srgb(xyz::XYZ)
    rgb = _XYZ_TO_LRGB * SVector(xyz.x, xyz.y, xyz.z)
    return rgb[1] >= 0.0 && rgb[1] <= 1.0 &&
           rgb[2] >= 0.0 && rgb[2] <= 1.0 &&
           rgb[3] >= 0.0 && rgb[3] <= 1.0
end

"""
    max_gamut_chroma(J_hk_target::Real, h::Real, env::ViewingEnvironment; alpha::Real=0.0, max_iters::Integer=45)

Finds the maximum CAM16-UCS chroma C' at hue angle `h` (in degrees) such that the color with
H-K perceived lightness `J_hk_target` (under weighting parameter `alpha`) sits inside the sRGB gamut cube.
"""
function max_gamut_chroma(J_hk_target::Real, h::Real, env::ViewingEnvironment; alpha::Real=0.0, max_iters::Integer=45)
    lo = 0.0
    hi = 120.0

    for _ in 1:max_iters
        mid = 0.5 * (lo + hi)
        (mid == lo || mid == hi) && break
        J_ach = cam16ucs_hk_inverse_lightness(J_hk_target, mid, h; alpha=alpha)
        if J_ach <= 0.0 || J_ach >= 100.0
            hi = mid
            continue
        end
        jch = CAM16UCSJCh(J_ach, mid, h, env)
        J_cam, C_cam, h_cam = _cam16ucs_to_cam16(jch)
        x, y, z = _cam16_to_xyz(CAM16JCh(J_cam, C_cam, h_cam, env), env)
        if in_srgb(XYZ(x, y, z))
            lo = mid
        else
            hi = mid
        end
    end
    return 0.5 * (lo + hi)
end

"""
    polygon_gamut_chroma(J_hk_target::Real, h0::Real, N::Integer, env::ViewingEnvironment; alpha::Real=0.0)

Computes the maximum uniform chroma C'_N(h0, alpha) for a regular N-gon rotated by h0:
    C'_N(h0, alpha) = min_{k=0..N-1} max_gamut_chroma(J_hk_target, h0 + k*360/N, env; alpha=alpha)
"""
function polygon_gamut_chroma(J_hk_target::Real, h0::Real, N::Integer, env::ViewingEnvironment; alpha::Real=0.0)
    step = 360.0 / N
    min_c = Inf
    for k in 0:(N - 1)
        h = mod(h0 + k * step, 360.0)
        c = max_gamut_chroma(J_hk_target, h, env; alpha=alpha)
        if c < min_c
            min_c = c
        end
    end
    return min_c
end

@inline function angdiff(h1::Real, h2::Real)
    return mod(h1 - h2 + 180.0, 360.0) - 180.0
end

"""
    AccentTone{T<:Real}

Represents a single accent color in CAM16-UCS and sRGB coordinates.
"""
struct AccentTone{T<:Real}
    name::String
    h::T
    C_ucs::T
    J_ach_ucs::T
    J_hk_ucs::T
    Y::T
    rgb::RGB{T}
    hex::String
end

"""
    AccentPalette{T<:Real}

A solved N-color accent palette with optimization metadata.
"""
struct AccentPalette{T<:Real}
    N::Int
    alpha::T
    h0::T
    C_poly::T
    C_inscribed::T
    rmse_hue::T
    max_abs_dh::T
    loss::T
    tones::Vector{AccentTone{T}}
end

const CAM16_UNIQUE_HUES = (
    ("red", 20.14, 0.8),
    ("yellow", 90.00, 0.7),
    ("green", 164.25, 1.0),
    ("blue", 237.53, 1.2),
)

"""
    optimize_accent_palette(N::Integer, J_hk_target::Real, env::ViewingEnvironment; alpha::Real=1.0)

Solves the N-color accent palette rotated along the polygonal gamut boundary via analytical
circular mean alignment across all four CAM16 Unique Hues (Red 20.14°, Yellow 90.00°,
Green 164.25°, Blue 237.53°), weighted by inverse CAM16 eccentricity squared (1 / e_i^2).
"""
function optimize_accent_palette(N::Integer, J_hk_target::Real, env::ViewingEnvironment; alpha::Real=1.0)
    names = get(CANONICAL_ACCENT_NAMES, N) do
        error("Unsupported accent palette size N=$N. Supported sizes: 6, 7, 8")
    end
    step = 360.0 / N

    c_inscribed = minimum(max_gamut_chroma(J_hk_target, h, env; alpha=alpha, max_iters=35) for h in 0.0:1.0:359.0)

    sin_sum = 0.0
    cos_sum = 0.0
    for (name, h_tgt, e) in CAM16_UNIQUE_HUES
        k = findfirst(==(name), names)
        k === nothing && continue
        phi = deg2rad(h_tgt - (k - 1) * step)
        w = 1.0 / (e^2)
        sin_sum += w * sin(phi)
        cos_sum += w * cos(phi)
    end
    best_h0 = mod(rad2deg(atan(sin_sum, cos_sum)), 360.0)
    c_final = polygon_gamut_chroma(J_hk_target, best_h0, N, env; alpha=alpha)

    dhs = Float64[]
    w_sq_err = 0.0
    sum_w = 0.0
    for (name, h_tgt, e) in CAM16_UNIQUE_HUES
        k = findfirst(==(name), names)
        k === nothing && continue
        hk = mod(best_h0 + (k - 1) * step, 360.0)
        dh = angdiff(hk, h_tgt)
        push!(dhs, dh)
        w = 1.0 / (e^2)
        w_sq_err += w * dh^2
        sum_w += w
    end
    rmse_hue = sqrt(sum(dhs.^2) / length(dhs))
    max_abs_dh = maximum(abs.(dhs))
    best_loss = w_sq_err / sum_w

    tones = AccentTone{Float64}[]
    for k in 1:N
        h = mod(best_h0 + (k - 1) * step, 360.0)
        j_ach = cam16ucs_hk_inverse_lightness(J_hk_target, c_final, h; alpha=alpha)
        jch = CAM16UCSJCh(j_ach, c_final, h, env)
        xyz = convert(XYZ, jch)
        rgb = convert(RGB, xyz)
        r = clamp(rgb.r, 0.0, 1.0)
        g = clamp(rgb.g, 0.0, 1.0)
        b = clamp(rgb.b, 0.0, 1.0)
        hex_str = string(hex(RGB(r, g, b)))
        push!(tones, AccentTone(
            names[k],
            Float64(h),
            Float64(c_final),
            Float64(j_ach),
            Float64(J_hk_target),
            Float64(xyz.y),
            RGB{Float64}(r, g, b),
            hex_str
        ))
    end

    return AccentPalette(
        N,
        Float64(alpha),
        Float64(best_h0),
        Float64(c_final),
        Float64(c_inscribed),
        Float64(rmse_hue),
        Float64(max_abs_dh),
        Float64(best_loss),
        tones
    )
end
