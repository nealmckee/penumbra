" Penumbra v2 -- Vim color scheme
" Mode: light, Tier: balanced
" Generated deterministically by Penumbra v2 pipeline.

hi clear
if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "penumbra_light"

" Canvas & Basic Highlighting
hi Normal       guifg=#8B8B8B     guibg=#EFE8DD   gui=NONE
hi NonText      guifg=#FFF6E9 guibg=#EFE8DD   gui=NONE
hi Cursor       guifg=#EFE8DD   guibg=#2C2E31  gui=NONE
hi CursorLine   guibg=#FFF6E9 gui=NONE
hi LineNr       guifg=#B4B1AD  guibg=#EFE8DD   gui=NONE
hi CursorLineNr guifg=#5E6063  guibg=#EFE8DD   gui=NONE
hi StatusLine   guifg=#5E6063  guibg=#DFD9D0 gui=NONE
hi StatusLineNC guifg=#B4B1AD  guibg=#DFD9D0 gui=NONE
hi VertSplit    guifg=#DFD9D0 guibg=#DFD9D0 gui=NONE
hi Visual       guibg=#FFF6E9 gui=NONE

" Syntax Equivalences (Strict Upright Roman)
hi Comment      guifg=#B4B1AD  gui=NONE
hi Keyword      guifg=#8972A7 gui=NONE
hi Statement    guifg=#8972A7 gui=NONE
hi Type         guifg=#948A2C gui=NONE
hi Function     guifg=#537DB2   gui=NONE
hi Identifier   guifg=#8B8B8B     gui=NONE
hi Operator     guifg=#008994   gui=NONE
hi String       guifg=#509064  gui=NONE
hi Constant     guifg=#B3754A gui=NONE
hi Number       guifg=#B3754A gui=NONE
hi Boolean      guifg=#B3754A gui=NONE
hi PreProc      guifg=#B4637F    gui=NONE
hi Special      guifg=#B4637F    gui=NONE
hi Error        guifg=#B4637F    guibg=#EFE8DD gui=NONE
hi Todo         guifg=#948A2C guibg=#EFE8DD gui=NONE
