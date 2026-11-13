# SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
# Copyright (c) 2021-2026 Neal McKee. All rights reserved.
#
# To install in Julia REPL:
# ] add OhMyREPL Crayons
# Then add to ~/.julia/config/startup.jl:

try
    @eval using OhMyREPL
    @eval using Crayons

    import OhMyREPL: Passes.SyntaxHighlighter

    # Penumbra (CAM16-UCS Opponent Scheme, N = 7)
    penumbra = SyntaxHighlighter.ColorScheme()
    SyntaxHighlighter.symbol!(penumbra, crayon"#B2637E")
    SyntaxHighlighter.comment!(penumbra, crayon"#5E6063")
    SyntaxHighlighter.string!(penumbra, crayon"#508F64")
    SyntaxHighlighter.call!(penumbra, crayon"#527CB0")
    SyntaxHighlighter.op!(penumbra, crayon"#008892")
    SyntaxHighlighter.keyword!(penumbra, crayon"#8871A6")
    SyntaxHighlighter.function_def!(penumbra, crayon"#527CB0")
    SyntaxHighlighter.error!(penumbra, crayon"#B2637E")
    SyntaxHighlighter.argdef!(penumbra, crayon"#948A2C")
    SyntaxHighlighter.macro!(penumbra, crayon"#B2637E")
    SyntaxHighlighter.number!(penumbra, crayon"#B2744A")
    SyntaxHighlighter.text!(penumbra, crayon"#8B8B8B")

    SyntaxHighlighter.add!("Penumbra", penumbra)
    colorscheme!("Penumbra")
catch e
    @warn "Error configuring OhMyREPL Penumbra scheme" e
end
