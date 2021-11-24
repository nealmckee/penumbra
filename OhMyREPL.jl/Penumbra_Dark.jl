#=
execute
] add OhMyREPL
] add Cryaons
in your REPL, then copy the code below into your startup.jl file at ~\.julia\config\
=#

try
    @eval using OhMyREPL
catch e
    @warn "error while importing OhMyREPL" e
end

import OhMyREPL: Passes.SyntaxHighlighter
using Crayons

penumbra_dark = SyntaxHighlighter.ColorScheme()
SyntaxHighlighter.symbol!(penumbra_dark, crayon"#00A0BE")
SyntaxHighlighter.comment!(penumbra_dark, crayon"#636363")
SyntaxHighlighter.string!(penumbra_dark, crayon"#46A473")
SyntaxHighlighter.call!(penumbra_dark, crayon"#7E87D6")
SyntaxHighlighter.op!(penumbra_dark, crayon"#CB7459")
SyntaxHighlighter.keyword!(penumbra_dark, crayon"#BD72A8")
SyntaxHighlighter.function_def!(penumbra_dark, crayon"#7E87D6")
SyntaxHighlighter.error!(penumbra_dark, crayon"#CB7459")
SyntaxHighlighter.argdef!(penumbra_dark, crayon"#00A0BE")
SyntaxHighlighter.macro!(penumbra_dark, crayon"#7E87D6")
SyntaxHighlighter.number!(penumbra_dark, crayon"#A38F2D")
SyntaxHighlighter.text!(penumbra_dark, crayon"#8F8F8F")
SyntaxHighlighter.add!("Penumbra Dark", penumbra_dark)

colorscheme!("Penumbra Dark")