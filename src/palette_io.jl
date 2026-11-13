# SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
# Copyright (c) 2021-2026 Neal McKee. All rights reserved.

"""
palette_io.jl

Canonical loader for exported Penumbra v2 TSV palettes:
- `penumbra_base.tsv`
- `penumbra_accents.tsv`

Provides a single source of truth for all downstream theme generators, swatches,
and visual assets, decoupling consumers from mathematical solver dependencies.
"""

"""
    load_palettes(root_dir::AbstractString=joinpath(@__DIR__, ".."))

Loads base tones and accent palettes directly from the official TSV files.
Returns:
- `base_tones::Dict{Symbol, Dict{String, String}}`: Base tones keyed by tier (:balanced, :contrast_plus, :contrast_plus_plus) and tone name ("sun+", "shade", etc.) -> uppercase hex without '#'
- `accents::Dict{Symbol, Dict{Int, Dict{String, String}}}`: Accent tones keyed by mode (:dark, :light), palette size (6, 7, 8), and color name -> uppercase hex without '#'
"""
function load_palettes(root_dir::AbstractString=joinpath(@__DIR__, ".."))
    base_path = joinpath(root_dir, "penumbra_base.tsv")
    accents_path = joinpath(root_dir, "penumbra_accents.tsv")

    # 1. Base tones
    base_tones = Dict{Symbol, Dict{String, String}}(
        :balanced           => Dict{String, String}(),
        :contrast_plus      => Dict{String, String}(),
        :contrast_plus_plus => Dict{String, String}()
    )

    for line in readlines(base_path)[2:end]
        isempty(strip(line)) && continue
        parts = split(line, "\t")
        name, tier, hex_code = parts[1], parts[2], uppercase(parts[3])
        if tier == "shared"
            for t in keys(base_tones)
                base_tones[t][name] = hex_code
            end
        elseif tier == "balanced"
            base_tones[:balanced][name] = hex_code
        elseif tier == "contrast+"
            base_tones[:contrast_plus][name] = hex_code
        elseif tier == "contrast++"
            base_tones[:contrast_plus_plus][name] = hex_code
        else
            throw(ArgumentError("Unknown tier '$tier' for tone '$name' in $base_path"))
        end
    end

    # 2. Accents
    accents = Dict{Symbol, Dict{Int, Dict{String, String}}}(
        :dark  => Dict(6 => Dict{String, String}(), 7 => Dict{String, String}(), 8 => Dict{String, String}()),
        :light => Dict(6 => Dict{String, String}(), 7 => Dict{String, String}(), 8 => Dict{String, String}())
    )

    pal_map = Dict("six" => 6, "seven" => 7, "eight" => 8)
    for line in readlines(accents_path)[2:end]
        isempty(strip(line)) && continue
        parts = split(line, "\t")
        mode = Symbol(parts[1])
        if mode !== :dark && mode !== :light
            throw(ArgumentError("Unknown mode '$(parts[1])' in $accents_path"))
        end
        n = get(pal_map, parts[2]) do
            throw(ArgumentError("Unknown palette size '$(parts[2])' in $accents_path"))
        end
        name = parts[3]
        hex_code = uppercase(parts[4])
        accents[mode][n][name] = hex_code
    end

    return base_tones, accents
end
