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

    # Penumbra Light (CAM16-UCS Opponent Scheme, N = 8)
    penumbra = SyntaxHighlighter.ColorScheme()
    SyntaxHighlighter.symbol!(penumbra, crayon"#9D68A2")
    SyntaxHighlighter.comment!(penumbra, crayon"#B4B1AD")
    SyntaxHighlighter.string!(penumbra, crayon"#509259")
    SyntaxHighlighter.call!(penumbra, crayon"#0082B5")
    SyntaxHighlighter.op!(penumbra, crayon"#008A87")
    SyntaxHighlighter.keyword!(penumbra, crayon"#7177B0")
    SyntaxHighlighter.function_def!(penumbra, crayon"#0082B5")
    SyntaxHighlighter.error!(penumbra, crayon"#BB626B")
    SyntaxHighlighter.argdef!(penumbra, crayon"#958A1C")
    SyntaxHighlighter.macro!(penumbra, crayon"#BB626B")
    SyntaxHighlighter.number!(penumbra, crayon"#B4763E")
    SyntaxHighlighter.text!(penumbra, crayon"#8B8B8B")

    SyntaxHighlighter.add!("Penumbra Light", penumbra)
    colorscheme!("Penumbra Light")
catch e
    @warn "Error configuring OhMyREPL Penumbra Light scheme" e
end
