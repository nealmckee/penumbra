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

    # Penumbra Dark+ (CAM16-UCS Opponent Scheme, N = 8)
    penumbra = SyntaxHighlighter.ColorScheme()
    SyntaxHighlighter.symbol!(penumbra, crayon"#AC72B2")
    SyntaxHighlighter.comment!(penumbra, crayon"#5B5D62")
    SyntaxHighlighter.string!(penumbra, crayon"#58A061")
    SyntaxHighlighter.call!(penumbra, crayon"#008FC6")
    SyntaxHighlighter.op!(penumbra, crayon"#009894")
    SyntaxHighlighter.keyword!(penumbra, crayon"#7D82C0")
    SyntaxHighlighter.function_def!(penumbra, crayon"#008FC6")
    SyntaxHighlighter.error!(penumbra, crayon"#CD6B76")
    SyntaxHighlighter.argdef!(penumbra, crayon"#A39720")
    SyntaxHighlighter.macro!(penumbra, crayon"#CD6B76")
    SyntaxHighlighter.number!(penumbra, crayon"#C58145")
    SyntaxHighlighter.text!(penumbra, crayon"#999999")

    SyntaxHighlighter.add!("Penumbra Dark+", penumbra)
    colorscheme!("Penumbra Dark+")
catch e
    @warn "Error configuring OhMyREPL Penumbra Dark+ scheme" e
end
