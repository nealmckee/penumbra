" Penumbra v2 -- Vim / Neovim color scheme
" Theme: penumbra_dark+ (Mode: dark, Tier: contrast_plus)
" Opponent Scheme: N = 8 (Strict Upright Typography)
" Generated deterministically by Penumbra v2 pipeline.

set background=dark

hi clear
if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "penumbra_dark+"

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
hi Normal            guifg=#999999 guibg=#1D2024 gui=NONE ctermfg=247  ctermbg=234  cterm=NONE
hi NormalNC          guifg=#999999 guibg=#1D2024 gui=NONE ctermfg=247  ctermbg=234  cterm=NONE
hi NormalFloat       guifg=#999999 guibg=#292B30 gui=NONE ctermfg=247  ctermbg=235  cterm=NONE
hi FloatBorder       guifg=#5B5D62 guibg=#292B30 gui=NONE ctermfg=59   ctermbg=235  cterm=NONE
hi Terminal          guifg=#999999 guibg=#1D2024 gui=NONE ctermfg=247  ctermbg=234  cterm=NONE
hi ColorColumn       guifg=NONE    guibg=#292B30 gui=NONE ctermfg=NONE ctermbg=235  cterm=NONE
hi Conceal           guifg=#5B5D62 guibg=NONE    gui=NONE ctermfg=59   ctermbg=NONE cterm=NONE
hi Cursor            guifg=#1D2024 guibg=#EFE8DD gui=NONE ctermfg=234  ctermbg=254  cterm=NONE
hi CursorColumn      guifg=NONE    guibg=#333435 gui=NONE ctermfg=NONE ctermbg=236  cterm=NONE
hi CursorLine        guifg=NONE    guibg=#333435 gui=NONE ctermfg=NONE ctermbg=236  cterm=NONE
hi CursorLineNr      guifg=#BAB8B4 guibg=#333435 gui=NONE ctermfg=250  ctermbg=236  cterm=NONE
hi CursorIM          guifg=#1D2024 guibg=#A39720 gui=NONE ctermfg=234  ctermbg=100  cterm=NONE
hi Directory         guifg=#008FC6 guibg=NONE    gui=NONE ctermfg=31   ctermbg=NONE cterm=NONE
hi DiffAdd           guifg=#58A061 guibg=#26392D gui=NONE ctermfg=71   ctermbg=236  cterm=NONE
hi DiffChange        guifg=#008FC6 guibg=#1C3546 gui=NONE ctermfg=31   ctermbg=236  cterm=NONE
hi DiffDelete        guifg=#CD6B76 guibg=#452C31 gui=NONE ctermfg=167  ctermbg=236  cterm=NONE
hi DiffText          guifg=#BAB8B4 guibg=#1A4660 gui=bold ctermfg=250  ctermbg=24   cterm=bold
hi EndOfBuffer       guifg=#292B30 guibg=NONE    gui=NONE ctermfg=235  ctermbg=NONE cterm=NONE
hi ErrorMsg          guifg=#CD6B76 guibg=#1D2024 gui=NONE ctermfg=167  ctermbg=234  cterm=NONE
hi FoldColumn        guifg=#5B5D62 guibg=#1D2024 gui=NONE ctermfg=59   ctermbg=234  cterm=NONE
hi Folded            guifg=#5B5D62 guibg=#292B30 gui=NONE ctermfg=59   ctermbg=235  cterm=NONE
hi IncSearch         guifg=#BAB8B4 guibg=#6D4A2F gui=bold ctermfg=250  ctermbg=94   cterm=bold
hi LineNr            guifg=#5B5D62 guibg=#1D2024 gui=NONE ctermfg=59   ctermbg=234  cterm=NONE
hi MatchParen        guifg=#BAB8B4 guibg=#292B30 gui=bold ctermfg=250  ctermbg=235  cterm=bold
hi ModeMsg           guifg=#008FC6 guibg=NONE    gui=NONE ctermfg=31   ctermbg=NONE cterm=NONE
hi MoreMsg           guifg=#008FC6 guibg=NONE    gui=NONE ctermfg=31   ctermbg=NONE cterm=NONE
hi NonText           guifg=#292B30 guibg=NONE    gui=NONE ctermfg=235  ctermbg=NONE cterm=NONE
hi Pmenu             guifg=#999999 guibg=#292B30 gui=NONE ctermfg=247  ctermbg=235  cterm=NONE
hi PmenuSbar         guifg=NONE    guibg=#292B30 gui=NONE ctermfg=NONE ctermbg=235  cterm=NONE
hi PmenuSel          guifg=#BAB8B4 guibg=#131418 gui=bold ctermfg=250  ctermbg=233  cterm=bold
hi PmenuThumb        guifg=NONE    guibg=#5B5D62 gui=NONE ctermfg=NONE ctermbg=59   cterm=NONE
hi Question          guifg=#009894 guibg=NONE    gui=NONE ctermfg=30   ctermbg=NONE cterm=NONE
hi QuickFixLine      guifg=NONE    guibg=#4A4947 gui=NONE ctermfg=NONE ctermbg=239  cterm=NONE
hi Search            guifg=#BAB8B4 guibg=#543B2A gui=NONE ctermfg=250  ctermbg=238  cterm=NONE
hi SignColumn        guifg=#5B5D62 guibg=#1D2024 gui=NONE ctermfg=59   ctermbg=234  cterm=NONE
hi SpecialKey        guifg=#5B5D62 guibg=NONE    gui=NONE ctermfg=59   ctermbg=NONE cterm=NONE
hi SpellBad          guifg=NONE    guibg=NONE    guisp=#CD6B76 gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline
hi SpellCap          guifg=NONE    guibg=NONE    guisp=#008FC6 gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline
hi SpellLocal        guifg=NONE    guibg=NONE    guisp=#009894 gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline
hi SpellRare         guifg=NONE    guibg=NONE    guisp=#7D82C0 gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline
hi StatusLine        guifg=#BAB8B4 guibg=#292B30 gui=NONE ctermfg=250  ctermbg=235  cterm=NONE
hi StatusLineNC      guifg=#5B5D62 guibg=#292B30 gui=NONE ctermfg=59   ctermbg=235  cterm=NONE
hi TabLine           guifg=#999999 guibg=#292B30 gui=NONE ctermfg=247  ctermbg=235  cterm=NONE
hi TabLineFill       guifg=#5B5D62 guibg=#292B30 gui=NONE ctermfg=59   ctermbg=235  cterm=NONE
hi TabLineSel        guifg=#BAB8B4 guibg=#1D2024 gui=bold ctermfg=250  ctermbg=234  cterm=bold
hi Title             guifg=#BAB8B4 guibg=NONE    gui=bold ctermfg=250  ctermbg=NONE cterm=bold
hi VertSplit         guifg=#292B30 guibg=#292B30 gui=NONE ctermfg=235  ctermbg=235  cterm=NONE
hi WinSeparator      guifg=#292B30 guibg=#292B30 gui=NONE ctermfg=235  ctermbg=235  cterm=NONE
hi Visual            guifg=NONE    guibg=#4A4947 gui=NONE ctermfg=NONE ctermbg=239  cterm=NONE
hi VisualNOS         guifg=NONE    guibg=#4A4947 gui=NONE ctermfg=NONE ctermbg=239  cterm=NONE
hi WarningMsg        guifg=#C58145 guibg=NONE    gui=NONE ctermfg=137  ctermbg=NONE cterm=NONE
hi WildMenu          guifg=#BAB8B4 guibg=#131418 gui=bold ctermfg=250  ctermbg=233  cterm=bold
hi WinBar            guifg=#BAB8B4 guibg=#1D2024 gui=NONE ctermfg=250  ctermbg=234  cterm=NONE
hi WinBarNC          guifg=#5B5D62 guibg=#1D2024 gui=NONE ctermfg=59   ctermbg=234  cterm=NONE

" ---------------------------------------------------------------------------
" Syntax Groups (Strict Upright Roman)
" ---------------------------------------------------------------------------
hi Comment           guifg=#5B5D62 guibg=NONE    gui=NONE ctermfg=59   ctermbg=NONE cterm=NONE
hi Constant          guifg=#C58145 guibg=NONE    gui=NONE ctermfg=137  ctermbg=NONE cterm=NONE
hi String            guifg=#58A061 guibg=NONE    gui=NONE ctermfg=71   ctermbg=NONE cterm=NONE
hi Character         guifg=#58A061 guibg=NONE    gui=NONE ctermfg=71   ctermbg=NONE cterm=NONE
hi Identifier        guifg=#999999 guibg=NONE    gui=NONE ctermfg=247  ctermbg=NONE cterm=NONE
hi Function          guifg=#008FC6 guibg=NONE    gui=NONE ctermfg=31   ctermbg=NONE cterm=NONE
hi Statement         guifg=#7D82C0 guibg=NONE    gui=NONE ctermfg=104  ctermbg=NONE cterm=NONE
hi Operator          guifg=#009894 guibg=NONE    gui=NONE ctermfg=30   ctermbg=NONE cterm=NONE
hi PreProc           guifg=#CD6B76 guibg=NONE    gui=NONE ctermfg=167  ctermbg=NONE cterm=NONE
hi Type              guifg=#A39720 guibg=NONE    gui=NONE ctermfg=100  ctermbg=NONE cterm=NONE
hi Special           guifg=#AC72B2 guibg=NONE    gui=NONE ctermfg=133  ctermbg=NONE cterm=NONE
hi Delimiter         guifg=#999999 guibg=NONE    gui=NONE ctermfg=247  ctermbg=NONE cterm=NONE
hi Underlined        guifg=#008FC6 guibg=NONE    gui=underline ctermfg=31   ctermbg=NONE cterm=underline
hi Ignore            guifg=#5B5D62 guibg=NONE    gui=NONE ctermfg=59   ctermbg=NONE cterm=NONE
hi Error             guifg=#CD6B76 guibg=#1D2024 gui=NONE ctermfg=167  ctermbg=234  cterm=NONE
hi Todo              guifg=#A39720 guibg=#1D2024 gui=bold ctermfg=100  ctermbg=234  cterm=bold

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
  let g:terminal_color_0 = '#131418'
  let g:terminal_color_1 = '#CD6584'
  let g:terminal_color_2 = '#81A026'
  let g:terminal_color_3 = '#C68237'
  let g:terminal_color_4 = '#008CCD'
  let g:terminal_color_5 = '#917BBF'
  let g:terminal_color_6 = '#009989'
  let g:terminal_color_7 = '#EFE8DD'
  let g:terminal_color_8 = '#5B5D62'
  let g:terminal_color_9 = '#CD6584'
  let g:terminal_color_10 = '#81A026'
  let g:terminal_color_11 = '#C68237'
  let g:terminal_color_12 = '#008CCD'
  let g:terminal_color_13 = '#917BBF'
  let g:terminal_color_14 = '#009989'
  let g:terminal_color_15 = '#FFF6E9'
  hi DiagnosticError   guifg=#CD6B76 guibg=NONE    gui=NONE ctermfg=167  ctermbg=NONE cterm=NONE
  hi DiagnosticWarn    guifg=#C58145 guibg=NONE    gui=NONE ctermfg=137  ctermbg=NONE cterm=NONE
  hi DiagnosticInfo    guifg=#008FC6 guibg=NONE    gui=NONE ctermfg=31   ctermbg=NONE cterm=NONE
  hi DiagnosticHint    guifg=#009894 guibg=NONE    gui=NONE ctermfg=30   ctermbg=NONE cterm=NONE
  hi DiagnosticOk      guifg=#58A061 guibg=NONE    gui=NONE ctermfg=71   ctermbg=NONE cterm=NONE
  hi DiagnosticUnderlineError guifg=NONE    guibg=NONE    guisp=#CD6B76 gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline
  hi DiagnosticUnderlineWarn guifg=NONE    guibg=NONE    guisp=#C58145 gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline
  hi DiagnosticUnderlineInfo guifg=NONE    guibg=NONE    guisp=#008FC6 gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline
  hi DiagnosticUnderlineHint guifg=NONE    guibg=NONE    guisp=#009894 gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline
  hi DiagnosticUnderlineOk guifg=NONE    guibg=NONE    guisp=#58A061 gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline
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
  let g:terminal_ansi_colors = ['#131418', '#CD6584', '#81A026', '#C68237', '#008CCD', '#917BBF', '#009989', '#EFE8DD', '#5B5D62', '#CD6584', '#81A026', '#C68237', '#008CCD', '#917BBF', '#009989', '#FFF6E9']
endif
