# SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
# Copyright (c) 2021-2026 Neal McKee. All rights reserved.

"""
generate_downstream_ports.jl

Deterministic generator for auxiliary editor, terminal, and AI CLI theme ports:
1. OhMyREPL.jl: `OhMyREPL.jl/Penumbra.jl`
2. Vim / Neovim: `vim/penumbra_*.vim`
3. Helix: `helix/themes/penumbra_*.toml`
4. iTerm2: `iTerm2/penumbra_*.itermcolors`
5. Ghostty: `ghostty/themes/penumbra_*`
6. Alacritty: `alacritty/penumbra_*.toml`
7. Kitty: `kitty/penumbra_*.conf`
8. Windows Terminal: `windows-terminal/penumbra.json`
9. CSS Custom Properties: `css/penumbra.css`
10. GIMP / Inkscape / Krita Palettes: `gpl/penumbra_*.gpl`, `gpl/penumbra.gpl`
11. WezTerm: `wezterm/colors/penumbra_*.toml`
12. Warp: `warp/themes/penumbra_*.yaml`
13. TextMate / bat / git-delta / Codex CLI: `tmtheme/penumbra_*.tmTheme`
14. Codex Desktop App: `codex/penumbra_*.txt`
15. Claude Code CLI: `claude-code/penumbra_*.json`
16. Base16 (tinted-theming): `base16/penumbra_*.yaml`

Generates clean, verified configurations based on the solved v2 base and accent palettes.
"""

using Printf
using JSON: JSON
using Colors: RGB, XYZ, Colorant, parse, colordiff

include(joinpath(@__DIR__, "..", "src", "palette_io.jl"))

const BASE_TONES, ACCENTS = load_palettes(joinpath(@__DIR__, ".."))

# =============================================================================
# Common Terminal ANSI 16-Color Data Model
# =============================================================================

struct TerminalAnsiPalette
    bg::String
    fg::String
    cursor::String
    cursor_text::String
    selection_bg::String
    selection_fg::String
    black::String
    red::String
    green::String
    yellow::String
    blue::String
    magenta::String
    cyan::String
    white::String
    bright_black::String
    bright_red::String
    bright_green::String
    bright_yellow::String
    bright_blue::String
    bright_magenta::String
    bright_cyan::String
    bright_white::String
end

function get_terminal_ansi_palette(mode::Symbol, tier::Symbol; ansi_n::Int=6)
    is_dark = mode == :dark
    base = BASE_TONES[tier]
    acc = ACCENTS[mode][tier][ansi_n]

    bg = is_dark ? base["shade"] : base["sun"]
    fg = base["sky"]
    cursor = is_dark ? base["sun"] : base["shade"]
    cursor_text = bg
    sel_bg = is_dark ? base["shade+"] : base["sun-"]
    sel_fg = fg

    # ANSI color roles (matches VSCode terminal.ansiBlack/White/Bright*)
    black = is_dark ? base["shade-"] : base["sun-"]
    white = is_dark ? base["sun"] : base["shade"]
    bright_black = is_dark ? base["sky-"] : base["sky+"]
    bright_white = is_dark ? base["sun+"] : base["shade-"]

    return TerminalAnsiPalette(
        bg, fg, cursor, cursor_text, sel_bg, sel_fg,
        black, acc["red"], acc["green"], acc["yellow"], acc["blue"], acc["magenta"], acc["cyan"], white,
        bright_black, acc["red"], acc["green"], acc["yellow"], acc["blue"], acc["magenta"], acc["cyan"], bright_white
    )
end

function tier_suffix(tier::Symbol)
    tier == :balanced ? "" : (tier == :contrast_plus ? "+" : "++")
end

# =============================================================================
# 1. Julia REPL (OhMyREPL.jl)
# =============================================================================

function generate_ohmyrepl_theme(mode::Symbol, tier::Symbol; target_path::String, dry_run::Bool=true)
    is_dark = mode == :dark
    base = BASE_TONES[tier]
    acc = ACCENTS[mode][tier][8]

    scheme_name = if is_dark
        tier == :balanced ? "Penumbra" : (tier == :contrast_plus ? "Penumbra Dark+" : "Penumbra Dark++")
    else
        "Penumbra Light"
    end

    fg_comment = is_dark ? base["sky-"] : base["sky+"]

    content = """# SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
# Copyright (c) 2021-2026 Neal McKee. All rights reserved.
#
# To install in Julia REPL:
# ] add OhMyREPL Crayons
# Then add to ~/.julia/config/startup.jl:

try
    @eval using OhMyREPL
    @eval using Crayons

    import OhMyREPL: Passes.SyntaxHighlighter

    # $scheme_name (CAM16-UCS Opponent Scheme, N = 8)
    penumbra = SyntaxHighlighter.ColorScheme()
    SyntaxHighlighter.symbol!(penumbra, crayon"#$(acc["magenta"])")
    SyntaxHighlighter.comment!(penumbra, crayon"#$fg_comment")
    SyntaxHighlighter.string!(penumbra, crayon"#$(acc["green"])")
    SyntaxHighlighter.call!(penumbra, crayon"#$(acc["blue"])")
    SyntaxHighlighter.op!(penumbra, crayon"#$(acc["cyan"])")
    SyntaxHighlighter.keyword!(penumbra, crayon"#$(acc["purple"])")
    SyntaxHighlighter.function_def!(penumbra, crayon"#$(acc["blue"])")
    SyntaxHighlighter.error!(penumbra, crayon"#$(acc["red"])")
    SyntaxHighlighter.argdef!(penumbra, crayon"#$(acc["yellow"])")
    SyntaxHighlighter.macro!(penumbra, crayon"#$(acc["red"])")
    SyntaxHighlighter.number!(penumbra, crayon"#$(acc["orange"])")
    SyntaxHighlighter.text!(penumbra, crayon"#$(base["sky"])")

    SyntaxHighlighter.add!("$scheme_name", penumbra)
    colorscheme!("$scheme_name")
catch e
    @warn "Error configuring OhMyREPL $scheme_name scheme" e
end
"""
    if dry_run
        println("  [DRY RUN] OhMyREPL theme ($scheme_name) target: $target_path ($(sizeof(content)) bytes)")
    else
        mkpath(dirname(target_path))
        write(target_path, content)
        println("  [WRITTEN] $target_path")
    end
end

function generate_ohmyrepl(; dry_run::Bool=true)
    generate_ohmyrepl_theme(:dark, :balanced; target_path=joinpath(@__DIR__, "..", "OhMyREPL.jl", "Penumbra.jl"), dry_run=dry_run)
    generate_ohmyrepl_theme(:dark, :contrast_plus; target_path=joinpath(@__DIR__, "..", "OhMyREPL.jl", "Penumbra_Dark+.jl"), dry_run=dry_run)
    generate_ohmyrepl_theme(:dark, :contrast_plus_plus; target_path=joinpath(@__DIR__, "..", "OhMyREPL.jl", "Penumbra_Dark++.jl"), dry_run=dry_run)
    generate_ohmyrepl_theme(:light, :balanced; target_path=joinpath(@__DIR__, "..", "OhMyREPL.jl", "Penumbra_Light.jl"), dry_run=dry_run)
end

# =============================================================================
# 2. Vim / Neovim
# =============================================================================

const _XTERM256_PALETTE = let
    steps = (0, 95, 135, 175, 215, 255)
    pal = Vector{Tuple{Int,RGB{Float64}}}(undef, 240)
    idx = 1
    for r in steps, g in steps, b in steps
        pal[idx] = (15 + idx, RGB{Float64}(r / 255, g / 255, b / 255))
        idx += 1
    end
    for i in 0:23
        v = (8 + 10 * i) / 255
        pal[idx] = (232 + i, RGB{Float64}(v, v, v))
        idx += 1
    end
    pal
end

const _XTERM256_CACHE = Dict{String,Int}()

function _hex_to_xterm256(hex::AbstractString)
    key = uppercase(hex)
    return get!(_XTERM256_CACHE, key) do
        c = parse(RGB{Float64}, "#" * key)
        best_idx = 16
        best_dist = Inf
        for (xterm_idx, ref) in _XTERM256_PALETTE
            d = colordiff(c, ref)
            if d < best_dist
                best_dist = d
                best_idx = xterm_idx
            end
        end
        best_idx
    end
end

function _vim_hi(group::String, fg::String, bg::String="NONE";
                 gui::String="NONE", cterm::String=gui, guisp::String="")
    g_fg = fg == "NONE" ? "NONE" : "#" * fg
    g_bg = bg == "NONE" ? "NONE" : "#" * bg
    c_fg = fg == "NONE" ? "NONE" : string(_hex_to_xterm256(fg))
    c_bg = bg == "NONE" ? "NONE" : string(_hex_to_xterm256(bg))
    sp_part = isempty(guisp) ? "" : " guisp=#$guisp"
    return @sprintf("hi %-17s guifg=%-7s guibg=%-7s%s gui=%s ctermfg=%-4s ctermbg=%-4s cterm=%s",
                    group, g_fg, g_bg, sp_part, gui, c_fg, c_bg, cterm)
end

function generate_vim_theme(mode::Symbol, tier::Symbol; target_path::String, dry_run::Bool=true)
    is_dark = mode == :dark
    base = BASE_TONES[tier]
    acc = ACCENTS[mode][tier][8]
    p = get_terminal_ansi_palette(mode, tier)

    bg_canvas = is_dark ? base["shade"] : base["sun"]
    bg_low = is_dark ? base["shade+"] : base["sun-"]
    bg_high = is_dark ? base["shade-"] : base["sun+"]
    bg_elevated = is_dark ? base["shade+"] : base["sun-"]
    fg_text = base["sky"]
    fg_comment = is_dark ? base["sky-"] : base["sky+"]
    fg_heading = is_dark ? base["sky+"] : base["sky-"]
    canvas_opp = is_dark ? base["sun"] : base["shade"]

    bg_cursorline = is_dark ? _blend_hex(bg_canvas, canvas_opp, 0.025) : _blend_hex(bg_canvas, canvas_opp, 0.10)
    bg_visual = is_dark ? _blend_hex(bg_canvas, canvas_opp, 0.065) : _blend_hex(bg_canvas, canvas_opp, 0.20)
    bg_search = is_dark ? _blend_hex(bg_canvas, acc["orange"], 0.14) : _blend_hex(bg_canvas, acc["orange"], 0.25)
    bg_incsearch = is_dark ? _blend_hex(bg_canvas, acc["orange"], 0.26) : _blend_hex(bg_canvas, acc["orange"], 0.42)
    bg_diff_add = is_dark ? _blend_hex(bg_canvas, acc["green"], 0.08) : _blend_hex(bg_canvas, acc["green"], 0.15)
    bg_diff_change = is_dark ? _blend_hex(bg_canvas, acc["blue"], 0.08) : _blend_hex(bg_canvas, acc["blue"], 0.15)
    bg_diff_delete = is_dark ? _blend_hex(bg_canvas, acc["red"], 0.08) : _blend_hex(bg_canvas, acc["red"], 0.15)
    bg_diff_text = is_dark ? _blend_hex(bg_canvas, acc["blue"], 0.18) : _blend_hex(bg_canvas, acc["blue"], 0.30)

    slug = _theme_slug(mode, tier)
    bg_setting = is_dark ? "dark" : "light"

    ui_lines = [
        _vim_hi("Normal", fg_text, bg_canvas),
        _vim_hi("NormalNC", fg_text, bg_canvas),
        _vim_hi("NormalFloat", fg_text, bg_low),
        _vim_hi("FloatBorder", fg_comment, bg_low),
        _vim_hi("Terminal", fg_text, bg_canvas),
        _vim_hi("ColorColumn", "NONE", bg_low),
        _vim_hi("Conceal", fg_comment, "NONE"),
        _vim_hi("Cursor", bg_canvas, canvas_opp),
        _vim_hi("CursorColumn", "NONE", bg_cursorline),
        _vim_hi("CursorLine", "NONE", bg_cursorline),
        _vim_hi("CursorLineNr", fg_heading, bg_cursorline),
        _vim_hi("CursorIM", bg_canvas, acc["yellow"]),
        _vim_hi("Directory", acc["blue"], "NONE"),
        _vim_hi("DiffAdd", acc["green"], bg_diff_add),
        _vim_hi("DiffChange", acc["blue"], bg_diff_change),
        _vim_hi("DiffDelete", acc["red"], bg_diff_delete),
        _vim_hi("DiffText", fg_heading, bg_diff_text; gui="bold", cterm="bold"),
        _vim_hi("EndOfBuffer", bg_elevated, "NONE"),
        _vim_hi("ErrorMsg", acc["red"], bg_canvas),
        _vim_hi("FoldColumn", fg_comment, bg_canvas),
        _vim_hi("Folded", fg_comment, bg_low),
        _vim_hi("IncSearch", fg_heading, bg_incsearch; gui="bold", cterm="bold"),
        _vim_hi("LineNr", fg_comment, bg_canvas),
        _vim_hi("MatchParen", fg_heading, bg_elevated; gui="bold", cterm="bold"),
        _vim_hi("ModeMsg", acc["blue"], "NONE"),
        _vim_hi("MoreMsg", acc["blue"], "NONE"),
        _vim_hi("NonText", bg_elevated, "NONE"),
        _vim_hi("Pmenu", fg_text, bg_low),
        _vim_hi("PmenuSbar", "NONE", bg_low),
        _vim_hi("PmenuSel", fg_heading, bg_high; gui="bold", cterm="bold"),
        _vim_hi("PmenuThumb", "NONE", fg_comment),
        _vim_hi("Question", acc["cyan"], "NONE"),
        _vim_hi("QuickFixLine", "NONE", bg_visual),
        _vim_hi("Search", fg_heading, bg_search),
        _vim_hi("SignColumn", fg_comment, bg_canvas),
        _vim_hi("SpecialKey", fg_comment, "NONE"),
        _vim_hi("SpellBad", "NONE", "NONE"; gui="undercurl", cterm="underline", guisp=acc["red"]),
        _vim_hi("SpellCap", "NONE", "NONE"; gui="undercurl", cterm="underline", guisp=acc["blue"]),
        _vim_hi("SpellLocal", "NONE", "NONE"; gui="undercurl", cterm="underline", guisp=acc["cyan"]),
        _vim_hi("SpellRare", "NONE", "NONE"; gui="undercurl", cterm="underline", guisp=acc["purple"]),
        _vim_hi("StatusLine", fg_heading, bg_low),
        _vim_hi("StatusLineNC", fg_comment, bg_low),
        _vim_hi("TabLine", fg_text, bg_low),
        _vim_hi("TabLineFill", fg_comment, bg_low),
        _vim_hi("TabLineSel", fg_heading, bg_canvas; gui="bold", cterm="bold"),
        _vim_hi("Title", fg_heading, "NONE"; gui="bold", cterm="bold"),
        _vim_hi("VertSplit", bg_low, bg_low),
        _vim_hi("WinSeparator", bg_low, bg_low),
        _vim_hi("Visual", "NONE", bg_visual),
        _vim_hi("VisualNOS", "NONE", bg_visual),
        _vim_hi("WarningMsg", acc["orange"], "NONE"),
        _vim_hi("WildMenu", fg_heading, bg_high; gui="bold", cterm="bold"),
        _vim_hi("WinBar", fg_heading, bg_canvas),
        _vim_hi("WinBarNC", fg_comment, bg_canvas),
    ]

    syntax_lines = [
        _vim_hi("Comment", fg_comment),
        _vim_hi("Constant", acc["orange"]),
        _vim_hi("String", acc["green"]),
        _vim_hi("Character", acc["green"]),
        _vim_hi("Identifier", fg_text),
        _vim_hi("Function", acc["blue"]),
        _vim_hi("Statement", acc["purple"]),
        _vim_hi("Operator", acc["cyan"]),
        _vim_hi("PreProc", acc["red"]),
        _vim_hi("Type", acc["yellow"]),
        _vim_hi("Special", acc["magenta"]),
        _vim_hi("Delimiter", fg_text),
        _vim_hi("Underlined", acc["blue"]; gui="underline", cterm="underline"),
        _vim_hi("Ignore", fg_comment),
        _vim_hi("Error", acc["red"], bg_canvas),
        _vim_hi("Todo", acc["yellow"], bg_canvas; gui="bold", cterm="bold"),
    ]

    term_colors = [
        p.black, p.red, p.green, p.yellow, p.blue, p.magenta, p.cyan, p.white,
        p.bright_black, p.bright_red, p.bright_green, p.bright_yellow,
        p.bright_blue, p.bright_magenta, p.bright_cyan, p.bright_white,
    ]
    term_vim_list = join(["'#" * c * "'" for c in term_colors], ", ")
    term_nvim_lines = join(["  let g:terminal_color_$(i - 1) = '#$(term_colors[i])'" for i in 1:16], "\n")

    nvim_diag_lines = [
        _vim_hi("DiagnosticError", acc["red"]),
        _vim_hi("DiagnosticWarn", acc["orange"]),
        _vim_hi("DiagnosticInfo", acc["blue"]),
        _vim_hi("DiagnosticHint", acc["cyan"]),
        _vim_hi("DiagnosticOk", acc["green"]),
        _vim_hi("DiagnosticUnderlineError", "NONE"; gui="undercurl", cterm="underline", guisp=acc["red"]),
        _vim_hi("DiagnosticUnderlineWarn", "NONE"; gui="undercurl", cterm="underline", guisp=acc["orange"]),
        _vim_hi("DiagnosticUnderlineInfo", "NONE"; gui="undercurl", cterm="underline", guisp=acc["blue"]),
        _vim_hi("DiagnosticUnderlineHint", "NONE"; gui="undercurl", cterm="underline", guisp=acc["cyan"]),
        _vim_hi("DiagnosticUnderlineOk", "NONE"; gui="undercurl", cterm="underline", guisp=acc["green"]),
    ]

    fg16_heading = is_dark ? "15" : "8"
    fg16_comment = "8"
    bg16_chrome = is_dark ? "0" : "7"
    fg16_sel = is_dark ? "0" : "0"
    bg16_sel = is_dark ? "7" : "3"

    content = """\" Penumbra v2 -- Vim / Neovim color scheme
\" Theme: $slug (Mode: $mode, Tier: $tier)
\" Opponent Scheme: N = 8 (Strict Upright Typography)
\" Generated deterministically by Penumbra v2 pipeline.

set background=$bg_setting

hi clear
if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "$slug"

" ---------------------------------------------------------------------------
" Highlight Group Links
" ---------------------------------------------------------------------------
hi! link Number           Constant
hi! link Boolean          Constant
hi! link Float            Constant
hi! link Conditional      Statement
hi! link Repeat           Statement
hi! link Label            Statement
hi! link Keyword          Statement
hi! link Exception        Statement
hi! link Include          PreProc
hi! link Define           PreProc
hi! link Macro            PreProc
hi! link PreCondit        PreProc
hi! link StorageClass     Type
hi! link Structure        Type
hi! link Typedef          Type
hi! link SpecialChar      Special
hi! link Tag              Special
hi! link Debug            Special
hi! link SpecialComment   Comment
hi! link CurSearch        IncSearch
hi! link lCursor          Cursor
hi! link PopupSelected    PmenuSel
hi! link StatusLineTerm   StatusLine
hi! link StatusLineTermNC StatusLineNC
hi! link Whitespace       NonText
hi! link Added            DiffAdd
hi! link Changed          DiffChange
hi! link Removed          DiffDelete

" ---------------------------------------------------------------------------
" UI & Editor Canvas (GUI / termguicolors / xterm-256color)
" ---------------------------------------------------------------------------
$(join(ui_lines, "\n"))

" ---------------------------------------------------------------------------
" Syntax Groups (Strict Upright Roman)
" ---------------------------------------------------------------------------
$(join(syntax_lines, "\n"))

" ---------------------------------------------------------------------------
" 16-Color / 8-Color Terminal Fallback (assumes Penumbra terminal palette)
" ---------------------------------------------------------------------------
if !has('gui_running') && !(has('termguicolors') && &termguicolors) && &t_Co < 256
  hi Normal       ctermfg=NONE          ctermbg=NONE         cterm=NONE
  hi Terminal     ctermfg=NONE          ctermbg=NONE         cterm=NONE
  hi ColorColumn  ctermfg=NONE          ctermbg=$bg16_chrome cterm=NONE
  hi CursorLine   ctermfg=NONE          ctermbg=$bg16_chrome cterm=NONE
  hi CursorLineNr ctermfg=$fg16_heading ctermbg=$bg16_chrome cterm=NONE
  hi LineNr       ctermfg=$fg16_comment ctermbg=NONE         cterm=NONE
  hi NonText      ctermfg=$fg16_comment ctermbg=NONE         cterm=NONE
  hi StatusLine   ctermfg=$fg16_heading ctermbg=$bg16_chrome cterm=NONE
  hi StatusLineNC ctermfg=$fg16_comment ctermbg=$bg16_chrome cterm=NONE
  hi TabLine      ctermfg=NONE          ctermbg=$bg16_chrome cterm=NONE
  hi TabLineFill  ctermfg=$fg16_comment ctermbg=$bg16_chrome cterm=NONE
  hi TabLineSel   ctermfg=$fg16_heading ctermbg=NONE         cterm=bold
  hi Pmenu        ctermfg=NONE          ctermbg=$bg16_chrome cterm=NONE
  hi PmenuSbar    ctermfg=NONE          ctermbg=$bg16_chrome cterm=NONE
  hi PmenuSel     ctermfg=$fg16_sel     ctermbg=$bg16_sel    cterm=bold
  hi PmenuThumb   ctermfg=NONE          ctermbg=$fg16_comment cterm=NONE
  hi VertSplit    ctermfg=$bg16_chrome  ctermbg=$bg16_chrome cterm=NONE
  hi Visual       ctermfg=NONE          ctermbg=NONE         cterm=reverse
  hi VisualNOS    ctermfg=NONE          ctermbg=NONE         cterm=reverse
  hi Search       ctermfg=0             ctermbg=3            cterm=NONE
  hi IncSearch    ctermfg=0             ctermbg=3            cterm=bold
  hi MatchParen   ctermfg=$fg16_heading ctermbg=$bg16_chrome cterm=bold
  hi DiffAdd      ctermfg=2             ctermbg=NONE         cterm=NONE
  hi DiffChange   ctermfg=4             ctermbg=NONE         cterm=NONE
  hi DiffDelete   ctermfg=1             ctermbg=NONE         cterm=NONE
  hi DiffText     ctermfg=15            ctermbg=4            cterm=bold
  hi Directory    ctermfg=4             ctermbg=NONE         cterm=NONE
  hi ErrorMsg     ctermfg=1             ctermbg=NONE         cterm=NONE
  hi WarningMsg   ctermfg=3             ctermbg=NONE         cterm=NONE
  hi ModeMsg      ctermfg=4             ctermbg=NONE         cterm=NONE
  hi MoreMsg      ctermfg=4             ctermbg=NONE         cterm=NONE
  hi Question     ctermfg=6             ctermbg=NONE         cterm=NONE
  hi Title        ctermfg=$fg16_heading ctermbg=NONE         cterm=bold
  hi WildMenu     ctermfg=$fg16_sel     ctermbg=$bg16_sel    cterm=bold
  hi Comment      ctermfg=$fg16_comment ctermbg=NONE         cterm=NONE
  hi Constant     ctermfg=3             ctermbg=NONE         cterm=NONE
  hi String       ctermfg=2             ctermbg=NONE         cterm=NONE
  hi Character    ctermfg=2             ctermbg=NONE         cterm=NONE
  hi Identifier   ctermfg=NONE          ctermbg=NONE         cterm=NONE
  hi Function     ctermfg=4             ctermbg=NONE         cterm=NONE
  hi Statement    ctermfg=5             ctermbg=NONE         cterm=NONE
  hi Operator     ctermfg=6             ctermbg=NONE         cterm=NONE
  hi PreProc      ctermfg=1             ctermbg=NONE         cterm=NONE
  hi Type         ctermfg=3             ctermbg=NONE         cterm=NONE
  hi Special      ctermfg=1             ctermbg=NONE         cterm=NONE
  hi Delimiter    ctermfg=NONE          ctermbg=NONE         cterm=NONE
  hi Underlined   ctermfg=4             ctermbg=NONE         cterm=underline
  hi Error        ctermfg=1             ctermbg=NONE         cterm=NONE
  hi Todo         ctermfg=3             ctermbg=NONE         cterm=bold
endif

" ---------------------------------------------------------------------------
" Terminal Colors & Neovim Diagnostics / Treesitter Links
" ---------------------------------------------------------------------------
if has('nvim')
$term_nvim_lines
$(join(["  " * l for l in nvim_diag_lines], "\n"))
  hi! link @comment             Comment
  hi! link @constant            Constant
  hi! link @constant.builtin    Constant
  hi! link @number              Number
  hi! link @boolean             Boolean
  hi! link @string              String
  hi! link @string.regexp       String
  hi! link @character           Character
  hi! link @variable            Identifier
  hi! link @variable.parameter  Identifier
  hi! link @variable.member     Identifier
  hi! link @variable.builtin    Special
  hi! link @property            Identifier
  hi! link @function            Function
  hi! link @function.builtin    Function
  hi! link @function.method     Function
  hi! link @function.macro      Macro
  hi! link @constructor         Type
  hi! link @type                Type
  hi! link @type.builtin        Type
  hi! link @attribute           PreProc
  hi! link @keyword             Keyword
  hi! link @keyword.operator    Operator
  hi! link @keyword.directive   PreProc
  hi! link @operator            Operator
  hi! link @punctuation         Delimiter
  hi! link @label               Special
  hi! link @markup.heading      Title
  hi! link @markup.raw          String
  hi! link @markup.link         Underlined
elseif (has('termguicolors') && &termguicolors) || has('gui_running')
  let g:terminal_ansi_colors = [$term_vim_list]
endif
"""

    _write_port(target_path, content, "Vim theme ($slug)"; dry_run=dry_run)
end

# =============================================================================
# 3. Helix Editor
# =============================================================================

function generate_helix_theme(mode::Symbol, tier::Symbol; target_path::String, dry_run::Bool=true)
    is_dark = mode == :dark
    base = BASE_TONES[tier]
    acc = ACCENTS[mode][tier][8]

    bg_canvas = is_dark ? base["shade"] : base["sun"]
    bg_recessed = is_dark ? base["shade-"] : base["sun-"]
    bg_elevated = is_dark ? base["shade+"] : base["sun+"]
    cursor_col = is_dark ? base["sun"] : base["shade"]
    theme_name = is_dark ? "penumbra_dark$(tier_suffix(tier))" : "penumbra_light"
    comment_ref = is_dark ? "sky_minus" : "sky_plus"
    linenr_ref = is_dark ? "sky_minus" : "sky_plus"

    content = """# Penumbra v2 -- Helix Editor Theme
# Theme: $theme_name
# Mode: $mode, Tier: $tier
# Opponent Scheme: N = 8 (Strict Upright Typography)

"attribute" = "yellow"
"type" = "yellow"
"type.builtin" = "yellow"
"type.parameter" = "yellow"
"constructor" = "yellow"

"constant" = "orange"
"constant.numeric" = "orange"
"constant.builtin.boolean" = "orange"
"constant.character" = "orange"
"constant.character.escape" = "magenta"

"string" = "green"
"string.regexp" = "magenta"
"string.special" = "green"

"comment" = { fg = "$comment_ref" }

"variable" = "sky"
"variable.builtin" = "magenta"
"variable.parameter" = "sky"
"variable.other.member" = "sky"

"label" = "red"
"special" = "magenta"

"function" = "blue"
"function.builtin" = "blue"
"function.method" = "blue"
"function.macro" = "red"

"operator" = "cyan"

"keyword" = "purple"
"keyword.control" = "purple"
"keyword.operator" = "cyan"
"keyword.directive" = "red"

# Markup / Markdown (Semantic styles for doc markup only)
"markup.heading" = { fg = "blue", modifiers = ["bold"] }
"markup.list" = "yellow"
"markup.bold" = { modifiers = ["bold"] }
"markup.italic" = { modifiers = ["italic"] }
"markup.link.url" = { fg = "cyan", underline = { style = "line" } }
"markup.link.text" = "purple"
"markup.raw" = "green"

# UI Canvas & Hierarchy
"ui.background" = { bg = "bg_canvas" }
"ui.background.separator" = { fg = "bg_recessed" }
"ui.cursor" = { fg = "bg_canvas", bg = "cursor_color" }
"ui.cursor.match" = { bg = "bg_elevated" }
"ui.cursor.primary" = { fg = "bg_canvas", bg = "cursor_color" }
"ui.selection" = { bg = "bg_elevated" }
"ui.selection.primary" = { bg = "bg_elevated" }
"ui.linenr" = { fg = "$linenr_ref" }
"ui.linenr.selected" = { fg = "sky_plus", bg = "bg_elevated" }
"ui.statusline" = { fg = "sky", bg = "bg_recessed" }
"ui.statusline.inactive" = { fg = "$comment_ref", bg = "bg_recessed" }
"ui.popup" = { bg = "bg_recessed", fg = "sky" }
"ui.window" = { fg = "bg_recessed" }
"ui.help" = { bg = "bg_recessed", fg = "sky" }
"ui.text" = "sky"
"ui.text.focus" = "sky_plus"

# Diagnostics & Alerts
"warning" = "orange"
"error" = "red"
"info" = "blue"
"hint" = "cyan"
"diagnostic" = { underline = { style = "line" } }
"diagnostic.warning" = { underline = { color = "orange", style = "curl" } }
"diagnostic.error" = { underline = { color = "red", style = "curl" } }
"diagnostic.info" = { underline = { color = "blue", style = "curl" } }
"diagnostic.hint" = { underline = { color = "cyan", style = "curl" } }

[palette]
bg_canvas = "#$bg_canvas"
bg_recessed = "#$bg_recessed"
bg_elevated = "#$bg_elevated"
cursor_color = "#$cursor_col"
sky_minus = "#$(base["sky-"])"
sky = "#$(base["sky"])"
sky_plus = "#$(base["sky+"])"
red = "#$(acc["red"])"
orange = "#$(acc["orange"])"
yellow = "#$(acc["yellow"])"
green = "#$(acc["green"])"
cyan = "#$(acc["cyan"])"
blue = "#$(acc["blue"])"
purple = "#$(acc["purple"])"
magenta = "#$(acc["magenta"])"
"""

    if dry_run
        println("  [DRY RUN] Helix theme ($theme_name) target: $target_path ($(sizeof(content)) bytes)")
    else
        mkpath(dirname(target_path))
        write(target_path, content)
        println("  [WRITTEN] $target_path")
    end
end

# =============================================================================
# 4. iTerm2
# =============================================================================

function generate_iterm2_profile(mode::Symbol, tier::Symbol; target_path::String, ansi_n::Int=6, dry_run::Bool=true)
    is_dark = mode == :dark
    base = BASE_TONES[tier]
    acc = ACCENTS[mode][tier][8]
    p = get_terminal_ansi_palette(mode, tier; ansi_n=ansi_n)

    bg_canvas = is_dark ? base["shade"] : base["sun"]
    fg_comment = is_dark ? base["sky-"] : base["sky+"]
    fg_heading = is_dark ? base["sky+"] : base["sky-"]
    canvas_opposite = is_dark ? base["sun"] : base["shade"]
    match_bg = _blend_hex(bg_canvas, acc["orange"], 0.35)

    function color_xml(name::String, hex_str::String; alpha::Union{Nothing,Real}=nothing)
        c = RGB(parse(Colorant, "#" * hex_str))
        alpha_entry = isnothing(alpha) ? "" : "\n\t\t<key>Alpha Component</key>\n\t\t<real>$alpha</real>"
        return """\t<key>$name</key>
\t<dict>
\t\t<key>Color Space</key>
\t\t<string>sRGB</string>$alpha_entry
\t\t<key>Red Component</key>
\t\t<real>$(c.r)</real>
\t\t<key>Green Component</key>
\t\t<real>$(c.g)</real>
\t\t<key>Blue Component</key>
\t\t<real>$(c.b)</real>
\t</dict>"""
    end

    entries = [
        color_xml("Background Color", p.bg),
        color_xml("Foreground Color", p.fg),
        color_xml("Bold Color", fg_heading),
        color_xml("Link Color", acc["blue"]),
        color_xml("Match Background Color", match_bg),
        color_xml("Active Pane Border Color", acc["blue"]),
        color_xml("IME Cursor Color", acc["yellow"]),
        color_xml("Cursor Color", p.cursor),
        color_xml("Cursor Text Color", p.cursor_text),
        color_xml("Cursor Guide Color", canvas_opposite; alpha=0.05),
        color_xml("Badge Color", fg_comment; alpha=0.5),
        color_xml("Selection Color", p.selection_bg),
        color_xml("Selected Text Color", p.selection_fg),
        color_xml("Ansi 0 Color", p.black),
        color_xml("Ansi 1 Color", p.red),
        color_xml("Ansi 2 Color", p.green),
        color_xml("Ansi 3 Color", p.yellow),
        color_xml("Ansi 4 Color", p.blue),
        color_xml("Ansi 5 Color", p.magenta),
        color_xml("Ansi 6 Color", p.cyan),
        color_xml("Ansi 7 Color", p.white),
        color_xml("Ansi 8 Color", p.bright_black),
        color_xml("Ansi 9 Color", p.bright_red),
        color_xml("Ansi 10 Color", p.bright_green),
        color_xml("Ansi 11 Color", p.bright_yellow),
        color_xml("Ansi 12 Color", p.bright_blue),
        color_xml("Ansi 13 Color", p.bright_magenta),
        color_xml("Ansi 14 Color", p.bright_cyan),
        color_xml("Ansi 15 Color", p.bright_white)
    ]

    content = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
$(join(entries, "\n"))
</dict>
</plist>
"""
    if dry_run
        println("  [DRY RUN] iTerm2 profile target: $target_path ($(sizeof(content)) bytes)")
    else
        mkpath(dirname(target_path))
        write(target_path, content)
        println("  [WRITTEN] $target_path")
    end
end

# =============================================================================
# 5. Ghostty Terminal
# =============================================================================

function generate_ghostty_theme(mode::Symbol, tier::Symbol; target_path::String, ansi_n::Int=6, dry_run::Bool=true)
    p = get_terminal_ansi_palette(mode, tier; ansi_n=ansi_n)
    theme_label = mode == :dark ? "penumbra_dark$(tier_suffix(tier))" : "penumbra_light"

    content = """# Penumbra v2 -- Ghostty Color Scheme
# Theme: $theme_label
# Mode: $mode, Tier: $tier

palette = 0=#$(lowercase(p.black))
palette = 1=#$(lowercase(p.red))
palette = 2=#$(lowercase(p.green))
palette = 3=#$(lowercase(p.yellow))
palette = 4=#$(lowercase(p.blue))
palette = 5=#$(lowercase(p.magenta))
palette = 6=#$(lowercase(p.cyan))
palette = 7=#$(lowercase(p.white))
palette = 8=#$(lowercase(p.bright_black))
palette = 9=#$(lowercase(p.bright_red))
palette = 10=#$(lowercase(p.bright_green))
palette = 11=#$(lowercase(p.bright_yellow))
palette = 12=#$(lowercase(p.bright_blue))
palette = 13=#$(lowercase(p.bright_magenta))
palette = 14=#$(lowercase(p.bright_cyan))
palette = 15=#$(lowercase(p.bright_white))

background = #$(lowercase(p.bg))
foreground = #$(lowercase(p.fg))
cursor-color = #$(lowercase(p.cursor))
cursor-text = #$(lowercase(p.cursor_text))
selection-background = #$(lowercase(p.selection_bg))
selection-foreground = #$(lowercase(p.selection_fg))
"""
    if dry_run
        println("  [DRY RUN] Ghostty theme ($theme_label) target: $target_path ($(sizeof(content)) bytes)")
    else
        mkpath(dirname(target_path))
        write(target_path, content)
        println("  [WRITTEN] $target_path")
    end
end

# =============================================================================
# 6. Alacritty Terminal
# =============================================================================

function generate_alacritty_theme(mode::Symbol, tier::Symbol; target_path::String, ansi_n::Int=6, dry_run::Bool=true)
    p = get_terminal_ansi_palette(mode, tier; ansi_n=ansi_n)
    theme_label = mode == :dark ? "penumbra_dark$(tier_suffix(tier))" : "penumbra_light"

    content = """# Penumbra v2 -- Alacritty Color Scheme
# Theme: $theme_label
# Mode: $mode, Tier: $tier

[colors.primary]
background = "#$(lowercase(p.bg))"
foreground = "#$(lowercase(p.fg))"

[colors.cursor]
text = "#$(lowercase(p.cursor_text))"
cursor = "#$(lowercase(p.cursor))"

[colors.selection]
text = "#$(lowercase(p.selection_fg))"
background = "#$(lowercase(p.selection_bg))"

[colors.normal]
black   = "#$(lowercase(p.black))"
red     = "#$(lowercase(p.red))"
green   = "#$(lowercase(p.green))"
yellow  = "#$(lowercase(p.yellow))"
blue    = "#$(lowercase(p.blue))"
magenta = "#$(lowercase(p.magenta))"
cyan    = "#$(lowercase(p.cyan))"
white   = "#$(lowercase(p.white))"

[colors.bright]
black   = "#$(lowercase(p.bright_black))"
red     = "#$(lowercase(p.bright_red))"
green   = "#$(lowercase(p.bright_green))"
yellow  = "#$(lowercase(p.bright_yellow))"
blue    = "#$(lowercase(p.bright_blue))"
magenta = "#$(lowercase(p.bright_magenta))"
cyan    = "#$(lowercase(p.bright_cyan))"
white   = "#$(lowercase(p.bright_white))"
"""
    if dry_run
        println("  [DRY RUN] Alacritty theme ($theme_label) target: $target_path ($(sizeof(content)) bytes)")
    else
        mkpath(dirname(target_path))
        write(target_path, content)
        println("  [WRITTEN] $target_path")
    end
end

# =============================================================================
# 7. Kitty Terminal
# =============================================================================

function generate_kitty_theme(mode::Symbol, tier::Symbol; target_path::String, ansi_n::Int=6, dry_run::Bool=true)
    p = get_terminal_ansi_palette(mode, tier; ansi_n=ansi_n)
    theme_label = mode == :dark ? "penumbra_dark$(tier_suffix(tier))" : "penumbra_light"

    content = """# Penumbra v2 -- Kitty Color Scheme
# Theme: $theme_label
# Mode: $mode, Tier: $tier

foreground            #$(lowercase(p.fg))
background            #$(lowercase(p.bg))
selection_foreground   #$(lowercase(p.selection_fg))
selection_background   #$(lowercase(p.selection_bg))
cursor                #$(lowercase(p.cursor))
cursor_text_color     #$(lowercase(p.cursor_text))

# Normal ANSI colors
color0  #$(lowercase(p.black))
color1  #$(lowercase(p.red))
color2  #$(lowercase(p.green))
color3  #$(lowercase(p.yellow))
color4  #$(lowercase(p.blue))
color5  #$(lowercase(p.magenta))
color6  #$(lowercase(p.cyan))
color7  #$(lowercase(p.white))

# Bright ANSI colors
color8  #$(lowercase(p.bright_black))
color9  #$(lowercase(p.bright_red))
color10 #$(lowercase(p.bright_green))
color11 #$(lowercase(p.bright_yellow))
color12 #$(lowercase(p.bright_blue))
color13 #$(lowercase(p.bright_magenta))
color14 #$(lowercase(p.bright_cyan))
color15 #$(lowercase(p.bright_white))
"""
    if dry_run
        println("  [DRY RUN] Kitty theme ($theme_label) target: $target_path ($(sizeof(content)) bytes)")
    else
        mkpath(dirname(target_path))
        write(target_path, content)
        println("  [WRITTEN] $target_path")
    end
end

# =============================================================================
# 8. Windows Terminal
# =============================================================================

function generate_windows_terminal_schemes(; target_path::String, dry_run::Bool=true)
    schemes = Dict{String,Any}[]

    targets = [
        (:dark, :balanced, "Penumbra Dark"),
        (:dark, :contrast_plus, "Penumbra Dark+"),
        (:dark, :contrast_plus_plus, "Penumbra Dark++"),
        (:light, :balanced, "Penumbra Light")
    ]

    for (ansi_n, name_suffix) in ((6, ""), (8, " (Semantic 6)"))
        for (mode, tier, name) in targets
            p = get_terminal_ansi_palette(mode, tier; ansi_n=ansi_n)
            push!(schemes, Dict{String,Any}(
                "name" => name * name_suffix,
                "background" => "#" * p.bg,
                "foreground" => "#" * p.fg,
                "cursorColor" => "#" * p.cursor,
                "selectionBackground" => "#" * p.selection_bg,
                "black" => "#" * p.black,
                "red" => "#" * p.red,
                "green" => "#" * p.green,
                "yellow" => "#" * p.yellow,
                "blue" => "#" * p.blue,
                "purple" => "#" * p.magenta,
                "cyan" => "#" * p.cyan,
                "white" => "#" * p.white,
                "brightBlack" => "#" * p.bright_black,
                "brightRed" => "#" * p.bright_red,
                "brightGreen" => "#" * p.bright_green,
                "brightYellow" => "#" * p.bright_yellow,
                "brightBlue" => "#" * p.bright_blue,
                "brightPurple" => "#" * p.bright_magenta,
                "brightCyan" => "#" * p.bright_cyan,
                "brightWhite" => "#" * p.bright_white
            ))
        end
    end

    data = Dict{String,Any}("schemes" => schemes)
    content = sprint(io -> JSON.print(io, data, 2))

    if dry_run
        println("  [DRY RUN] Windows Terminal schemes target: $target_path ($(sizeof(content)) bytes)")
    else
        mkpath(dirname(target_path))
        write(target_path, content * "\n")
        println("  [WRITTEN] $target_path")
    end
end

# =============================================================================
# 9. CSS Custom Properties
# =============================================================================

const ACCENT_ORDERS = Dict(
    6 => ("red", "yellow", "green", "cyan", "blue", "magenta"),
    7 => ("red", "orange", "yellow", "green", "cyan", "blue", "purple"),
    8 => ("red", "orange", "yellow", "green", "cyan", "blue", "purple", "magenta"),
)

function _css_token_name(s::AbstractString)
    return replace(s, "+" => "-plus", "-" => "-minus")
end

function generate_css_tokens(; target_path::String, dry_run::Bool=true)
    lines = String[
        "/* Penumbra v2 Color Palette CSS Tokens (MIT License) */",
        "/* Generated by scripts/generate_downstream_ports.jl */",
        "",
        ":root {",
        "  /* Shared sunlit & sky base tokens */"
    ]

    balanced = BASE_TONES[:balanced]
    push!(lines, @sprintf("  --penumbra-%s: #%s;", _css_token_name("sun+"), balanced["sun+"]))
    for name in ("sun", "sun-", "sky+", "sky", "sky-")
        push!(lines, @sprintf("  --penumbra-%s: #%s;", _css_token_name(name), balanced[name]))
    end

    push!(lines, "")
    push!(lines, "  /* Re-anchored contrast-tiered base tokens */")
    for (tier, tier_slug) in ((:balanced, "balanced"), (:contrast_plus, "contrast-plus"), (:contrast_plus_plus, "contrast-plus-plus"))
        base = BASE_TONES[tier]
        for name in ("sun", "sun-", "sky+", "sky", "sky-", "shade+", "shade", "shade-")
            push!(lines, @sprintf("  --penumbra-%s-%s: #%s;", tier_slug, _css_token_name(name), base[name]))
        end
    end

    pal_slugs = Dict(6 => "six", 7 => "seven", 8 => "eight")

    for (mode, tier, tier_prefix) in (
        (:dark, :balanced, "dark"),
        (:dark, :contrast_plus, "dark-contrast-plus"),
        (:dark, :contrast_plus_plus, "dark-contrast-plus-plus"),
        (:light, :balanced, "light"),
    )
        for n in (6, 7, 8)
            push!(lines, "")
            push!(lines, "  /* $tier_prefix accents (N = $n) */")
            acc = ACCENTS[mode][tier][n]
            for cname in ACCENT_ORDERS[n]
                push!(lines, @sprintf("  --penumbra-%s-%s-%s: #%s;", tier_prefix, pal_slugs[n], cname, acc[cname]))
            end
        end
    end
    push!(lines, "}")

    # Semantic theme bindings
    themes = [
        (":root,\n[data-theme=\"penumbra-dark\"],\n.penumbra-dark", :dark, :balanced, "balanced", "dark"),
        ("[data-theme=\"penumbra-dark-contrast-plus\"],\n.penumbra-dark-contrast-plus", :dark, :contrast_plus, "contrast-plus", "dark-contrast-plus"),
        ("[data-theme=\"penumbra-dark-contrast-plus-plus\"],\n.penumbra-dark-contrast-plus-plus", :dark, :contrast_plus_plus, "contrast-plus-plus", "dark-contrast-plus-plus"),
        ("[data-theme=\"penumbra-light\"],\n.penumbra-light", :light, :balanced, "balanced", "light"),
    ]

    for (selector, mode, tier, tier_slug, accent_prefix) in themes
        is_dark = mode == :dark
        push!(lines, "")
        push!(lines, "$selector {")
        if is_dark
            push!(lines, "  --penumbra-bg: var(--penumbra-$tier_slug-shade);")
            push!(lines, "  --penumbra-bg-recessed: var(--penumbra-$tier_slug-shade-minus);")
            push!(lines, "  --penumbra-bg-elevated: var(--penumbra-$tier_slug-shade-plus);")
            push!(lines, "  --penumbra-fg: var(--penumbra-$tier_slug-sky);")
            push!(lines, "  --penumbra-fg-muted: var(--penumbra-$tier_slug-sky-minus);")
            push!(lines, "  --penumbra-fg-emphasis: var(--penumbra-$tier_slug-sky-plus);")
            push!(lines, "  --penumbra-selection: var(--penumbra-$tier_slug-shade-plus);")
            push!(lines, "  --penumbra-cursor: var(--penumbra-$tier_slug-sun);")
            push!(lines, "  --penumbra-border: var(--penumbra-$tier_slug-shade-plus);")
        else
            push!(lines, "  --penumbra-bg: var(--penumbra-sun);")
            push!(lines, "  --penumbra-bg-recessed: var(--penumbra-sun-plus);")
            push!(lines, "  --penumbra-bg-elevated: var(--penumbra-sun-minus);")
            push!(lines, "  --penumbra-fg: var(--penumbra-sky);")
            push!(lines, "  --penumbra-fg-muted: var(--penumbra-sky-plus);")
            push!(lines, "  --penumbra-fg-emphasis: var(--penumbra-sky-minus);")
            push!(lines, "  --penumbra-selection: var(--penumbra-sun-minus);")
            push!(lines, "  --penumbra-cursor: var(--penumbra-balanced-shade);")
            push!(lines, "  --penumbra-border: var(--penumbra-sun-minus);")
        end
        for cname in ACCENT_ORDERS[8]
            push!(lines, "  --penumbra-$cname: var(--penumbra-$accent_prefix-eight-$cname);")
        end
        push!(lines, "}")
    end

    content = join(lines, "\n") * "\n"
    if dry_run
        println("  [DRY RUN] CSS tokens target: $target_path ($(sizeof(content)) bytes)")
    else
        mkpath(dirname(target_path))
        write(target_path, content)
        println("  [WRITTEN] $target_path")
    end
end

# =============================================================================
# 10. GIMP / Inkscape / Krita Palettes (.gpl)
# =============================================================================

function _hex_to_rgb255(hex::AbstractString)
    r = parse(Int, hex[1:2]; base=16)
    g = parse(Int, hex[3:4]; base=16)
    b = parse(Int, hex[5:6]; base=16)
    return (r, g, b)
end

function generate_gpl_palette(mode::Symbol, tier::Symbol; target_path::String, dry_run::Bool=true)
    base = BASE_TONES[tier]
    acc = ACCENTS[mode][tier][8]
    tier_label = tier == :balanced ? "" : (tier == :contrast_plus ? " Contrast+" : " Contrast++")
    mode_label = mode == :dark ? "Dark" : "Light"

    lines = String[
        "GIMP Palette",
        "Name: Penumbra $mode_label$tier_label",
        "Columns: 3",
        "#"
    ]

    for name in ("sun+", "sun", "sun-", "sky+", "sky", "sky-", "shade+", "shade", "shade-")
        r, g, b = _hex_to_rgb255(base[name])
        push!(lines, @sprintf("%3d %3d %3d\t%s", r, g, b, name))
    end
    for cname in ACCENT_ORDERS[8]
        r, g, b = _hex_to_rgb255(acc[cname])
        push!(lines, @sprintf("%3d %3d %3d\t%s", r, g, b, cname))
    end

    content = join(lines, "\n") * "\n"
    if dry_run
        println("  [DRY RUN] GPL palette target: $target_path ($(sizeof(content)) bytes)")
    else
        mkpath(dirname(target_path))
        write(target_path, content)
        println("  [WRITTEN] $target_path")
    end
end

function generate_gpl_all(; target_path::String, dry_run::Bool=true)
    lines = String[
        "GIMP Palette",
        "Name: Penumbra v2 (All Tiers & Accents)",
        "Columns: 3",
        "#"
    ]

    balanced = BASE_TONES[:balanced]
    r_sp, g_sp, b_sp = _hex_to_rgb255(balanced["sun+"])
    push!(lines, @sprintf("%3d %3d %3d\t%s", r_sp, g_sp, b_sp, "sun+"))
    for (tier, prefix) in ((:balanced, "balanced"), (:contrast_plus, "contrast+"), (:contrast_plus_plus, "contrast++"))
        base = BASE_TONES[tier]
        for name in ("sun", "sun-", "sky+", "sky", "sky-", "shade+", "shade", "shade-")
            r, g, b = _hex_to_rgb255(base[name])
            push!(lines, @sprintf("%3d %3d %3d\t%s %s", r, g, b, prefix, name))
        end
    end

    for (mode, tier, label) in (
        (:dark, :balanced, "dark balanced"),
        (:dark, :contrast_plus, "dark contrast+"),
        (:dark, :contrast_plus_plus, "dark contrast++"),
        (:light, :balanced, "light"),
    )
        for n in (6, 7, 8)
            acc = ACCENTS[mode][tier][n]
            for cname in ACCENT_ORDERS[n]
                r, g, b = _hex_to_rgb255(acc[cname])
                push!(lines, @sprintf("%3d %3d %3d\t%s %d %s", r, g, b, label, n, cname))
            end
        end
    end

    content = join(lines, "\n") * "\n"
    if dry_run
        println("  [DRY RUN] GPL master palette target: $target_path ($(sizeof(content)) bytes)")
    else
        mkpath(dirname(target_path))
        write(target_path, content)
        println("  [WRITTEN] $target_path")
    end
end

# =============================================================================
# Shared Helpers for Additional Ports
# =============================================================================

function _theme_slug(mode::Symbol, tier::Symbol)
    return mode == :dark ? "penumbra_dark$(tier_suffix(tier))" : "penumbra_light"
end

function _display_name(mode::Symbol, tier::Symbol)
    return mode == :dark ? "Penumbra Dark$(tier_suffix(tier))" : "Penumbra Light"
end

function _write_port(target_path::String, content::String, label::String; dry_run::Bool=true)
    if dry_run
        println("  [DRY RUN] $label target: $target_path ($(sizeof(content)) bytes)")
    else
        mkpath(dirname(target_path))
        write(target_path, content)
        println("  [WRITTEN] $target_path")
    end
end

function _blend_hex(bg_hex::AbstractString, fg_hex::AbstractString, alpha::Real)
    c_bg = convert(XYZ{Float64}, parse(RGB{Float64}, "#" * bg_hex))
    c_fg = convert(XYZ{Float64}, parse(RGB{Float64}, "#" * fg_hex))
    mix = XYZ{Float64}(
        (1 - alpha) * c_bg.x + alpha * c_fg.x,
        (1 - alpha) * c_bg.y + alpha * c_fg.y,
        (1 - alpha) * c_bg.z + alpha * c_fg.z,
    )
    rgb = convert(RGB{Float64}, mix)
    r = clamp(round(Int, rgb.r * 255), 0, 255)
    g = clamp(round(Int, rgb.g * 255), 0, 255)
    b = clamp(round(Int, rgb.b * 255), 0, 255)
    return @sprintf("%02X%02X%02X", r, g, b)
end

# =============================================================================
# 11. WezTerm Terminal
# =============================================================================

function generate_wezterm_theme(mode::Symbol, tier::Symbol; target_path::String, ansi_n::Int=6, dry_run::Bool=true)
    p = get_terminal_ansi_palette(mode, tier; ansi_n=ansi_n)
    name = _display_name(mode, tier) * (ansi_n == 8 ? " (Semantic 6)" : "")
    slug = _theme_slug(mode, tier) * (ansi_n == 8 ? "_semantic6" : "")

    content = """# Penumbra v2 -- WezTerm Color Scheme
# Theme: $slug
# Mode: $mode, Tier: $tier

[metadata]
name = "$name"
author = "Neal McKee"

[colors]
foreground = "#$(lowercase(p.fg))"
background = "#$(lowercase(p.bg))"
cursor_bg = "#$(lowercase(p.cursor))"
cursor_border = "#$(lowercase(p.cursor))"
cursor_fg = "#$(lowercase(p.cursor_text))"
selection_bg = "#$(lowercase(p.selection_bg))"
selection_fg = "#$(lowercase(p.selection_fg))"

ansi = [
  "#$(lowercase(p.black))",
  "#$(lowercase(p.red))",
  "#$(lowercase(p.green))",
  "#$(lowercase(p.yellow))",
  "#$(lowercase(p.blue))",
  "#$(lowercase(p.magenta))",
  "#$(lowercase(p.cyan))",
  "#$(lowercase(p.white))",
]

brights = [
  "#$(lowercase(p.bright_black))",
  "#$(lowercase(p.bright_red))",
  "#$(lowercase(p.bright_green))",
  "#$(lowercase(p.bright_yellow))",
  "#$(lowercase(p.bright_blue))",
  "#$(lowercase(p.bright_magenta))",
  "#$(lowercase(p.bright_cyan))",
  "#$(lowercase(p.bright_white))",
]
"""
    _write_port(target_path, content, "WezTerm theme ($slug)"; dry_run=dry_run)
end

# =============================================================================
# 12. Warp Terminal
# =============================================================================

function generate_warp_theme(mode::Symbol, tier::Symbol; target_path::String, ansi_n::Int=6, dry_run::Bool=true)
    p = get_terminal_ansi_palette(mode, tier; ansi_n=ansi_n)
    acc = ACCENTS[mode][tier][8]
    suffix = ansi_n == 8 ? " (Semantic 6)" : ""
    name = _display_name(mode, tier) * suffix
    slug = _theme_slug(mode, tier)
    details = mode == :dark ? "darker" : "lighter"

    content = """# Penumbra v2 -- Warp Terminal Theme
# Theme: $slug
# Mode: $mode, Tier: $tier

name: "$name"
accent: "#$(lowercase(acc["blue"]))"
cursor: "#$(lowercase(p.cursor))"
background: "#$(lowercase(p.bg))"
foreground: "#$(lowercase(p.fg))"
details: $details
terminal_colors:
  normal:
    black: "#$(lowercase(p.black))"
    red: "#$(lowercase(p.red))"
    green: "#$(lowercase(p.green))"
    yellow: "#$(lowercase(p.yellow))"
    blue: "#$(lowercase(p.blue))"
    magenta: "#$(lowercase(p.magenta))"
    cyan: "#$(lowercase(p.cyan))"
    white: "#$(lowercase(p.white))"
  bright:
    black: "#$(lowercase(p.bright_black))"
    red: "#$(lowercase(p.bright_red))"
    green: "#$(lowercase(p.bright_green))"
    yellow: "#$(lowercase(p.bright_yellow))"
    blue: "#$(lowercase(p.bright_blue))"
    magenta: "#$(lowercase(p.bright_magenta))"
    cyan: "#$(lowercase(p.bright_cyan))"
    white: "#$(lowercase(p.bright_white))"
"""
    _write_port(target_path, content, "Warp theme ($slug)"; dry_run=dry_run)
end

# =============================================================================
# 13. TextMate .tmTheme (bat, git-delta, Codex CLI, Sublime Text)
# =============================================================================

const TMTHEME_UUIDS = Dict(
    (:dark, :balanced)           => "6B7A4F2C-9E31-4A18-8C01-5D2E4F8A1001",
    (:dark, :contrast_plus)      => "6B7A4F2C-9E31-4A18-8C01-5D2E4F8A1002",
    (:dark, :contrast_plus_plus) => "6B7A4F2C-9E31-4A18-8C01-5D2E4F8A1003",
    (:light, :balanced)          => "6B7A4F2C-9E31-4A18-8C01-5D2E4F8A1004",
)

function _tmtheme_rule(name::String, scope::String, fg::String; font_style::String="")
    style_entry = isempty(font_style) ? "" : "\n\t\t\t\t<key>fontStyle</key>\n\t\t\t\t<string>$font_style</string>"
    return """\t\t<dict>
\t\t\t<key>name</key>
\t\t\t<string>$name</string>
\t\t\t<key>scope</key>
\t\t\t<string>$scope</string>
\t\t\t<key>settings</key>
\t\t\t<dict>
\t\t\t\t<key>foreground</key>
\t\t\t\t<string>#$fg</string>$style_entry
\t\t\t</dict>
\t\t</dict>"""
end

function generate_tmtheme(mode::Symbol, tier::Symbol; target_path::String, dry_run::Bool=true)
    is_dark = mode == :dark
    base = BASE_TONES[tier]
    acc = ACCENTS[mode][tier][8]
    name = _display_name(mode, tier)
    slug = _theme_slug(mode, tier)
    uuid = TMTHEME_UUIDS[(mode, tier)]

    bg_canvas = is_dark ? base["shade"] : base["sun"]
    bg_elevated = is_dark ? base["shade+"] : base["sun+"]
    fg_comment = is_dark ? base["sky-"] : base["sky+"]
    fg_text = base["sky"]
    fg_heading = is_dark ? base["sky+"] : base["sky-"]
    canvas_opposite = is_dark ? base["sun"] : base["shade"]
    find_hl = _blend_hex(bg_canvas, acc["orange"], 0.35)

    rules = [
        _tmtheme_rule("Comments &amp; Marginalia", "comment, punctuation.definition.comment", fg_comment),
        _tmtheme_rule("Keywords &amp; Control Flow", "keyword.control, keyword.operator.new, keyword.operator.expression, keyword.other, storage.type, storage.modifier", acc["purple"]),
        _tmtheme_rule("Functions &amp; Method Calls", "entity.name.function, support.function, meta.function-call, variable.function", acc["blue"]),
        _tmtheme_rule("Types, Classes &amp; Modules", "entity.name.type, entity.name.class, entity.name.namespace, entity.name.scope-resolution, entity.other.inherited-class, support.type, support.class", acc["yellow"]),
        _tmtheme_rule("Operators", "keyword.operator, storage.type.function.arrow, punctuation.definition.template-expression.begin, punctuation.definition.template-expression.end, punctuation.section.embedded", acc["cyan"]),
        _tmtheme_rule("Syntactic Punctuation &amp; Brackets", "punctuation, punctuation.separator, punctuation.terminator, meta.brace, meta.template.expression, meta.embedded", fg_text),
        _tmtheme_rule("Strings &amp; Code", "string, string.quoted, string.template", acc["green"]),
        _tmtheme_rule("String Escapes &amp; RegExp", "constant.character.escape, string.regexp", acc["magenta"]),
        _tmtheme_rule("Numbers, Units &amp; Booleans", "constant.numeric, constant.language.boolean, constant.language.null, constant.language", acc["orange"]),
        _tmtheme_rule("Macros &amp; Decorators", "entity.name.function.macro, support.function.macro, entity.name.function.decorator", acc["red"]),
        _tmtheme_rule("Symbols &amp; Special Bindings", "constant.other.symbol, variable.language.special, variable.language.this, variable.language.self", acc["magenta"]),
        _tmtheme_rule("Errors &amp; Invalid Syntax", "invalid, invalid.illegal", acc["red"]),
        _tmtheme_rule("Variables &amp; Parameters", "variable, variable.parameter, variable.other", fg_text),
        _tmtheme_rule("Markdown Headings", "markup.heading, entity.name.section", fg_heading; font_style="bold"),
        _tmtheme_rule("Markdown Bold", "markup.bold", acc["yellow"]; font_style="bold"),
        _tmtheme_rule("Markdown Italic", "markup.italic", acc["purple"]; font_style="italic"),
        _tmtheme_rule("Markdown Code", "markup.inline.raw, markup.raw.block", acc["green"]),
        _tmtheme_rule("Markdown Links", "markup.underline.link, string.other.link", acc["blue"]),
        _tmtheme_rule("Markdown Quotes", "markup.quote", fg_comment),
        _tmtheme_rule("Markdown List Markers", "punctuation.definition.list.begin.markdown", acc["cyan"]),
        _tmtheme_rule("Structured Property Keys", "support.type.property-name, meta.property-name, entity.name.tag.yaml", acc["blue"]),
        _tmtheme_rule("Markup Tags", "entity.name.tag", acc["blue"]),
        _tmtheme_rule("Markup Tag Brackets", "punctuation.definition.tag", fg_comment),
        _tmtheme_rule("Markup Attributes", "entity.other.attribute-name", acc["yellow"]),
        _tmtheme_rule("Diff Additions", "markup.inserted", acc["green"]),
        _tmtheme_rule("Diff Deletions", "markup.deleted", acc["red"]),
        _tmtheme_rule("Diff Modifications", "markup.changed", acc["blue"]),
    ]

    content = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
\t<key>name</key>
\t<string>$name</string>
\t<key>author</key>
\t<string>Neal McKee</string>
\t<key>semanticClass</key>
\t<string>theme.$(is_dark ? "dark" : "light").$slug</string>
\t<key>uuid</key>
\t<string>$uuid</string>
\t<key>settings</key>
\t<array>
\t\t<dict>
\t\t\t<key>settings</key>
\t\t\t<dict>
\t\t\t\t<key>background</key>
\t\t\t\t<string>#$bg_canvas</string>
\t\t\t\t<key>foreground</key>
\t\t\t\t<string>#$fg_text</string>
\t\t\t\t<key>caret</key>
\t\t\t\t<string>#$canvas_opposite</string>
\t\t\t\t<key>selection</key>
\t\t\t\t<string>#$bg_elevated</string>
\t\t\t\t<key>selectionBorder</key>
\t\t\t\t<string>#$bg_elevated</string>
\t\t\t\t<key>lineHighlight</key>
\t\t\t\t<string>#$bg_elevated</string>
\t\t\t\t<key>invisibles</key>
\t\t\t\t<string>#$fg_comment</string>
\t\t\t\t<key>gutter</key>
\t\t\t\t<string>#$bg_canvas</string>
\t\t\t\t<key>gutterForeground</key>
\t\t\t\t<string>#$fg_comment</string>
\t\t\t\t<key>activeGuide</key>
\t\t\t\t<string>#$fg_comment</string>
\t\t\t\t<key>findHighlight</key>
\t\t\t\t<string>#$find_hl</string>
\t\t\t</dict>
\t\t</dict>
$(join(rules, "\n"))
\t</array>
</dict>
</plist>
"""
    _write_port(target_path, content, "TextMate .tmTheme ($slug)"; dry_run=dry_run)
end

# =============================================================================
# 14. Codex Desktop App (codex-theme-v1)
# =============================================================================

function generate_codex_theme(mode::Symbol, tier::Symbol; target_path::String, dry_run::Bool=true)
    is_dark = mode == :dark
    base = BASE_TONES[tier]
    acc = ACCENTS[mode][tier][8]
    slug = _theme_slug(mode, tier)

    bg_canvas = is_dark ? base["shade"] : base["sun"]
    contrast = tier == :balanced ? 45 : (tier == :contrast_plus ? 60 : 75)

    payload = Dict{String,Any}(
        "codeThemeId" => "codex",
        "variant" => is_dark ? "dark" : "light",
        "theme" => Dict{String,Any}(
            "accent" => "#" * lowercase(acc["blue"]),
            "contrast" => contrast,
            "fonts" => Dict{String,Any}("code" => nothing, "ui" => nothing),
            "ink" => "#" * lowercase(base["sky"]),
            "opaqueWindows" => true,
            "semanticColors" => Dict{String,Any}(
                "diffAdded" => "#" * lowercase(acc["green"]),
                "diffRemoved" => "#" * lowercase(acc["red"]),
                "skill" => "#" * lowercase(acc["purple"]),
            ),
            "surface" => "#" * lowercase(bg_canvas),
        ),
    )

    content = "codex-theme-v1:" * sprint(io -> JSON.print(io, payload)) * "\n"
    _write_port(target_path, content, "Codex Desktop theme ($slug)"; dry_run=dry_run)
end

# =============================================================================
# 15. Claude Code CLI (~/.claude/themes/*.json)
# =============================================================================

function generate_claude_code_theme(mode::Symbol, tier::Symbol; target_path::String, dry_run::Bool=true)
    is_dark = mode == :dark
    base = BASE_TONES[tier]
    acc = ACCENTS[mode][tier][8]
    name = _display_name(mode, tier)
    slug = _theme_slug(mode, tier)

    bg_recessed = is_dark ? base["shade-"] : base["sun-"]
    bg_canvas = is_dark ? base["shade"] : base["sun"]
    bg_elevated = is_dark ? base["shade+"] : base["sun+"]
    fg_comment = is_dark ? base["sky-"] : base["sky+"]
    fg_text = base["sky"]

    overrides = Dict{String,String}(
        "text" => "#" * fg_text,
        "inverseText" => "#" * bg_canvas,
        "background" => "#" * bg_canvas,
        "subtle" => "#" * fg_comment,
        "inactive" => "#" * fg_comment,
        "selectionBg" => "#" * bg_elevated,
        "userMessageBackground" => "#" * bg_elevated,
        "userMessageBackgroundHover" => "#" * _blend_hex(bg_elevated, fg_comment, 0.15),
        "messageActionsBackground" => "#" * bg_recessed,
        "composerSidebarBackground" => "#" * bg_recessed,
        "bashBorder" => "#" * acc["cyan"],
        "promptBorder" => "#" * fg_comment,
        "claude" => "#" * acc["orange"],
        "permission" => "#" * acc["blue"],
        "planMode" => "#" * acc["purple"],
        "autoAccept" => "#" * acc["green"],
        "ide" => "#" * acc["cyan"],
        "remember" => "#" * acc["yellow"],
        "skill" => "#" * acc["purple"],
        "effortUltra" => "#" * acc["magenta"],
        "success" => "#" * acc["green"],
        "warning" => "#" * acc["orange"],
        "error" => "#" * acc["red"],
        "merged" => "#" * acc["purple"],
        "suggestion" => "#" * acc["cyan"],
        "diffAdded" => "#" * _blend_hex(bg_canvas, acc["green"], 0.15),
        "diffRemoved" => "#" * _blend_hex(bg_canvas, acc["red"], 0.15),
        "diffAddedDimmed" => "#" * _blend_hex(bg_canvas, acc["green"], 0.09),
        "diffRemovedDimmed" => "#" * _blend_hex(bg_canvas, acc["red"], 0.09),
        "diffAddedWord" => "#" * _blend_hex(bg_canvas, acc["green"], 0.28),
        "diffRemovedWord" => "#" * _blend_hex(bg_canvas, acc["red"], 0.28),
    )

    data = Dict{String,Any}(
        "name" => name,
        "base" => is_dark ? "dark" : "light",
        "overrides" => overrides,
    )
    content = sprint(io -> JSON.print(io, data, 2)) * "\n"
    _write_port(target_path, content, "Claude Code CLI theme ($slug)"; dry_run=dry_run)
end

# =============================================================================
# 16. Base16 (tinted-theming/schemes YAML)
# =============================================================================

function generate_base16_theme(mode::Symbol, tier::Symbol; target_path::String, dry_run::Bool=true)
    is_dark = mode == :dark
    base = BASE_TONES[tier]
    acc = ACCENTS[mode][tier][8]
    name = _display_name(mode, tier)
    slug = _theme_slug(mode, tier)
    variant = is_dark ? "dark" : "light"

    bg_recessed = is_dark ? base["shade-"] : base["sun-"]
    bg_canvas = is_dark ? base["shade"] : base["sun"]
    bg_elevated = is_dark ? base["shade+"] : base["sun+"]
    fg_comment = is_dark ? base["sky-"] : base["sky+"]
    fg_text = base["sky"]
    fg_heading = is_dark ? base["sky+"] : base["sky-"]
    canvas_opposite = is_dark ? base["sun"] : base["shade"]

    content = """system: "base16"
name: "$name"
author: "Neal McKee"
variant: "$variant"
palette:
  base00: "#$bg_canvas"
  base01: "#$bg_recessed"
  base02: "#$bg_elevated"
  base03: "#$fg_comment"
  base04: "#$fg_text"
  base05: "#$fg_text"
  base06: "#$fg_heading"
  base07: "#$canvas_opposite"
  base08: "#$(acc["red"])"
  base09: "#$(acc["orange"])"
  base0A: "#$(acc["yellow"])"
  base0B: "#$(acc["green"])"
  base0C: "#$(acc["cyan"])"
  base0D: "#$(acc["blue"])"
  base0E: "#$(acc["purple"])"
  base0F: "#$(acc["magenta"])"
"""
    _write_port(target_path, content, "Base16 scheme ($slug)"; dry_run=dry_run)
end

# =============================================================================
# Main Entry Point
# =============================================================================

function main(; dry_run::Bool=true)
    println("="^80)
    println("PENUMBRA V2 DOWNSTREAM PORTS GENERATOR (dry_run = $dry_run)")
    println("="^80)

    # 1. OhMyREPL.jl
    println("\n[Julia REPL]")
    generate_ohmyrepl(dry_run=dry_run)

    # 2-7 & 11-16. Multi-tier editor, terminal, and AI CLI ports
    multi_tier_targets = [
        ("Vim / Neovim", generate_vim_theme, "vim", ".vim"),
        ("Helix Editor", generate_helix_theme, joinpath("helix", "themes"), ".toml"),
        ("iTerm2", generate_iterm2_profile, "iTerm2", ".itermcolors"),
        ("Ghostty", generate_ghostty_theme, joinpath("ghostty", "themes"), ""),
        ("Alacritty", generate_alacritty_theme, "alacritty", ".toml"),
        ("Kitty", generate_kitty_theme, "kitty", ".conf"),
        ("GIMP Palette", generate_gpl_palette, "gpl", ".gpl"),
        ("WezTerm", generate_wezterm_theme, joinpath("wezterm", "colors"), ".toml"),
        ("Warp", generate_warp_theme, joinpath("warp", "themes"), ".yaml"),
        ("TextMate .tmTheme", generate_tmtheme, "tmtheme", ".tmTheme"),
        ("Codex Desktop", generate_codex_theme, "codex", ".txt"),
        ("Claude Code CLI", generate_claude_code_theme, "claude-code", ".json"),
        ("Base16", generate_base16_theme, "base16", ".yaml"),
    ]

    tier_configs = [
        (:dark, :balanced),
        (:dark, :contrast_plus),
        (:dark, :contrast_plus_plus),
        (:light, :balanced)
    ]

    for (label, fn, dir, ext) in multi_tier_targets
        println("\n[$label]")
        for (mode, tier) in tier_configs
            stem = mode == :dark ? "penumbra_dark$(tier_suffix(tier))" : "penumbra_light"
            target_path = joinpath(@__DIR__, "..", dir, stem * ext)
            fn(mode, tier; target_path=target_path, dry_run=dry_run)
        end
    end

    # Terminal ANSI Option A ("6 from N = 8" semantic subset)
    semantic6_terminal_targets = [
        ("iTerm2 (Semantic 6)", generate_iterm2_profile, "iTerm2", ".itermcolors"),
        ("Ghostty (Semantic 6)", generate_ghostty_theme, joinpath("ghostty", "themes"), ""),
        ("Alacritty (Semantic 6)", generate_alacritty_theme, "alacritty", ".toml"),
        ("Kitty (Semantic 6)", generate_kitty_theme, "kitty", ".conf"),
        ("WezTerm (Semantic 6)", generate_wezterm_theme, joinpath("wezterm", "colors"), ".toml"),
        ("Warp (Semantic 6)", generate_warp_theme, joinpath("warp", "themes"), ".yaml"),
    ]
    for (label, fn, dir, ext) in semantic6_terminal_targets
        println("\n[$label]")
        for (mode, tier) in tier_configs
            stem = mode == :dark ? "penumbra_dark$(tier_suffix(tier))_semantic6" : "penumbra_light_semantic6"
            target_path = joinpath(@__DIR__, "..", dir, stem * ext)
            fn(mode, tier; target_path=target_path, ansi_n=8, dry_run=dry_run)
        end
    end

    # 8. Windows Terminal
    println("\n[Windows Terminal]")
    generate_windows_terminal_schemes(target_path=joinpath(@__DIR__, "..", "windows-terminal", "penumbra.json"); dry_run=dry_run)

    # 9. CSS Custom Properties
    println("\n[CSS Custom Properties]")
    generate_css_tokens(target_path=joinpath(@__DIR__, "..", "css", "penumbra.css"); dry_run=dry_run)

    # 10. Master GIMP Palette
    println("\n[GIMP Master Palette]")
    generate_gpl_all(target_path=joinpath(@__DIR__, "..", "gpl", "penumbra.gpl"); dry_run=dry_run)

    println("\n" * "="^80)
end

if abspath(PROGRAM_FILE) == @__FILE__
    dry_run = !("--write" in ARGS)
    main(dry_run=dry_run)
end
