#=
execute
] add OhMyREPL
] add Crayons
in your REPL, then copy the code below into your startup.jl file at ~\.julia\config\
=#

try
    @eval using OhMyREPL
catch e
    @warn "error while importing OhMyREPL" e
end

import OhMyREPL: Passes.SyntaxHighlighter
using Crayons

penumbra_darkest = SyntaxHighlighter.ColorScheme()
SyntaxHighlighter.symbol!(penumbra_darkest, crayon"#1AC2E1")
SyntaxHighlighter.comment!(penumbra_darkest, crayon"#636363")
SyntaxHighlighter.string!(penumbra_darkest, crayon"#61C68A")
SyntaxHighlighter.call!(penumbra_darkest, crayon"#97A6FF")
SyntaxHighlighter.op!(penumbra_darkest, crayon"#F48E74")
SyntaxHighlighter.keyword!(penumbra_darkest, crayon"#E18DCE")
SyntaxHighlighter.function_def!(penumbra_darkest, crayon"#97A6FF")
SyntaxHighlighter.error!(penumbra_darkest, crayon"#F48E74")
SyntaxHighlighter.argdef!(penumbra_darkest, crayon"#1AC2E1")
SyntaxHighlighter.macro!(penumbra_darkest, crayon"#97A6FF")
SyntaxHighlighter.number!(penumbra_darkest, crayon"#C7AD40")
SyntaxHighlighter.text!(penumbra_darkest, crayon"#AEAEAE")
SyntaxHighlighter.add!("Penumbra Dark Contrast+", penumbra_darkest)

colorscheme!("Penumbra Dark Contrast+")
