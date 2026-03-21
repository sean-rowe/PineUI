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
        .pine-caption { font-size: 0.85em; color: alpha(@window_fg_color, 0.55); }
        .pine-caption2 { font-size: 0.75em; color: alpha(@window_fg_color, 0.45); }
        .pine-footnote { font-size: 0.8em; color: alpha(@window_fg_color, 0.45); }
        .pine-bold { font-weight: 700; }

        /* ── Foreground styles ── */
        .pine-fg-primary { color: @window_fg_color; }
        .pine-fg-secondary { color: alpha(@window_fg_color, 0.55); }
        .pine-fg-tertiary { color: alpha(@window_fg_color, 0.35); }
        .pine-fg-quaternary { color: alpha(@window_fg_color, 0.2); }
        .pine-fg-accent { color: @accent_bg_color; }

        /* ═══════════════════════════════════════════════════════════════
           Liquid Glass Surfaces
           ═══════════════════════════════════════════════════════════════ */

        /* ── Sidebar — translucent glass panel ── */
        .pine-sidebar {
            background: alpha(@window_bg_color, 0.65);
            border-right: 1px solid alpha(@borders, 0.15);
            padding-top: 8px;
        }

        .pine-sidebar-section-header {
            font-size: 0.7em;
            font-weight: 700;
            text-transform: uppercase;
            color: alpha(@window_fg_color, 0.4);
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

        .pine-sidebar-item:hover {
            background: alpha(@accent_bg_color, 0.08);
            border: 1px solid alpha(@accent_bg_color, 0.06);
        }

        .pine-sidebar-item-active {
            background: alpha(@accent_bg_color, 0.15);
            border: 1px solid alpha(@accent_bg_color, 0.1);
            box-shadow: 0 1px 3px alpha(black, 0.08);
        }

        .pine-sidebar-badge {
            background: alpha(@window_fg_color, 0.1);
            color: alpha(@window_fg_color, 0.6);
            border-radius: 10px;
            padding: 0px 7px;
            font-size: 0.78em;
            font-weight: 600;
            min-width: 18px;
        }

        .pine-sidebar-list { padding-bottom: 12px; }

        /* ── Toolbar — floating glass bar ── */
        .pine-toolbar {
            background: alpha(@headerbar_bg_color, 0.7);
            border-bottom: 1px solid alpha(@borders, 0.15);
            min-height: 38px;
            box-shadow: 0 1px 4px alpha(black, 0.06);
        }

        /* ── Status Bar — subtle glass footer ── */
        .pine-status-bar {
            padding: 3px 16px;
            background: alpha(@window_bg_color, 0.75);
            border-top: 1px solid alpha(@borders, 0.12);
            min-height: 22px;
        }

        .pine-status-label {
            font-size: 0.78em;
            color: alpha(@window_fg_color, 0.5);
        }

        /* ═══════════════════════════════════════════════════════════════
           Cards & Containers — Frosted glass panels
           ═══════════════════════════════════════════════════════════════ */

        .pine-card {
            background: alpha(white, 0.04);
            border-radius: 12px;
            border: 1px solid alpha(white, 0.08);
            box-shadow: 0 2px 8px alpha(black, 0.08),
                        inset 0 1px 0 alpha(white, 0.05);
        }

        .pine-card-header {
            background: alpha(white, 0.03);
            border-radius: 12px 12px 0 0;
            border-bottom: 1px solid alpha(white, 0.05);
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
            background: alpha(white, 0.03);
            border: 1px solid alpha(white, 0.06);
        }
        .pine-list-bordered {
            border: 1px solid alpha(@borders, 0.2);
            border-radius: 12px;
        }

        /* ── Form ── */
        .pine-form { }

        /* ═══════════════════════════════════════════════════════════════
           Buttons — Liquid Glass pill buttons
           ═══════════════════════════════════════════════════════════════ */

        .pine-btn {
            border-radius: 8px;
            border: 1px solid alpha(@borders, 0.15);
            box-shadow: 0 1px 2px alpha(black, 0.05);
        }

        .pine-btn:hover {
            box-shadow: 0 2px 6px alpha(black, 0.1);
        }

        .pine-btn-bordered {
            border-radius: 8px;
            border: 1px solid alpha(@borders, 0.35);
            background: alpha(white, 0.04);
        }

        .pine-btn-bordered:hover {
            background: alpha(white, 0.08);
        }

        /* Glass button style (Tahoe .glass / .glassProminent) */
        .pine-btn-glass {
            border-radius: 20px;
            background: alpha(white, 0.12);
            border: 1px solid alpha(white, 0.2);
            box-shadow: 0 2px 8px alpha(black, 0.1),
                        inset 0 1px 0 alpha(white, 0.15);
            padding: 6px 16px;
        }

        .pine-btn-glass:hover {
            background: alpha(white, 0.18);
            box-shadow: 0 4px 12px alpha(black, 0.15),
                        inset 0 1px 0 alpha(white, 0.2);
        }

        .pine-btn-glass-prominent {
            border-radius: 20px;
            background: alpha(@accent_bg_color, 0.8);
            border: 1px solid alpha(@accent_bg_color, 0.3);
            box-shadow: 0 2px 8px alpha(@accent_bg_color, 0.25),
                        inset 0 1px 0 alpha(white, 0.2);
            color: white;
            padding: 6px 16px;
        }

        .pine-btn-glass-prominent:hover {
            background: @accent_bg_color;
            box-shadow: 0 4px 16px alpha(@accent_bg_color, 0.35),
                        inset 0 1px 0 alpha(white, 0.25);
        }

        /* ── Suggested/destructive action buttons (Adwaita overrides) ── */
        .suggested-action {
            border-radius: 20px;
            box-shadow: 0 2px 8px alpha(@accent_bg_color, 0.2);
        }

        .destructive-action {
            border-radius: 20px;
            box-shadow: 0 2px 8px alpha(red, 0.2);
        }

        /* ═══════════════════════════════════════════════════════════════
           Text & Editor
           ═══════════════════════════════════════════════════════════════ */

        .pine-text-editor {
            background: alpha(white, 0.03);
            border-radius: 8px;
            border: 1px solid alpha(@borders, 0.1);
        }

        /* ── Disclosure group ── */
        expander title {
            font-weight: 600;
            padding: 4px 0;
        }

        /* ── Level bar (Gauge) ── */
        levelbar block.filled {
            background: @accent_bg_color;
            border-radius: 4px;
        }

        /* ═══════════════════════════════════════════════════════════════
           Table
           ═══════════════════════════════════════════════════════════════ */

        .pine-table-header {
            font-weight: 700;
            font-size: 0.85em;
            color: alpha(@window_fg_color, 0.55);
            background: alpha(@window_bg_color, 0.6);
            border-bottom: 1px solid alpha(@borders, 0.15);
            padding: 6px 8px;
        }

        .pine-table-alt-row {
            background: alpha(white, 0.02);
        }

        /* ═══════════════════════════════════════════════════════════════
           Liquid Glass Utilities
           ═══════════════════════════════════════════════════════════════ */

        /* Glass surface — apply to any widget */
        .pine-glass {
            background: alpha(white, 0.12);
            border: 1px solid alpha(white, 0.2);
            border-radius: 16px;
            box-shadow: 0 4px 16px alpha(black, 0.1),
                        inset 0 1px 0 alpha(white, 0.15);
        }

        .pine-glass-clear {
            background: alpha(white, 0.06);
            border: 1px solid alpha(white, 0.1);
            border-radius: 16px;
            box-shadow: 0 2px 8px alpha(black, 0.06);
        }

        .pine-glass-tinted {
            background: alpha(@accent_bg_color, 0.12);
            border: 1px solid alpha(@accent_bg_color, 0.15);
            border-radius: 16px;
            box-shadow: 0 4px 16px alpha(@accent_bg_color, 0.08),
                        inset 0 1px 0 alpha(white, 0.1);
        }

        /* ── Tab view — glass tabs ── */
        notebook header tab {
            border-radius: 8px;
            padding: 4px 12px;
            margin: 2px;
        }

        notebook header tab:checked {
            background: alpha(white, 0.1);
            box-shadow: 0 1px 4px alpha(black, 0.08);
        }

        /* ── Switch / Toggle — glass pill ── */
        switch {
            border-radius: 14px;
            min-height: 24px;
            min-width: 44px;
        }

        switch slider {
            border-radius: 12px;
            box-shadow: 0 1px 3px alpha(black, 0.15);
        }

        /* ── Entry / TextField — glass input ── */
        entry {
            border-radius: 8px;
            border: 1px solid alpha(@borders, 0.2);
            background: alpha(white, 0.04);
            min-height: 30px;
        }

        entry:focus {
            border-color: @accent_bg_color;
            box-shadow: 0 0 0 2px alpha(@accent_bg_color, 0.2);
        }

        /* ── Dropdown — glass picker ── */
        dropdown button {
            border-radius: 8px;
            border: 1px solid alpha(@borders, 0.2);
            background: alpha(white, 0.04);
        }

        /* ── Scale / Slider — glass track ── */
        scale trough {
            border-radius: 4px;
            background: alpha(white, 0.06);
            min-height: 4px;
        }

        scale highlight {
            border-radius: 4px;
            background: @accent_bg_color;
        }

        scale slider {
            border-radius: 50%;
            background: white;
            box-shadow: 0 1px 4px alpha(black, 0.2);
            min-width: 18px;
            min-height: 18px;
        }

        /* ── Popover — glass floating panel ── */
        popover contents {
            border-radius: 12px;
            background: alpha(@window_bg_color, 0.85);
            border: 1px solid alpha(white, 0.1);
            box-shadow: 0 8px 32px alpha(black, 0.2);
            padding: 4px;
        }

        /* ── Scrollbar — thin overlay style ── */
        scrollbar slider {
            border-radius: 8px;
            min-width: 6px;
            min-height: 6px;
            background: alpha(@window_fg_color, 0.25);
        }

        scrollbar slider:hover {
            background: alpha(@window_fg_color, 0.4);
            min-width: 8px;
        }

        /* ── Progress bar — glass track ── */
        progressbar trough {
            border-radius: 4px;
            background: alpha(white, 0.06);
            min-height: 4px;
        }

        progressbar progress {
            border-radius: 4px;
            background: @accent_bg_color;
        }

        /* ── Spinner ── */
        spinner {
            color: @accent_bg_color;
        }

        /* ── Calendar — glass date picker ── */
        calendar {
            border-radius: 12px;
            border: 1px solid alpha(@borders, 0.15);
            background: alpha(white, 0.03);
        }

        calendar day {
            border-radius: 50%;
        }

        calendar day:selected {
            background: @accent_bg_color;
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
            border-right: 1px solid alpha(@borders, 0.15);
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
