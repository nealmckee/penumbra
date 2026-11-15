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

    # Penumbra Dark++ (CAM16-UCS Opponent Scheme, N = 8)
    penumbra = SyntaxHighlighter.ColorScheme()
    SyntaxHighlighter.symbol!(penumbra, crayon"#BE7FC4")
    SyntaxHighlighter.comment!(penumbra, crayon"#575B62")
    SyntaxHighlighter.string!(penumbra, crayon"#62B06C")
    SyntaxHighlighter.call!(penumbra, crayon"#009EDB")
    SyntaxHighlighter.op!(penumbra, crayon"#00A8A4")
    SyntaxHighlighter.keyword!(penumbra, crayon"#8A90D4")
    SyntaxHighlighter.function_def!(penumbra, crayon"#009EDB")
    SyntaxHighlighter.error!(penumbra, crayon"#E17782")
    SyntaxHighlighter.argdef!(penumbra, crayon"#B4A724")
    SyntaxHighlighter.macro!(penumbra, crayon"#E17782")
    SyntaxHighlighter.number!(penumbra, crayon"#D88F4C")
    SyntaxHighlighter.text!(penumbra, crayon"#A9A9A9")

    SyntaxHighlighter.add!("Penumbra Dark++", penumbra)
    colorscheme!("Penumbra Dark++")
catch e
    @warn "Error configuring OhMyREPL Penumbra Dark++ scheme" e
end
