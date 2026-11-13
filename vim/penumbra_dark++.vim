" Penumbra v2 -- Vim color scheme
" Mode: dark, Tier: contrast_plus_plus
" Generated deterministically by Penumbra v2 pipeline.

hi clear
if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "penumbra_dark_plus_plus"

" Canvas & Basic Highlighting
hi Normal       guifg=#8B8B8B     guibg=#151619   gui=NONE
hi NonText      guifg=#202225 guibg=#151619   gui=NONE
hi Cursor       guifg=#151619   guibg=#EFE8DD  gui=NONE
hi CursorLine   guibg=#202225 gui=NONE
hi LineNr       guifg=#5E6063  guibg=#151619   gui=NONE
hi CursorLineNr guifg=#B4B1AD  guibg=#151619   gui=NONE
hi StatusLine   guifg=#B4B1AD  guibg=#0A0B0D gui=NONE
hi StatusLineNC guifg=#5E6063  guibg=#0A0B0D gui=NONE
hi VertSplit    guifg=#0A0B0D guibg=#0A0B0D gui=NONE
hi Visual       guibg=#202225 gui=NONE

" Syntax Equivalences (Strict Upright Roman)
hi Comment      guifg=#5E6063  gui=NONE
hi Keyword      guifg=#8871A6 gui=NONE
hi Statement    guifg=#8871A6 gui=NONE
hi Type         guifg=#948A2C gui=NONE
hi Function     guifg=#527CB0   gui=NONE
hi Identifier   guifg=#8B8B8B     gui=NONE
hi Operator     guifg=#008892   gui=NONE
hi String       guifg=#508F64  gui=NONE
hi Constant     guifg=#B2744A gui=NONE
hi Number       guifg=#B2744A gui=NONE
hi Boolean      guifg=#B2744A gui=NONE
hi PreProc      guifg=#B2637E    gui=NONE
hi Special      guifg=#B2637E    gui=NONE
hi Error        guifg=#B2637E    guibg=#151619 gui=NONE
hi Todo         guifg=#948A2C guibg=#151619 gui=NONE
