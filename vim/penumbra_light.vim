" Penumbra v2 -- Vim / Neovim color scheme
" Theme: penumbra_light (Mode: light, Tier: balanced)
" Opponent Scheme: N = 7 (Strict Upright Typography)
" Generated deterministically by Penumbra v2 pipeline.

set background=light

hi clear
if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "penumbra_light"

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
hi Normal            guifg=#8B8B8B guibg=#EFE8DD gui=NONE ctermfg=245  ctermbg=254  cterm=NONE
hi NormalNC          guifg=#8B8B8B guibg=#EFE8DD gui=NONE ctermfg=245  ctermbg=254  cterm=NONE
hi NormalFloat       guifg=#8B8B8B guibg=#DFD9D0 gui=NONE ctermfg=245  ctermbg=253  cterm=NONE
hi FloatBorder       guifg=#B4B1AD guibg=#DFD9D0 gui=NONE ctermfg=249  ctermbg=253  cterm=NONE
hi Terminal          guifg=#8B8B8B guibg=#EFE8DD gui=NONE ctermfg=245  ctermbg=254  cterm=NONE
hi ColorColumn       guifg=NONE    guibg=#DFD9D0 gui=NONE ctermfg=NONE ctermbg=253  cterm=NONE
hi Conceal           guifg=#B4B1AD guibg=NONE    gui=NONE ctermfg=249  ctermbg=NONE cterm=NONE
hi Cursor            guifg=#EFE8DD guibg=#2C2E31 gui=NONE ctermfg=254  ctermbg=236  cterm=NONE
hi CursorColumn      guifg=NONE    guibg=#E4DED3 gui=NONE ctermfg=NONE ctermbg=253  cterm=NONE
hi CursorLine        guifg=NONE    guibg=#E4DED3 gui=NONE ctermfg=NONE ctermbg=253  cterm=NONE
hi CursorLineNr      guifg=#5E6063 guibg=#E4DED3 gui=NONE ctermfg=59   ctermbg=253  cterm=NONE
hi CursorIM          guifg=#EFE8DD guibg=#948A2C gui=NONE ctermfg=254  ctermbg=100  cterm=NONE
hi Directory         guifg=#537DB2 guibg=NONE    gui=NONE ctermfg=67   ctermbg=NONE cterm=NONE
hi DiffAdd           guifg=#509064 guibg=#E0DED0 gui=NONE ctermfg=65   ctermbg=253  cterm=NONE
hi DiffChange        guifg=#537DB2 guibg=#E0DCD7 gui=NONE ctermfg=67   ctermbg=253  cterm=NONE
hi DiffDelete        guifg=#B4637F guibg=#E7DAD2 gui=NONE ctermfg=132  ctermbg=253  cterm=NONE
hi DiffText          guifg=#5E6063 guibg=#D0CFD1 gui=bold ctermfg=59   ctermbg=252  cterm=bold
hi EndOfBuffer       guifg=#DFD9D0 guibg=NONE    gui=NONE ctermfg=253  ctermbg=NONE cterm=NONE
hi ErrorMsg          guifg=#B4637F guibg=#EFE8DD gui=NONE ctermfg=132  ctermbg=254  cterm=NONE
hi FoldColumn        guifg=#B4B1AD guibg=#EFE8DD gui=NONE ctermfg=249  ctermbg=254  cterm=NONE
hi Folded            guifg=#B4B1AD guibg=#DFD9D0 gui=NONE ctermfg=249  ctermbg=253  cterm=NONE
hi IncSearch         guifg=#5E6063 guibg=#D8C3B3 gui=bold ctermfg=59   ctermbg=180  cterm=bold
hi LineNr            guifg=#B4B1AD guibg=#EFE8DD gui=NONE ctermfg=249  ctermbg=254  cterm=NONE
hi MatchParen        guifg=#5E6063 guibg=#DFD9D0 gui=bold ctermfg=59   ctermbg=253  cterm=bold
hi ModeMsg           guifg=#537DB2 guibg=NONE    gui=NONE ctermfg=67   ctermbg=NONE cterm=NONE
hi MoreMsg           guifg=#537DB2 guibg=NONE    gui=NONE ctermfg=67   ctermbg=NONE cterm=NONE
hi NonText           guifg=#DFD9D0 guibg=NONE    gui=NONE ctermfg=253  ctermbg=NONE cterm=NONE
hi Pmenu             guifg=#8B8B8B guibg=#DFD9D0 gui=NONE ctermfg=245  ctermbg=253  cterm=NONE
hi PmenuSbar         guifg=NONE    guibg=#DFD9D0 gui=NONE ctermfg=NONE ctermbg=253  cterm=NONE
hi PmenuSel          guifg=#5E6063 guibg=#FFF6E9 gui=bold ctermfg=59   ctermbg=231  cterm=bold
hi PmenuThumb        guifg=NONE    guibg=#B4B1AD gui=NONE ctermfg=NONE ctermbg=249  cterm=NONE
hi Question          guifg=#008994 guibg=NONE    gui=NONE ctermfg=30   ctermbg=NONE cterm=NONE
hi QuickFixLine      guifg=NONE    guibg=#D9D3C9 gui=NONE ctermfg=NONE ctermbg=188  cterm=NONE
hi Search            guifg=#5E6063 guibg=#E2D3C5 gui=NONE ctermfg=59   ctermbg=188  cterm=NONE
hi SignColumn        guifg=#B4B1AD guibg=#EFE8DD gui=NONE ctermfg=249  ctermbg=254  cterm=NONE
hi SpecialKey        guifg=#B4B1AD guibg=NONE    gui=NONE ctermfg=249  ctermbg=NONE cterm=NONE
hi SpellBad          guifg=NONE    guibg=NONE    guisp=#B4637F gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline
hi SpellCap          guifg=NONE    guibg=NONE    guisp=#537DB2 gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline
hi SpellLocal        guifg=NONE    guibg=NONE    guisp=#008994 gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline
hi SpellRare         guifg=NONE    guibg=NONE    guisp=#8972A7 gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline
hi StatusLine        guifg=#5E6063 guibg=#DFD9D0 gui=NONE ctermfg=59   ctermbg=253  cterm=NONE
hi StatusLineNC      guifg=#B4B1AD guibg=#DFD9D0 gui=NONE ctermfg=249  ctermbg=253  cterm=NONE
hi TabLine           guifg=#8B8B8B guibg=#DFD9D0 gui=NONE ctermfg=245  ctermbg=253  cterm=NONE
hi TabLineFill       guifg=#B4B1AD guibg=#DFD9D0 gui=NONE ctermfg=249  ctermbg=253  cterm=NONE
hi TabLineSel        guifg=#5E6063 guibg=#EFE8DD gui=bold ctermfg=59   ctermbg=254  cterm=bold
hi Title             guifg=#5E6063 guibg=NONE    gui=bold ctermfg=59   ctermbg=NONE cterm=bold
hi VertSplit         guifg=#DFD9D0 guibg=#DFD9D0 gui=NONE ctermfg=253  ctermbg=253  cterm=NONE
hi WinSeparator      guifg=#DFD9D0 guibg=#DFD9D0 gui=NONE ctermfg=253  ctermbg=253  cterm=NONE
hi Visual            guifg=NONE    guibg=#D9D3C9 gui=NONE ctermfg=NONE ctermbg=188  cterm=NONE
hi VisualNOS         guifg=NONE    guibg=#D9D3C9 gui=NONE ctermfg=NONE ctermbg=188  cterm=NONE
hi WarningMsg        guifg=#B3754A guibg=NONE    gui=NONE ctermfg=137  ctermbg=NONE cterm=NONE
hi WildMenu          guifg=#5E6063 guibg=#FFF6E9 gui=bold ctermfg=59   ctermbg=231  cterm=bold
hi WinBar            guifg=#5E6063 guibg=#EFE8DD gui=NONE ctermfg=59   ctermbg=254  cterm=NONE
hi WinBarNC          guifg=#B4B1AD guibg=#EFE8DD gui=NONE ctermfg=249  ctermbg=254  cterm=NONE

" ---------------------------------------------------------------------------
" Syntax Groups (Strict Upright Roman)
" ---------------------------------------------------------------------------
hi Comment           guifg=#B4B1AD guibg=NONE    gui=NONE ctermfg=249  ctermbg=NONE cterm=NONE
hi Constant          guifg=#B3754A guibg=NONE    gui=NONE ctermfg=137  ctermbg=NONE cterm=NONE
hi String            guifg=#509064 guibg=NONE    gui=NONE ctermfg=65   ctermbg=NONE cterm=NONE
hi Character         guifg=#509064 guibg=NONE    gui=NONE ctermfg=65   ctermbg=NONE cterm=NONE
hi Identifier        guifg=#8B8B8B guibg=NONE    gui=NONE ctermfg=245  ctermbg=NONE cterm=NONE
hi Function          guifg=#537DB2 guibg=NONE    gui=NONE ctermfg=67   ctermbg=NONE cterm=NONE
hi Statement         guifg=#8972A7 guibg=NONE    gui=NONE ctermfg=97   ctermbg=NONE cterm=NONE
hi Operator          guifg=#008994 guibg=NONE    gui=NONE ctermfg=30   ctermbg=NONE cterm=NONE
hi PreProc           guifg=#B4637F guibg=NONE    gui=NONE ctermfg=132  ctermbg=NONE cterm=NONE
hi Type              guifg=#948A2C guibg=NONE    gui=NONE ctermfg=100  ctermbg=NONE cterm=NONE
hi Special           guifg=#B4637F guibg=NONE    gui=NONE ctermfg=132  ctermbg=NONE cterm=NONE
hi Delimiter         guifg=#8B8B8B guibg=NONE    gui=NONE ctermfg=245  ctermbg=NONE cterm=NONE
hi Underlined        guifg=#537DB2 guibg=NONE    gui=underline ctermfg=67   ctermbg=NONE cterm=underline
hi Ignore            guifg=#B4B1AD guibg=NONE    gui=NONE ctermfg=249  ctermbg=NONE cterm=NONE
hi Error             guifg=#B4637F guibg=#EFE8DD gui=NONE ctermfg=132  ctermbg=254  cterm=NONE
hi Todo              guifg=#948A2C guibg=#EFE8DD gui=bold ctermfg=100  ctermbg=254  cterm=bold

" ---------------------------------------------------------------------------
" 16-Color / 8-Color Terminal Fallback (assumes Penumbra terminal palette)
" ---------------------------------------------------------------------------
if !has('gui_running') && !(has('termguicolors') && &termguicolors) && &t_Co < 256
  hi Normal       ctermfg=NONE          ctermbg=NONE         cterm=NONE
  hi Terminal     ctermfg=NONE          ctermbg=NONE         cterm=NONE
  hi ColorColumn  ctermfg=NONE          ctermbg=7 cterm=NONE
  hi CursorLine   ctermfg=NONE          ctermbg=7 cterm=NONE
  hi CursorLineNr ctermfg=8 ctermbg=7 cterm=NONE
  hi LineNr       ctermfg=8 ctermbg=NONE         cterm=NONE
  hi NonText      ctermfg=8 ctermbg=NONE         cterm=NONE
  hi StatusLine   ctermfg=8 ctermbg=7 cterm=NONE
  hi StatusLineNC ctermfg=8 ctermbg=7 cterm=NONE
  hi TabLine      ctermfg=NONE          ctermbg=7 cterm=NONE
  hi TabLineFill  ctermfg=8 ctermbg=7 cterm=NONE
  hi TabLineSel   ctermfg=8 ctermbg=NONE         cterm=bold
  hi Pmenu        ctermfg=NONE          ctermbg=7 cterm=NONE
  hi PmenuSbar    ctermfg=NONE          ctermbg=7 cterm=NONE
  hi PmenuSel     ctermfg=0     ctermbg=3    cterm=bold
  hi PmenuThumb   ctermfg=NONE          ctermbg=8 cterm=NONE
  hi VertSplit    ctermfg=7  ctermbg=7 cterm=NONE
  hi Visual       ctermfg=NONE          ctermbg=NONE         cterm=reverse
  hi VisualNOS    ctermfg=NONE          ctermbg=NONE         cterm=reverse
  hi Search       ctermfg=0             ctermbg=3            cterm=NONE
  hi IncSearch    ctermfg=0             ctermbg=3            cterm=bold
  hi MatchParen   ctermfg=8 ctermbg=7 cterm=bold
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
  hi Title        ctermfg=8 ctermbg=NONE         cterm=bold
  hi WildMenu     ctermfg=0     ctermbg=3    cterm=bold
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
  let g:terminal_color_1 = '#B86960'
  let g:terminal_color_2 = '#599159'
  let g:terminal_color_3 = '#A48334'
  let g:terminal_color_4 = '#5F7BB0'
  let g:terminal_color_5 = '#996CA1'
  let g:terminal_color_6 = '#008993'
  let g:terminal_color_7 = '#FFF6E9'
  let g:terminal_color_8 = '#2C2E31'
  let g:terminal_color_9 = '#B86960'
  let g:terminal_color_10 = '#599159'
  let g:terminal_color_11 = '#A48334'
  let g:terminal_color_12 = '#5F7BB0'
  let g:terminal_color_13 = '#996CA1'
  let g:terminal_color_14 = '#008993'
  let g:terminal_color_15 = '#FFF6E9'
  hi DiagnosticError   guifg=#B4637F guibg=NONE    gui=NONE ctermfg=132  ctermbg=NONE cterm=NONE
  hi DiagnosticWarn    guifg=#B3754A guibg=NONE    gui=NONE ctermfg=137  ctermbg=NONE cterm=NONE
  hi DiagnosticInfo    guifg=#537DB2 guibg=NONE    gui=NONE ctermfg=67   ctermbg=NONE cterm=NONE
  hi DiagnosticHint    guifg=#008994 guibg=NONE    gui=NONE ctermfg=30   ctermbg=NONE cterm=NONE
  hi DiagnosticOk      guifg=#509064 guibg=NONE    gui=NONE ctermfg=65   ctermbg=NONE cterm=NONE
  hi DiagnosticUnderlineError guifg=NONE    guibg=NONE    guisp=#B4637F gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline
  hi DiagnosticUnderlineWarn guifg=NONE    guibg=NONE    guisp=#B3754A gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline
  hi DiagnosticUnderlineInfo guifg=NONE    guibg=NONE    guisp=#537DB2 gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline
  hi DiagnosticUnderlineHint guifg=NONE    guibg=NONE    guisp=#008994 gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline
  hi DiagnosticUnderlineOk guifg=NONE    guibg=NONE    guisp=#509064 gui=undercurl ctermfg=NONE ctermbg=NONE cterm=underline
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
  let g:terminal_ansi_colors = ['#202225', '#B86960', '#599159', '#A48334', '#5F7BB0', '#996CA1', '#008993', '#FFF6E9', '#2C2E31', '#B86960', '#599159', '#A48334', '#5F7BB0', '#996CA1', '#008993', '#FFF6E9']
endif
