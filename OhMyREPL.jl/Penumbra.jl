# SPDX-License-Identifier: MIT
# Copyright (c) 2021-2026 Neal McKee
#
# To install in Julia REPL:
# ] add OhMyREPL Crayons
# Then add to ~/.julia/config/startup.jl:

try
    @eval using OhMyREPL
    @eval using Crayons

    import OhMyREPL: Passes.SyntaxHighlighter

    # Penumbra (CAM16-UCS Opponent Scheme, N = 8)
    penumbra = SyntaxHighlighter.ColorScheme()
    SyntaxHighlighter.symbol!(penumbra, crayon"#9C67A1")
    SyntaxHighlighter.comment!(penumbra, crayon"#5E6063")
    SyntaxHighlighter.string!(penumbra, crayon"#4F9158")
    SyntaxHighlighter.call!(penumbra, crayon"#0081B4")
    SyntaxHighlighter.op!(penumbra, crayon"#008986")
    SyntaxHighlighter.keyword!(penumbra, crayon"#7176AE")
    SyntaxHighlighter.function_def!(penumbra, crayon"#0081B4")
    SyntaxHighlighter.error!(penumbra, crayon"#BA616A")
    SyntaxHighlighter.argdef!(penumbra, crayon"#948A1D")
    SyntaxHighlighter.macro!(penumbra, crayon"#BA616A")
    SyntaxHighlighter.number!(penumbra, crayon"#B3763E")
    SyntaxHighlighter.text!(penumbra, crayon"#8B8B8B")

    SyntaxHighlighter.add!("Penumbra", penumbra)
    colorscheme!("Penumbra")
catch e
    @warn "Error configuring OhMyREPL Penumbra scheme" e
end
