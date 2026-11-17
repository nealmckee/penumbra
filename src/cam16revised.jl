# SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
# Copyright (c) 2021-2026 Neal McKee. All rights reserved.

import Colors: cnvt, convert
import Base: convert
using Colors: Colors, Color, Colorant, XYZ, RGB, AbstractRGB
using ColorTypes: ColorTypes
using StaticArrays: SVector, SMatrix, @SMatrix

const M16 = @SMatrix [
    0.401288 0.650173 -0.051461;
    -0.250268 1.204414 0.045854;
    -0.002079 0.048952 0.953127
]

const M16_INV = @SMatrix [
    1.8620678550872327 -1.0112546305316843 0.14918677544445175;
    0.38752654323613717 0.6214474419314753 -0.008973985167612518;
    -0.015841498849333856 -0.03412293802851557 1.0499644368778496
]

const M1 = @SMatrix [
    2.0 1.0 0.05;
    1.0 -12/11 1/11;
    1/9 1/9 -2/9
]

const M2 = @SMatrix [
    460.0 451.0 288.0;
    460.0 -891.0 -261.0;
    460.0 -220.0 -6300.0
]

const SURROUND = (dark=(0.8, 0.525, 0.8), dim=(0.9, 0.59, 0.9), average=(1.0, 0.69, 1.0))

# Red, Yellow, Green, Blue, Red
const PRIMARY_HUES = (20.14, 90.00, 164.25, 237.53, 380.14)

const HUE_QUADRATURE = (
    h=PRIMARY_HUES, e=(0.8, 0.7, 1.0, 1.2, 0.8), H=(0.0, 100.0, 200.0, 300.0, 400.0)
)

_lerp(a, b, t) = a + (b - a) * t

function _adapt(C_c::T, F_L::T) where {T<:Real}
    c_100 = oftype(C_c, 100)
    p = oftype(C_c, 0.42)
    k400 = oftype(C_c, 400)
    k27 = oftype(C_c, 27.13)
    x = (F_L * abs(C_c) / c_100) ^ p
    return k400 * sign(C_c) * x / (x + k27)
end
_adapt(C_c, F_L) = _adapt(promote(C_c, F_L)...)

function _unadapt(C_a::T, F_L::T) where {T<:Real}
    k400 = oftype(C_a, 400)
    k27 = oftype(C_a, 27.13)
    c_100 = oftype(C_a, 100)
    p = oftype(C_a, 0.42)
    if abs(C_a) >= k400
        throw(
            DomainError(
                C_a,
                "CAM16 post-adaptation cone response |C_a| must be strictly less than 400.0",
            ),
        )
    end
    x = (k27 * abs(C_a)) / (k400 - abs(C_a))
    return sign(C_a) * (c_100 / F_L) * (x ^ (one(T) / p))
end
_unadapt(C_a, F_L) = _unadapt(promote(C_a, F_L)...)

# ---------------------------------------------------------
# Viewing Environment
# ---------------------------------------------------------

struct ViewingEnvironment{T<:AbstractFloat}
    WP_xyz::XYZ{T}
    L_A::T
    Y_b::T
    discounting::Bool
    F::T
    c::T
    N_c::T
    D_RGB::SVector{3,T}
    F_L::T
    n::T
    z::T
    A_w::T
end

function ViewingEnvironment{T}(;
    whitepoint::XYZ=XYZ(T(0.95047), T(1.0), T(1.08883)),
    adapting_luminance::Real=24.0,
    relative_background_luminance::Real=0.20,
    surround::Union{Symbol,AbstractString,Real}=:average,
    discounting::Bool=true,
) where {T<:AbstractFloat}
    if surround isa Symbol
        F_val, c_val, N_c_val = getproperty(SURROUND, surround)
        F, c, N_c = T(F_val), T(c_val), T(N_c_val)
    elseif surround isa AbstractString
        F_val, c_val, N_c_val = getproperty(SURROUND, Symbol(surround))
        F, c, N_c = T(F_val), T(c_val), T(N_c_val)
    elseif surround isa Real
        surround_t = T(surround)
        c = if surround_t <= T(0.1)
            _lerp(T(SURROUND.dark[2]), T(SURROUND.dim[2]), max(surround_t / T(0.1), T(0.0)))
        else
            _lerp(
                T(SURROUND.dim[2]),
                T(SURROUND.average[2]),
                min((surround_t - T(0.1)) / T(0.9), T(1.0)),
            )
        end
        F = if surround_t <= T(0.1)
            _lerp(T(SURROUND.dark[1]), T(SURROUND.dim[1]), max(surround_t / T(0.1), T(0.0)))
        else
            _lerp(
                T(SURROUND.dim[1]),
                T(SURROUND.average[1]),
                min((surround_t - T(0.1)) / T(0.9), T(1.0)),
            )
        end
        N_c = F
    else
        error("Invalid surround value: $surround")
    end

    L_A = T(adapting_luminance)
    Y_b = T(relative_background_luminance)

    # Cone responses for whitepoint via matrix multiplication
    # Scale unit-scale whitepoint by 100 for CAM16 cone response equations
    c_100 = oftype(T(whitepoint.y), 100)
    wp = SVector(T(whitepoint.x) * c_100, T(whitepoint.y) * c_100, T(whitepoint.z) * c_100)
    R_W, G_W, B_W = M16 * wp

    D = if discounting
        T(1.0)
    else
        clamp(
            F * (T(1.0) - (T(1.0) / T(3.6)) * exp((-L_A - T(42.0)) / T(92.0))),
            T(0.0),
            T(1.0),
        )
    end

    wp_y_100 = T(whitepoint.y) * c_100
    D_R = D * (wp_y_100 / R_W) - D + T(1.0)
    D_G = D * (wp_y_100 / G_W) - D + T(1.0)
    D_B = D * (wp_y_100 / B_W) - D + T(1.0)

    k = T(1.0) / (T(5.0) * L_A + T(1.0))
    k4 = k^4
    F_L = k4 * L_A + T(0.1) * (T(1.0) - k4)^2 * cbrt(T(5.0) * L_A)
    n = Y_b / T(whitepoint.y)
    z = T(1.48) + sqrt(n)
    R_wc = D_R * R_W
    G_wc = D_G * G_W
    B_wc = D_B * B_W
    R_aw = _adapt(R_wc, F_L)
    G_aw = _adapt(G_wc, F_L)
    B_aw = _adapt(B_wc, F_L)
    A_w = T(2.0) * R_aw + G_aw + T(0.05) * B_aw
    return ViewingEnvironment{T}(
        XYZ{T}(T(whitepoint.x), T(whitepoint.y), T(whitepoint.z)),
        L_A,
        Y_b,
        discounting,
        F,
        c,
        N_c,
        SVector(D_R, D_G, D_B),
        F_L,
        n,
        z,
        A_w,
    )
end

function ViewingEnvironment(;
    whitepoint::XYZ=XYZ(0.95047, 1.0, 1.08883),
    adapting_luminance::Real=24.0,
    relative_background_luminance::Real=0.20,
    surround::Union{Symbol,AbstractString,Real}=:average,
    discounting::Bool=true,
)
    T = Colors.floattype(eltype(whitepoint))
    return ViewingEnvironment{T}(;
        whitepoint,
        adapting_luminance,
        relative_background_luminance,
        surround,
        discounting,
    )
end

const VE = ViewingEnvironment()

# ---------------------------------------------------------
# CAM Type Hierarchy & Struct Definitions
# ---------------------------------------------------------

abstract type AbstractCAM16{T<:Real,E} <: Color{T,3} end
abstract type AbstractCAM16UCS{T<:Real,E} <: AbstractCAM16{T,E} end

struct CAM16JCh{T<:Real,E} <: AbstractCAM16{T,E}
    j::T
    c::T
    h::T
end

struct CAM16QMh{T<:Real,E} <: AbstractCAM16{T,E}
    q::T
    m::T
    h::T
end

struct CAM16UCSJab{T<:Real,E} <: AbstractCAM16UCS{T,E}
    j::T
    a::T
    b::T
end

struct CAM16UCSJCh{T<:Real,E} <: AbstractCAM16UCS{T,E}
    j::T
    c::T
    h::T
end

struct CAM16UCSQpt{T<:Real,E} <: AbstractCAM16UCS{T,E}
    q::T
    p::T
    t::T
end

struct CAM16UCSQMh{T<:Real,E} <: AbstractCAM16UCS{T,E}
    q::T
    m::T
    h::T
end

# Constructors
for C in (:CAM16JCh, :CAM16QMh, :CAM16UCSJab, :CAM16UCSJCh, :CAM16UCSQpt, :CAM16UCSQMh)
    @eval begin
        $C{T}(x::Real, y::Real, z::Real, env::ViewingEnvironment=VE) where {T<:Real} =
            $C{T,env}(T(x), T(y), T(z))
        $C(x::Real, y::Real, z::Real, env::ViewingEnvironment=VE) = begin
            T = promote_type(typeof(float(x)), typeof(float(y)), typeof(float(z)))
            $C{T,env}(T(x), T(y), T(z))
        end
        $C(c::Color, env::ViewingEnvironment=VE) =
            convert($C{Colors.floattype(eltype(c)),env}, c)
        $C{T}(c::Color, env::ViewingEnvironment=VE) where {T<:Real} =
            convert($C{T,env}, c)
        $C{T,E}(c::Color) where {T<:Real,E} =
            convert($C{T,E}, c)
    end
end

# ---------------------------------------------------------
# ColorTypes.jl Trait Integration
# ---------------------------------------------------------

for C in (:CAM16JCh, :CAM16QMh, :CAM16UCSJab, :CAM16UCSJCh, :CAM16UCSQpt, :CAM16UCSQMh)
    @eval begin
        ColorTypes.base_colorant_type(::Type{$C{T,E}}) where {T,E} = ($C{S,E} where S<:Real)
        ColorTypes.base_colorant_type(::Type{$C{S,E} where S<:Real}) where {E} = ($C{S,E} where S<:Real)
    end
end
ColorTypes.floattype(::Type{C}) where {C<:AbstractCAM16} = C
ColorTypes.ccolor(::Type{C}, ::Type{CO}) where {C<:AbstractCAM16,CO<:Colorant{<:ColorTypes.FixedPoint}} =
    ColorTypes.base_colorant_type(C){Float32}

# ---------------------------------------------------------
# Eccentricity & Hue Quadrature
# ---------------------------------------------------------

function _eccentricity(h_rad)
    sin_h, cos_h = sincos(h_rad)
    cos_2h = 2.0 * cos_h * cos_h - 1.0
    sin_2h = 2.0 * sin_h * cos_h
    cos_3h = cos_h * (4.0 * cos_h * cos_h - 3.0)
    sin_3h = sin_h * (3.0 - 4.0 * sin_h * sin_h)
    cos_4h = 2.0 * cos_2h * cos_2h - 1.0
    sin_4h = 2.0 * sin_2h * cos_2h

    return -0.0582 * cos_h - 0.0258 * cos_2h - 0.1347 * cos_3h + 0.0289 * cos_4h -
            0.1475 * sin_h - 0.0308 * sin_2h +
        0.0385 * sin_3h +
        0.0096 * sin_4h +
        1.0
end

function _hue_quadrature(h)
    _h = h < HUE_QUADRATURE.h[1] ? h + 360.0 : h
    i = if _h <= HUE_QUADRATURE.h[2]
        1
    elseif _h <= HUE_QUADRATURE.h[3]
        2
    elseif _h <= HUE_QUADRATURE.h[4]
        3
    else
        4
    end

    h_i, h_i1 = HUE_QUADRATURE.h[i], HUE_QUADRATURE.h[i+1]
    e_i, e_i1 = HUE_QUADRATURE.e[i], HUE_QUADRATURE.e[i+1]
    H_i = HUE_QUADRATURE.H[i]

    return H_i + 100.0 * e_i * (_h - h_i) / (e_i1 * (_h - h_i) + e_i * (h_i1 - _h))
end

# ---------------------------------------------------------
# Value-Domain Kernels
# ---------------------------------------------------------

@inline function _cam16_coords(xyz::XYZ)
    return xyz.x, xyz.y, xyz.z
end
@inline function _cam16_coords(xyz::Union{SVector{3,<:Real},NTuple{3,<:Real},AbstractVector{<:Real}})
    return xyz[1], xyz[2], xyz[3]
end

function _xyz_to_cam16(xyz::Union{XYZ,SVector{3,<:Real},NTuple{3,<:Real},AbstractVector{<:Real}}, env::ViewingEnvironment)
    x_in, y_in, z_in = _cam16_coords(xyz)
    T = promote_type(typeof(x_in), typeof(y_in), typeof(z_in), typeof(env.L_A))
    c_100 = oftype(x_in, 100)
    v = SVector(T(x_in) * c_100, T(y_in) * c_100, T(z_in) * c_100)
    R, G, B = M16 * v

    D_R, D_G, D_B = env.D_RGB
    R_c = D_R * R
    G_c = D_G * G
    B_c = D_B * B

    R_a = _adapt(R_c, env.F_L)
    G_a = _adapt(G_c, env.F_L)
    B_a = _adapt(B_c, env.F_L)

    p_2, a, b = M1 * SVector(R_a, G_a, B_a)

    h_rad = atan(b, a)
    h = mod(atand(b, a), oftype(x_in, 360))
    e_t = _eccentricity(h_rad)

    A = p_2
    c_100_a = oftype(A, 100)
    J = c_100_a * sign(A) * abs(A / env.A_w) ^ (env.c * env.z)
    Q = (oftype(J, 2) / env.c) * (J / c_100_a) * env.A_w
    M = oftype(A, 43) * env.N_c * e_t * hypot(a, b)
    C = oftype(M, 35) * M / env.A_w
    s = iszero(Q) ? zero(T) : c_100_a * M / Q
    return J, Q, C, M, s, h
end

function _cam16_to_xyz(jch::CAM16JCh, env::ViewingEnvironment)
    T = promote_type(eltype(jch), typeof(env.L_A))
    h_rad = deg2rad(jch.h)
    M = jch.c * env.A_w / oftype(jch.c, 35)
    e_t = _eccentricity(h_rad)
    c_100 = oftype(jch.j, 100)
    A = sign(jch.j) * env.A_w * abs(jch.j / c_100) ^ (one(T) / (env.c * env.z))
    p1 = oftype(M, 43) * env.N_c * e_t
    p2 = A
    gamma = M / p1
    sin_h, cos_h = sincos(h_rad)
    a = gamma * cos_h
    b = gamma * sin_h

    R_a, G_a, B_a = (M2 * SVector(p2, a, b)) ./ oftype(p2, 1403)

    R_c = _unadapt(R_a, env.F_L)
    G_c = _unadapt(G_a, env.F_L)
    B_c = _unadapt(B_a, env.F_L)

    D_R, D_G, D_B = env.D_RGB
    R = R_c / D_R
    G = G_c / D_G
    B = B_c / D_B

    xyz = (M16_INV * SVector(R, G, B)) ./ c_100
    return xyz[1], xyz[2], xyz[3]
end

function _cam16_to_xyz(qmh::CAM16QMh, env::ViewingEnvironment)
    T = promote_type(eltype(qmh), typeof(env.L_A))
    h_rad = deg2rad(qmh.h)
    e_t = _eccentricity(h_rad)
    c_100 = oftype(qmh.q, 100)
    J = oftype(qmh.q, 50) * env.c * qmh.q / env.A_w
    A = sign(J) * env.A_w * abs(J / c_100) ^ (one(T) / (env.c * env.z))
    p1 = oftype(qmh.m, 43) * env.N_c * e_t
    p2 = A
    gamma = qmh.m / p1
    sin_h, cos_h = sincos(h_rad)
    a = gamma * cos_h
    b = gamma * sin_h

    R_a, G_a, B_a = (M2 * SVector(p2, a, b)) ./ oftype(p2, 1403)

    R_c = _unadapt(R_a, env.F_L)
    G_c = _unadapt(G_a, env.F_L)
    B_c = _unadapt(B_a, env.F_L)

    D_R, D_G, D_B = env.D_RGB
    R = R_c / D_R
    G = G_c / D_G
    B = B_c / D_B

    xyz = (M16_INV * SVector(R, G, B)) ./ c_100
    return xyz[1], xyz[2], xyz[3]
end

_cam16_to_xyz(c::AbstractCAM16{T,E}) where {T,E} = _cam16_to_xyz(c, E)

function _jch_to_qmh(jch::CAM16JCh, env::ViewingEnvironment)
    Q = (2.0 / env.c) * (jch.j / 100.0) * env.A_w
    M = jch.c * env.A_w / 35.0
    return Q, M, jch.h
end

function _qmh_to_jch(qmh::CAM16QMh, env::ViewingEnvironment)
    J = 50.0 * env.c * qmh.q / env.A_w
    C = 35.0 * qmh.m / env.A_w
    return J, C, qmh.h
end

# ---------------------------------------------------------
# CAM16-UCS Algebraic Contraction (Hellwig & Fairchild 2022)
#
# In the revised CAM16 formulation (Hellwig & Fairchild 2022, Color Res. Appl.):
# - Lightness: J = 100 * (A / A_w)^(c * z)
# - Brightness (Eq. 17): Q = (2 / c) * (J / 100) * A_w  <=>  J = 50 * c * Q / A_w
# - Colorfulness (Appendix A / Eq. 23): M is rescaled by 0.75 relative to CAM16
#   M = 43 * N_c * e_t * hypot(a, b)
# - Chroma (Eq. 24): C is rescaled by 0.6 relative to CAM16: C = 35 * M / A_w
#
# Substituting into CAM16-UCS log-compression and refitting to COMBVD (Hellwig & Fairchild, CIC30 2022):
# - J' = 1.7 * J / (1 + 0.007 * J)
# - C' = (2.4 / 0.098) * ln(1 + 0.098 * C)
# - M' = (2.0 / 0.094) * ln(1 + 0.094 * M)
# - Q': Q' = 1.462 * Q / (1 + 0.007 * J)
#   Substituting J = 50 * c * Q / A_w into the denominator yields:
#   1 + 0.007 * (50 * c / A_w) * Q = 1 + 0.35 * (c / A_w) * Q
#   Inverting Q' for Q gives:
#   Q = Q' / (1.462 - 0.35 * (c / A_w) * Q')
# ---------------------------------------------------------

function _cam16_to_cam16ucs(jch::CAM16JCh)
    J_prime = sign(jch.j) * 1.7 * abs(jch.j) / (1.0 + 0.007 * abs(jch.j))
    C_prime = sign(jch.c) * 2.4 * log1p(0.098 * abs(jch.c)) / 0.098
    a_prime = C_prime * cosd(jch.h)
    b_prime = C_prime * sind(jch.h)
    return J_prime, a_prime, b_prime, C_prime, jch.h
end

function _cam16_to_cam16ucs(qmh::CAM16QMh, env::ViewingEnvironment)
    J = 50.0 * env.c * qmh.q / env.A_w
    Q_prime = sign(qmh.q) * 1.462 * abs(qmh.q) / (1.0 + 0.007 * abs(J))
    M_prime = sign(qmh.m) * 2.0 * log1p(0.094 * abs(qmh.m)) / 0.094
    p_prime = M_prime * cosd(qmh.h)
    t_prime = M_prime * sind(qmh.h)
    return Q_prime, p_prime, t_prime, M_prime, qmh.h
end
_cam16_to_cam16ucs(qmh::CAM16QMh{T,E}) where {T,E} = _cam16_to_cam16ucs(qmh, E)

function _cam16ucs_to_cam16(jab::CAM16UCSJab)
    J = sign(jab.j) * abs(jab.j) / (1.7 - 0.007 * abs(jab.j))
    C_prime = hypot(jab.a, jab.b)
    C = expm1(0.098 * C_prime / 2.4) / 0.098
    h = mod(atand(jab.b, jab.a), 360.0)
    return J, C, h
end

function _cam16ucs_to_cam16(jch::CAM16UCSJCh)
    J = sign(jch.j) * abs(jch.j) / (1.7 - 0.007 * abs(jch.j))
    C = sign(jch.c) * expm1(0.098 * abs(jch.c) / 2.4) / 0.098
    return J, C, jch.h
end

function _cam16ucs_to_cam16(qpt::CAM16UCSQpt, env::ViewingEnvironment)
    Q = sign(qpt.q) * abs(qpt.q) / (1.462 - 0.35 * (env.c / env.A_w) * abs(qpt.q))
    M_prime = hypot(qpt.p, qpt.t)
    M = expm1(0.094 * M_prime / 2.0) / 0.094
    h = mod(atand(qpt.t, qpt.p), 360.0)
    return Q, M, h
end
_cam16ucs_to_cam16(qpt::CAM16UCSQpt{T,E}) where {T,E} = _cam16ucs_to_cam16(qpt, E)

function _cam16ucs_to_cam16(qmh::CAM16UCSQMh, env::ViewingEnvironment)
    Q = sign(qmh.q) * abs(qmh.q) / (1.462 - 0.35 * (env.c / env.A_w) * abs(qmh.q))
    M = sign(qmh.m) * expm1(0.094 * abs(qmh.m) / 2.0) / 0.094
    return Q, M, qmh.h
end
_cam16ucs_to_cam16(qmh::CAM16UCSQMh{T,E}) where {T,E} = _cam16ucs_to_cam16(qmh, E)

# ---------------------------------------------------------
# Conversions: XYZ <-> Base CAM16
# ---------------------------------------------------------

function cnvt(::Type{CAM16JCh{T,E}}, c::XYZ) where {T,E}
    J, _, C, _, _, h = _xyz_to_cam16(c, E)
    return CAM16JCh{T,E}(T(J), T(C), T(h))
end

function cnvt(::Type{XYZ{T}}, c::CAM16JCh{S,E}) where {T,S,E}
    x, y, z = _cam16_to_xyz(c, E)
    return XYZ{T}(T(x), T(y), T(z))
end

function cnvt(::Type{CAM16QMh{T,E}}, c::XYZ) where {T,E}
    _, Q, _, M, _, h = _xyz_to_cam16(c, E)
    return CAM16QMh{T,E}(T(Q), T(M), T(h))
end

function cnvt(::Type{XYZ{T}}, c::CAM16QMh{S,E}) where {T,S,E}
    x, y, z = _cam16_to_xyz(c, E)
    return XYZ{T}(T(x), T(y), T(z))
end

# ---------------------------------------------------------
# Intra-CAM Conversions (Same Environment E)
# ---------------------------------------------------------

cnvt(::Type{C}, c::C) where {T,E,C<:AbstractCAM16{T,E}} = c

for C in (:CAM16JCh, :CAM16QMh, :CAM16UCSJab, :CAM16UCSJCh, :CAM16UCSQpt, :CAM16UCSQMh)
    @eval begin
        cnvt(::Type{$C{T,E}}, c::$C{S,E}) where {T,S,E} =
            $C{T,E}(T(getfield(c, 1)), T(getfield(c, 2)), T(getfield(c, 3)))
    end
end

# JCh <-> QMh
function cnvt(::Type{CAM16JCh{T,E}}, c::CAM16QMh{S,E}) where {T,S,E}
    J, C, h = _qmh_to_jch(c, E)
    return CAM16JCh{T,E}(T(J), T(C), T(h))
end

function cnvt(::Type{CAM16QMh{T,E}}, c::CAM16JCh{S,E}) where {T,S,E}
    Q, M, h = _jch_to_qmh(c, E)
    return CAM16QMh{T,E}(T(Q), T(M), T(h))
end

# CAM16UCSJab <-> CAM16JCh
function cnvt(::Type{CAM16UCSJab{T,E}}, c::CAM16JCh{S,E}) where {T,S,E}
    J, a, b, _, _ = _cam16_to_cam16ucs(c)
    return CAM16UCSJab{T,E}(T(J), T(a), T(b))
end

function cnvt(::Type{CAM16JCh{T,E}}, c::CAM16UCSJab{S,E}) where {T,S,E}
    J, C, h = _cam16ucs_to_cam16(c)
    return CAM16JCh{T,E}(T(J), T(C), T(h))
end

# CAM16UCSJCh <-> CAM16JCh
function cnvt(::Type{CAM16UCSJCh{T,E}}, c::CAM16JCh{S,E}) where {T,S,E}
    J, _, _, C, h = _cam16_to_cam16ucs(c)
    return CAM16UCSJCh{T,E}(T(J), T(C), T(h))
end

function cnvt(::Type{CAM16JCh{T,E}}, c::CAM16UCSJCh{S,E}) where {T,S,E}
    J, C, h = _cam16ucs_to_cam16(c)
    return CAM16JCh{T,E}(T(J), T(C), T(h))
end

# CAM16UCSJab <-> CAM16UCSJCh (Cartesian <-> Polar)
function cnvt(::Type{CAM16UCSJCh{T,E}}, c::CAM16UCSJab{S,E}) where {T,S,E}
    C = hypot(c.a, c.b)
    h = mod(atand(c.b, c.a), 360.0)
    return CAM16UCSJCh{T,E}(T(c.j), T(C), T(h))
end

function cnvt(::Type{CAM16UCSJab{T,E}}, c::CAM16UCSJCh{S,E}) where {T,S,E}
    a = c.c * cosd(c.h)
    b = c.c * sind(c.h)
    return CAM16UCSJab{T,E}(T(c.j), T(a), T(b))
end

# CAM16UCSQpt <-> CAM16QMh
function cnvt(::Type{CAM16UCSQpt{T,E}}, c::CAM16QMh{S,E}) where {T,S,E}
    Q, p, t, _, _ = _cam16_to_cam16ucs(c, E)
    return CAM16UCSQpt{T,E}(T(Q), T(p), T(t))
end

function cnvt(::Type{CAM16QMh{T,E}}, c::CAM16UCSQpt{S,E}) where {T,S,E}
    Q, M, h = _cam16ucs_to_cam16(c, E)
    return CAM16QMh{T,E}(T(Q), T(M), T(h))
end

# CAM16UCSQMh <-> CAM16QMh
function cnvt(::Type{CAM16UCSQMh{T,E}}, c::CAM16QMh{S,E}) where {T,S,E}
    Q, _, _, M, h = _cam16_to_cam16ucs(c, E)
    return CAM16UCSQMh{T,E}(T(Q), T(M), T(h))
end

function cnvt(::Type{CAM16QMh{T,E}}, c::CAM16UCSQMh{S,E}) where {T,S,E}
    Q, M, h = _cam16ucs_to_cam16(c, E)
    return CAM16QMh{T,E}(T(Q), T(M), T(h))
end

# CAM16UCSQpt <-> CAM16UCSQMh (Cartesian <-> Polar)
function cnvt(::Type{CAM16UCSQMh{T,E}}, c::CAM16UCSQpt{S,E}) where {T,S,E}
    M = hypot(c.p, c.t)
    h = mod(atand(c.t, c.p), 360.0)
    return CAM16UCSQMh{T,E}(T(c.q), T(M), T(h))
end

function cnvt(::Type{CAM16UCSQpt{T,E}}, c::CAM16UCSQMh{S,E}) where {T,S,E}
    p = c.m * cosd(c.h)
    t = c.m * sind(c.h)
    return CAM16UCSQpt{T,E}(T(c.q), T(p), T(t))
end

# Inter-branch in same environment
function cnvt(::Type{CAM16JCh{T,E}}, c::Union{CAM16UCSQpt{S,E},CAM16UCSQMh{S,E}}) where {T,S,E}
    cnvt(CAM16JCh{T,E}, cnvt(CAM16QMh{T,E}, c))
end

function cnvt(::Type{CAM16QMh{T,E}}, c::Union{CAM16UCSJab{S,E},CAM16UCSJCh{S,E}}) where {T,S,E}
    cnvt(CAM16QMh{T,E}, cnvt(CAM16JCh{T,E}, c))
end

function cnvt(::Type{CAM16UCSJab{T,E}}, c::Union{CAM16QMh{S,E},CAM16UCSQpt{S,E},CAM16UCSQMh{S,E}}) where {T,S,E}
    cnvt(CAM16UCSJab{T,E}, cnvt(CAM16JCh{T,E}, c))
end

function cnvt(::Type{CAM16UCSJCh{T,E}}, c::Union{CAM16QMh{S,E},CAM16UCSQpt{S,E},CAM16UCSQMh{S,E}}) where {T,S,E}
    cnvt(CAM16UCSJCh{T,E}, cnvt(CAM16JCh{T,E}, c))
end

function cnvt(::Type{CAM16UCSQpt{T,E}}, c::Union{CAM16JCh{S,E},CAM16UCSJab{S,E},CAM16UCSJCh{S,E}}) where {T,S,E}
    cnvt(CAM16UCSQpt{T,E}, cnvt(CAM16QMh{T,E}, c))
end

function cnvt(::Type{CAM16UCSQMh{T,E}}, c::Union{CAM16JCh{S,E},CAM16UCSJab{S,E},CAM16UCSJCh{S,E}}) where {T,S,E}
    cnvt(CAM16UCSQMh{T,E}, cnvt(CAM16QMh{T,E}, c))
end

# ---------------------------------------------------------
# Conversions to/from XYZ and Other Spaces
# ---------------------------------------------------------

# Direct XYZ forwarding for UCS types
cnvt(::Type{CAM16UCSJab{T,E}}, c::XYZ) where {T,E} =
    cnvt(CAM16UCSJab{T,E}, cnvt(CAM16JCh{T,E}, c))

cnvt(::Type{CAM16UCSJCh{T,E}}, c::XYZ) where {T,E} =
    cnvt(CAM16UCSJCh{T,E}, cnvt(CAM16JCh{T,E}, c))

cnvt(::Type{CAM16UCSQpt{T,E}}, c::XYZ) where {T,E} =
    cnvt(CAM16UCSQpt{T,E}, cnvt(CAM16QMh{T,E}, c))

cnvt(::Type{CAM16UCSQMh{T,E}}, c::XYZ) where {T,E} =
    cnvt(CAM16UCSQMh{T,E}, cnvt(CAM16QMh{T,E}, c))

cnvt(::Type{XYZ{T}}, c::CAM16UCSJab{S,E}) where {T,S,E} =
    cnvt(XYZ{T}, cnvt(CAM16JCh{S,E}, c))

cnvt(::Type{XYZ{T}}, c::CAM16UCSJCh{S,E}) where {T,S,E} =
    cnvt(XYZ{T}, cnvt(CAM16JCh{S,E}, c))

cnvt(::Type{XYZ{T}}, c::CAM16UCSQpt{S,E}) where {T,S,E} =
    cnvt(XYZ{T}, cnvt(CAM16QMh{S,E}, c))

cnvt(::Type{XYZ{T}}, c::CAM16UCSQMh{S,E}) where {T,S,E} =
    cnvt(XYZ{T}, cnvt(CAM16QMh{S,E}, c))

cnvt(::Type{XYZ}, c::AbstractCAM16{T,E}) where {T,E} = cnvt(XYZ{T}, c)

# ---------------------------------------------------------
# Cross-Environment Conversions (E1 !== E2)
# ---------------------------------------------------------

function cnvt(::Type{C1}, c::C2) where {T1,E1,C1<:AbstractCAM16{T1,E1},T2,E2,C2<:AbstractCAM16{T2,E2}}
    if E1 === E2
        error("Unreachable: intra-CAM conversion should have been dispatched")
    else
        return cnvt(C1, cnvt(XYZ{T1}, c))
    end
end

# ---------------------------------------------------------
# Fallbacks for Generic Color
# ---------------------------------------------------------

# Forward conversion from generic Color: route through XYZ
cnvt(::Type{C}, c::Color) where {T,E,C<:AbstractCAM16{T,E}} =
    cnvt(C, cnvt(XYZ{T}, c)::XYZ{T})

# Unparameterized E fallbacks
for C in (:CAM16JCh, :CAM16QMh, :CAM16UCSJab, :CAM16UCSJCh, :CAM16UCSQpt, :CAM16UCSQMh)
    @eval begin
        cnvt(::Type{$C{T}}, c::AbstractCAM16{S,E}) where {T,S,E} = cnvt($C{T,E}, c)
        cnvt(::Type{$C}, c::AbstractCAM16{S,E}) where {S,E} = cnvt($C{S,E}, c)
        cnvt(::Type{$C{T}}, c::Color) where {T} = cnvt($C{T,VE}, c)
        cnvt(::Type{$C}, c::Color) = cnvt($C{Colors.floattype(eltype(c)),VE}, c)
    end
end

# 3-argument explicit environment conversions
function convert(::Type{C}, c::Color, env::ViewingEnvironment) where {C<:AbstractCAM16}
    T = eltype(C) === Any ? Colors.floattype(eltype(c)) : eltype(C)
    base_c = ColorTypes.basetype(C)
    return cnvt(base_c{T,env}, c)
end

# Inverse conversions to RGB
function convert(::Type{RGB}, c::AbstractCAM16{T,E}) where {T,E}
    cnvt(RGB{T}, cnvt(XYZ{T}, c))
end

function convert(::Type{RGB{TR}}, c::AbstractCAM16{T,E}) where {TR,T,E}
    cnvt(RGB{TR}, cnvt(XYZ{TR}, c))
end

function cnvt(::Type{CV}, c::AbstractCAM16{T,E}) where {CV<:AbstractRGB,T,E}
    cnvt(CV, cnvt(XYZ{T}, c))
end

# ---------------------------------------------------------
# Distance Metrics
# ---------------------------------------------------------

function cam16dist(c1::AbstractCAM16{T1,E}, c2::AbstractCAM16{T2,E}; absolute::Bool=false) where {T1,T2,E}
    T = promote_type(T1, T2)
    if absolute
        c1_qpt = cnvt(CAM16UCSQpt{T,E}, c1)
        c2_qpt = cnvt(CAM16UCSQpt{T,E}, c2)
        return hypot(c2_qpt.q - c1_qpt.q, c2_qpt.p - c1_qpt.p, c2_qpt.t - c1_qpt.t)
    else
        c1_jab = cnvt(CAM16UCSJab{T,E}, c1)
        c2_jab = cnvt(CAM16UCSJab{T,E}, c2)
        return hypot(c2_jab.j - c1_jab.j, c2_jab.a - c1_jab.a, c2_jab.b - c1_jab.b)
    end
end

function cam16dist(c1::AbstractCAM16{T1,E1}, c2::AbstractCAM16{T2,E2}; kwargs...) where {T1,E1,T2,E2}
    throw(ArgumentError("Cannot compute CAM16 distance between colors adapted to different viewing environments ($E1 != $E2)"))
end

function cam16dist(c1::Color, c2::Color, env::ViewingEnvironment=VE; absolute::Bool=false)
    if c1 isa AbstractCAM16 && c2 isa AbstractCAM16
        throw(ArgumentError("Cannot compute CAM16 distance between colors adapted to different viewing environments"))
    end
    c1_cam = c1 isa AbstractCAM16 ? c1 : convert(CAM16UCSJab, c1, env)
    c2_cam = c2 isa AbstractCAM16 ? c2 : convert(CAM16UCSJab, c2, env)
    return cam16dist(c1_cam, c2_cam; absolute=absolute)
end

# ---------------------------------------------------------
# Helmholtz–Kohlrausch (H–K) Extension
# Hellwig, Stolitzka & Fairchild (2022), Eqs. (6), (8), (9)
# ---------------------------------------------------------

"""
    _hk_hue_dependency(h_rad::Real)

Calculates the hue-angle dependency factor f(h) for CAM16 per Hellwig, Stolitzka & Fairchild (2022),
Equation (9):
    f(h) = -0.160 cos(h) + 0.132 cos(2h) - 0.405 sin(h) + 0.080 sin(2h) + 0.792
with hue angle `h_rad` in radians. Fully differentiable under AD.
"""
function _hk_hue_dependency(h_rad::Real)
    sin_h, cos_h = sincos(h_rad)
    cos_2h = oftype(cos_h, 2) * cos_h * cos_h - one(cos_h)
    sin_2h = oftype(sin_h, 2) * sin_h * cos_h
    return oftype(cos_h, -0.160) * cos_h +
            oftype(cos_h, 0.132) * cos_2h -
            oftype(cos_h, 0.405) * sin_h +
        oftype(cos_h, 0.080) * sin_2h +
        oftype(cos_h, 0.792)
end

"""
    cam16_hk_lightness(J::Real, C::Real, h::Real; alpha::Real=1.0)

Computes Helmholtz–Kohlrausch compensated lightness J_HK for CAM16 (Eq. 8):
    J_HK = J + alpha * f(deg2rad(h)) * (C ^ 0.587)
where `h` is in degrees, and `alpha` in [0, 1] allows continuous blending between
uncompensated lightness (alpha = 0) and full H–K compensation (alpha = 1).
"""
function cam16_hk_lightness(J::Real, C::Real, h::Real; alpha::Real=1.0)
    fh = _hk_hue_dependency(deg2rad(h))
    p = C isa AbstractFloat ? oftype(C, 0.587) : 0.587
    c_pow = C <= zero(C) ? zero(C) : C^p
    return J + alpha * fh * c_pow
end

"""
    cam16_hk_brightness(J_HK::Real, env::ViewingEnvironment)
    cam16_hk_brightness(J::Real, C::Real, h::Real, env::ViewingEnvironment; alpha::Real=1.0)

Computes Helmholtz–Kohlrausch compensated brightness Q_HK for CAM16 (Eq. 6):
    Q_HK = (2 / env.c) * (J_HK / 100) * env.A_w
"""
function cam16_hk_brightness(J_HK::Real, env::ViewingEnvironment)
    c_100 = oftype(J_HK, 100)
    k2 = oftype(J_HK, 2)
    return (k2 / env.c) * (J_HK / c_100) * env.A_w
end

function cam16_hk_brightness(J::Real, C::Real, h::Real, env::ViewingEnvironment; alpha::Real=1.0)
    J_HK = cam16_hk_lightness(J, C, h; alpha=alpha)
    return cam16_hk_brightness(J_HK, env)
end

# Dispatches for CAM16 color types
cam16_hk_lightness(c::CAM16JCh; alpha::Real=1.0) = cam16_hk_lightness(c.j, c.c, c.h; alpha=alpha)

function cam16_hk_lightness(c::AbstractCAM16{T,E}; alpha::Real=1.0) where {T,E}
    jch = cnvt(CAM16JCh{T,E}, c)
    return cam16_hk_lightness(jch; alpha=alpha)
end

function cam16_hk_brightness(c::AbstractCAM16{T,E}; alpha::Real=1.0) where {T,E}
    jch = cnvt(CAM16JCh{T,E}, c)
    J_HK = cam16_hk_lightness(jch; alpha=alpha)
    return cam16_hk_brightness(J_HK, E)
end

"""
    cam16_hk_inverse_lightness(J_HK::Real, C::Real, h::Real; alpha::Real=1.0)

Analytical inverse recovering uncompensated lightness J from target J_HK, chroma C,
and hue angle h (in degrees):
    J = J_HK - alpha * f(deg2rad(h)) * (C ^ 0.587)
"""
function cam16_hk_inverse_lightness(J_HK::Real, C::Real, h::Real; alpha::Real=1.0)
    fh = _hk_hue_dependency(deg2rad(h))
    p = C isa AbstractFloat ? oftype(C, 0.587) : 0.587
    c_pow = C <= zero(C) ? zero(C) : C^p
    return J_HK - alpha * fh * c_pow
end

function cam16_hk_inverse_lightness(Q_HK::Real, C::Real, h::Real, env::ViewingEnvironment; alpha::Real=1.0)
    c_50 = oftype(Q_HK, 50)
    J_HK = (c_50 * env.c * Q_HK) / env.A_w
    return cam16_hk_inverse_lightness(J_HK, C, h; alpha=alpha)
end

# ---------------------------------------------------------
# CAM16-UCS H–K Extensions
# ---------------------------------------------------------

"""
    cam16ucs_hk_lightness(J_prime::Real, C_prime::Real, h::Real; alpha::Real=1.0)

Computes H–K compensated UCS lightness J'_HK by converting UCS (J', C') to base (J, C),
evaluating J_HK, and transferring back to UCS lightness:
    J' -> J
    C' -> C
    J_HK = J + alpha * f(h) * C^0.587
    J'_HK = 1.7 * J_HK / (1 + 0.007 * J_HK)
"""
function cam16ucs_hk_lightness(J_prime::Real, C_prime::Real, h::Real; alpha::Real=1.0)
    J = sign(J_prime) * abs(J_prime) / (1.7 - 0.007 * abs(J_prime))
    C = sign(C_prime) * expm1(0.098 * abs(C_prime) / 2.4) / 0.098
    J_HK = cam16_hk_lightness(J, C, h; alpha=alpha)
    return sign(J_HK) * 1.7 * abs(J_HK) / (1.0 + 0.007 * abs(J_HK))
end

cam16ucs_hk_lightness(c::CAM16UCSJCh; alpha::Real=1.0) = cam16ucs_hk_lightness(c.j, c.c, c.h; alpha=alpha)

function cam16ucs_hk_lightness(c::CAM16UCSJab; alpha::Real=1.0)
    C_prime = hypot(c.a, c.b)
    h = mod(atand(c.b, c.a), 360.0)
    return cam16ucs_hk_lightness(c.j, C_prime, h; alpha=alpha)
end

function cam16ucs_hk_lightness(c::AbstractCAM16UCS{T,E}; alpha::Real=1.0) where {T,E}
    ucs_jch = cnvt(CAM16UCSJCh{T,E}, c)
    return cam16ucs_hk_lightness(ucs_jch; alpha=alpha)
end

"""
    cam16ucs_hk_inverse_lightness(J_prime_HK::Real, C_prime::Real, h::Real; alpha::Real=1.0)

Analytical inverse recovering UCS lightness J' from target J'_HK, UCS chroma C',
and hue angle h (in degrees):
    J'_HK -> J_HK
    C' -> C
    J = J_HK - alpha * f(h) * C^0.587
    J' = 1.7 * J / (1 + 0.007 * J)
"""
function cam16ucs_hk_inverse_lightness(J_prime_HK::Real, C_prime::Real, h::Real; alpha::Real=1.0)
    J_HK = sign(J_prime_HK) * abs(J_prime_HK) / (1.7 - 0.007 * abs(J_prime_HK))
    C = sign(C_prime) * expm1(0.098 * abs(C_prime) / 2.4) / 0.098
    J = cam16_hk_inverse_lightness(J_HK, C, h; alpha=alpha)
    return sign(J) * 1.7 * abs(J) / (1.0 + 0.007 * abs(J))
end
