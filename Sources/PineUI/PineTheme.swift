// PineTheme.swift — Liquid Glass theme for PineOS apps.
//
// Matches macOS Tahoe's design language: translucent surfaces,
// rounded corners, depth-aware transparency, frosted glass panels.

import CGTK4

public enum PineTheme {
    private static var applied = false

    public static func apply() {
        guard !applied else { return }
        applied = true

        let provider = gtk_css_provider_new()!

        let css = """
        /* ═══════════════════════════════════════════════════════════════
           PineUI Liquid Glass Theme — macOS Tahoe Design Language
           Colors sourced from the official MacTahoe GTK theme (dark mode)
           ═══════════════════════════════════════════════════════════════ */

        /* ── Global ── */
        * {
            transition: all 0.15s ease;
        }

        /* ── Typography scale (matches SF Pro sizes) ── */
        .pine-large-title { font-size: 2.0em; font-weight: 700; }
        .pine-title  { font-size: 1.5em; font-weight: 700; }
        .pine-title2 { font-size: 1.3em; font-weight: 600; }
        .pine-title3 { font-size: 1.15em; font-weight: 600; }
        .pine-headline { font-size: 1.0em; font-weight: 600; }
        .pine-subheadline { font-size: 0.9em; font-weight: 400; }
        .pine-body { font-size: 1.0em; }
        .pine-callout { font-size: 0.95em; }
        .pine-caption { font-size: 0.85em; color: rgba(222,222,222,0.55); }
        .pine-caption2 { font-size: 0.75em; color: rgba(222,222,222,0.45); }
        .pine-footnote { font-size: 0.8em; color: rgba(222,222,222,0.45); }
        .pine-bold { font-weight: 700; }

        /* ── Foreground styles ── */
        /* fg_color: #dedede */
        .pine-fg-primary { color: #dedede; }
        .pine-fg-secondary { color: rgba(222,222,222,0.55); }
        .pine-fg-tertiary { color: rgba(222,222,222,0.35); }
        .pine-fg-quaternary { color: rgba(222,222,222,0.2); }
        .pine-fg-accent { color: #0088FF; }

        /* ═══════════════════════════════════════════════════════════════
           Liquid Glass Surfaces
           ═══════════════════════════════════════════════════════════════ */

        /* ── Sidebar — translucent glass panel ── */
        /* sidebar_bg: rgba(#282828, 0.85) */
        .pine-sidebar {
            background: rgba(40,40,40,0.85);
            border-right: 1px solid rgba(255,255,255,0.1);
            padding-top: 8px;
        }

        /* hint_fg_color: #999999 */
        .pine-sidebar-section-header {
            font-size: 0.7em;
            font-weight: 700;
            text-transform: uppercase;
            color: #999999;
            padding: 16px 16px 4px 16px;
            letter-spacing: 0.8px;
        }

        .pine-sidebar-item {
            border-radius: 8px;
            padding: 5px 12px;
            margin: 1px 8px;
            min-height: 28px;
            border: 1px solid transparent;
        }

        /* sidebar_highlight: rgba(white, 0.06) */
        .pine-sidebar-item:hover {
            background: rgba(255,255,255,0.06);
            border: 1px solid transparent;
        }

        /* selected_bg: #0088FF at 0.15 opacity */
        .pine-sidebar-item-active {
            background: rgba(0,136,255,0.15);
            border: 1px solid rgba(0,136,255,0.1);
            box-shadow: 0 1px 3px rgba(0,0,0,0.08);
        }

        .pine-sidebar-badge {
            background: rgba(222,222,222,0.1);
            color: rgba(222,222,222,0.6);
            border-radius: 10px;
            padding: 0px 7px;
            font-size: 0.78em;
            font-weight: 600;
            min-width: 18px;
        }

        .pine-sidebar-list { padding-bottom: 12px; }

        /* ── Toolbar — floating glass bar ── */
        /* header_bg: #1e1e1e at 0.85 opacity */
        .pine-toolbar {
            background: rgba(30,30,30,0.85);
            border-bottom: 1px solid rgba(255,255,255,0.1);
            min-height: 38px;
            box-shadow: 0 1px 4px rgba(0,0,0,0.06);
        }

        /* ── Status Bar — subtle glass footer ── */
        /* base_color: #242424 at 0.85 opacity */
        .pine-status-bar {
            padding: 3px 16px;
            background: rgba(36,36,36,0.85);
            border-top: 1px solid rgba(255,255,255,0.08);
            min-height: 22px;
        }

        /* hint_fg_color: #999999 */
        .pine-status-label {
            font-size: 0.78em;
            color: #999999;
        }

        /* ═══════════════════════════════════════════════════════════════
           Cards & Containers — Frosted glass panels
           ═══════════════════════════════════════════════════════════════ */

        .pine-card {
            background: rgba(255,255,255,0.04);
            border-radius: 12px;
            border: 1px solid rgba(255,255,255,0.08);
            box-shadow: 0 2px 8px rgba(0,0,0,0.08),
                        inset 0 1px 0 rgba(255,255,255,0.05);
        }

        .pine-card-header {
            background: rgba(255,255,255,0.03);
            border-radius: 12px 12px 0 0;
            border-bottom: 1px solid rgba(255,255,255,0.05);
            padding: 10px 16px;
        }

        .pine-card-body { padding: 12px 16px; }

        /* ── List ── */
        .pine-list { padding: 4px 0; }

        /* ── List style variants ── */
        .pine-list-sidebar { background: transparent; }
        .pine-list-plain { background: transparent; padding: 0; }
        .pine-list-inset { margin: 8px; }
        .pine-list-inset-grouped {
            margin: 8px;
            border-radius: 12px;
            background: rgba(255,255,255,0.03);
            border: 1px solid rgba(255,255,255,0.06);
        }
        .pine-list-bordered {
            border: 1px solid rgba(255,255,255,0.12);
            border-radius: 12px;
        }

        /* ── Form ── */
        .pine-form { }

        /* ═══════════════════════════════════════════════════════════════
           Buttons — Liquid Glass pill buttons
           ═══════════════════════════════════════════════════════════════ */

        /* button_bg: rgba(white, 0.06) */
        .pine-btn {
            border-radius: 8px;
            background: rgba(255,255,255,0.06);
            border: none;
        }

        /* button_hover_bg: rgba(white, 0.1) */
        .pine-btn:hover {
            background: rgba(255,255,255,0.1);
            box-shadow: 0 8px 26px rgba(0,0,0,0.2),
                        inset 1px 2px 1px -1px rgba(255,255,255,0.08),
                        inset -1px -1px 1px 0 rgba(255,255,255,0.08);
        }

        /* button_active_bg: rgba(white, 0.25) */
        .pine-btn:active {
            background: rgba(255,255,255,0.25);
        }

        .pine-btn-bordered {
            border-radius: 8px;
            border: 1px solid rgba(255,255,255,0.12);
            background: rgba(255,255,255,0.04);
        }

        .pine-btn-bordered:hover {
            background: rgba(255,255,255,0.1);
        }

        /* Glass button style (Tahoe .glass / .glassProminent) */
        .pine-btn-glass {
            border-radius: 20px;
            background: rgba(255,255,255,0.08);
            border: 1px solid rgba(255,255,255,0.12);
            box-shadow: 0 4px 16px rgba(0,0,0,0.12),
                        inset 0 1px 0 rgba(255,255,255,0.1);
            padding: 6px 16px;
        }

        .pine-btn-glass:hover {
            background: rgba(255,255,255,0.1);
            box-shadow: 0 8px 26px rgba(0,0,0,0.2),
                        inset 1px 2px 1px -1px rgba(255,255,255,0.08),
                        inset -1px -1px 1px 0 rgba(255,255,255,0.08);
        }

        /* suggested: #0088FF */
        .pine-btn-glass-prominent {
            border-radius: 20px;
            background: #0088FF;
            border: none;
            box-shadow: 0 2px 8px rgba(0,136,255,0.25),
                        inset 0 1px 0 rgba(255,255,255,0.2);
            color: white;
            padding: 6px 16px;
        }

        .pine-btn-glass-prominent:hover {
            background: #0088FF;
            box-shadow: 0 4px 16px rgba(0,136,255,0.35),
                        inset 0 1px 0 rgba(255,255,255,0.25);
        }

        /* ── Suggested/destructive action buttons (Adwaita overrides) ── */
        /* suggested: #0088FF, destructive: #ED5F5D */
        .suggested-action {
            background: #0088FF;
            color: white;
            border-radius: 20px;
            box-shadow: 0 2px 8px rgba(0,136,255,0.2);
        }

        .destructive-action {
            background: #ED5F5D;
            color: white;
            border-radius: 20px;
            box-shadow: 0 2px 8px rgba(237,95,93,0.2);
        }

        /* ═══════════════════════════════════════════════════════════════
           Text & Editor
           ═══════════════════════════════════════════════════════════════ */

        /* entry_bg: rgba(white, 0.06) */
        .pine-text-editor {
            background: rgba(255,255,255,0.06);
            border-radius: 8px;
            border: 1px solid rgba(255,255,255,0.12);
        }

        /* ── Disclosure group ── */
        expander title {
            font-weight: 600;
            padding: 4px 0;
        }

        /* ── Level bar (Gauge) ── */
        /* accent: #0088FF */
        levelbar block.filled {
            background: #0088FF;
            border-radius: 4px;
        }

        /* ═══════════════════════════════════════════════════════════════
           Table
           ═══════════════════════════════════════════════════════════════ */

        /* table header: bg rgba(#282828, 0.6) */
        .pine-table-header {
            font-weight: 600;
            font-size: 0.85em;
            color: rgba(222,222,222,0.55);
            background: rgba(40,40,40,0.6);
            border-bottom: 1px solid rgba(255,255,255,0.12);
            padding: 6px 8px;
        }

        .pine-table-alt-row {
            background: rgba(255,255,255,0.02);
        }

        /* ═══════════════════════════════════════════════════════════════
           Liquid Glass Utilities
           ═══════════════════════════════════════════════════════════════ */

        /* Glass surface — apply to any widget */
        /* pine-glass: rgba(white, 0.08), border rgba(white, 0.12), shadow */
        .pine-glass {
            background: rgba(255,255,255,0.08);
            border: 1px solid rgba(255,255,255,0.12);
            border-radius: 16px;
            box-shadow: 0 4px 16px rgba(0,0,0,0.12),
                        inset 0 1px 0 rgba(255,255,255,0.1);
        }

        /* pine-glass-clear: rgba(white, 0.04) */
        .pine-glass-clear {
            background: rgba(255,255,255,0.04);
            border: 1px solid rgba(255,255,255,0.08);
            border-radius: 16px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
        }

        /* pine-glass-tinted: rgba(#0088FF, 0.1), border rgba(#0088FF, 0.12) */
        .pine-glass-tinted {
            background: rgba(0,136,255,0.1);
            border: 1px solid rgba(0,136,255,0.12);
            border-radius: 16px;
            box-shadow: 0 4px 16px rgba(0,136,255,0.08),
                        inset 0 1px 0 rgba(255,255,255,0.1);
        }

        /* ── Tab view — glass tabs ── */
        notebook header tab {
            border-radius: 8px;
            padding: 4px 12px;
            margin: 2px;
        }

        notebook header tab:checked {
            background: rgba(255,255,255,0.1);
            box-shadow: 0 1px 4px rgba(0,0,0,0.08);
        }

        /* ── Switch / Toggle — glass pill ── */
        switch {
            border-radius: 14px;
            min-height: 24px;
            min-width: 44px;
        }

        switch slider {
            border-radius: 12px;
            background: white;
            box-shadow: 0 1px 3px rgba(0,0,0,0.15);
        }

        /* ── Entry / TextField — glass input ── */
        /* entry_bg: rgba(white, 0.06), border: rgba(white, 0.12) */
        entry {
            border-radius: 8px;
            border: 1px solid rgba(255,255,255,0.12);
            background: rgba(255,255,255,0.06);
            min-height: 30px;
        }

        /* focus: accent #0088FF, glow rgba(#0088FF, 0.25) */
        entry:focus {
            border-color: #0088FF;
            box-shadow: 0 0 0 2px rgba(0,136,255,0.25);
        }

        /* ── Dropdown — glass picker ── */
        dropdown button {
            border-radius: 8px;
            border: 1px solid rgba(255,255,255,0.12);
            background: rgba(255,255,255,0.06);
        }

        /* ── Scale / Slider — glass track ── */
        /* track: rgba(white, 0.06), fill: #0088FF, thumb: white 18x18 */
        scale trough {
            border-radius: 4px;
            background: rgba(255,255,255,0.06);
            min-height: 4px;
        }

        scale highlight {
            border-radius: 4px;
            background: #0088FF;
        }

        scale slider {
            border-radius: 50%;
            background: white;
            box-shadow: 0 1px 4px rgba(0,0,0,0.2);
            min-width: 18px;
            min-height: 18px;
        }

        /* ── Popover — glass floating panel ── */
        /* menu_bg: rgba(#333333, 0.92), base_color: #242424 */
        popover contents {
            border-radius: 12px;
            background: rgba(36,36,36,0.92);
            border: 1px solid rgba(255,255,255,0.1);
            box-shadow: 0 8px 32px rgba(0,0,0,0.3);
            padding: 4px;
        }

        /* ── Scrollbar — thin overlay style ── */
        /* bg: rgba(white, 0.25), hover: rgba(white, 0.4) */
        scrollbar slider {
            border-radius: 8px;
            min-width: 6px;
            min-height: 6px;
            background: rgba(255,255,255,0.25);
        }

        scrollbar slider:hover {
            background: rgba(255,255,255,0.4);
            min-width: 8px;
        }

        /* ── Progress bar — glass track ── */
        /* track: rgba(white, 0.06), fill: #0088FF */
        progressbar trough {
            border-radius: 4px;
            background: rgba(255,255,255,0.06);
            min-height: 4px;
        }

        progressbar progress {
            border-radius: 4px;
            background: #0088FF;
        }

        /* ── Spinner ── */
        spinner {
            color: #0088FF;
        }

        /* ── Calendar — glass date picker ── */
        calendar {
            border-radius: 12px;
            border: 1px solid rgba(255,255,255,0.1);
            background: rgba(255,255,255,0.03);
        }

        calendar day {
            border-radius: 50%;
        }

        calendar day:selected {
            background: #0088FF;
            color: white;
        }

        /* ── Window rounding ── */
        window {
            border-radius: 12px;
        }

        /* ═══════════════════════════════════════════════════════════════
           Linked Controls (SegmentedControl, ControlGroup)
           ═══════════════════════════════════════════════════════════════ */

        .linked button {
            border-radius: 0;
            border-right: 1px solid rgba(255,255,255,0.1);
        }

        .linked button:first-child {
            border-radius: 8px 0 0 8px;
        }

        .linked button:last-child {
            border-radius: 0 8px 8px 0;
            border-right: none;
        }

        .linked button:only-child {
            border-radius: 8px;
        }
        """

        let providerPtr = UnsafeMutableRawPointer(provider)
            .assumingMemoryBound(to: GtkCssProvider.self)
        gtk_css_provider_load_from_string(providerPtr, css)

        let display = gdk_display_get_default()!
        let styleProvider = OpaquePointer(provider)
        gtk_style_context_add_provider_for_display(
            display,
            styleProvider,
            UInt32(GTK_STYLE_PROVIDER_PRIORITY_APPLICATION)
        )
    }
}
