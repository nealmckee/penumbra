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

penumbra = SyntaxHighlighter.ColorScheme()
SyntaxHighlighter.symbol!(penumbra, crayon"#00A0BE")
SyntaxHighlighter.comment!(penumbra, crayon"#636363")
SyntaxHighlighter.string!(penumbra, crayon"#46A473")
SyntaxHighlighter.call!(penumbra, crayon"#7E87D6")
SyntaxHighlighter.op!(penumbra, crayon"#CB7459")
SyntaxHighlighter.keyword!(penumbra, crayon"#BD72A8")
SyntaxHighlighter.function_def!(penumbra, crayon"#7E87D6")
SyntaxHighlighter.error!(penumbra, crayon"#CB7459")
SyntaxHighlighter.argdef!(penumbra, crayon"#00A0BE")
SyntaxHighlighter.macro!(penumbra, crayon"#7E87D6")
SyntaxHighlighter.number!(penumbra, crayon"#A38F2D")
SyntaxHighlighter.text!(penumbra, crayon"#8F8F8F")
SyntaxHighlighter.add!("Penumbra", penumbra)

colorscheme!("Penumbra")
