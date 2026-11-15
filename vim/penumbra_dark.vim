" Penumbra v2 -- Vim / Neovim color scheme
" Theme: penumbra_dark (Mode: dark, Tier: balanced)
" Opponent Scheme: N = 8 (Strict Upright Typography)
" Generated deterministically by Penumbra v2 pipeline.

set background=dark

hi clear
if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "penumbra_dark"

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
hi Normal            guifg=#8B8B8B guibg=#2C2E31 gui=NONE ctermfg=245  ctermbg=236  cterm=NONE
hi NormalNC          guifg=#8B8B8B guibg=#2C2E31 gui=NONE ctermfg=245  ctermbg=236  cterm=NONE
hi NormalFloat       guifg=#8B8B8B guibg=#383A3D gui=NONE ctermfg=245  ctermbg=237  cterm=NONE
hi FloatBorder       guifg=#5E6063 guibg=#383A3D gui=NONE ctermfg=59   ctermbg=237  cterm=NONE
hi Terminal          guifg=#8B8B8B guibg=#2C2E31 gui=NONE ctermfg=245  ctermbg=236  cterm=NONE
hi ColorColumn       guifg=NONE    guibg=#383A3D gui=NONE ctermfg=NONE ctermbg=237  cterm=NONE
hi Conceal           guifg=#5E6063 guibg=NONE    gui=NONE ctermfg=59   ctermbg=NONE cterm=NONE
hi Cursor            guifg=#2C2E31 guibg=#EFE8DD gui=NONE ctermfg=236  ctermbg=254  cterm=NONE
hi CursorColumn      guifg=NONE    guibg=#3D3D3E gui=NONE ctermfg=NONE ctermbg=237  cterm=NONE
hi CursorLine        guifg=NONE    guibg=#3D3D3E gui=NONE ctermfg=NONE ctermbg=237  cterm=NONE
hi CursorLineNr      guifg=#B4B1AD guibg=#3D3D3E gui=NONE ctermfg=249  ctermbg=237  cterm=NONE
hi CursorIM          guifg=#2C2E31 guibg=#948A1D gui=NONE ctermfg=236  ctermbg=100  cterm=NONE
hi Directory         guifg=#0081B4 guibg=NONE    gui=NONE ctermfg=31   ctermbg=NONE cterm=NONE
hi DiffAdd           guifg=#4F9158 guibg=#303E35 gui=NONE ctermfg=65   ctermbg=237  cterm=NONE
hi DiffChange        guifg=#0081B4 guibg=#2A3A48 gui=NONE ctermfg=31   ctermbg=237  cterm=NONE
hi DiffDelete        guifg=#BA616A guibg=#473438 gui=NONE ctermfg=131  ctermbg=237  cterm=NONE
hi DiffText          guifg=#B4B1AD guibg=#27465C gui=bold ctermfg=249  ctermbg=24   cterm=bold
hi EndOfBuffer       guifg=#383A3D guibg=NONE    gui=NONE ctermfg=237  ctermbg=NONE cterm=NONE
hi ErrorMsg          guifg=#BA616A guibg=#2C2E31 gui=NONE ctermfg=131  ctermbg=236  cterm=NONE
hi FoldColumn        guifg=#5E6063 guibg=#2C2E31 gui=NONE ctermfg=59   ctermbg=236  cterm=NONE
hi Folded            guifg=#5E6063 guibg=#383A3D gui=NONE ctermfg=59   ctermbg=237  cterm=NONE
hi IncSearch         guifg=#B4B1AD guibg=#674935 gui=bold ctermfg=249  ctermbg=95   cterm=bold
hi LineNr            guifg=#5E6063 guibg=#2C2E31 gui=NONE ctermfg=59   ctermbg=236  cterm=NONE
hi MatchParen        guifg=#B4B1AD guibg=#383A3D gui=bold ctermfg=249  ctermbg=237  cterm=bold
hi ModeMsg           guifg=#0081B4 guibg=NONE    gui=NONE ctermfg=31   ctermbg=NONE cterm=NONE
hi MoreMsg           guifg=#0081B4 guibg=NONE    gui=NONE ctermfg=31   ctermbg=NONE cterm=NONE
hi NonText           guifg=#383A3D guibg=NONE    gui=NONE ctermfg=237  ctermbg=NONE cterm=NONE
hi Pmenu             guifg=#8B8B8B guibg=#383A3D gui=NONE ctermfg=245  ctermbg=237  cterm=NONE
hi PmenuSbar         guifg=NONE    guibg=#383A3D gui=NONE ctermfg=NONE ctermbg=237  cterm=NONE
hi PmenuSel          guifg=#B4B1AD guibg=#202225 gui=bold ctermfg=249  ctermbg=235  cterm=bold
hi PmenuThumb        guifg=NONE    guibg=#5E6063 gui=NONE ctermfg=NONE ctermbg=59   cterm=NONE
hi Question          guifg=#008986 guibg=NONE    gui=NONE ctermfg=30   ctermbg=NONE cterm=NONE
hi QuickFixLine      guifg=NONE    guibg=#504F4E gui=NONE ctermfg=NONE ctermbg=239  cterm=NONE
hi Search            guifg=#B4B1AD guibg=#523E33 gui=NONE ctermfg=249  ctermbg=238  cterm=NONE
hi SignColumn        guifg=#5E6063 guibg=#2C2E31 gui=NONE ctermfg=59   ctermbg=236  cterm=NONE
hi SpecialKey        guifg=#5E6063 guibg=NONE    gui=NONE ctermfg=59   ctermbg=NONE cterm=NONE
hi SpellBad          guifg=NONE    guibg=NONE    guisp=#BA616A gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline
hi SpellCap          guifg=NONE    guibg=NONE    guisp=#0081B4 gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline
hi SpellLocal        guifg=NONE    guibg=NONE    guisp=#008986 gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline
hi SpellRare         guifg=NONE    guibg=NONE    guisp=#7176AE gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline
hi StatusLine        guifg=#B4B1AD guibg=#383A3D gui=NONE ctermfg=249  ctermbg=237  cterm=NONE
hi StatusLineNC      guifg=#5E6063 guibg=#383A3D gui=NONE ctermfg=59   ctermbg=237  cterm=NONE
hi TabLine           guifg=#8B8B8B guibg=#383A3D gui=NONE ctermfg=245  ctermbg=237  cterm=NONE
hi TabLineFill       guifg=#5E6063 guibg=#383A3D gui=NONE ctermfg=59   ctermbg=237  cterm=NONE
hi TabLineSel        guifg=#B4B1AD guibg=#2C2E31 gui=bold ctermfg=249  ctermbg=236  cterm=bold
hi Title             guifg=#B4B1AD guibg=NONE    gui=bold ctermfg=249  ctermbg=NONE cterm=bold
hi VertSplit         guifg=#383A3D guibg=#383A3D gui=NONE ctermfg=237  ctermbg=237  cterm=NONE
hi WinSeparator      guifg=#383A3D guibg=#383A3D gui=NONE ctermfg=237  ctermbg=237  cterm=NONE
hi Visual            guifg=NONE    guibg=#504F4E gui=NONE ctermfg=NONE ctermbg=239  cterm=NONE
hi VisualNOS         guifg=NONE    guibg=#504F4E gui=NONE ctermfg=NONE ctermbg=239  cterm=NONE
hi WarningMsg        guifg=#B3763E guibg=NONE    gui=NONE ctermfg=137  ctermbg=NONE cterm=NONE
hi WildMenu          guifg=#B4B1AD guibg=#202225 gui=bold ctermfg=249  ctermbg=235  cterm=bold
hi WinBar            guifg=#B4B1AD guibg=#2C2E31 gui=NONE ctermfg=249  ctermbg=236  cterm=NONE
hi WinBarNC          guifg=#5E6063 guibg=#2C2E31 gui=NONE ctermfg=59   ctermbg=236  cterm=NONE

" ---------------------------------------------------------------------------
" Syntax Groups (Strict Upright Roman)
" ---------------------------------------------------------------------------
hi Comment           guifg=#5E6063 guibg=NONE    gui=NONE ctermfg=59   ctermbg=NONE cterm=NONE
hi Constant          guifg=#B3763E guibg=NONE    gui=NONE ctermfg=137  ctermbg=NONE cterm=NONE
hi String            guifg=#4F9158 guibg=NONE    gui=NONE ctermfg=65   ctermbg=NONE cterm=NONE
hi Character         guifg=#4F9158 guibg=NONE    gui=NONE ctermfg=65   ctermbg=NONE cterm=NONE
hi Identifier        guifg=#8B8B8B guibg=NONE    gui=NONE ctermfg=245  ctermbg=NONE cterm=NONE
hi Function          guifg=#0081B4 guibg=NONE    gui=NONE ctermfg=31   ctermbg=NONE cterm=NONE
hi Statement         guifg=#7176AE guibg=NONE    gui=NONE ctermfg=103  ctermbg=NONE cterm=NONE
hi Operator          guifg=#008986 guibg=NONE    gui=NONE ctermfg=30   ctermbg=NONE cterm=NONE
hi PreProc           guifg=#BA616A guibg=NONE    gui=NONE ctermfg=131  ctermbg=NONE cterm=NONE
hi Type              guifg=#948A1D guibg=NONE    gui=NONE ctermfg=100  ctermbg=NONE cterm=NONE
hi Special           guifg=#9C67A1 guibg=NONE    gui=NONE ctermfg=133  ctermbg=NONE cterm=NONE
hi Delimiter         guifg=#8B8B8B guibg=NONE    gui=NONE ctermfg=245  ctermbg=NONE cterm=NONE
hi Underlined        guifg=#0081B4 guibg=NONE    gui=underline ctermfg=31   ctermbg=NONE cterm=underline
hi Ignore            guifg=#5E6063 guibg=NONE    gui=NONE ctermfg=59   ctermbg=NONE cterm=NONE
hi Error             guifg=#BA616A guibg=#2C2E31 gui=NONE ctermfg=131  ctermbg=236  cterm=NONE
hi Todo              guifg=#948A1D guibg=#2C2E31 gui=bold ctermfg=100  ctermbg=236  cterm=bold

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
  let g:terminal_color_0 = '#202225'
  let g:terminal_color_1 = '#BA5B78'
  let g:terminal_color_2 = '#759122'
  let g:terminal_color_3 = '#B47632'
  let g:terminal_color_4 = '#007FBA'
  let g:terminal_color_5 = '#836FAE'
  let g:terminal_color_6 = '#008B7C'
  let g:terminal_color_7 = '#EFE8DD'
  let g:terminal_color_8 = '#5E6063'
  let g:terminal_color_9 = '#BA5B78'
  let g:terminal_color_10 = '#759122'
  let g:terminal_color_11 = '#B47632'
  let g:terminal_color_12 = '#007FBA'
  let g:terminal_color_13 = '#836FAE'
  let g:terminal_color_14 = '#008B7C'
  let g:terminal_color_15 = '#FFF6E9'
  hi DiagnosticError   guifg=#BA616A guibg=NONE    gui=NONE ctermfg=131  ctermbg=NONE cterm=NONE
  hi DiagnosticWarn    guifg=#B3763E guibg=NONE    gui=NONE ctermfg=137  ctermbg=NONE cterm=NONE
  hi DiagnosticInfo    guifg=#0081B4 guibg=NONE    gui=NONE ctermfg=31   ctermbg=NONE cterm=NONE
  hi DiagnosticHint    guifg=#008986 guibg=NONE    gui=NONE ctermfg=30   ctermbg=NONE cterm=NONE
  hi DiagnosticOk      guifg=#4F9158 guibg=NONE    gui=NONE ctermfg=65   ctermbg=NONE cterm=NONE
  hi DiagnosticUnderlineError guifg=NONE    guibg=NONE    guisp=#BA616A gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline
  hi DiagnosticUnderlineWarn guifg=NONE    guibg=NONE    guisp=#B3763E gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline
  hi DiagnosticUnderlineInfo guifg=NONE    guibg=NONE    guisp=#0081B4 gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline
  hi DiagnosticUnderlineHint guifg=NONE    guibg=NONE    guisp=#008986 gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline
  hi DiagnosticUnderlineOk guifg=NONE    guibg=NONE    guisp=#4F9158 gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline
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
  let g:terminal_ansi_colors = ['#202225', '#BA5B78', '#759122', '#B47632', '#007FBA', '#836FAE', '#008B7C', '#EFE8DD', '#5E6063', '#BA5B78', '#759122', '#B47632', '#007FBA', '#836FAE', '#008B7C', '#FFF6E9']
endif
