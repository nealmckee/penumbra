# SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
# Copyright (c) 2021-2026 Neal McKee. All rights reserved.

"""
generate_swatches.jl

Deterministic generator and renderer for all 7 Penumbra v2 visual swatch cards:
1. `swatches/penumbra_swatch_base_balanced.svg`
2. `swatches/penumbra_swatch_base_contrast+.svg`
3. `swatches/penumbra_swatch_base_contrast++.svg`
4. `swatches/penumbra_swatch_dark_balanced.svg`
5. `swatches/penumbra_swatch_dark_contrast+.svg`
6. `swatches/penumbra_swatch_dark_contrast++.svg`
7. `swatches/penumbra_swatch_light_balanced.svg`

Reads color values directly from canonical TSVs (`penumbra_base.tsv`, `penumbra_accents.tsv`),
and renders high-resolution 2× retina PNGs via `resvg` using repository fonts in `fonts/`.
"""

include(joinpath(@__DIR__, "..", "src", "palette_io.jl"))

function generate_base_swatches(swatches_dir::String, base_tones)
    bal_path = joinpath(swatches_dir, "penumbra_swatch_base_balanced.svg")
    content = read(bal_path, String)

    tones_bal = Dict(k => lowercase(v) for (k, v) in base_tones[:balanced])
    tones_c1  = Dict(k => lowercase(v) for (k, v) in base_tones[:contrast_plus])
    tones_c2  = Dict(k => lowercase(v) for (k, v) in base_tones[:contrast_plus_plus])

    # 1. Standardize font family to Fira Sans
    content = replace(content, "font-family:'fira sans'" => "font-family:'Fira Sans', sans-serif")
    content = replace(content, "-inkscape-font-specification:'fira sans'" => "-inkscape-font-specification:'Fira Sans'")

    # Ensure sky (rect40235-6) keeps the 1px black outline and sky- (rect40237-2) does not
    content = replace(content, r"style=\"fill:#[0-9a-fA-F]{6};fill-opacity:1;stroke-width:0.264998;stroke-dasharray:0.264998, 0.264998;paint-order:stroke fill markers\"\s+id=\"rect40235-6\"" =>
                               SubstitutionString("style=\"fill:#000000;fill-opacity:1;stroke:#010101;stroke-width:0.264583;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1;paint-order:stroke fill markers\"\n         id=\"rect40235-6\""))
    content = replace(content, r"style=\"fill:#[0-9a-fA-F]{6};fill-opacity:1;stroke:#010101;stroke-width:0.264583;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1;paint-order:stroke fill markers\"\s+id=\"rect40237-2\"" =>
                               SubstitutionString("style=\"fill:#000000;fill-opacity:1;stroke-width:0.264998;stroke-dasharray:0.264998, 0.264998;paint-order:stroke fill markers\"\n         id=\"rect40237-2\""))

    function build_base_tier(tier_tones, title_text)
        tc = content
        sun_plus  = tier_tones["sun+"]
        sun       = tier_tones["sun"]
        sun_minus = tier_tones["sun-"]
        sky_plus  = tier_tones["sky+"]
        sky       = tier_tones["sky"]
        sky_minus = tier_tones["sky-"]
        sh_plus   = tier_tones["shade+"]
        sh        = tier_tones["shade"]
        sh_minus  = tier_tones["shade-"]

        # Outer background rect209496 -> tier sky
        tc = replace(tc, r"style=\"fill:#[0-9a-fA-F]{6}(;fill-opacity:1;stroke:none;stroke-width:0.264582;paint-order:stroke fill markers\"\s+id=\"rect209496\")" =>
                         SubstitutionString("style=\"fill:#$sky\\1"))

        for (rect_id, hex_val) in (
            ("rect40227-9", sun_plus),
            ("rect40229-3", sun),
            ("rect40231-6", sun_minus),
            ("rect40233-0", sky_plus),
            ("rect40235-6", sky),
            ("rect40237-2", sky_minus),
            ("rect40239-6", sh_plus),
            ("rect40241-1", sh),
            ("rect133712",  sh_minus),
        )
            rx = Regex("style=\\\"fill:#[0-9a-fA-F]{6}(;[^\\\"]*\\\"\\s+id=\\\"$rect_id\\\")")
            tc = replace(tc, rx => SubstitutionString("style=\"fill:#$hex_val\\1"))
        end

        # Label and title fills -> tier shade- for >5:1 contrast against tier sky
        tc = replace(tc, r"(<tspan[^>]*style=\"[^\"]*fill:)#[0-9a-fA-F]{6}" => SubstitutionString("\\1#$sh_minus"))
        tc = replace(tc, r"(<text[^>]*style=\"[^\"]*fill:)#[0-9a-fA-F]{6}" => SubstitutionString("\\1#$sh_minus"))

        # Frame border (rect240049) -> stroke: shade
        tc = replace(tc, r"stroke:#[0-9a-fA-F]{6}(;stroke-width:0.264583;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1;paint-order:stroke fill markers\"\s+id=\"rect240049\")" =>
                         SubstitutionString("stroke:#$sh\\1"))
        # Title text (case-insensitive replace for lowercase heading)
        tc = replace(tc, r"penumbra base [a-z+]+"i => title_text)
        return tc
    end

    c_bal = build_base_tier(tones_bal, "penumbra base balanced")
    write(bal_path, c_bal)
    println("  [UPDATED SVG] $bal_path")

    c_c1 = build_base_tier(tones_c1, "penumbra base contrast+")
    p_c1 = joinpath(swatches_dir, "penumbra_swatch_base_contrast+.svg")
    write(p_c1, c_c1)
    println("  [UPDATED SVG] $p_c1")

    c_c2 = build_base_tier(tones_c2, "penumbra base contrast++")
    p_c2 = joinpath(swatches_dir, "penumbra_swatch_base_contrast++.svg")
    write(p_c2, c_c2)
    println("  [UPDATED SVG] $p_c2")
end

const DARK_ACCENT_RECTS = [
    # N = 8
    (8, "rect3554", "red"), (8, "rect3636", "orange"), (8, "rect1104", "yellow"),
    (8, "rect1106", "green"), (8, "rect1108", "cyan"), (8, "rect1110", "blue"),
    (8, "rect1112", "purple"), (8, "rect1114", "magenta"),
    # N = 7
    (7, "rect1340", "red"), (7, "rect1342", "orange"), (7, "rect1346", "yellow"),
    (7, "rect1348", "green"), (7, "rect1350", "cyan"), (7, "rect1352", "blue"),
    (7, "rect1354", "purple"),
    # N = 6
    (6, "rect1724", "red"), (6, "rect1730", "yellow"), (6, "rect1732", "green"),
    (6, "rect1734", "cyan"), (6, "rect1736", "blue"), (6, "rect1740", "magenta")
]

const LIGHT_ACCENT_RECTS = [
    # N = 8
    (8, "rect40227", "red"), (8, "rect40229", "orange"), (8, "rect40231", "yellow"),
    (8, "rect40233", "green"), (8, "rect40235", "cyan"), (8, "rect40237", "blue"),
    (8, "rect40239", "purple"), (8, "rect40241", "magenta"),
    # N = 7
    (7, "rect40245", "red"), (7, "rect40247", "orange"), (7, "rect40249", "yellow"),
    (7, "rect40251", "green"), (7, "rect40253", "cyan"), (7, "rect40255", "blue"),
    (7, "rect40257", "purple"),
    # N = 6
    (6, "rect40263", "red"), (6, "rect40265", "yellow"), (6, "rect40267", "green"),
    (6, "rect40269", "cyan"), (6, "rect40271", "blue"), (6, "rect40273", "magenta")
]

function _apply_accent_rects(content::String, rects, accents_by_n)
    for (n, rect_id, color_name) in rects
        hex_val = accents_by_n[n][color_name]
        rx = Regex("style=\\\"fill:#[0-9a-fA-F]{6}(;[^\\\"]*\\\"\\s+id=\\\"$rect_id\\\")")
        content = replace(content, rx => SubstitutionString("style=\"fill:#$hex_val\\1"))
    end
    return content
end

function generate_accent_swatches(swatches_dir::String, base_tones, accents)
    bal_dark_path = joinpath(swatches_dir, "penumbra_swatch_dark_balanced.svg")
    content_dark = read(bal_dark_path, String)

    tones_bal = Dict(k => lowercase(v) for (k, v) in base_tones[:balanced])
    tones_c1  = Dict(k => lowercase(v) for (k, v) in base_tones[:contrast_plus])
    tones_c2  = Dict(k => lowercase(v) for (k, v) in base_tones[:contrast_plus_plus])

    sky_bal = tones_bal["sky"]
    shade_minus_bal = tones_bal["shade-"]

    accs_l = Dict(n => Dict(k => lowercase(v) for (k, v) in accents[:light][:balanced][n]) for n in (6, 7, 8))

    # 1. Font family updates
    content_dark = replace(content_dark, "font-family:'fira sans'" => "font-family:'Fira Sans', sans-serif")
    content_dark = replace(content_dark, "-inkscape-font-specification:'fira sans'" => "-inkscape-font-specification:'Fira Sans'")

    function build_dark_tier(tier_sym::Symbol, tier_tones, title_text)
        tc = content_dark
        tier_sky = tier_tones["sky"]
        tier_shade = tier_tones["shade"]
        tier_shade_minus = tier_tones["shade-"]
        accs_d = Dict(n => Dict(k => lowercase(v) for (k, v) in accents[:dark][tier_sym][n]) for n in (6, 7, 8))

        tc = replace(tc, r"style=\"fill:#[0-9a-fA-F]{6}(;fill-opacity:1;stroke:none;stroke-width:0.264582;paint-order:stroke fill markers\"\s+id=\"rect209496\")" =>
                         SubstitutionString("style=\"fill:#$tier_sky\\1"))
        tc = replace(tc, r"(<tspan[^>]*style=\"[^\"]*fill:)#[0-9a-fA-F]{6}" => SubstitutionString("\\1#$tier_sky"))
        tc = replace(tc, r"(<text[^>]*style=\"[^\"]*fill:)#[0-9a-fA-F]{6}" => SubstitutionString("\\1#$tier_sky"))
        tc = replace(tc, r"(id=\"text194332\"><tspan[^>]*style=\"fill:)#[0-9a-fA-F]{6}" => SubstitutionString("\\1#$tier_shade_minus"))
        tc = _apply_accent_rects(tc, DARK_ACCENT_RECTS, accs_d)
        tc = replace(tc, r"style=\"fill:#[0-9a-fA-F]{6}(;fill-opacity:1;stroke:none;stroke-width:0.264999;stroke-dasharray:0.264999, 0.264999;paint-order:stroke fill markers\"\s+id=\"rect2032\")" =>
                         SubstitutionString("style=\"fill:#$tier_shade\\1"))
        tc = replace(tc, r"penumbra dark [a-z+]+"i => title_text)
        return tc
    end

    c_d_bal = build_dark_tier(:balanced, tones_bal, "penumbra dark balanced")
    write(bal_dark_path, c_d_bal)
    println("  [UPDATED SVG] $bal_dark_path")

    c_d_c1 = build_dark_tier(:contrast_plus, tones_c1, "penumbra dark contrast+")
    p_d_c1 = joinpath(swatches_dir, "penumbra_swatch_dark_contrast+.svg")
    write(p_d_c1, c_d_c1)
    println("  [UPDATED SVG] $p_d_c1")

    c_d_c2 = build_dark_tier(:contrast_plus_plus, tones_c2, "penumbra dark contrast++")
    p_d_c2 = joinpath(swatches_dir, "penumbra_swatch_dark_contrast++.svg")
    write(p_d_c2, c_d_c2)
    println("  [UPDATED SVG] $p_d_c2")

    # 8. Light Balanced Swatch
    light_path = joinpath(swatches_dir, "penumbra_swatch_light_balanced.svg")
    content_light = read(light_path, String)

    content_light = replace(content_light, "font-family:'fira sans'" => "font-family:'Fira Sans', sans-serif")
    content_light = replace(content_light, "-inkscape-font-specification:'fira sans'" => "-inkscape-font-specification:'Fira Sans'")

    # Outer bg -> sky
    content_light = replace(content_light, r"style=\"fill:#[0-9a-fA-F]{6}(;fill-opacity:1;stroke:none;stroke-width:0.264582;paint-order:stroke fill markers\"\s+id=\"rect209496\")" =>
                                           SubstitutionString("style=\"fill:#$sky_bal\\1"))

    # Canvas rect170570 -> sun
    sun_hex = tones_bal["sun"]
    content_light = replace(content_light, r"style=\"fill:#[0-9a-fA-F]{6}(;fill-opacity:1;stroke-width:0.264999;stroke-dasharray:0.264999, 0.264999;paint-order:stroke fill markers\"\s+id=\"rect170570\")" =>
                                           SubstitutionString("style=\"fill:#$sun_hex\\1"))

    # Title text fill -> shade-
    content_light = replace(content_light, r"(id=\"text194332\"><tspan[^>]*style=\"fill:)#[0-9a-fA-F]{6}" => SubstitutionString("\\1#$shade_minus_bal"))

    # Light accents (N = 8, 7, 6)
    content_light = _apply_accent_rects(content_light, LIGHT_ACCENT_RECTS, accs_l)

    write(light_path, content_light)
    println("  [UPDATED SVG] $light_path")
end

function main()
    println("="^80)
    println("GENERATING AND RENDERING PENUMBRA V2 SWATCHES")
    println("="^80)

    root_dir = joinpath(@__DIR__, "..")
    base_tones, accents = load_palettes(root_dir)
    swatches_dir = joinpath(root_dir, "swatches")
    fonts_dir = joinpath(root_dir, "fonts")

    # 1. Base Swatches
    generate_base_swatches(swatches_dir, base_tones)

    # 2. Accent Swatches
    generate_accent_swatches(swatches_dir, base_tones, accents)

    # 3. Render PNGs via resvg (1600x800 for crisp 2x retina)
    svg_files = [
        "penumbra_swatch_base_balanced",
        "penumbra_swatch_base_contrast+",
        "penumbra_swatch_base_contrast++",
        "penumbra_swatch_dark_balanced",
        "penumbra_swatch_dark_contrast+",
        "penumbra_swatch_dark_contrast++",
        "penumbra_swatch_light_balanced"
    ]

    println("\n[Rendering PNG Swatches via resvg]")
    for name in svg_files
        svg = joinpath(swatches_dir, "$name.svg")
        png = joinpath(swatches_dir, "$name.png")
        cmd = isdir(fonts_dir) ? `resvg --use-fonts-dir $fonts_dir -w 1600 -h 800 $svg $png` : `resvg -w 1600 -h 800 $svg $png`
        run(cmd)
        println("  [RENDERED] $png")
    end

    # 4. Mirror to penumbra_vscode/images/
    vscode_images_dir = joinpath(@__DIR__, "..", "..", "penumbra_vscode", "images")
    if isdir(vscode_images_dir)
        println("\n[Mirroring to penumbra_vscode/images/]")
        for name in ["penumbra_swatch_base_balanced", "penumbra_swatch_dark_balanced", "penumbra_swatch_light_balanced"]
            src = joinpath(swatches_dir, "$name.png")
            dst = joinpath(vscode_images_dir, "$name.png")
            cp(src, dst; force=true)
            println("  [COPIED] $dst")
        end
    end

    println("="^80)
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
