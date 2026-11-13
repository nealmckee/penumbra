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

    # Penumbra Light (CAM16-UCS Opponent Scheme, N = 7)
    penumbra = SyntaxHighlighter.ColorScheme()
    SyntaxHighlighter.symbol!(penumbra, crayon"#B4637F")
    SyntaxHighlighter.comment!(penumbra, crayon"#B4B1AD")
    SyntaxHighlighter.string!(penumbra, crayon"#509064")
    SyntaxHighlighter.call!(penumbra, crayon"#537DB2")
    SyntaxHighlighter.op!(penumbra, crayon"#008994")
    SyntaxHighlighter.keyword!(penumbra, crayon"#8972A7")
    SyntaxHighlighter.function_def!(penumbra, crayon"#537DB2")
    SyntaxHighlighter.error!(penumbra, crayon"#B4637F")
    SyntaxHighlighter.argdef!(penumbra, crayon"#948A2C")
    SyntaxHighlighter.macro!(penumbra, crayon"#B4637F")
    SyntaxHighlighter.number!(penumbra, crayon"#B3754A")
    SyntaxHighlighter.text!(penumbra, crayon"#8B8B8B")

    SyntaxHighlighter.add!("Penumbra Light", penumbra)
    colorscheme!("Penumbra Light")
catch e
    @warn "Error configuring OhMyREPL Penumbra Light scheme" e
end
