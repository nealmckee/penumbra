# SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
# Copyright (c) 2021-2026 Neal McKee. All rights reserved.

"""
generate_accent_inspection.jl

Generates `data/inspection/accent_comparison.html` for the finalized Max-Chroma polygonal
accent optimization across N ∈ {6, 7, 8} and H–K compensation α ∈ {0.00, 0.25, 0.50, 0.75, 1.00},
plus the finalized Re-anchored higher-contrast tiers (`Contrast+` and `Contrast++`).
"""

using Printf
using Colors: XYZ, RGB, hex

include(joinpath(@__DIR__, "..", "src", "accent_palette.jl"))

const ALPHAS = (0.00, 0.25, 0.50, 0.75, 1.00)

function _role_colors(tones::Vector{AccentTone{Float64}})
    d = Dict(t.name => "#" * uppercase(t.hex) for t in tones)
    return (
        red     = d["red"],
        orange  = get(d, "orange", d["yellow"]),
        yellow  = d["yellow"],
        green   = d["green"],
        cyan    = d["cyan"],
        blue    = d["blue"],
        purple  = haskey(d, "purple") ? d["purple"] : d["magenta"],
        magenta = haskey(d, "magenta") ? d["magenta"] : d["red"],
    )
end

function _code_preview_html(title::String, bg::String, fg::String, heading::String, comment::String, r; badge_fg::String="#202225")
    return """
<div class="code-box" style="background: $bg; color: $fg;">
  <div style="font-weight: bold; margin-bottom: 8px; color: $heading;">$title</div>
  <span style="color: $comment;"># Syntax highlighting preview (neutral sky carrier wave)</span><br/>
  <span style="color: $(r.purple);">struct</span> <span style="color: $(r.yellow);">AccentPalette</span>{<span style="color: $(r.yellow);">T</span> <span style="color: $(r.cyan);">&lt;:</span> <span style="color: $(r.yellow);">Real</span>}<br/>
  &nbsp;&nbsp;&nbsp;&nbsp;h0<span style="color: $(r.cyan);">::</span><span style="color: $(r.yellow);">T</span><br/>
  <span style="color: $(r.purple);">end</span><br/><br/>
  <span style="color: $(r.red);">@inline</span> <span style="color: $(r.purple);">function</span> <span style="color: $(r.blue);">solve_loop</span>(target_j<span style="color: $(r.cyan);">::</span><span style="color: $(r.yellow);">Float64</span>)<span style="color: $(r.cyan);">::</span><span style="color: $(r.yellow);">AccentPalette</span><br/>
  &nbsp;&nbsp;&nbsp;&nbsp;iters <span style="color: $(r.cyan);">=</span> <span style="color: $(r.orange);">45</span><br/>
  &nbsp;&nbsp;&nbsp;&nbsp;label <span style="color: $(r.cyan);">=</span> <span style="color: $(r.green);">"penumbra"</span><br/>
  &nbsp;&nbsp;&nbsp;&nbsp;status <span style="color: $(r.cyan);">=</span> <span style="color: $(r.magenta);">:balanced</span><br/>
  &nbsp;&nbsp;&nbsp;&nbsp;<span style="color: $(r.purple);">return</span> <span style="color: $(r.yellow);">AccentPalette</span>(target_j)<br/>
  <span style="color: $(r.purple);">end</span>
  <div style="margin-top: 12px; display: flex; flex-wrap: wrap; gap: 6px;">
    <span class="badge" style="background: $(r.red); color: $badge_fg;">ERR</span>
    <span class="badge" style="background: $(r.orange); color: $badge_fg;">NUM</span>
    <span class="badge" style="background: $(r.yellow); color: $badge_fg;">TYPE</span>
    <span class="badge" style="background: $(r.green); color: $badge_fg;">STR</span>
    <span class="badge" style="background: $(r.cyan); color: $badge_fg;">OP</span>
    <span class="badge" style="background: $(r.blue); color: $badge_fg;">FN</span>
    <span class="badge" style="background: $(r.purple); color: $badge_fg;">KW</span>
    <span class="badge" style="background: $(r.magenta); color: $badge_fg;">MAG</span>
  </div>
</div>"""
end

function _swatch_row_html(pal::AccentPalette)
    chips = IOBuffer()
    for t in pal.tones
        h_hex = "#" * uppercase(t.hex)
        @printf(chips, """
<div class="swatch-chip">
  <div class="swatch-color" style="background: %s;"></div>
  <div class="swatch-label">
    <b>%s</b> %s<br/>
    h: %.1f° | C′: %.1f<br/>
    J′_ach: %.1f | Y: %.3f
  </div>
</div>""", h_hex, t.name, h_hex, t.h, t.C_ucs, t.J_ach_ucs, t.Y)
    end
    return "<div class=\"swatch-row\">\n" * String(take!(chips)) * "\n</div>"
end

function generate_inspection_html(out_path::String)
    sol = solve_base_palette()
    tones_bal = Dict(t.name => "#" * uppercase(t.hex) for t in base_palette_tones(sol) if t.tier == :balanced)
    j_sky_dark = convert(CAM16UCSJCh, convert(XYZ, sol.curve(sol.J_sky)), sol.env_dark).j
    j_sky_light = convert(CAM16UCSJCh, convert(XYZ, sol.curve(sol.J_sky)), sol.env_light).j

    buf = IOBuffer()
    write(buf, """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8"/>
<title>Penumbra v2: Max-Chroma Polygon &amp; H–K Compensation Inspection</title>
<style>
  :root {
    --bg: #1a1c1e;
    --fg: #e0e2e5;
    --card-bg: #24272b;
    --border: #383c42;
    --font-mono: "Fira Code", ui-monospace, SFMono-Regular, Menlo, monospace;
    --font-sans: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
  }
  body {
    background: var(--bg);
    color: var(--fg);
    font-family: var(--font-sans);
    margin: 0;
    padding: 32px;
    line-height: 1.5;
  }
  h1, h2, h3, h4 {
    color: #fff;
    margin-top: 24px;
    margin-bottom: 12px;
  }
  .lead {
    font-size: 1.05rem;
    color: #a0a6b0;
    max-width: 920px;
    margin-bottom: 24px;
  }
  .card {
    background: var(--card-bg);
    border: 1px solid var(--border);
    border-radius: 8px;
    padding: 24px;
    margin-bottom: 32px;
  }
  table.diag-table {
    width: 100%;
    border-collapse: collapse;
    font-family: var(--font-mono);
    font-size: 0.85rem;
    margin: 16px 0;
  }
  table.diag-table th, table.diag-table td {
    padding: 8px 12px;
    border: 1px solid var(--border);
    text-align: left;
  }
  table.diag-table th {
    background: #2a2e35;
    color: #fff;
  }
  .swatch-row {
    display: flex;
    flex-wrap: wrap;
    gap: 12px;
    margin: 16px 0;
  }
  .swatch-chip {
    flex: 1;
    min-width: 120px;
    border-radius: 6px;
    overflow: hidden;
    border: 1px solid rgba(255,255,255,0.1);
  }
  .swatch-color {
    height: 54px;
    width: 100%;
  }
  .swatch-label {
    padding: 8px;
    font-family: var(--font-mono);
    font-size: 0.75rem;
    background: rgba(0,0,0,0.3);
  }
  .preview-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 20px;
    margin-top: 16px;
  }
  .code-box {
    border-radius: 8px;
    padding: 20px;
    font-family: var(--font-mono);
    font-size: 0.88rem;
    line-height: 1.6;
    overflow-x: auto;
    border: 1px solid rgba(0,0,0,0.2);
  }
  .badge {
    display: inline-block;
    padding: 2px 8px;
    border-radius: 4px;
    font-size: 0.75rem;
    font-family: var(--font-mono);
    font-weight: bold;
  }
</style>
</head>
<body>
<h1>Penumbra v2: Max-Chroma Polygon &amp; H–K Compensation Inspection</h1>
<p class="lead">
  Inspection suite for the <b>Max-Chroma rotated N-gon</b> criterion (<code>criterion = :max_chroma</code>),
  comparing Helmholtz–Kohlrausch compensation across <b>α ∈ {0.00, 0.25, 0.50, 0.75, 1.00}</b> on both thin
  typographic strokes and solid UI badges.
</p>
""")

    for N in (6, 7, 8)
        role_list = join(CANONICAL_ACCENT_NAMES[N], ", ")
        write(buf, """
<div class="card">
<h2>Palette Size N = $N</h2>
<p>Canonical named roles: <code>$role_list</code></p>
<h3>1. Quantitative Diagnostics Matrix (Dark Balanced J′_HK = $(round(j_sky_dark, digits=2)))</h3>
<table class="diag-table">
<thead>
<tr>
  <th>α (H–K)</th>
  <th>h₀</th>
  <th>Polygon C′_$N</th>
  <th>Inscribed C′</th>
  <th>Polygon Gain</th>
  <th>Unique Hue RMSE</th>
  <th>Max Unique |Δh|</th>
  <th>J′_ach Range</th>
  <th>Luminance Y Range</th>
</tr>
</thead>
<tbody>
""")
        pals_dark = [optimize_accent_palette(N, j_sky_dark, sol.env_dark; alpha=a) for a in ALPHAS]
        pals_light = [optimize_accent_palette(N, j_sky_light, sol.env_light; alpha=a) for a in ALPHAS]

        for pal in pals_dark
            j_lo = minimum(t.J_ach_ucs for t in pal.tones)
            j_hi = maximum(t.J_ach_ucs for t in pal.tones)
            y_lo = minimum(t.Y for t in pal.tones)
            y_hi = maximum(t.Y for t in pal.tones)
            gain = 100.0 * (pal.C_poly / pal.C_inscribed - 1.0)
            @printf(buf,
                "<tr><td>α = %.2f</td><td>%.2f°</td><td><b>%.2f</b></td><td>%.2f</td><td>+%.1f%%</td><td>%.2f°</td><td>%.2f°</td><td>%.2f – %.2f</td><td>%.4f – %.4f</td></tr>\n",
                pal.alpha, pal.h0, pal.C_poly, pal.C_inscribed, gain, pal.rmse_hue, pal.max_abs_dh, j_lo, j_hi, y_lo, y_hi
            )
        end
        write(buf, "</tbody>\n</table>\n<h3>2. Swatches &amp; Colorimetric Coordinates (Dark Balanced)</h3>\n")
        for pal in pals_dark
            write(buf, @sprintf("<h4>α = %.2f (h₀ = %.2f°, C′_%d = %.2f)</h4>\n", pal.alpha, pal.h0, N, pal.C_poly))
            write(buf, _swatch_row_html(pal))
        end

        write(buf, "<h3>3. Syntax Highlighting &amp; UI Badge Previews (Dark &amp; Light)</h3>\n")
        for (pd, pl) in zip(pals_dark, pals_light)
            write(buf, @sprintf("<h4>α = %.2f (Dark C′ = %.2f | Light C′ = %.2f)</h4>\n<div class=\"preview-grid\">\n", pd.alpha, pd.C_poly, pl.C_poly))
            rd = _role_colors(pd.tones)
            rl = _role_colors(pl.tones)
            write(buf, _code_preview_html(
                "Dark Mode ($(tones_bal["shade"]) canvas) [α = $(@sprintf("%.2f", pd.alpha))]",
                tones_bal["shade"], tones_bal["sky"], tones_bal["sky+"], tones_bal["sky-"], rd;
                badge_fg=tones_bal["shade-"],
            ))
            write(buf, _code_preview_html(
                "Light Mode ($(tones_bal["sun"]) canvas) [α = $(@sprintf("%.2f", pl.alpha))]",
                tones_bal["sun"], tones_bal["sky"], tones_bal["sky-"], tones_bal["sky+"], rl;
                badge_fg=tones_bal["sun+"],
            ))
            write(buf, "\n</div>\n")
        end
        write(buf, "</div>\n")
    end

    # Section 4: Finalized Contrast+ & Contrast++ (Re-anchored, α = 1.00, N = 8 & N = 6)
    write(buf, """
<div class="card">
<h2>Finalized Contrast Tiers (Re-anchored Curve, 7Δ → 9Δ → 11Δ, α = 1.00)</h2>
<p>Re-anchored daylight curve (<code>sky = 6504 K</code>, <code>sun+ = 5772 K</code>, steeper <code>k_μ</code>) with re-solved per-tier accents.</p>
""")
    for (tier_label, sh_step, sk_step) in [("Contrast+ (4Δ → 13Δ, 9Δ)", 4.0, 13.0), ("Contrast++ (3Δ → 14Δ, 11Δ)", 3.0, 14.0)]
        res = solve_contrast_tier_base(sol, sh_step, sk_step)
        pal8 = optimize_accent_palette(8, res.J_sky_dark, res.env; alpha=1.0)
        pal6 = optimize_accent_palette(6, res.J_sky_dark, res.env; alpha=1.0)
        b = Dict(k => "#" * uppercase(v) for (k, v) in res.dict)

        write(buf, @sprintf("<h3>%s — k_μ = %.4f, sky = %s, shade = %s</h3>\n", tier_label, res.curve.k_mu, b["sky"], b["shade"]))
        write(buf, @sprintf("<p><b>N = 8 (Syntax):</b> h₀ = %.2f°, C′ = %.2f</p>\n", pal8.h0, pal8.C_poly))
        write(buf, _swatch_row_html(pal8))
        write(buf, @sprintf("<p><b>N = 6 (Terminal ANSI):</b> h₀ = %.2f°, C′ = %.2f</p>\n", pal6.h0, pal6.C_poly))
        write(buf, _swatch_row_html(pal6))
        write(buf, "<div class=\"preview-grid\">\n")
        write(buf, _code_preview_html(
            "Syntax Preview N = 8 ($(b["shade"]) bg, $(b["sky"]) text)",
            b["shade"], b["sky"], b["sky+"], b["sky-"], _role_colors(pal8.tones);
            badge_fg=b["shade-"],
        ))
        write(buf, _code_preview_html(
            "Terminal ANSI Preview N = 6 ($(b["shade"]) bg, $(b["sky"]) text)",
            b["shade"], b["sky"], b["sky+"], b["sky-"], _role_colors(pal6.tones);
            badge_fg=b["shade-"],
        ))
        write(buf, "\n</div>\n")
    end
    write(buf, "</div>\n</body>\n</html>\n")

    mkpath(dirname(out_path))
    write(out_path, String(take!(buf)))
    println("[WRITTEN] $out_path")
end

if abspath(PROGRAM_FILE) == @__FILE__
    out = joinpath(@__DIR__, "..", "data", "inspection", "accent_comparison.html")
    generate_inspection_html(out)
end
