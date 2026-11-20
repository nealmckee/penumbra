" Penumbra v2 -- Vim / Neovim color scheme
" Theme: penumbra_dark++ (Mode: dark, Tier: contrast_plus_plus)
" Opponent Scheme: N = 8 (Strict Upright Typography)
" Generated deterministically by Penumbra v2 pipeline.

set background=dark

hi clear
if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "penumbra_dark++"

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
hi Normal            guifg=#A9A9A9 guibg=#101317 gui=NONE ctermfg=248  ctermbg=233  cterm=NONE
hi NormalNC          guifg=#A9A9A9 guibg=#101317 gui=NONE ctermfg=248  ctermbg=233  cterm=NONE
hi NormalFloat       guifg=#A9A9A9 guibg=#1B1E23 gui=NONE ctermfg=248  ctermbg=234  cterm=NONE
hi FloatBorder       guifg=#575B62 guibg=#1B1E23 gui=NONE ctermfg=240  ctermbg=234  cterm=NONE
hi Terminal          guifg=#A9A9A9 guibg=#101317 gui=NONE ctermfg=248  ctermbg=233  cterm=NONE
hi ColorColumn       guifg=NONE    guibg=#1B1E23 gui=NONE ctermfg=NONE ctermbg=234  cterm=NONE
hi Conceal           guifg=#575B62 guibg=NONE    gui=NONE ctermfg=240  ctermbg=NONE cterm=NONE
hi Cursor            guifg=#101317 guibg=#EEE8DD gui=NONE ctermfg=233  ctermbg=254  cterm=NONE
hi CursorColumn      guifg=NONE    guibg=#2D2D2D gui=NONE ctermfg=NONE ctermbg=236  cterm=NONE
hi CursorLine        guifg=NONE    guibg=#2D2D2D gui=NONE ctermfg=NONE ctermbg=236  cterm=NONE
hi CursorLineNr      guifg=#C2C0BD guibg=#2D2D2D gui=NONE ctermfg=250  ctermbg=236  cterm=NONE
hi CursorIM          guifg=#101317 guibg=#B4A724 gui=NONE ctermfg=233  ctermbg=142  cterm=NONE
hi Directory         guifg=#009EDB guibg=NONE    gui=NONE ctermfg=39   ctermbg=NONE cterm=NONE
hi DiffAdd           guifg=#62B06C guibg=#203927 gui=NONE ctermfg=71   ctermbg=236  cterm=NONE
hi DiffChange        guifg=#009EDB guibg=#0F3348 gui=NONE ctermfg=39   ctermbg=236  cterm=NONE
hi DiffDelete        guifg=#E17782 guibg=#48272D gui=NONE ctermfg=174  ctermbg=52   cterm=NONE
hi DiffText          guifg=#C2C0BD guibg=#0E4967 gui=bold ctermfg=250  ctermbg=24   cterm=bold
hi EndOfBuffer       guifg=#1B1E23 guibg=NONE    gui=NONE ctermfg=234  ctermbg=NONE cterm=NONE
hi ErrorMsg          guifg=#E17782 guibg=#101317 gui=NONE ctermfg=174  ctermbg=233  cterm=NONE
hi FoldColumn        guifg=#575B62 guibg=#101317 gui=NONE ctermfg=240  ctermbg=233  cterm=NONE
hi Folded            guifg=#575B62 guibg=#1B1E23 gui=NONE ctermfg=240  ctermbg=234  cterm=NONE
hi IncSearch         guifg=#C2C0BD guibg=#764E2C gui=bold ctermfg=250  ctermbg=94   cterm=bold
hi LineNr            guifg=#575B62 guibg=#101317 gui=NONE ctermfg=240  ctermbg=233  cterm=NONE
hi MatchParen        guifg=#C2C0BD guibg=#1B1E23 gui=bold ctermfg=250  ctermbg=234  cterm=bold
hi ModeMsg           guifg=#009EDB guibg=NONE    gui=NONE ctermfg=39   ctermbg=NONE cterm=NONE
hi MoreMsg           guifg=#009EDB guibg=NONE    gui=NONE ctermfg=39   ctermbg=NONE cterm=NONE
hi NonText           guifg=#1B1E23 guibg=NONE    gui=NONE ctermfg=234  ctermbg=NONE cterm=NONE
hi Pmenu             guifg=#A9A9A9 guibg=#1B1E23 gui=NONE ctermfg=248  ctermbg=234  cterm=NONE
hi PmenuSbar         guifg=NONE    guibg=#1B1E23 gui=NONE ctermfg=NONE ctermbg=234  cterm=NONE
hi PmenuSel          guifg=#C2C0BD guibg=#07080B gui=bold ctermfg=250  ctermbg=232  cterm=bold
hi PmenuThumb        guifg=NONE    guibg=#575B62 gui=NONE ctermfg=NONE ctermbg=240  cterm=NONE
hi Question          guifg=#00A8A4 guibg=NONE    gui=NONE ctermfg=37   ctermbg=NONE cterm=NONE
hi QuickFixLine      guifg=NONE    guibg=#464442 gui=NONE ctermfg=NONE ctermbg=238  cterm=NONE
hi Search            guifg=#C2C0BD guibg=#593B24 gui=NONE ctermfg=250  ctermbg=238  cterm=NONE
hi SignColumn        guifg=#575B62 guibg=#101317 gui=NONE ctermfg=240  ctermbg=233  cterm=NONE
hi SpecialKey        guifg=#575B62 guibg=NONE    gui=NONE ctermfg=240  ctermbg=NONE cterm=NONE
hi SpellBad          guifg=NONE    guibg=NONE    guisp=#E17782 gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline
hi SpellCap          guifg=NONE    guibg=NONE    guisp=#009EDB gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline
hi SpellLocal        guifg=NONE    guibg=NONE    guisp=#00A8A4 gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline
hi SpellRare         guifg=NONE    guibg=NONE    guisp=#8A90D4 gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline
hi StatusLine        guifg=#C2C0BD guibg=#1B1E23 gui=NONE ctermfg=250  ctermbg=234  cterm=NONE
hi StatusLineNC      guifg=#575B62 guibg=#1B1E23 gui=NONE ctermfg=240  ctermbg=234  cterm=NONE
hi TabLine           guifg=#A9A9A9 guibg=#1B1E23 gui=NONE ctermfg=248  ctermbg=234  cterm=NONE
hi TabLineFill       guifg=#575B62 guibg=#1B1E23 gui=NONE ctermfg=240  ctermbg=234  cterm=NONE
hi TabLineSel        guifg=#C2C0BD guibg=#101317 gui=bold ctermfg=250  ctermbg=233  cterm=bold
hi Title             guifg=#C2C0BD guibg=NONE    gui=bold ctermfg=250  ctermbg=NONE cterm=bold
hi VertSplit         guifg=#1B1E23 guibg=#1B1E23 gui=NONE ctermfg=234  ctermbg=234  cterm=NONE
hi WinSeparator      guifg=#1B1E23 guibg=#1B1E23 gui=NONE ctermfg=234  ctermbg=234  cterm=NONE
hi Visual            guifg=NONE    guibg=#464442 gui=NONE ctermfg=NONE ctermbg=238  cterm=NONE
hi VisualNOS         guifg=NONE    guibg=#464442 gui=NONE ctermfg=NONE ctermbg=238  cterm=NONE
hi WarningMsg        guifg=#D88F4C guibg=NONE    gui=NONE ctermfg=172  ctermbg=NONE cterm=NONE
hi WildMenu          guifg=#C2C0BD guibg=#07080B gui=bold ctermfg=250  ctermbg=232  cterm=bold
hi WinBar            guifg=#C2C0BD guibg=#101317 gui=NONE ctermfg=250  ctermbg=233  cterm=NONE
hi WinBarNC          guifg=#575B62 guibg=#101317 gui=NONE ctermfg=240  ctermbg=233  cterm=NONE

" ---------------------------------------------------------------------------
" Syntax Groups (Strict Upright Roman)
" ---------------------------------------------------------------------------
hi Comment           guifg=#575B62 guibg=NONE    gui=NONE ctermfg=240  ctermbg=NONE cterm=NONE
hi Constant          guifg=#D88F4C guibg=NONE    gui=NONE ctermfg=172  ctermbg=NONE cterm=NONE
hi String            guifg=#62B06C guibg=NONE    gui=NONE ctermfg=71   ctermbg=NONE cterm=NONE
hi Character         guifg=#62B06C guibg=NONE    gui=NONE ctermfg=71   ctermbg=NONE cterm=NONE
hi Identifier        guifg=#A9A9A9 guibg=NONE    gui=NONE ctermfg=248  ctermbg=NONE cterm=NONE
hi Function          guifg=#009EDB guibg=NONE    gui=NONE ctermfg=39   ctermbg=NONE cterm=NONE
hi Statement         guifg=#8A90D4 guibg=NONE    gui=NONE ctermfg=104  ctermbg=NONE cterm=NONE
hi Operator          guifg=#00A8A4 guibg=NONE    gui=NONE ctermfg=37   ctermbg=NONE cterm=NONE
hi PreProc           guifg=#E17782 guibg=NONE    gui=NONE ctermfg=174  ctermbg=NONE cterm=NONE
hi Type              guifg=#B4A724 guibg=NONE    gui=NONE ctermfg=142  ctermbg=NONE cterm=NONE
hi Special           guifg=#BE7FC4 guibg=NONE    gui=NONE ctermfg=176  ctermbg=NONE cterm=NONE
hi Delimiter         guifg=#A9A9A9 guibg=NONE    gui=NONE ctermfg=248  ctermbg=NONE cterm=NONE
hi Underlined        guifg=#009EDB guibg=NONE    gui=underline ctermfg=39   ctermbg=NONE cterm=underline
hi Ignore            guifg=#575B62 guibg=NONE    gui=NONE ctermfg=240  ctermbg=NONE cterm=NONE
hi Error             guifg=#E17782 guibg=#101317 gui=NONE ctermfg=174  ctermbg=233  cterm=NONE
hi Todo              guifg=#B4A724 guibg=#101317 gui=bold ctermfg=142  ctermbg=233  cterm=bold

" ---------------------------------------------------------------------------
" 16-Color / 8-Color Terminal Fallback (assumes Penumbra terminal palette)
" ---------------------------------------------------------------------------
if !has('gui_running') && !(has('termguicolors') && &termguicolors) && &t_Co < 256
  hi Normal       ctermfg=NONE          ctermbg=NONE         cterm=NONE
  hi Terminal     ctermfg=NONE          ctermbg=NONE         cterm=NONE
  hi ColorColumn  ctermfg=NONE          ctermbg=0 cterm=NONE
  hi CursorLine   ctermfg=NONE          ctermbg=0 cterm=NONE
  hi CursorLineNr ctermfg=15 ctermbg=0 cterm=NONE
  hi LineNr       ctermfg=8 ctermbg=NONE         cterm=NONE
  hi NonText      ctermfg=8 ctermbg=NONE         cterm=NONE
  hi StatusLine   ctermfg=15 ctermbg=0 cterm=NONE
  hi StatusLineNC ctermfg=8 ctermbg=0 cterm=NONE
  hi TabLine      ctermfg=NONE          ctermbg=0 cterm=NONE
  hi TabLineFill  ctermfg=8 ctermbg=0 cterm=NONE
  hi TabLineSel   ctermfg=15 ctermbg=NONE         cterm=bold
  hi Pmenu        ctermfg=NONE          ctermbg=0 cterm=NONE
  hi PmenuSbar    ctermfg=NONE          ctermbg=0 cterm=NONE
  hi PmenuSel     ctermfg=0     ctermbg=7    cterm=bold
  hi PmenuThumb   ctermfg=NONE          ctermbg=8 cterm=NONE
  hi VertSplit    ctermfg=0  ctermbg=0 cterm=NONE
  hi Visual       ctermfg=NONE          ctermbg=NONE         cterm=reverse
  hi VisualNOS    ctermfg=NONE          ctermbg=NONE         cterm=reverse
  hi Search       ctermfg=0             ctermbg=3            cterm=NONE
  hi IncSearch    ctermfg=0             ctermbg=3            cterm=bold
  hi MatchParen   ctermfg=15 ctermbg=0 cterm=bold
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
  hi Title        ctermfg=15 ctermbg=NONE         cterm=bold
  hi WildMenu     ctermfg=0     ctermbg=7    cterm=bold
  hi Comment      ctermfg=8 ctermbg=NONE         cterm=NONE
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
  let g:terminal_color_0 = '#07080B'
  let g:terminal_color_1 = '#E27092'
  let g:terminal_color_2 = '#8EB02A'
  let g:terminal_color_3 = '#DA8F3E'
  let g:terminal_color_4 = '#009BE2'
  let g:terminal_color_5 = '#A088D3'
  let g:terminal_color_6 = '#00AA98'
  let g:terminal_color_7 = '#EEE8DD'
  let g:terminal_color_8 = '#575B62'
  let g:terminal_color_9 = '#E27092'
  let g:terminal_color_10 = '#8EB02A'
  let g:terminal_color_11 = '#DA8F3E'
  let g:terminal_color_12 = '#009BE2'
  let g:terminal_color_13 = '#A088D3'
  let g:terminal_color_14 = '#00AA98'
  let g:terminal_color_15 = '#FFF6E9'
  hi DiagnosticError   guifg=#E17782 guibg=NONE    gui=NONE ctermfg=174  ctermbg=NONE cterm=NONE
  hi DiagnosticWarn    guifg=#D88F4C guibg=NONE    gui=NONE ctermfg=172  ctermbg=NONE cterm=NONE
  hi DiagnosticInfo    guifg=#009EDB guibg=NONE    gui=NONE ctermfg=39   ctermbg=NONE cterm=NONE
  hi DiagnosticHint    guifg=#00A8A4 guibg=NONE    gui=NONE ctermfg=37   ctermbg=NONE cterm=NONE
  hi DiagnosticOk      guifg=#62B06C guibg=NONE    gui=NONE ctermfg=71   ctermbg=NONE cterm=NONE
  hi DiagnosticUnderlineError guifg=NONE    guibg=NONE    guisp=#E17782 gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline
  hi DiagnosticUnderlineWarn guifg=NONE    guibg=NONE    guisp=#D88F4C gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline
  hi DiagnosticUnderlineInfo guifg=NONE    guibg=NONE    guisp=#009EDB gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline
  hi DiagnosticUnderlineHint guifg=NONE    guibg=NONE    guisp=#00A8A4 gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline
  hi DiagnosticUnderlineOk guifg=NONE    guibg=NONE    guisp=#62B06C gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline
  hi! link @comment             Comment
  hi! link @constant            Constant
  hi! link @constant.builtin    Constant
  hi! link @number              Number
  hi! link @boolean             Boolean
  hi! link @string              String
  hi! link @string.regexp       Special
  hi! link @character           String
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
  hi! link @markup.strikethrough Comment
  hi! link @diff.plus           DiffAdd
  hi! link @diff.minus          DiffDelete
  hi! link @diff.delta          DiffChange
elseif (has('termguicolors') && &termguicolors) || has('gui_running')
  let g:terminal_ansi_colors = ['#07080B', '#E27092', '#8EB02A', '#DA8F3E', '#009BE2', '#A088D3', '#00AA98', '#EEE8DD', '#575B62', '#E27092', '#8EB02A', '#DA8F3E', '#009BE2', '#A088D3', '#00AA98', '#FFF6E9']
endif
