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

penumbra_darker = SyntaxHighlighter.ColorScheme()
SyntaxHighlighter.symbol!(penumbra_darker, crayon"#00B0D2")
SyntaxHighlighter.comment!(penumbra_darker, crayon"#636363")
SyntaxHighlighter.string!(penumbra_darker, crayon"#4EB67F")
SyntaxHighlighter.call!(penumbra_darker, crayon"#8C96EC")
SyntaxHighlighter.op!(penumbra_darker, crayon"#E18163")
SyntaxHighlighter.keyword!(penumbra_darker, crayon"#D07EBA")
SyntaxHighlighter.function_def!(penumbra_darker, crayon"#8C96EC")
SyntaxHighlighter.error!(penumbra_darker, crayon"#E18163")
SyntaxHighlighter.argdef!(penumbra_darker, crayon"#00B0D2")
SyntaxHighlighter.macro!(penumbra_darker, crayon"#8C96EC")
SyntaxHighlighter.number!(penumbra_darker, crayon"#B49E33")
SyntaxHighlighter.text!(penumbra_darker, crayon"#9E9E9E")
SyntaxHighlighter.add!("Penumbra Dark Contrast+", penumbra_darker)

colorscheme!("Penumbra Dark Contrast+")
