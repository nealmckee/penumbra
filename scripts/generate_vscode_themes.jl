# SPDX-License-Identifier: MIT
# Copyright (c) 2021-2026 Neal McKee

"""
generate_vscode_themes.jl

Deterministic compiler for Penumbra v2 VSCode themes:
- Penumbra Dark (balanced)
- Penumbra Dark Contrast+ (contrast+)
- Penumbra Dark Contrast++ (contrast++)
- Penumbra Light (balanced)

Architecture:
- LSP Semantic Tokens (`semanticTokenColors`): Complete, canonical 26-token mapping (`N = 8`).
- TextMate Scopes (`tokenColors`): Canonical root and 2nd-level scopes across all languages (`N = 8`).
- Workbench Chrome (`colors`): Curated keys mapped to Penumbra's 3-tier contrast lattice.
- Terminal ANSI (`terminal.ansi*`): Equidistant `N = 6` palette (`sun`/`sun+` whites in dark, `shade`/`shade-` in light).
- Typography: Strict upright roman font style (zero italics in code/comments).
"""

using JSON
using Printf

include(joinpath(@__DIR__, "..", "src", "palette_io.jl"))

"""
    build_theme_dict(mode::Symbol, tier::Symbol, base_dict, accent_dict, term_dict)

Constructs the complete VSCode theme dictionary for the specified mode and contrast tier.
"""
function build_theme_dict(
    mode::Symbol,
    tier::Symbol,
    base_dict::Dict{String,String},
    accent_dict::Dict{String,String},
    term_dict::Dict{String,String}=accent_dict,
)
    is_dark = mode == :dark

    # 1. Surface plane mappings (contrast-monotonic from chrome -> canvas -> interactive focus)
    # Dark:  shade+ (low-contrast chrome) -> shade (canvas) -> shade- (high-contrast active)
    # Light: sun-   (low-contrast chrome) -> sun   (canvas) -> sun+   (high-contrast active)
    bg_low = is_dark ? base_dict["shade+"] : base_dict["sun-"]
    bg_canvas = is_dark ? base_dict["shade"] : base_dict["sun"]
    bg_high = is_dark ? base_dict["shade-"] : base_dict["sun+"]

    # 2. Typography mappings
    fg_comment = is_dark ? base_dict["sky-"] : base_dict["sky+"]  # de-emphasis toward background
    fg_text = base_dict["sky"]                                 # 0Δ neutral carrier wave
    fg_heading = is_dark ? base_dict["sky+"] : base_dict["sky-"]  # subtle typographical emphasis

    # 3. Theme display names & VSCode classification
    theme_name, file_name, theme_type = if is_dark
        if tier == :balanced
            ("Penumbra Dark", "penumbra-dark-color-theme.json", "dark")
        elseif tier == :contrast_plus
            ("Penumbra Dark Contrast+", "penumbra-dark+-color-theme.json", "dark")
        else
            ("Penumbra Dark Contrast++", "penumbra-dark++-color-theme.json", "dark")
        end
    else
        ("Penumbra Light", "penumbra-light-color-theme.json", "light")
    end

    # 4. Canvas opposites, badge foreground & uniform 25% border
    canvas_opposite = is_dark ? base_dict["sun"] : base_dict["shade"]
    fg_badge = bg_high
    border_subtle = "#$fg_comment" * "40"

    # 5. Accent mappings (N = 8 canonical opponent scheme)
    c_red = accent_dict["red"]         # Errors, invalid, deletions, macros, decorators
    c_orange = accent_dict["orange"]   # Numbers, booleans, numeric constants
    c_yellow = accent_dict["yellow"]   # Types, classes, structs, modules
    c_green = accent_dict["green"]     # Strings, character literals
    c_cyan = accent_dict["cyan"]       # Operators, delimiters, type annotations
    c_blue = accent_dict["blue"]       # Functions, methods, callables
    c_purple = accent_dict["purple"]   # Keywords, control flow, declarations
    c_magenta = accent_dict["magenta"] # Escapes, regexp, symbols, self/defaultLibrary

    # 6. Terminal ANSI 6-color equidistant palette
    t_red = term_dict["red"]
    t_green = term_dict["green"]
    t_yellow = term_dict["yellow"]
    t_blue = term_dict["blue"]
    t_magenta = term_dict["magenta"]
    t_cyan = term_dict["cyan"]

    # --- WORKBENCH UI COLORS (~190 curated keys) ---
    colors = Dict{String,String}(
        # Base Foreground, Surface Shell & Focus
        "foreground" => "#$fg_text",
        "descriptionForeground" => "#$fg_comment",
        "disabledForeground" => "#$fg_comment",
        "errorForeground" => "#$c_red",
        "textLink.foreground" => "#$c_blue",
        "textLink.activeForeground" => "#$c_cyan",
        "focusBorder" => "#$c_cyan",
        "sash.hoverBorder" => "#$c_cyan",
        "surface.background" => "#$bg_low",
        "surface.border" => border_subtle,
        "surface.foreground" => "#$fg_text",
        "widget.border" => border_subtle,
        "selection.background" => "#$canvas_opposite" * "33",
        "widget.shadow" => is_dark ? "#00000055" : "#00000022",
        "scrollbar.shadow" => is_dark ? "#00000044" : "#00000015",
        "icon.foreground" => "#$fg_text",
        "toolbar.hoverBackground" => "#$bg_high",
        "toolbar.activeBackground" => "#$bg_high",
        "toolbar.hoverOutline" => "#00000000",

        # Activity Bar & Modern Dock (Tier 0: Low-Contrast Chrome)
        "activityBar.background" => "#$bg_low",
        "activityBar.foreground" => "#$fg_heading",
        "activityBar.inactiveForeground" => "#$fg_text",
        "activityBar.activeBorder" => "#$fg_heading",
        "activityBar.border" => border_subtle,
        "activityBarTop.foreground" => "#$fg_heading",
        "activityBarTop.inactiveForeground" => "#$fg_text",
        "activityBarTop.activeBorder" => "#$fg_heading",
        "activityBarBadge.background" => "#$c_blue",
        "activityBarBadge.foreground" => "#$fg_badge",
        "activityErrorBadge.background" => "#$c_red",
        "activityErrorBadge.foreground" => "#$fg_badge",
        "activityWarningBadge.background" => "#$c_orange",
        "activityWarningBadge.foreground" => "#$fg_badge",
        "modernActivityBar.background" => "#$bg_low",
        "modernActivityBar.border" => border_subtle,
        "modernActivityBarItem.activeBackground" => "#$bg_high",
        "modernActivityBarItem.activeForeground" => "#$fg_heading",
        "modernActivityBarItem.hoverBackground" => "#$bg_high" * "88",
        "modernActivityBarItem.hoverForeground" => "#$fg_heading",

        # Side Bar & Secondary Side Bar (Tier 0: Low-Contrast Chrome)
        "sideBar.background" => "#$bg_low",
        "sideBar.foreground" => "#$fg_text",
        "sideBar.border" => border_subtle,
        "sideBarActivityBarTop.border" => border_subtle,
        "sideBarTitle.foreground" => "#$fg_heading",
        "sideBarSectionHeader.background" => "#$bg_canvas",
        "sideBarSectionHeader.foreground" => "#$fg_heading",
        "sideBarSectionHeader.border" => border_subtle,
        "auxiliaryBar.background" => "#$bg_low",
        "auxiliaryBar.foreground" => "#$fg_text",
        "auxiliaryBar.border" => border_subtle,
        "auxiliaryBarTitle.foreground" => "#$fg_heading",
        "auxiliaryBarSectionHeader.background" => "#$bg_canvas",
        "auxiliaryBarSectionHeader.foreground" => "#$fg_heading",
        "auxiliaryBarSectionHeader.border" => border_subtle,

        # Agents Panel
        "agents.background" => "#$bg_low",
        "agentsPanel.background" => "#$bg_low",
        "agentsPanel.border" => border_subtle,
        "agentsPanel.foreground" => "#$fg_text",
        "agentsChatInput.background" => "#$bg_canvas",
        "agentsChatInput.border" => border_subtle,
        "agentsChatInput.focusBorder" => "#$c_cyan",
        "agentsChatInput.foreground" => "#$fg_text",
        "agentsChatInput.placeholderForeground" => "#$fg_comment",
        "agentsNewSessionButton.background" => "#00000000",
        "agentsNewSessionButton.border" => border_subtle,
        "agentsNewSessionButton.foreground" => "#$fg_heading",
        "agentsNewSessionButton.hoverBackground" => "#$bg_high",
        "agentsBadge.background" => "#$c_blue",
        "agentsBadge.foreground" => "#$fg_badge",
        "agentsUnreadBadge.background" => "#$c_blue",
        "agentsUnreadBadge.foreground" => "#$fg_badge",
        "agentsGradient.tintColor" => "#$c_blue",
        "chat.requestBorder" => border_subtle,
        "chat.avatarBackground" => "#$bg_canvas",
        "chat.slashCommandBackground" => "#$bg_high",
        "chat.slashCommandForeground" => "#$c_blue",
        "chat.editedFileForeground" => "#$c_yellow",
        "chat.linesAddedForeground" => "#$c_green",
        "chat.linesRemovedForeground" => "#$c_red",
        "chat.requestBubbleBackground" => "#$bg_high",
        "chat.requestBubbleHoverBackground" => "#$bg_high" * "dd",

        # Lists & Trees (Interactive on Canvas & Sidebar)
        "list.hoverBackground" => "#$bg_high" * "80",
        "list.hoverForeground" => "#$fg_text",
        "list.activeSelectionBackground" => "#$bg_high",
        "list.activeSelectionForeground" => "#$fg_heading",
        "list.inactiveSelectionBackground" => "#$bg_high" * "aa",
        "list.inactiveSelectionForeground" => "#$fg_heading",
        "list.focusBackground" => "#$bg_high",
        "list.focusForeground" => "#$fg_heading",
        "list.focusOutline" => "#$c_cyan",
        "list.highlightForeground" => "#$c_cyan",
        "list.dropBackground" => "#$c_blue" * "25",
        "list.errorForeground" => "#$c_red",
        "list.warningForeground" => "#$c_orange",
        "list.invalidItemForeground" => "#$fg_comment",
        "list.deemphasizedForeground" => "#$fg_comment",
        "listFilterWidget.outline" => "#$c_cyan",
        "tree.indentGuidesStroke" => border_subtle,

        # Editor Group & Tabs (Tier 0 Header, Tier 1 Active Canvas)
        "editorGroup.border" => border_subtle,
        "editorGroupHeader.tabsBackground" => "#$bg_low",
        "editorGroupHeader.tabsBorder" => border_subtle,
        "tab.activeBackground" => "#$bg_canvas",
        "tab.activeForeground" => "#$fg_heading",
        "tab.activeBorder" => "#$bg_canvas",
        "tab.activeBorderTop" => "#$c_blue",
        "tab.activeModifiedBorder" => "#$c_orange",
        "tab.selectedBorderTop" => "#$c_blue",
        "tab.inactiveBackground" => "#$bg_low",
        "tab.inactiveForeground" => "#$fg_text",
        "tab.inactiveModifiedBorder" => "#$c_orange" * "80",
        "tab.hoverBackground" => "#$bg_canvas" * "88",
        "tab.hoverForeground" => "#$fg_heading",
        "tab.unfocusedActiveForeground" => "#$fg_text",
        "tab.unfocusedActiveModifiedBorder" => "#$c_orange" * "80",
        "tab.unfocusedInactiveForeground" => "#$fg_comment",
        "tab.unfocusedInactiveModifiedBorder" => "#$c_orange" * "55",
        "tab.unfocusedHoverBackground" => "#$bg_canvas" * "55",
        "tab.border" => border_subtle,
        "tab.lastPinnedBorder" => border_subtle,

        # Editor (Tier 1: Canvas)
        "editor.background" => "#$bg_canvas",
        "editor.foreground" => "#$fg_text",
        "editorLineNumber.foreground" => "#$fg_comment",
        "editorLineNumber.activeForeground" => "#$fg_heading",
        "editorCursor.foreground" => "#$canvas_opposite",
        "editorCursor.background" => "#$bg_canvas",
        "editorLink.activeForeground" => "#$c_cyan",
        "editorStickyScroll.border" => border_subtle,
        "editorStickyScrollHover.background" => "#$bg_high",

        # Editor Selections & Highlights
        "editor.selectionBackground" => "#$canvas_opposite" * "25",
        "editor.inactiveSelectionBackground" => "#$canvas_opposite" * "15",
        "editor.selectionHighlightBackground" => "#$canvas_opposite" * "20",
        "editor.selectionHighlightBorder" => "#00000000",
        "editor.wordHighlightBackground" => "#$canvas_opposite" * "20",
        "editor.wordHighlightBorder" => "#00000000",
        "editor.wordHighlightStrongBackground" => "#$canvas_opposite" * "30",
        "editor.wordHighlightStrongBorder" => "#00000000",
        "editor.hoverHighlightBackground" => "#$canvas_opposite" * "15",
        "editor.rangeHighlightBackground" => "#$canvas_opposite" * "15",
        "editor.rangeHighlightBorder" => "#00000000",
        "editor.symbolHighlightBorder" => "#00000000",
        "editor.linkedEditingBackground" => "#$c_cyan" * "25",
        "editor.lineHighlightBackground" => "#$canvas_opposite" * "0d",
        "editor.lineHighlightBorder" => "#00000000",
        "editor.placeholder.foreground" => "#$fg_comment",
        "editorCodeLens.foreground" => "#$fg_comment",
        "editorWhitespace.foreground" => "#$fg_comment" * "55",
        "editorIndentGuide.background1" => "#$fg_comment" * "44",
        "editorIndentGuide.activeBackground1" => "#$fg_comment",
        "editorRuler.foreground" => "#$fg_comment" * "44",
        "editorGhostText.foreground" => "#$fg_comment",
        "editorGhostText.border" => "#00000000",
        "editorInlayHint.foreground" => "#$fg_comment",
        "editorInlayHint.background" => "#$bg_low",
        "editorUnnecessaryCode.border" => "#00000000",

        # Search / Find Highlights
        "editor.findMatchBackground" => "#$c_orange" * "44",
        "editor.findMatchBorder" => "#00000000",
        "editor.findMatchHighlightBackground" => "#$c_orange" * "25",
        "editor.findMatchHighlightBorder" => "#00000000",
        "editor.findRangeHighlightBackground" => "#$canvas_opposite" * "15",

        # Brackets & Breadcrumbs
        "editorBracketMatch.background" => "#$bg_high",
        "editorBracketMatch.border" => "#$fg_heading" * "66",
        "editorBracketHighlight.foreground1" => "#$c_cyan",
        "editorBracketHighlight.foreground2" => "#$c_purple",
        "editorBracketHighlight.foreground3" => "#$c_yellow",
        "editorBracketHighlight.foreground4" => "#$c_blue",
        "editorBracketHighlight.foreground5" => "#$c_green",
        "editorBracketHighlight.foreground6" => "#$c_orange",
        "editorBracketHighlight.unexpectedBracket.foreground" => "#$c_red",
        "breadcrumb.background" => "#$bg_canvas",
        "breadcrumb.foreground" => "#$fg_text",
        "breadcrumb.focusForeground" => "#$fg_heading",
        "breadcrumb.activeSelectionForeground" => "#$fg_heading",

        # Gutters & Minimap
        "editorGutter.background" => "#$bg_canvas",
        "editorGutter.addedBackground" => "#$c_green",
        "editorGutter.modifiedBackground" => "#$c_blue",
        "editorGutter.deletedBackground" => "#$c_red",
        "editorGutter.foldingControlForeground" => "#$fg_text",
        "editorGutter.commentRangeForeground" => "#$fg_comment",
        "editorGutter.commentGlyphForeground" => "#$fg_comment",
        "editorGutter.commentUnresolvedGlyphForeground" => "#$c_blue",
        "editorCommentsWidget.rangeBackground" => "#$c_blue" * "22",
        "editorCommentsWidget.rangeActiveBackground" => "#$c_blue" * "38",
        "editorCommentsWidget.resolvedBorder" => border_subtle,
        "editorCommentsWidget.unresolvedBorder" => "#$c_blue",
        "editorOverviewRuler.border" => border_subtle,
        "editorOverviewRuler.addedForeground" => "#$c_green",
        "editorOverviewRuler.modifiedForeground" => "#$c_blue",
        "editorOverviewRuler.deletedForeground" => "#$c_red",
        "editorOverviewRuler.errorForeground" => "#$c_red",
        "editorOverviewRuler.warningForeground" => "#$c_orange",
        "editorOverviewRuler.infoForeground" => "#$c_blue",
        "editorOverviewRuler.findMatchForeground" => "#$c_orange" * "66",
        "minimap.background" => "#$bg_canvas",
        "minimap.findMatchHighlight" => "#$c_orange" * "66",
        "minimap.selectionHighlight" => "#$canvas_opposite" * "33",
        "minimap.errorHighlight" => "#$c_red",
        "minimap.warningHighlight" => "#$c_orange",
        "minimapGutter.addedBackground" => "#$c_green",
        "minimapGutter.modifiedBackground" => "#$c_blue",
        "minimapGutter.deletedBackground" => "#$c_red",

        # Diagnostics & Error Squiggles
        "editorError.foreground" => "#$c_red",
        "editorError.border" => "#00000000",
        "editorWarning.foreground" => "#$c_orange",
        "editorWarning.border" => "#00000000",
        "editorInfo.foreground" => "#$c_blue",
        "editorInfo.border" => "#00000000",
        "editorHint.foreground" => "#$c_cyan",
        "editorHint.border" => "#00000000",

        # Widgets (Autocomplete, Hover, Suggest, Quick Input, Diff)
        "editorWidget.background" => "#$bg_low",
        "editorWidget.border" => border_subtle,
        "editorWidget.resizeBorder" => border_subtle,
        "editorWidget.foreground" => "#$fg_text",
        "editorSuggestWidget.background" => "#$bg_low",
        "editorSuggestWidget.border" => border_subtle,
        "editorSuggestWidget.foreground" => "#$fg_text",
        "editorSuggestWidget.highlightForeground" => "#$c_cyan",
        "editorSuggestWidget.selectedBackground" => "#$bg_high",
        "editorHoverWidget.background" => "#$bg_low",
        "editorHoverWidget.border" => border_subtle,
        "editorHoverWidget.foreground" => "#$fg_text",
        "simpleFindWidget.sashBorder" => border_subtle,
        "quickInputTitle.background" => "#$bg_low",
        "quickInputList.focusBackground" => "#$bg_high",
        "quickInputList.focusForeground" => "#$fg_heading",
        "pickerGroup.border" => border_subtle,
        "pickerGroup.foreground" => "#$c_blue",
        "debugToolBar.background" => "#$bg_low",
        "debugToolBar.border" => border_subtle,
        "diffEditor.border" => border_subtle,
        "diffEditor.insertedTextBackground" => "#$c_green" * "25",
        "diffEditor.removedTextBackground" => "#$c_red" * "25",
        "diffEditor.insertedLineBackground" => "#$c_green" * "18",
        "diffEditor.removedLineBackground" => "#$c_red" * "18",
        "diffEditor.unchangedRegionBackground" => "#$bg_low",
        "diffEditor.insertedTextBorder" => "#00000000",
        "diffEditor.removedTextBorder" => "#00000000",
        "merge.border" => border_subtle,

        # Peek Views
        "peekView.border" => "#$c_blue",
        "peekViewEditor.background" => "#$bg_low",
        "peekViewEditor.matchHighlightBackground" => "#$c_orange" * "44",
        "peekViewEditorGutter.background" => "#$bg_low",
        "peekViewResult.background" => "#$bg_canvas",
        "peekViewResult.fileForeground" => "#$fg_text",
        "peekViewResult.lineForeground" => "#$fg_heading",
        "peekViewResult.matchHighlightBackground" => "#$c_orange" * "44",
        "peekViewResult.selectionBackground" => "#$bg_high",
        "peekViewResult.selectionForeground" => "#$fg_heading",
        "peekViewTitle.background" => "#$bg_low",
        "peekViewTitleDescription.foreground" => "#$fg_comment",
        "peekViewTitleLabel.foreground" => "#$fg_heading",

        # Status Bar (Tier 0: Low-Contrast Chrome)
        "statusBar.background" => "#$bg_low",
        "statusBar.foreground" => "#$fg_text",
        "statusBar.border" => border_subtle,
        "statusBar.debuggingBackground" => "#$c_red",
        "statusBar.debuggingForeground" => "#$fg_badge",
        "statusBar.noFolderBackground" => "#$bg_low",
        "statusBar.noFolderForeground" => "#$fg_text",
        "statusBarItem.remoteBackground" => "#$c_blue",
        "statusBarItem.remoteForeground" => "#$fg_badge",
        "statusBarItem.errorBackground" => "#$c_red",
        "statusBarItem.errorForeground" => "#$fg_badge",
        "statusBarItem.warningBackground" => "#$c_orange",
        "statusBarItem.warningForeground" => "#$fg_badge",
        "statusBarItem.hoverBackground" => "#$bg_high",
        "ports.iconRunningProcessForeground" => "#$c_green",

        # Title Bar, Command Center & Menus
        "titleBar.activeBackground" => "#$bg_low",
        "titleBar.activeForeground" => "#$fg_heading",
        "titleBar.inactiveBackground" => "#$bg_low",
        "titleBar.inactiveForeground" => "#$fg_comment",
        "titleBar.border" => border_subtle,
        "commandCenter.background" => "#$bg_canvas",
        "commandCenter.foreground" => "#$fg_text",
        "commandCenter.border" => border_subtle,
        "commandCenter.activeBackground" => "#$bg_high",
        "commandCenter.activeForeground" => "#$fg_heading",
        "commandCenter.activeBorder" => border_subtle,
        "menubar.selectionBackground" => "#$bg_high",
        "menubar.selectionForeground" => "#$fg_heading",
        "menubar.selectionBorder" => "#00000000",
        "menu.background" => "#$bg_low",
        "menu.foreground" => "#$fg_text",
        "menu.border" => border_subtle,
        "menu.selectionBackground" => "#$bg_high",
        "menu.selectionForeground" => "#$fg_heading",
        "menu.selectionBorder" => "#00000000",
        "menu.separatorBackground" => border_subtle,

        # Inputs, Controls, Settings & Markdown
        "input.background" => "#$bg_canvas",
        "input.foreground" => "#$fg_text",
        "input.border" => border_subtle,
        "input.placeholderForeground" => "#$fg_comment",
        "inputOption.activeBackground" => "#$c_blue" * "33",
        "inputOption.activeForeground" => "#$fg_heading",
        "inputOption.activeBorder" => "#$c_blue",
        "inputValidation.infoBackground" => "#$bg_low",
        "inputValidation.infoBorder" => "#$c_blue",
        "inputValidation.warningBackground" => "#$bg_low",
        "inputValidation.warningBorder" => "#$c_orange",
        "inputValidation.errorBackground" => "#$bg_low",
        "inputValidation.errorBorder" => "#$c_red",
        "checkbox.background" => "#$bg_canvas",
        "checkbox.foreground" => "#$fg_heading",
        "checkbox.border" => border_subtle,
        "dropdown.background" => "#$bg_canvas",
        "dropdown.listBackground" => "#$bg_low",
        "dropdown.foreground" => "#$fg_text",
        "dropdown.border" => border_subtle,
        "button.background" => "#$c_blue",
        "button.foreground" => "#$fg_badge",
        "button.border" => "#00000000",
        "button.hoverBackground" => "#$c_blue" * "dd",
        "button.secondaryBackground" => "#$bg_high",
        "button.secondaryForeground" => "#$fg_heading",
        "button.secondaryBorder" => border_subtle,
        "button.secondaryHoverBackground" => "#$bg_high" * "dd",
        "extensionButton.prominentBackground" => "#$c_blue",
        "extensionButton.prominentForeground" => "#$fg_badge",
        "extensionButton.prominentHoverBackground" => "#$c_blue" * "dd",
        "settings.focusedRowBackground" => "#$bg_high",
        "settings.rowHoverBackground" => "#$bg_high" * "88",
        "welcomePage.tileBackground" => "#$bg_low",
        "welcomePage.tileBorder" => border_subtle,
        "welcomePage.progress.foreground" => "#$c_blue",
        "textBlockQuote.background" => "#$bg_low",
        "textBlockQuote.border" => "#$c_blue",
        "textCodeBlock.background" => "#$bg_low",
        "textPreformat.foreground" => "#$c_green",
        "textSeparator.foreground" => border_subtle,

        # Terminal & Panel
        "panel.background" => "#$bg_canvas",
        "panel.border" => border_subtle,
        "panelInput.border" => border_subtle,
        "panelSection.border" => border_subtle,
        "panelSectionHeader.border" => border_subtle,
        "panelTitle.activeForeground" => "#$fg_heading",
        "panelTitle.activeBorder" => "#$c_blue",
        "panelTitle.inactiveForeground" => "#$fg_comment",
        "terminal.background" => "#$bg_canvas",
        "terminal.border" => border_subtle,
        "terminal.foreground" => "#$fg_text",
        "terminal.selectionBackground" => "#$canvas_opposite" * "25",
        "terminal.findMatchBackground" => "#$c_orange" * "44",
        "terminal.findMatchBorder" => "#00000000",
        "terminal.findMatchHighlightBackground" => "#$c_orange" * "25",
        "terminal.findMatchHighlightBorder" => "#00000000",
        "terminalOverviewRuler.findMatchForeground" => "#$c_orange" * "66",
        "terminalStickyScroll.border" => border_subtle,
        "terminalStickyScrollHover.background" => "#$bg_high",
        "terminalCursor.foreground" => "#$canvas_opposite",
        "terminalCursor.background" => "#$bg_canvas",
        "terminal.ansiBlack" => is_dark ? "#$bg_high" : "#$bg_low",
        "terminal.ansiRed" => "#$t_red",
        "terminal.ansiGreen" => "#$t_green",
        "terminal.ansiYellow" => "#$t_yellow",
        "terminal.ansiBlue" => "#$t_blue",
        "terminal.ansiMagenta" => "#$t_magenta",
        "terminal.ansiCyan" => "#$t_cyan",
        "terminal.ansiWhite" => "#$canvas_opposite",
        "terminal.ansiBrightBlack" => "#$fg_comment",
        "terminal.ansiBrightRed" => "#$t_red",
        "terminal.ansiBrightGreen" => "#$t_green",
        "terminal.ansiBrightYellow" => "#$t_yellow",
        "terminal.ansiBrightBlue" => "#$t_blue",
        "terminal.ansiBrightMagenta" => "#$t_magenta",
        "terminal.ansiBrightCyan" => "#$t_cyan",
        "terminal.ansiBrightWhite" => is_dark ? "#$(base_dict["sun+"])" : "#$(base_dict["shade-"])",

        # Git Decorations
        "gitDecoration.addedResourceForeground" => "#$c_green",
        "gitDecoration.modifiedResourceForeground" => "#$c_blue",
        "gitDecoration.deletedResourceForeground" => "#$c_red",
        "gitDecoration.renamedResourceForeground" => "#$c_green",
        "gitDecoration.untrackedResourceForeground" => "#$c_green",
        "gitDecoration.stageModifiedResourceForeground" => "#$c_blue",
        "gitDecoration.stageDeletedResourceForeground" => "#$c_red",
        "gitDecoration.submoduleResourceForeground" => "#$c_cyan",
        "gitDecoration.ignoredResourceForeground" => "#$fg_comment",
        "gitDecoration.conflictingResourceForeground" => "#$c_orange",

        # Charts
        "charts.foreground" => "#$fg_text",
        "charts.lines" => "#$fg_comment" * "80",
        "charts.red" => "#$c_red",
        "charts.orange" => "#$c_orange",
        "charts.yellow" => "#$c_yellow",
        "charts.green" => "#$c_green",
        "charts.blue" => "#$c_blue",
        "charts.purple" => "#$c_purple",

        # Scrollbar
        "scrollbarSlider.background" => "#$fg_text" * "40",
        "scrollbarSlider.hoverBackground" => "#$fg_text" * "66",
        "scrollbarSlider.activeBackground" => "#$fg_heading",

        # Badges & Progress
        "badge.background" => "#$bg_high",
        "badge.foreground" => "#$fg_heading",
        "progressBar.background" => "#$c_blue",

        # Notifications
        "notifications.background" => "#$bg_low",
        "notifications.foreground" => "#$fg_text",
        "notifications.border" => border_subtle,
        "notificationCenter.border" => border_subtle,
        "notificationToast.border" => border_subtle,
        "notificationsErrorIcon.foreground" => "#$c_red",
        "notificationsWarningIcon.foreground" => "#$c_orange",
        "notificationsInfoIcon.foreground" => "#$c_blue"
    )

    # --- LSP SEMANTIC TOKEN COLORS (Full 26 Canonical Token Types) ---
    semanticTokenColors = Dict{String,Any}(
        "comment" => Dict("foreground" => "#$fg_comment", "fontStyle" => ""),
        "keyword" => Dict("foreground" => "#$c_purple", "fontStyle" => ""),
        "modifier" => Dict("foreground" => "#$c_purple", "fontStyle" => ""),
        "newOperator" => Dict("foreground" => "#$c_purple", "fontStyle" => ""),
        "function" => Dict("foreground" => "#$c_blue", "fontStyle" => ""),
        "method" => Dict("foreground" => "#$c_blue", "fontStyle" => ""),
        "customLiteral" => Dict("foreground" => "#$c_blue", "fontStyle" => ""),
        "type" => Dict("foreground" => "#$c_yellow", "fontStyle" => ""),
        "class" => Dict("foreground" => "#$c_yellow", "fontStyle" => ""),
        "struct" => Dict("foreground" => "#$c_yellow", "fontStyle" => ""),
        "interface" => Dict("foreground" => "#$c_yellow", "fontStyle" => ""),
        "enum" => Dict("foreground" => "#$c_yellow", "fontStyle" => ""),
        "typeParameter" => Dict("foreground" => "#$c_yellow", "fontStyle" => ""),
        "namespace" => Dict("foreground" => "#$c_yellow", "fontStyle" => ""),
        "string" => Dict("foreground" => "#$c_green", "fontStyle" => ""),
        "stringLiteral" => Dict("foreground" => "#$c_green", "fontStyle" => ""),
        "number" => Dict("foreground" => "#$c_orange", "fontStyle" => ""),
        "numberLiteral" => Dict("foreground" => "#$c_orange", "fontStyle" => ""),
        "regexp" => Dict("foreground" => "#$c_magenta", "fontStyle" => ""),
        "operator" => Dict("foreground" => "#$c_cyan", "fontStyle" => ""),
        "macro" => Dict("foreground" => "#$c_red", "fontStyle" => ""),
        "enumMember" => Dict("foreground" => "#$c_orange", "fontStyle" => ""),
        "variable" => Dict("foreground" => "#$fg_text", "fontStyle" => ""),
        "parameter" => Dict("foreground" => "#$fg_text", "fontStyle" => ""),
        "property" => Dict("foreground" => "#$fg_text", "fontStyle" => ""),
        "variable.defaultLibrary" => Dict("foreground" => "#$c_magenta", "fontStyle" => "")
    )

    # --- TEXTMATE SCOPES (Canonical Root Hierarchy, Upright Roman) ---
    tokenColors = [
        # 1. Comments
        Dict(
            "name" => "Comments & Marginalia",
            "scope" => [
                "comment",
                "punctuation.definition.comment"
            ],
            "settings" => Dict("foreground" => "#$fg_comment", "fontStyle" => "")
        ),

        # 2. Keywords & Storage
        Dict(
            "name" => "Keywords & Control Flow",
            "scope" => [
                "keyword",
                "keyword.control",
                "keyword.operator.new",
                "keyword.operator.expression",
                "keyword.other"
            ],
            "settings" => Dict("foreground" => "#$c_purple", "fontStyle" => "")
        ),
        Dict(
            "name" => "Storage & Type Modifiers",
            "scope" => [
                "storage",
                "storage.type",
                "storage.modifier",
                "keyword.storage"
            ],
            "settings" => Dict("foreground" => "#$c_purple", "fontStyle" => "")
        ),

        # 3. Functions & Methods
        Dict(
            "name" => "Functions & Method Calls",
            "scope" => [
                "entity.name.function",
                "support.function",
                "meta.function-call",
                "variable.function"
            ],
            "settings" => Dict("foreground" => "#$c_blue", "fontStyle" => "")
        ),

        # 4. Types, Classes & Namespaces
        Dict(
            "name" => "Types, Classes, Structs & Modules",
            "scope" => [
                "entity.name.type",
                "entity.name.class",
                "entity.name.namespace",
                "entity.name.scope-resolution",
                "entity.other.inherited-class",
                "support.type",
                "support.class"
            ],
            "settings" => Dict("foreground" => "#$c_yellow", "fontStyle" => "")
        ),

        # 5. Operators & Punctuation
        Dict(
            "name" => "Operators",
            "scope" => [
                "keyword.operator",
                "storage.type.function.arrow"
            ],
            "settings" => Dict("foreground" => "#$c_cyan", "fontStyle" => "")
        ),
        Dict(
            "name" => "Syntactic Punctuation & Brackets",
            "scope" => [
                "punctuation",
                "punctuation.separator",
                "punctuation.terminator",
                "meta.brace"
            ],
            "settings" => Dict("foreground" => "#$fg_text", "fontStyle" => "")
        ),
        Dict(
            "name" => "Embedded & Template Interpolation Delimiters",
            "scope" => [
                "punctuation.definition.template-expression.begin",
                "punctuation.definition.template-expression.end",
                "punctuation.section.embedded"
            ],
            "settings" => Dict("foreground" => "#$c_cyan", "fontStyle" => "")
        ),
        Dict(
            "name" => "Embedded & Template Expression Bodies",
            "scope" => [
                "meta.template.expression",
                "meta.embedded"
            ],
            "settings" => Dict("foreground" => "#$fg_text", "fontStyle" => "")
        ),

        # 6. Literals (Strings & Numbers)
        Dict(
            "name" => "Strings & Text Literals",
            "scope" => [
                "string",
                "string.quoted",
                "string.template"
            ],
            "settings" => Dict("foreground" => "#$c_green", "fontStyle" => "")
        ),
        Dict(
            "name" => "String Escapes & RegExp",
            "scope" => [
                "constant.character.escape",
                "string.regexp"
            ],
            "settings" => Dict("foreground" => "#$c_magenta", "fontStyle" => "")
        ),
        Dict(
            "name" => "Numbers, Units & Booleans",
            "scope" => [
                "constant.numeric",
                "constant.language.boolean",
                "constant.language.null",
                "constant.language"
            ],
            "settings" => Dict("foreground" => "#$c_orange", "fontStyle" => "")
        ),

        # 7. Macros, Symbols, Special Bindings & Errors
        Dict(
            "name" => "Macros, Decorators & Directives",
            "scope" => [
                "entity.name.function.macro",
                "support.function.macro",
                "entity.name.function.decorator"
            ],
            "settings" => Dict("foreground" => "#$c_red", "fontStyle" => "")
        ),
        Dict(
            "name" => "Symbols & Special Language Bindings",
            "scope" => [
                "constant.other.symbol",
                "variable.language.special",
                "variable.language.this",
                "variable.language.self"
            ],
            "settings" => Dict("foreground" => "#$c_magenta", "fontStyle" => "")
        ),
        Dict(
            "name" => "Invalid & Errors",
            "scope" => [
                "invalid",
                "invalid.illegal"
            ],
            "settings" => Dict("foreground" => "#$c_red", "fontStyle" => "")
        ),

        # 8. Identifiers & Variables (Neutral Carrier Wave)
        Dict(
            "name" => "Variables & Parameters",
            "scope" => [
                "variable",
                "variable.parameter",
                "variable.other"
            ],
            "settings" => Dict("foreground" => "#$fg_text", "fontStyle" => "")
        ),

        # 9. Markdown & Document Markup
        Dict(
            "name" => "Markdown Headings",
            "scope" => [
                "markup.heading",
                "entity.name.section"
            ],
            "settings" => Dict("foreground" => "#$fg_heading", "fontStyle" => "bold")
        ),
        Dict(
            "name" => "Markdown Bold",
            "scope" => [
                "markup.bold"
            ],
            "settings" => Dict("foreground" => "#$c_yellow", "fontStyle" => "bold")
        ),
        Dict(
            "name" => "Markdown Italic",
            "scope" => [
                "markup.italic"
            ],
            "settings" => Dict("foreground" => "#$c_purple", "fontStyle" => "italic")
        ),
        Dict(
            "name" => "Markdown Code",
            "scope" => [
                "markup.inline.raw",
                "markup.raw.block"
            ],
            "settings" => Dict("foreground" => "#$c_green", "fontStyle" => "")
        ),
        Dict(
            "name" => "Markdown Links",
            "scope" => [
                "markup.underline.link",
                "string.other.link"
            ],
            "settings" => Dict("foreground" => "#$c_blue", "fontStyle" => "")
        ),
        Dict(
            "name" => "Markdown Quotes",
            "scope" => [
                "markup.quote"
            ],
            "settings" => Dict("foreground" => "#$fg_comment", "fontStyle" => "")
        ),
        Dict(
            "name" => "Markdown List Markers",
            "scope" => [
                "punctuation.definition.list.begin.markdown"
            ],
            "settings" => Dict("foreground" => "#$c_cyan", "fontStyle" => "")
        ),

        # 10. Structured Data, Markup Tags & Diffs
        Dict(
            "name" => "Structured Property Keys (JSON/YAML/CSS)",
            "scope" => [
                "support.type.property-name",
                "support.type.property-name.json",
                "meta.property-name",
                "entity.name.tag.yaml"
            ],
            "settings" => Dict("foreground" => "#$c_blue", "fontStyle" => "")
        ),
        Dict(
            "name" => "HTML/XML/JSX Element Tags",
            "scope" => [
                "entity.name.tag"
            ],
            "settings" => Dict("foreground" => "#$c_blue", "fontStyle" => "")
        ),
        Dict(
            "name" => "HTML/XML/JSX Tag Angle Brackets",
            "scope" => [
                "punctuation.definition.tag"
            ],
            "settings" => Dict("foreground" => "#$fg_comment", "fontStyle" => "")
        ),
        Dict(
            "name" => "HTML/XML/JSX Attributes",
            "scope" => [
                "entity.other.attribute-name"
            ],
            "settings" => Dict("foreground" => "#$c_yellow", "fontStyle" => "")
        ),
        Dict(
            "name" => "Diff Additions",
            "scope" => [
                "markup.inserted"
            ],
            "settings" => Dict("foreground" => "#$c_green", "fontStyle" => "")
        ),
        Dict(
            "name" => "Diff Deletions",
            "scope" => [
                "markup.deleted"
            ],
            "settings" => Dict("foreground" => "#$c_red", "fontStyle" => "")
        ),
        Dict(
            "name" => "Diff Modifications",
            "scope" => [
                "markup.changed"
            ],
            "settings" => Dict("foreground" => "#$c_blue", "fontStyle" => "")
        )
    ]

    theme_dict = Dict{String,Any}(
        "name" => theme_name,
        "type" => theme_type,
        "semanticHighlighting" => true,
        "semanticTokenColors" => semanticTokenColors,
        "tokenColors" => tokenColors,
        "colors" => colors
    )

    return (file_name=file_name, data=theme_dict)
end

"""
    generate_all_themes(; target_dir::String, dry_run::Bool=true)

Computes the base and accent palettes and creates the VSCode theme JSON files.
If dry_run is true, displays file stats without overwriting disk.
"""
function _write_theme(theme, target_dir::String, dry_run::Bool)
    target_path = joinpath(target_dir, theme.file_name)
    json_str = JSON.json(theme.data, 2)
    n_lines = count(==('\n'), json_str) + 1
    n_bytes = sizeof(json_str)

    @printf("Theme: %-38s -> %-42s (%5d lines, %6d bytes)\n",
        theme.data["name"], theme.file_name, n_lines, n_bytes)

    if !dry_run
        mkpath(dirname(target_path))
        write(target_path, json_str)
        println("  [WRITTEN] $target_path")
    else
        println("  [DRY RUN] Target: $target_path (file preserved)")
    end
end

function generate_all_themes(; target_dir::String=joinpath(@__DIR__, "..", "..", "penumbra_vscode", "themes"), dry_run::Bool=true)
    println("="^80)
    println("PENUMBRA V2 VSCODE THEME COMPILER (dry_run = $dry_run)")
    println("="^80)

    base_tones, accents = load_palettes(joinpath(@__DIR__, ".."))

    # 4 Theme configurations matching package.json
    configs = [
        (:dark, :balanced),
        (:dark, :contrast_plus),
        (:dark, :contrast_plus_plus),
        (:light, :balanced)
    ]

    for (mode, tier) in configs
        base_dict = Dict(k => lowercase(v) for (k, v) in base_tones[tier])
        acc_dict = Dict(k => lowercase(v) for (k, v) in accents[mode][tier][8])
        term_dict = Dict(k => lowercase(v) for (k, v) in accents[mode][tier][6])
        theme = build_theme_dict(mode, tier, base_dict, acc_dict, term_dict)
        _write_theme(theme, target_dir, dry_run)
    end
    println("="^80)
end

if abspath(PROGRAM_FILE) == @__FILE__
    dry_run = !("--write" in ARGS)
    generate_all_themes(; dry_run=dry_run)
end
