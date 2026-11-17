# SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
# Copyright (c) 2021-2026 Neal McKee. All rights reserved.

"""
generate_geometry_figure.jl

Generates the two-panel Penumbra construction diagram (`docs/penumbra_geometry.svg` and
2× retina `docs/penumbra_geometry.png`) directly from the CAM16-UCS solvers in `src/`:
- Panel A: Daylight trajectory (`BaseColorCurve`) decomposed into vertical lightness (J' 0–100)
  and horizontal daylight CCT, marking standard illuminants (Shade, Daylight, Sunlight).
- Panel B: Exact sRGB gamut slice at `sky` lightness in CAM16-UCS (a', b'), showing the
  faint inscribed circle vs. the rotated N = 8 octagon.
"""

using Colors: XYZ, xyY, RGB, hex
using Printf: @sprintf

include(joinpath(@__DIR__, "..", "src", "accent_palette.jl"))

function _clamp_rgb_hex(xyz::XYZ)
    rgb = convert(RGB, xyz)
    r = clamp(rgb.r, 0.0, 1.0)
    g = clamp(rgb.g, 0.0, 1.0)
    b = clamp(rgb.b, 0.0, 1.0)
    return "#" * lowercase(string(hex(RGB(r, g, b))))
end

function build_geometry_svg()
    sol = solve_base_palette()
    tones_all = base_palette_tones(sol)
    tones_bal = filter(t -> t.tier == :balanced, tones_all)
    order = ["shade-", "shade", "shade+", "sky-", "sky", "sky+", "sun-", "sun", "sun+"]
    tones_bal = [only(filter(t -> t.name == nm, tones_bal)) for nm in order]

    j_sky_dark = only(filter(t -> t.name == "sky", tones_bal)).J_dark
    pal8 = optimize_accent_palette(8, j_sky_dark, sol.env_dark; alpha=1.0)

    # Canvas geometry (logical 920x440 -> rendered 1840x880 @ 2x)
    W, H = 920, 440
    bg_page = "#ffffff"
    ink_dark = "#222222"
    ink_muted = "#666666"
    hairline = "#d8d8d8"
    bar_border = "#cccccc"

    svg = String[]
    push!(svg, """<?xml version="1.0" encoding="UTF-8"?>""")
    push!(svg, """<svg width="$W" height="$H" viewBox="0 0 $W $H" xmlns="http://www.w3.org/2000/svg">""")
    push!(svg, """  <rect width="$W" height="$H" fill="$bg_page" />""")

    # -------------------------------------------------------------------------
    # PANEL A (Left): Daylight Curve (J' 0..100 vs Mired CCT) — Tufte minimal
    # -------------------------------------------------------------------------
    ax_x0, ax_x1 = 76.0, 416.0   # plot span X
    ax_y0, ax_y1 = 56.0, 366.0   # plot span Y (y0 = J'=100, y1 = J'=0)
    bar_w = 16.0
    bar_h = 16.0
    lbar_x = ax_x0 - 26.0
    cbar_y = ax_y1 + 12.0

    mu_min = 108.0               # ~9259 K (cool)
    mu_max = 196.0               # ~5102 K (warm)
    map_x(mu) = ax_x0 + (mu - mu_min) / (mu_max - mu_min) * (ax_x1 - ax_x0)
    map_y(j)  = ax_y1 - (j / 100.0) * (ax_y1 - ax_y0)

    push!(svg, """  <text x="$(0.5*(ax_x0+ax_x1))" y="30" text-anchor="middle" fill="$ink_dark" font-family="'Fira Sans', sans-serif" font-size="14.5">Daylight Base Trajectory</text>""")

    # 1. Left Lightness Bar (J' 0..100, neutral D65)
    n_lsteps = 120
    for i in 0:(n_lsteps - 1)
        j0 = 100.0 * i / n_lsteps
        j1 = 100.0 * (i + 1) / n_lsteps
        jm = 0.5 * (j0 + j1)
        Y = luminance_for_cam16ucs_j(_WP_D65.x, _WP_D65.y, jm, VE)
        hx = _clamp_rgb_hex(convert(XYZ, xyY(_WP_D65.x, _WP_D65.y, Y)))
        y_top = map_y(j1)
        y_bot = map_y(j0)
        push!(svg, @sprintf("  <rect x=\"%.2f\" y=\"%.2f\" width=\"%.2f\" height=\"%.2f\" fill=\"%s\" />",
                            lbar_x, y_top, bar_w, (y_bot - y_top) + 0.6, hx))
    end
    push!(svg, """  <rect x="$lbar_x" y="$ax_y0" width="$bar_w" height="$(ax_y1-ax_y0)" fill="none" stroke="$bar_border" stroke-width="0.9" />""")

    # 2. Bottom CCT Bar (CIE daylight locus at constant lightness J'=82)
    n_csteps = 140
    for i in 0:(n_csteps - 1)
        m0 = mu_min + (mu_max - mu_min) * i / n_csteps
        m1 = mu_min + (mu_max - mu_min) * (i + 1) / n_csteps
        mm = 0.5 * (m0 + m1)
        T = 1e6 / mm
        xd, yd = daylight_chromaticity(T)
        Y = luminance_for_cam16ucs_j(xd, yd, 82.0, VE)
        hx = _clamp_rgb_hex(convert(XYZ, xyY(xd, yd, Y)))
        x_l = map_x(m0)
        x_r = map_x(m1)
        push!(svg, @sprintf("  <rect x=\"%.2f\" y=\"%.2f\" width=\"%.2f\" height=\"%.2f\" fill=\"%s\" />",
                            x_l, cbar_y, (x_r - x_l) + 0.6, bar_h, hx))
    end
    push!(svg, """  <rect x="$ax_x0" y="$cbar_y" width="$(ax_x1-ax_x0)" height="$bar_h" fill="none" stroke="$bar_border" stroke-width="0.9" />""")

    # 3. Standard illuminant guides (Shade, Daylight / D65, Sunlight / 5772 K)
    t_shade = only(filter(t -> t.name == "shade", tones_bal))
    t_sky   = only(filter(t -> t.name == "sky", tones_bal))
    t_sunp  = only(filter(t -> t.name == "sun+", tones_bal))
    illuminants = [
        ("Shade",    1e6 / t_shade.T_cct, t_shade.J_base),
        ("Daylight", 1e6 / t_sky.T_cct,   t_sky.J_base),
        ("Sunlight", 1e6 / t_sunp.T_cct,  t_sunp.J_base),
    ]
    for (lbl, mu_i, j_i) in illuminants
        xi = map_x(mu_i)
        yi = map_y(j_i)
        push!(svg, @sprintf("  <line x1=\"%.2f\" y1=\"%.2f\" x2=\"%.2f\" y2=\"%.2f\" stroke=\"%s\" stroke-width=\"0.9\" stroke-dasharray=\"2.5,3\" />",
                            xi, yi, xi, cbar_y, hairline))
        push!(svg, @sprintf("  <line x1=\"%.2f\" y1=\"%.2f\" x2=\"%.2f\" y2=\"%.2f\" stroke=\"%s\" stroke-width=\"1.1\" />",
                            xi, cbar_y + bar_h, xi, cbar_y + bar_h + 4.5, ink_dark))
        push!(svg, @sprintf("  <text x=\"%.2f\" y=\"%.2f\" text-anchor=\"middle\" fill=\"%s\" font-family=\"'Fira Sans', sans-serif\" font-size=\"11\">%s</text>",
                            xi, cbar_y + bar_h + 18, ink_muted, lbl))
    end

    # 4. Continuous BaseColorCurve trajectory from shade- to sun+
    j_lo = tones_bal[1].J_base
    j_hi = tones_bal[end].J_base
    curve_pts = String[]
    for k in 0:100
        jk = j_lo + (j_hi - j_lo) * (k / 100.0)
        mu_k = sol.curve.k_mu * (jk - sol.curve.J_sky) + MIRED_D65
        push!(curve_pts, @sprintf("%.2f,%.2f", map_x(mu_k), map_y(jk)))
    end
    push!(svg, """  <polyline points="$(join(curve_pts, " "))" fill="none" stroke="#666666" stroke-width="1.5" />""")

    # 5. Step tick marks on both bars + outlined scatterpoints
    for t in tones_bal
        mu_t = 1e6 / t.T_cct
        xt = map_x(mu_t)
        yt = map_y(t.J_base)
        push!(svg, @sprintf("  <line x1=\"%.2f\" y1=\"%.2f\" x2=\"%.2f\" y2=\"%.2f\" stroke=\"%s\" stroke-width=\"1.0\" />",
                            lbar_x + bar_w, yt, lbar_x + bar_w + 4.5, yt, ink_dark))
        push!(svg, @sprintf("  <line x1=\"%.2f\" y1=\"%.2f\" x2=\"%.2f\" y2=\"%.2f\" stroke=\"%s\" stroke-width=\"1.0\" />",
                            xt, cbar_y - 4.5, xt, cbar_y, ink_dark))
        push!(svg, @sprintf("  <circle cx=\"%.2f\" cy=\"%.2f\" r=\"5.2\" fill=\"#%s\" stroke=\"%s\" stroke-width=\"1.2\" />",
                            xt, yt, lowercase(t.hex), ink_dark))
    end

    # -------------------------------------------------------------------------
    # PANEL B (Right): sRGB Gamut Slice, Faint Inscribed Circle & N=8 Octagon
    # -------------------------------------------------------------------------
    box_x0, box_x1 = 488.0, 888.0
    box_y0, box_y1 = 56.0, 386.0

    push!(svg, """  <text x="$(0.5*(box_x0+box_x1))" y="30" text-anchor="middle" fill="$ink_dark" font-family="'Fira Sans', sans-serif" font-size="14.5">Accent Octagon in CAM16-UCS</text>""")

    # Exact 1-degree sRGB gamut boundary at j_sky_dark
    n_h = 360
    gamut_pts = Vector{Tuple{Float64, Float64, Float64, String}}(undef, n_h)
    min_a, max_a = Inf, -Inf
    min_b, max_b = Inf, -Inf
    for deg in 0:(n_h - 1)
        h = Float64(deg)
        c_max = max_gamut_chroma(j_sky_dark, h, sol.env_dark; alpha=1.0, max_iters=45)
        a_p = c_max * cosd(h)
        b_p = c_max * sind(h)
        min_a, max_a = min(min_a, a_p), max(max_a, a_p)
        min_b, max_b = min(min_b, b_p), max(max_b, b_p)
        j_ach = cam16ucs_hk_inverse_lightness(j_sky_dark, c_max, h; alpha=1.0)
        xyz = convert(XYZ, CAM16UCSJCh(j_ach, c_max, h, sol.env_dark))
        hx = _clamp_rgb_hex(xyz)
        gamut_pts[deg + 1] = (h, a_p, b_p, hx)
    end

    pad_frac = 0.86
    scale_ab = min((box_x1 - box_x0) * pad_frac / (max_a - min_a),
                   (box_y1 - box_y0) * pad_frac / (max_b - min_b))
    bx_cx = 0.5 * (box_x0 + box_x1) - 0.5 * (min_a + max_a) * scale_ab
    bx_cy = 0.5 * (box_y0 + box_y1) + 0.5 * (min_b + max_b) * scale_ab
    to_px(a_p, b_p) = (bx_cx + a_p * scale_ab, bx_cy - b_p * scale_ab)

    # Short neutral crosshairs clipped comfortably around gamut bounds
    ch_x0, _ = to_px(min_a - 4.0, 0.0)
    ch_x1, _ = to_px(max_a + 4.0, 0.0)
    _, ch_y1 = to_px(0.0, min_b - 4.0)
    _, ch_y0 = to_px(0.0, max_b + 4.0)
    push!(svg, @sprintf("  <line x1=\"%.2f\" y1=\"%.2f\" x2=\"%.2f\" y2=\"%.2f\" stroke=\"%s\" stroke-width=\"0.9\" />",
                        ch_x0, bx_cy, ch_x1, bx_cy, hairline))
    push!(svg, @sprintf("  <line x1=\"%.2f\" y1=\"%.2f\" x2=\"%.2f\" y2=\"%.2f\" stroke=\"%s\" stroke-width=\"0.9\" />",
                        bx_cx, ch_y0, bx_cx, ch_y1, hairline))

    # Subtle low-alpha radial wash inside the sRGB gamut polygon
    push!(svg, """  <defs>""")
    for deg in 0:(n_h - 1)
        _, a1, b1, hx1 = gamut_pts[deg + 1]
        px1, py1 = to_px(a1, b1)
        push!(svg, @sprintf("    <linearGradient id=\"g%d\" gradientUnits=\"userSpaceOnUse\" x1=\"%.2f\" y1=\"%.2f\" x2=\"%.2f\" y2=\"%.2f\">",
                            deg, bx_cx, bx_cy, px1, py1))
        push!(svg, """      <stop offset="0%" stop-color="#ffffff" stop-opacity="0" />""")
        push!(svg, """      <stop offset="100%" stop-color="$hx1" stop-opacity="0.16" />""")
        push!(svg, """    </linearGradient>""")
    end
    push!(svg, """  </defs>""")

    for deg in 0:(n_h - 1)
        nxt = mod(deg + 1, n_h)
        _, a1, b1, _ = gamut_pts[deg + 1]
        _, a2, b2, _ = gamut_pts[nxt + 1]
        x1, y1 = to_px(a1, b1)
        x2, y2 = to_px(a2, b2)
        push!(svg, @sprintf("  <polygon points=\"%.2f,%.2f %.2f,%.2f %.2f,%.2f\" fill=\"url(#g%d)\" />",
                            bx_cx, bx_cy, x1, y1, x2, y2, deg))
    end

    # Colored sRGB gamut boundary perimeter stroke
    for deg in 0:(n_h - 1)
        nxt = mod(deg + 1, n_h)
        _, a1, b1, hx1 = gamut_pts[deg + 1]
        _, a2, b2, _   = gamut_pts[nxt + 1]
        x1, y1 = to_px(a1, b1)
        x2, y2 = to_px(a2, b2)
        push!(svg, @sprintf("  <line x1=\"%.2f\" y1=\"%.2f\" x2=\"%.2f\" y2=\"%.2f\" stroke=\"%s\" stroke-width=\"2.2\" stroke-linecap=\"round\" />",
                            x1, y1, x2, y2, hx1))
    end

    # Faint inscribed circle
    r_inscr = pal8.C_inscribed * scale_ab
    push!(svg, @sprintf("  <circle cx=\"%.2f\" cy=\"%.2f\" r=\"%.2f\" fill=\"none\" stroke=\"#999999\" stroke-width=\"1.0\" stroke-dasharray=\"3,3\" />",
                        bx_cx, bx_cy, r_inscr))

    # Faint rotated N=8 octagon edges
    oct_pts = String[]
    for t in pal8.tones
        px, py = to_px(t.C_ucs * cosd(t.h), t.C_ucs * sind(t.h))
        push!(oct_pts, @sprintf("%.2f,%.2f", px, py))
    end
    push!(svg, """  <polygon points="$(join(oct_pts, " "))" fill="none" stroke="#666666" stroke-width="1.1" />""")

    # Center neutral sky reference point
    push!(svg, @sprintf("  <circle cx=\"%.2f\" cy=\"%.2f\" r=\"3.2\" fill=\"#%s\" stroke=\"%s\" stroke-width=\"1.0\" />",
                        bx_cx, bx_cy, lowercase(only(filter(t -> t.name == "sky", tones_bal)).hex), ink_dark))

    # 8 Accent vertices with crisp neutral outlines
    for t in pal8.tones
        px, py = to_px(t.C_ucs * cosd(t.h), t.C_ucs * sind(t.h))
        push!(svg, @sprintf("  <circle cx=\"%.2f\" cy=\"%.2f\" r=\"6.4\" fill=\"#%s\" stroke=\"%s\" stroke-width=\"1.3\" />",
                            px, py, lowercase(t.hex), ink_dark))
    end

    push!(svg, """</svg>""")
    return join(svg, "\n")
end

function main()
    root_dir = joinpath(@__DIR__, "..")
    docs_dir = joinpath(root_dir, "docs")
    fonts_dir = joinpath(root_dir, "fonts")

    svg_path = joinpath(docs_dir, "penumbra_geometry.svg")
    png_path = joinpath(docs_dir, "penumbra_geometry.png")

    svg_content = build_geometry_svg()
    write(svg_path, svg_content)
    println("  [GENERATED] $svg_path")

    cmd = isdir(fonts_dir) ? `resvg --use-fonts-dir $fonts_dir --zoom 2 $svg_path $png_path` : `resvg --zoom 2 $svg_path $png_path`
    run(cmd)
    println("  [RENDERED]  $png_path")
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
