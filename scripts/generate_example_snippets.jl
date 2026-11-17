# SPDX-License-Identifier: MIT
# Copyright (c) 2021-2026 Neal McKee

"""
generate_example_snippets.jl

Generates vector SVG and renders 2× retina PNG code snippets (812×376 logical, 1624×752 @2×)
at exact 16px Fira Code Retina for:
1. `examples/penumbra_example_dark.png`
2. `examples/penumbra_example_light.png`
3. `examples/penumbra_example_dark_contrast+.png`
4. `examples/penumbra_example_dark_contrast++.png`
5. `examples/penumbra_example_header.png` (curved lunar limb split: Light top-right, Dark bottom-left)

Reads color values directly from canonical TSVs (`penumbra_base.tsv`, `penumbra_accents.tsv`),
and renders high-resolution 2× retina PNGs via `resvg --zoom 2` using repository fonts in `fonts/`.
Mirrors all five images to `../penumbra_vscode/images/`.
"""

include(joinpath(@__DIR__, "..", "src", "palette_io.jl"))

const SNIPPET_WIDTH  = 812
const SNIPPET_HEIGHT = 376

function generate_snippet_svg(theme_name::Symbol, base_tones, accents)
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
        ("1",  """<tspan fill="$red">@lru_cache</tspan><tspan fill="$sky">(</tspan><tspan fill="$sky">maxsize</tspan><tspan fill="$cyan">=</tspan><tspan fill="$orange">256</tspan><tspan fill="$sky">)  </tspan><tspan fill="$comment"># Exact solar disk obscuration in the penumbra</tspan>"""),
        ("2",  """<tspan fill="$purple">def</tspan> <tspan fill="$blue">obscuration</tspan><tspan fill="$sky">(</tspan><tspan fill="$sky">d</tspan><tspan fill="$sky">: </tspan><tspan fill="$yellow">float</tspan><tspan fill="$sky">, </tspan><tspan fill="$sky">rs</tspan><tspan fill="$sky">: </tspan><tspan fill="$yellow">float</tspan> <tspan fill="$cyan">=</tspan> <tspan fill="$orange">0.266</tspan><tspan fill="$sky">, </tspan><tspan fill="$sky">rm</tspan><tspan fill="$sky">: </tspan><tspan fill="$yellow">float</tspan> <tspan fill="$cyan">=</tspan> <tspan fill="$orange">0.272</tspan><tspan fill="$sky">) </tspan><tspan fill="$cyan">-&gt;</tspan> <tspan fill="$yellow">float</tspan><tspan fill="$sky">:</tspan>"""),
        ("3",  """    <tspan fill="$green">&quot;&quot;&quot;Fraction of solar disk covered (angular radii in degrees).&quot;&quot;&quot;</tspan>"""),
        ("4",  """    <tspan fill="$purple">if</tspan> <tspan fill="$sky">d</tspan> <tspan fill="$cyan">&lt;</tspan> <tspan fill="$orange">0.0</tspan><tspan fill="$sky">:</tspan>"""),
        ("5",  """        <tspan fill="$purple">raise</tspan> <tspan fill="$yellow">ValueError</tspan><tspan fill="$sky">(</tspan><tspan fill="$purple">f</tspan><tspan fill="$green">&quot;negative separation: </tspan><tspan fill="$sky">{</tspan><tspan fill="$sky">d</tspan><tspan fill="$magenta">!r</tspan><tspan fill="$sky">}</tspan><tspan fill="$magenta">\\n</tspan><tspan fill="$green">&quot;</tspan><tspan fill="$sky">)</tspan>"""),
        ("6",  """    <tspan fill="$purple">if</tspan> <tspan fill="$sky">d</tspan> <tspan fill="$cyan">&gt;=</tspan> <tspan fill="$sky">rs</tspan> <tspan fill="$cyan">+</tspan> <tspan fill="$sky">rm</tspan><tspan fill="$sky">:</tspan>"""),
        ("7",  """        <tspan fill="$purple">return</tspan> <tspan fill="$orange">0.0</tspan>"""),
        ("8",  """    <tspan fill="$purple">if</tspan> <tspan fill="$sky">d</tspan> <tspan fill="$cyan">&lt;=</tspan> <tspan fill="$blue">abs</tspan><tspan fill="$sky">(</tspan><tspan fill="$sky">rm</tspan> <tspan fill="$cyan">-</tspan> <tspan fill="$sky">rs</tspan><tspan fill="$sky">):</tspan>"""),
        ("9",  """        <tspan fill="$purple">return</tspan> <tspan fill="$orange">1.0</tspan> <tspan fill="$purple">if</tspan> <tspan fill="$sky">rm</tspan> <tspan fill="$cyan">&gt;=</tspan> <tspan fill="$sky">rs</tspan> <tspan fill="$purple">else</tspan> <tspan fill="$sky">(</tspan><tspan fill="$sky">rm</tspan> <tspan fill="$cyan">/</tspan> <tspan fill="$sky">rs</tspan><tspan fill="$sky">)</tspan> <tspan fill="$cyan">**</tspan> <tspan fill="$orange">2</tspan>"""),
        ("10", """    <tspan fill="$sky">a</tspan> <tspan fill="$cyan">=</tspan> <tspan fill="$sky">math</tspan><tspan fill="$sky">.</tspan><tspan fill="$blue">acos</tspan><tspan fill="$sky">((</tspan><tspan fill="$sky">d</tspan><tspan fill="$cyan">*</tspan><tspan fill="$sky">d</tspan> <tspan fill="$cyan">+</tspan> <tspan fill="$sky">rs</tspan><tspan fill="$cyan">*</tspan><tspan fill="$sky">rs</tspan> <tspan fill="$cyan">-</tspan> <tspan fill="$sky">rm</tspan><tspan fill="$cyan">*</tspan><tspan fill="$sky">rm</tspan><tspan fill="$sky">)</tspan> <tspan fill="$cyan">/</tspan> <tspan fill="$sky">(</tspan><tspan fill="$orange">2.0</tspan> <tspan fill="$cyan">*</tspan> <tspan fill="$sky">d</tspan> <tspan fill="$cyan">*</tspan> <tspan fill="$sky">rs</tspan><tspan fill="$sky">))</tspan>"""),
        ("11", """    <tspan fill="$sky">b</tspan> <tspan fill="$cyan">=</tspan> <tspan fill="$sky">math</tspan><tspan fill="$sky">.</tspan><tspan fill="$blue">acos</tspan><tspan fill="$sky">((</tspan><tspan fill="$sky">d</tspan><tspan fill="$cyan">*</tspan><tspan fill="$sky">d</tspan> <tspan fill="$cyan">+</tspan> <tspan fill="$sky">rm</tspan><tspan fill="$cyan">*</tspan><tspan fill="$sky">rm</tspan> <tspan fill="$cyan">-</tspan> <tspan fill="$sky">rs</tspan><tspan fill="$cyan">*</tspan><tspan fill="$sky">rs</tspan><tspan fill="$sky">)</tspan> <tspan fill="$cyan">/</tspan> <tspan fill="$sky">(</tspan><tspan fill="$orange">2.0</tspan> <tspan fill="$cyan">*</tspan> <tspan fill="$sky">d</tspan> <tspan fill="$cyan">*</tspan> <tspan fill="$sky">rm</tspan><tspan fill="$sky">))</tspan>"""),
        ("12", """    <tspan fill="$sky">s</tspan> <tspan fill="$cyan">=</tspan> <tspan fill="$orange">0.5</tspan> <tspan fill="$cyan">*</tspan> <tspan fill="$sky">(</tspan><tspan fill="$sky">d</tspan> <tspan fill="$cyan">+</tspan> <tspan fill="$sky">rs</tspan> <tspan fill="$cyan">+</tspan> <tspan fill="$sky">rm</tspan><tspan fill="$sky">)</tspan>"""),
        ("13", """    <tspan fill="$sky">area</tspan> <tspan fill="$cyan">=</tspan> <tspan fill="$sky">rs</tspan><tspan fill="$cyan">*</tspan><tspan fill="$sky">rs</tspan><tspan fill="$cyan">*</tspan><tspan fill="$sky">a</tspan> <tspan fill="$cyan">+</tspan> <tspan fill="$sky">rm</tspan><tspan fill="$cyan">*</tspan><tspan fill="$sky">rm</tspan><tspan fill="$cyan">*</tspan><tspan fill="$sky">b</tspan> <tspan fill="$cyan">-</tspan> <tspan fill="$orange">2.0</tspan> <tspan fill="$cyan">*</tspan> <tspan fill="$sky">math</tspan><tspan fill="$sky">.</tspan><tspan fill="$blue">sqrt</tspan><tspan fill="$sky">(</tspan><tspan fill="$sky">s</tspan><tspan fill="$cyan">*</tspan><tspan fill="$sky">(</tspan><tspan fill="$sky">s</tspan> <tspan fill="$cyan">-</tspan> <tspan fill="$sky">d</tspan><tspan fill="$sky">)</tspan><tspan fill="$cyan">*</tspan><tspan fill="$sky">(</tspan><tspan fill="$sky">s</tspan> <tspan fill="$cyan">-</tspan> <tspan fill="$sky">rs</tspan><tspan fill="$sky">)</tspan><tspan fill="$cyan">*</tspan><tspan fill="$sky">(</tspan><tspan fill="$sky">s</tspan> <tspan fill="$cyan">-</tspan> <tspan fill="$sky">rm</tspan><tspan fill="$sky">))</tspan>"""),
        ("14", """    <tspan fill="$purple">return</tspan> <tspan fill="$sky">area</tspan> <tspan fill="$cyan">/</tspan> <tspan fill="$sky">(</tspan><tspan fill="$sky">math</tspan><tspan fill="$sky">.</tspan><tspan fill="$sky">pi</tspan> <tspan fill="$cyan">*</tspan> <tspan fill="$sky">rs</tspan> <tspan fill="$cyan">*</tspan> <tspan fill="$sky">rs</tspan><tspan fill="$sky">)</tspan>"""),
    ]

    font_family = "'Fira Code Retina', 'Fira Code', monospace"
    font_size = 16
    line_step = 24
    y_start = 36
    gutter_x = 34
    code_x = 48

    svg_elements = String[]
    for (i, (num, code_str)) in enumerate(lines)
        y = y_start + (i - 1) * line_step
        push!(svg_elements, """    <text x="$gutter_x" y="$y" text-anchor="end" fill="$gutter" font-family="$font_family" font-size="$(font_size)px">$num</text>""")
        push!(svg_elements, """    <text x="$code_x" y="$y" font-family="$font_family" font-size="$(font_size)px" xml:space="preserve">$code_str</text>""")
    end

    return (bg=bg, body=join(svg_elements, "\n"))
end

function render_single_snippet(theme_name::Symbol, base_tones, accents, out_svg::String, out_png::String, fonts_dir::String)
    snippet = generate_snippet_svg(theme_name, base_tones, accents)
    svg_content = """<?xml version="1.0" encoding="UTF-8"?>
<svg width="$SNIPPET_WIDTH" height="$SNIPPET_HEIGHT" viewBox="0 0 $SNIPPET_WIDTH $SNIPPET_HEIGHT" xmlns="http://www.w3.org/2000/svg">
  <rect width="$SNIPPET_WIDTH" height="$SNIPPET_HEIGHT" fill="$(snippet.bg)" />
$(snippet.body)
</svg>
"""
    write(out_svg, svg_content)
    cmd = isdir(fonts_dir) ? `resvg --use-fonts-dir $fonts_dir --zoom 2 $out_svg $out_png` : `resvg --zoom 2 $out_svg $out_png`
    run(cmd)
    println("  [RENDERED] $out_png")
end

function render_header_banner(base_tones, accents, out_svg::String, out_png::String, fonts_dir::String)
    dark_part = generate_snippet_svg(:dark_balanced, base_tones, accents)
    light_part = generate_snippet_svg(:light_balanced, base_tones, accents)
    W, H = SNIPPET_WIDTH, SNIPPET_HEIGHT
    x_seam = 215
    R = 440

    svg_content = """<?xml version="1.0" encoding="UTF-8"?>
<svg width="$W" height="$H" viewBox="0 0 $W $H" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <clipPath id="clip-dark">
      <path d="M $x_seam,0 A $R $R 0 0 0 $x_seam,$H L $W,$H L $W,0 Z" />
    </clipPath>
  </defs>
  <rect width="$W" height="$H" fill="$(light_part.bg)" />
$(light_part.body)
  <g clip-path="url(#clip-dark)">
    <rect width="$W" height="$H" fill="$(dark_part.bg)" />
$(dark_part.body)
  </g>
</svg>
"""
    write(out_svg, svg_content)
    cmd = isdir(fonts_dir) ? `resvg --use-fonts-dir $fonts_dir --zoom 2 $out_svg $out_png` : `resvg --zoom 2 $out_svg $out_png`
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

    render_single_snippet(:dark_balanced, base_tones, accents,
                          joinpath(examples_dir, "penumbra_example_dark.svg"),
                          joinpath(examples_dir, "penumbra_example_dark.png"),
                          fonts_dir)

    render_single_snippet(:dark_contrast_plus, base_tones, accents,
                          joinpath(examples_dir, "penumbra_example_dark_contrast+.svg"),
                          joinpath(examples_dir, "penumbra_example_dark_contrast+.png"),
                          fonts_dir)

    render_single_snippet(:dark_contrast_plus_plus, base_tones, accents,
                          joinpath(examples_dir, "penumbra_example_dark_contrast++.svg"),
                          joinpath(examples_dir, "penumbra_example_dark_contrast++.png"),
                          fonts_dir)

    render_single_snippet(:light_balanced, base_tones, accents,
                          joinpath(examples_dir, "penumbra_example_light.svg"),
                          joinpath(examples_dir, "penumbra_example_light.png"),
                          fonts_dir)

    render_header_banner(base_tones, accents,
                         joinpath(examples_dir, "penumbra_example_header.svg"),
                         joinpath(examples_dir, "penumbra_example_header.png"),
                         fonts_dir)

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

    for svg in filter(f -> endswith(f, ".svg"), readdir(examples_dir, join=true))
        rm(svg; force=true)
    end

    println("="^80)
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
