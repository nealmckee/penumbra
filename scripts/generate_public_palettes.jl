# SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
# Copyright (c) 2021-2026 Neal McKee. All rights reserved.

"""
generate_public_palettes.jl

Generates the canonical public TSV palette tables at the repository root:
1. `penumbra_base.tsv`: Continuous daylight base color lattice with deduplicated sun/sky tones.
2. `penumbra_accents.tsv`: Equichromatic cyclic opponent accent polygons (N = 6, 7, 8) in CAM16-UCS.
"""

using Printf
using DelimitedFiles: writedlm
using Colors: HSL, RGB, XYZ, ColorTypes

include(joinpath(@__DIR__, "..", "src", "base_color_curve.jl"))
include(joinpath(@__DIR__, "..", "src", "accent_palette.jl"))

function _tone_color_channels(rgb::RGB)
    r = round(Int, rgb.r * 255)
    g = round(Int, rgb.g * 255)
    b = round(Int, rgb.b * 255)
    hsl = convert(HSL, rgb)
    h = round(Int, isfinite(hsl.h) ? hsl.h : 0.0)
    s = round(Int, hsl.s * 100)
    l = round(Int, hsl.l * 100)
    return (r, g, b, h, s, l)
end

function generate_public_base_tsv(target_path::String)
    sol = solve_base_palette()
    tones = base_palette_tones(sol)

    header = [
        "name", "tier", "rgb_hex", "r", "g", "b", "h", "s", "l",
        "cam16_ucs_lightness", "correlate_cct_k"
    ]
    rows = Any[header]

    # 1. Deduplicated shared sun and sky tones
    for t in tones
        if t.tier == :balanced && startswith(t.name, "s") && !startswith(t.name, "shade")
            r, g, b, h, s, l = _tone_color_channels(t.rgb)
            push!(rows, Any[
                t.name, "shared", t.hex, r, g, b, h, s, l,
                round(t.J_base, digits=2), round(Int, t.T_cct)
            ])
        end
    end

    # 2. Telescoping shade triad per contrast tier
    for tier in [:balanced, :contrast_plus, :contrast_plus_plus]
        tier_label = tier == :balanced ? "balanced" : (tier == :contrast_plus ? "contrast+" : "contrast++")
        for t in tones
            if t.tier == tier && startswith(t.name, "shade")
                r, g, b, h, s, l = _tone_color_channels(t.rgb)
                push!(rows, Any[
                    t.name, tier_label, t.hex, r, g, b, h, s, l,
                    round(t.J_base, digits=2), round(Int, t.T_cct)
                ])
            end
        end
    end

    writedlm(target_path, rows, '\t')
    println("  [WRITTEN] $target_path ($(length(rows) - 1) tones)")
end

function generate_public_accents_tsv(target_path::String)
    sol = solve_base_palette()
    modes = [(:dark, sol.env_dark), (:light, sol.env_light)]
    pal_names = Dict(6 => "six", 7 => "seven", 8 => "eight")

    header = [
        "mode", "palette", "name", "rgb_hex", "r", "g", "b", "h", "s", "l",
        "cam16_ucs_lightness", "cam16_ucs_chroma", "cam16_ucs_hue"
    ]
    rows = Any[header]

    for (mode_sym, env) in modes
        mode_str = string(mode_sym)
        J_target = convert(CAM16UCSJCh, convert(XYZ, sol.curve(sol.J_sky)), env).j
        for N in (6, 7, 8)
            pal = optimize_accent_palette(N, J_target, env; alpha=1.0)
            for t in pal.tones
                r, g, b, h, s, l = _tone_color_channels(t.rgb)
                push!(rows, Any[
                    mode_str, pal_names[N], t.name, t.hex, r, g, b, h, s, l,
                    round(t.J_hk_ucs, digits=2), round(t.C_ucs, digits=2), round(t.h, digits=2)
                ])
            end
        end
    end

    writedlm(target_path, rows, '\t')
    println("  [WRITTEN] $target_path ($(length(rows) - 1) tones)")
end

function main()
    println("="^80)
    println("GENERATING CANONICAL PUBLIC PALETTE TABLES")
    println("="^80)
    base_path = joinpath(@__DIR__, "..", "penumbra_base.tsv")
    accent_path = joinpath(@__DIR__, "..", "penumbra_accents.tsv")
    generate_public_base_tsv(base_path)
    generate_public_accents_tsv(accent_path)
    println("="^80)
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
