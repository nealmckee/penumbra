# SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
# Copyright (c) 2021-2026 Neal McKee. All rights reserved.

"""
generate_example_snippets.jl

Generates vector SVG and renders 2× retina PNG code snippets for:
1. `examples/penumbra_example_dark.png` (1024x512)
2. `examples/penumbra_example_light.png` (1024x512)
3. `examples/penumbra_example_dark_contrast+.png` (1024x512)
4. `examples/penumbra_example_dark_contrast++.png` (1024x512)
5. `examples/penumbra_example_header.png` (2048x512, side-by-side dark & light)
6. `examples/penumbra_example_dark_header.png` (400x200 crop/scaled)
7. `examples/penumbra_example_light_header.png` (400x200 crop/scaled)

Reads color values directly from canonical TSVs (`penumbra_base.tsv`, `penumbra_accents.tsv`),
and renders high-resolution 2× retina PNGs via `resvg` using repository fonts in `fonts/`.
Mirrors images to `../penumbra_vscode/images/`.
"""

include(joinpath(@__DIR__, "..", "src", "palette_io.jl"))

function generate_snippet_svg(theme_name::Symbol, base_tones, accents; width::Int=1024, height::Int=512, x_offset::Int=0)
    # Determine mode, tier, background, and accents from TSV palettes
    is_light = theme_name == :light_balanced
    mode = is_light ? :light : :dark
    tier = if theme_name == :dark_contrast_plus
        :contrast_plus
    elseif theme_name == :dark_contrast_plus_plus
        :contrast_plus_plus
    else
        :balanced
    end

    bg = is_light ? "#" * base_tones[tier]["sun"] : "#" * base_tones[tier]["shade"]
    acc = accents[mode][tier][8]

    red     = "#" * acc["red"]
    orange  = "#" * acc["orange"]
    yellow  = "#" * acc["yellow"]
    green   = "#" * acc["green"]
    cyan    = "#" * acc["cyan"]
    blue    = "#" * acc["blue"]
    purple  = "#" * acc["purple"]
    magenta = "#" * acc["magenta"]
    sky     = "#" * base_tones[tier]["sky"]
    comment = is_light ? "#" * base_tones[tier]["sky+"] : "#" * base_tones[tier]["sky-"]
    gutter  = is_light ? "#" * base_tones[tier]["sky+"] : "#" * base_tones[tier]["sky-"]

    lines = [
        # (line_no, tokens)
        ("1", """<tspan fill="$red">@requires_authorization</tspan><tspan fill="$sky">(</tspan><tspan fill="$sky">roles</tspan><tspan fill="$cyan">=</tspan><tspan fill="$sky">[</tspan><tspan fill="$green">&quot;</tspan><tspan fill="$yellow">ADMIN</tspan><tspan fill="$green">&quot;</tspan><tspan fill="$sky">])</tspan>"""),
        ("2", """<tspan fill="$purple">def</tspan> <tspan fill="$blue">somefunc</tspan><tspan fill="$sky">(</tspan><tspan fill="$sky">param1</tspan><tspan fill="$cyan">=</tspan><tspan fill="$green">&#39;&#39;</tspan><tspan fill="$sky">, </tspan><tspan fill="$sky">param2</tspan><tspan fill="$cyan">=</tspan><tspan fill="$orange">0</tspan><tspan fill="$sky">):</tspan>"""),
        ("3", """    <tspan fill="$green">r&#39;&#39;&#39;A docstring&#39;&#39;&#39;</tspan>"""),
        ("4", """    <tspan fill="$purple">if</tspan> <tspan fill="$sky">param1</tspan> <tspan fill="$cyan">&gt;</tspan> <tspan fill="$sky">param2</tspan><tspan fill="$sky">:</tspan> <tspan fill="$comment"># interesting</tspan>"""),
        ("5", """        <tspan fill="$blue">print</tspan><tspan fill="$sky">(</tspan><tspan fill="$purple">f</tspan><tspan fill="$green">&#39;Gre</tspan><tspan fill="$magenta">\\&#39;</tspan><tspan fill="$green">ater </tspan><tspan fill="$sky">{</tspan><tspan fill="$sky">param1</tspan><tspan fill="$sky">}</tspan><tspan fill="$green">&#39;</tspan><tspan fill="$sky">)</tspan>"""),
        ("6", """        <tspan fill="$purple">return</tspan> <tspan fill="$sky">(</tspan><tspan fill="$sky">param2</tspan> <tspan fill="$cyan">-</tspan> <tspan fill="$sky">param1</tspan> <tspan fill="$cyan">+</tspan> <tspan fill="$orange">1</tspan> <tspan fill="$cyan">+</tspan> <tspan fill="$orange">0b10</tspan><tspan fill="$sky">)</tspan> <tspan fill="$purple">or</tspan> <tspan fill="$orange">None</tspan>"""),
        ("",  ""),
        ("8", """<tspan fill="$purple">class</tspan> <tspan fill="$yellow">SomeClass</tspan><tspan fill="$sky">:</tspan>"""),
        ("9", """    <tspan fill="$purple">pass</tspan>"""),
        ("",  ""),
        ("11", """<tspan fill="$comment">&gt;&gt;&gt;</tspan> <tspan fill="$sky">message</tspan> <tspan fill="$cyan">=</tspan> <tspan fill="$blue">prompt</tspan><tspan fill="$green">&#39;&#39;&#39;</tspan>"""),
        ("12", """<tspan fill="$comment">...</tspan> <tspan fill="$green">&#39;&#39;&#39;</tspan><tspan fill="$comment">interpreter</tspan>""")
    ]

    font_family = "'Fira Code', 'Fira Code Retina', monospace"
    font_size = 28
    line_step = 40
    y_start = 40
    gutter_x = x_offset + 38
    code_x = x_offset + 58

    svg_elements = String[]
    for (i, (num, code_str)) in enumerate(lines)
        y = y_start + (i - 1) * line_step
        if !isempty(num)
            push!(svg_elements, """    <text x="$gutter_x" y="$y" text-anchor="end" fill="$gutter" font-family="$font_family" font-size="$(font_size)px" font-weight="normal">$num</text>""")
        end
        if !isempty(code_str)
            push!(svg_elements, """    <text x="$code_x" y="$y" font-family="$font_family" font-size="$(font_size)px" xml:space="preserve">$code_str</text>""")
        end
    end

    body = join(svg_elements, "\n")
    return (bg=bg, body=body)
end

function render_single_snippet(theme_name::Symbol, base_tones, accents, out_svg::String, out_png::String, fonts_dir::String)
    snippet = generate_snippet_svg(theme_name, base_tones, accents; width=1024, height=512)
    svg_content = """<?xml version="1.0" encoding="UTF-8"?>
<svg width="1024" height="512" viewBox="0 0 1024 512" xmlns="http://www.w3.org/2000/svg">
  <rect width="1024" height="512" fill="$(snippet.bg)" />
$(snippet.body)
</svg>
"""
    write(out_svg, svg_content)
    cmd = isdir(fonts_dir) ? `resvg --use-fonts-dir $fonts_dir $out_svg $out_png` : `resvg $out_svg $out_png`
    run(cmd)
    println("  [RENDERED] $out_png")
end

function render_header_banner(base_tones, accents, out_svg::String, out_png::String, fonts_dir::String)
    dark_part = generate_snippet_svg(:dark_balanced, base_tones, accents; width=1024, height=512, x_offset=0)
    light_part = generate_snippet_svg(:light_balanced, base_tones, accents; width=1024, height=512, x_offset=1024)

    svg_content = """<?xml version="1.0" encoding="UTF-8"?>
<svg width="2048" height="512" viewBox="0 0 2048 512" xmlns="http://www.w3.org/2000/svg">
  <rect x="0" y="0" width="1024" height="512" fill="$(dark_part.bg)" />
  <rect x="1024" y="0" width="1024" height="512" fill="$(light_part.bg)" />
$(dark_part.body)
$(light_part.body)
</svg>
"""
    write(out_svg, svg_content)
    cmd = isdir(fonts_dir) ? `resvg --use-fonts-dir $fonts_dir $out_svg $out_png` : `resvg $out_svg $out_png`
    run(cmd)
    println("  [RENDERED] $out_png")
end

function main()
    println("="^80)
    println("GENERATING AND RENDERING PENUMBRA V2 CODE SNIPPETS")
    println("="^80)

    root_dir = joinpath(@__DIR__, "..")
    base_tones, accents = load_palettes(root_dir)
    examples_dir = joinpath(root_dir, "examples")
    fonts_dir = joinpath(root_dir, "fonts")

    # 1. Dark Balanced
    render_single_snippet(:dark_balanced, base_tones, accents,
                          joinpath(examples_dir, "penumbra_example_dark.svg"),
                          joinpath(examples_dir, "penumbra_example_dark.png"),
                          fonts_dir)

    # 2. Dark Contrast+
    render_single_snippet(:dark_contrast_plus, base_tones, accents,
                          joinpath(examples_dir, "penumbra_example_dark_contrast+.svg"),
                          joinpath(examples_dir, "penumbra_example_dark_contrast+.png"),
                          fonts_dir)

    # 3. Dark Contrast++
    render_single_snippet(:dark_contrast_plus_plus, base_tones, accents,
                          joinpath(examples_dir, "penumbra_example_dark_contrast++.svg"),
                          joinpath(examples_dir, "penumbra_example_dark_contrast++.png"),
                          fonts_dir)

    # 4. Light Balanced
    render_single_snippet(:light_balanced, base_tones, accents,
                          joinpath(examples_dir, "penumbra_example_light.svg"),
                          joinpath(examples_dir, "penumbra_example_light.png"),
                          fonts_dir)

    # 5. Header Banner (2048x512)
    render_header_banner(base_tones, accents,
                         joinpath(examples_dir, "penumbra_example_header.svg"),
                         joinpath(examples_dir, "penumbra_example_header.png"),
                         fonts_dir)

    # 6. Small header crops / scales (400x200)
    run(`magick $(joinpath(examples_dir, "penumbra_example_dark.png")) -resize 400x200 $(joinpath(examples_dir, "penumbra_example_dark_header.png"))`)
    println("  [RENDERED] $(joinpath(examples_dir, "penumbra_example_dark_header.png"))")

    run(`magick $(joinpath(examples_dir, "penumbra_example_light.png")) -resize 400x200 $(joinpath(examples_dir, "penumbra_example_light_header.png"))`)
    println("  [RENDERED] $(joinpath(examples_dir, "penumbra_example_light_header.png"))")

    # 7. Mirror to penumbra_vscode/images/
    vscode_images_dir = joinpath(@__DIR__, "..", "..", "penumbra_vscode", "images")
    if isdir(vscode_images_dir)
        println("\n[Mirroring to penumbra_vscode/images/]")
        for name in [
            "penumbra_example_dark.png",
            "penumbra_example_dark_contrast+.png",
            "penumbra_example_dark_contrast++.png",
            "penumbra_example_light.png",
            "penumbra_example_header.png"
        ]
            src = joinpath(examples_dir, name)
            dst = joinpath(vscode_images_dir, name)
            cp(src, dst; force=true)
            println("  [COPIED] $dst")
        end
    end

    # Clean up intermediate SVG files in examples
    for svg in filter(f -> endswith(f, ".svg"), readdir(examples_dir, join=true))
        rm(svg; force=true)
    end

    println("="^80)
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
