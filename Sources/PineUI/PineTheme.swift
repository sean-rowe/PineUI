// PineTheme.swift — Liquid Glass theme for PineOS apps.
//
// Matches macOS Tahoe's design language: translucent surfaces,
// rounded corners, depth-aware transparency, frosted glass panels.
// Values sourced precisely from the MacTahoe GTK theme (dark mode).

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
           Precise values from MacTahoe GTK theme (dark mode)
           Loaded at PRIORITY_USER (800) to fully override Adwaita
           ═══════════════════════════════════════════════════════════════ */

        /* ═══════════════════════════════════════════════════════════════
           ADWAITA RESET — neutralize GTK4/Adwaita defaults
           ═══════════════════════════════════════════════════════════════ */

        /* Reset ALL widget backgrounds to our base */
        window, box, frame, scrolledwindow, viewport, stack,
        paned, overlay, revealer, expander, notebook, grid {
            background: none;
            border: none;
            box-shadow: none;
        }

        /* Window base */
        window {
            background-color: #242424;
            color: #dedede;
        }

        /* Reset button Adwaita styling completely */
        button {
            background: rgba(255,255,255,0.06);
            border: none;
            box-shadow: 0 1px 1px 0 rgba(0,0,0,0.03), 0 1px 2px 0 rgba(0,0,0,0.01);
            border-radius: 6px;
            color: #afafaf;
            min-height: 24px;
            padding: 4px 12px;
        }
        button:hover {
            background: rgba(255,255,255,0.1);
            color: #dedede;
            box-shadow: 0 6px 20px rgba(0,0,0,0.15),
                        inset 1px 2px 1px -1px rgba(255,255,255,0.08),
                        inset -1px -1px 1px 0 rgba(255,255,255,0.08);
        }
        button:active, button:checked {
            background: rgba(255,255,255,0.25);
            color: #dedede;
        }
        button:disabled {
            background: rgba(255,255,255,0.02);
            color: rgba(222,222,222,0.35);
        }
        button.flat {
            background: none;
            border: none;
            box-shadow: none;
        }
        button.flat:hover {
            background: rgba(255,255,255,0.06);
            box-shadow: none;
        }

        /* Reset entry Adwaita styling */
        entry, searchentry, passwordentry {
            background: rgba(255,255,255,0.06);
            border: none;
            border-radius: 6px;
            box-shadow: inset 0 0 0 1px rgba(255,255,255,0.08);
            color: #dedede;
            min-height: 30px;
            padding: 0 8px;
        }
        entry:focus, searchentry:focus, passwordentry:focus {
            box-shadow: inset 0 0 0 2px rgba(0,136,255,0.75);
        }

        /* Reset switch Adwaita styling */
        switch {
            background: rgba(0,0,0,0.3);
            border: none;
            border-radius: 9999px;
            min-height: 26px;
            min-width: 48px;
            box-shadow: none;
        }
        switch:checked {
            background: #0088FF;
        }
        switch slider {
            background: white;
            border-radius: 9999px;
            border: none;
            min-width: 22px;
            min-height: 22px;
            box-shadow: 0 1px 2px 0 rgba(0,0,0,0.15), 0 2px 3px 0 rgba(0,0,0,0.1);
        }
        switch:hover slider {
            box-shadow: 0 2px 3px 0 rgba(0,0,0,0.2), 0 3px 5px 0 rgba(0,0,0,0.15);
        }

        /* Reset scale/slider Adwaita styling */
        scale {
            padding: 8px 0;
        }
        scale trough {
            background: rgba(0,0,0,0.2);
            border: none;
            border-radius: 9999px;
            min-height: 6px;
            box-shadow: none;
        }
        scale highlight {
            background: #0088FF;
            border-radius: 9999px;
            border: none;
        }
        scale slider {
            background: white;
            border: none;
            border-radius: 9999px;
            min-width: 24px;
            min-height: 26px;
            box-shadow: 0 1px 2px 0 rgba(0,0,0,0.05), 0 3px 8px 0 rgba(0,0,0,0.03);
        }
        scale slider:hover {
            box-shadow: 0 1px 2px 0 rgba(0,0,0,0.05), 0 3px 12px 0 rgba(0,0,0,0.1);
        }

        /* Reset spinbutton Adwaita styling */
        spinbutton {
            background: rgba(255,255,255,0.06);
            border: none;
            border-radius: 6px;
            box-shadow: inset 0 0 0 1px rgba(255,255,255,0.08);
        }
        spinbutton button {
            background: none;
            border: none;
            box-shadow: none;
            border-radius: 0;
            min-width: 28px;
        }
        spinbutton button:hover {
            background: rgba(255,255,255,0.08);
        }

        /* Reset dropdown Adwaita styling */
        dropdown, dropdown button {
            background: rgba(255,255,255,0.06);
            border: none;
            border-radius: 6px;
            box-shadow: inset 0 0 0 1px rgba(255,255,255,0.08);
            color: #dedede;
        }
        dropdown:hover button, dropdown button:hover {
            background: rgba(255,255,255,0.1);
        }

        /* Reset notebook/tabs Adwaita styling */
        notebook {
            background: none;
        }
        notebook header {
            background: rgba(40,40,40,0.6);
            border: none;
            box-shadow: none;
        }
        notebook header tab {
            background: none;
            border: none;
            border-radius: 9999px;
            padding: 4px 14px;
            margin: 3px 2px;
            color: rgba(222,222,222,0.6);
            box-shadow: none;
        }
        notebook header tab:checked {
            background: rgba(255,255,255,0.1);
            color: #dedede;
            box-shadow: 0 1px 4px rgba(0,0,0,0.08);
        }
        notebook header tab:hover:not(:checked) {
            background: rgba(255,255,255,0.04);
            color: #dedede;
        }

        /* Reset progressbar Adwaita styling */
        progressbar trough {
            background: rgba(0,0,0,0.2);
            border: none;
            border-radius: 9999px;
            min-height: 6px;
        }
        progressbar progress {
            background: #0088FF;
            border: none;
            border-radius: 9999px;
        }

        /* Reset levelbar (gauge) */
        levelbar trough {
            background: rgba(0,0,0,0.2);
            border: none;
            border-radius: 4px;
        }
        levelbar block.filled {
            background: #0088FF;
            border-radius: 4px;
            border: none;
        }
        levelbar block.empty {
            background: none;
            border: none;
        }

        /* Reset scrollbar */
        scrollbar {
            background: none;
            border: none;
        }
        scrollbar slider {
            background: rgba(255,255,255,0.25);
            border: none;
            border-radius: 9999px;
            min-width: 6px;
            min-height: 6px;
        }
        scrollbar slider:hover {
            background: rgba(255,255,255,0.4);
            min-width: 8px;
        }

        /* Reset popover */
        popover, popover contents {
            background: rgba(36,36,36,0.95);
            border: 1px solid rgba(255,255,255,0.1);
            border-radius: 16px;
            box-shadow: 0 3px 8px 1px rgba(0,0,0,0.08),
                        0 10px 30px rgba(0,0,0,0.12);
            color: #dedede;
        }

        /* Reset expander */
        expander title {
            background: none;
            border: none;
        }

        /* Reset calendar */
        calendar {
            background: rgba(255,255,255,0.03);
            border: 1px solid rgba(255,255,255,0.1);
            border-radius: 10px;
            color: #dedede;
        }
        calendar day:selected {
            background: #0088FF;
            color: white;
            border-radius: 50%;
        }

        /* Reset separator */
        separator {
            background: rgba(255,255,255,0.1);
            min-height: 1px;
            min-width: 1px;
        }

        /* Reset label colors */
        label {
            color: #dedede;
        }
        label.dim-label {
            color: #999999;
        }

        /* Mail row — consistent sizing for all states */
        .pine-mail-row {
            padding: 0;
            border-radius: 6px;
            margin: 1px 4px;
            background: none;
            border: 1px solid transparent;
        }
        .pine-mail-row-selected {
            background: rgba(0,136,255,0.15);
            border: 1px solid rgba(0,136,255,0.08);
        }

        /* Suggested / Destructive action buttons */
        button.suggested-action {
            background: #0088FF;
            color: white;
            border-radius: 6px;
            box-shadow: 0 2px 8px rgba(0,136,255,0.2);
        }
        button.suggested-action:hover {
            box-shadow: 0 4px 16px rgba(0,136,255,0.3);
        }
        button.destructive-action {
            background: #ED5F5D;
            color: white;
            border-radius: 6px;
            box-shadow: 0 2px 8px rgba(237,95,93,0.2);
        }

        /* Reset link button */
        linkbutton {
            color: #3484e2;
        }

        /* Spinner */
        spinner {
            color: #0088FF;
        }

        /* ── Global transitions ── */
        * {
            transition: all 150ms cubic-bezier(0.0, 0.0, 0.2, 1);
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
        /* hint_fg: #999999, alt_fg: #afafaf */
        .pine-caption { font-size: 0.85em; color: #afafaf; }
        .pine-caption2 { font-size: 0.75em; color: #999999; }
        .pine-footnote { font-size: 0.8em; color: #999999; }
        .pine-bold { font-weight: 700; }

        /* ── Foreground styles ── */
        /* fg_color: #dedede, alt_fg: #afafaf, hint_fg: #999999 */
        .pine-fg-primary { color: #dedede; }
        .pine-fg-secondary { color: #afafaf; }
        .pine-fg-tertiary { color: #999999; }
        .pine-fg-quaternary { color: rgba(222,222,222,0.2); }
        .pine-fg-accent { color: #0088FF; }

        /* ═══════════════════════════════════════════════════════════════
           Liquid Glass Surfaces
           ═══════════════════════════════════════════════════════════════ */

        /* ── Sidebar — translucent glass panel ── */
        /* sidebar_bg: rgba(#282828, 0.85), border: rgba(white, 0.12) */
        .pine-sidebar {
            background: rgba(40,40,40,0.85);
            border-right: 1px solid rgba(255,255,255,0.12);
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

        /* $base_border_radius: 8px, $menuitem_size: 32px */
        .pine-sidebar-item {
            border-radius: 8px;
            padding: 5px 12px;
            margin: 1px 8px;
            min-height: 32px;
            border: 1px solid transparent;
        }

        /* sidebar_highlight: rgba(white, 0.06) */
        .pine-sidebar-item:hover {
            background: rgba(255,255,255,0.06);
            border: 1px solid transparent;
        }

        /* selected_bg: rgba(#0088FF, 0.15), border: rgba(#0088FF, 0.1) */
        .pine-sidebar-item-active {
            background: rgba(0,136,255,0.15);
            border: 1px solid rgba(0,136,255,0.1);
            /* $shadow_3: 0 1px 1px 0 rgba(black,0.03), 0 1px 2px 0 rgba(black,0.01) */
            box-shadow: 0 1px 1px 0 rgba(0,0,0,0.03),
                        0 1px 2px 0 rgba(0,0,0,0.01);
        }

        .pine-sidebar-badge {
            background: rgba(222,222,222,0.1);
            color: rgba(222,222,222,0.6);
            border-radius: 9999px;
            padding: 0px 7px;
            font-size: 0.78em;
            font-weight: 600;
            min-width: 18px;
        }

        .pine-sidebar-list { padding-bottom: 12px; }

        /* ── Toolbar / Headerbar — floating glass bar ── */
        /* header_bg: rgba(#1e1e1e, 0.85), $headerbar_size: 50px */
        /* border: rgba(white, 0.12) */
        /* $shadow_1: 0 1px 1px 0 rgba(black,0.12), 0 1px 2px 0 rgba(black,0.06) */
        .pine-toolbar {
            background: rgba(30,30,30,0.85);
            border-bottom: 1px solid rgba(255,255,255,0.12);
            min-height: 50px;
            box-shadow: 0 1px 1px 0 rgba(0,0,0,0.12),
                        0 1px 2px 0 rgba(0,0,0,0.06);
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
           $bd_radius: 10px
           ═══════════════════════════════════════════════════════════════ */

        /* Glass depth: subtle inner shadow for glass effect */
        .pine-card {
            background: rgba(255,255,255,0.04);
            border-radius: 10px;
            border: 1px solid rgba(255,255,255,0.08);
            box-shadow: 0 2px 8px rgba(0,0,0,0.08),
                        inset 0 1px 0 rgba(255,255,255,0.05),
                        inset 0 0 0 1px rgba(255,255,255,0.02);
        }

        .pine-card-header {
            background: rgba(255,255,255,0.03);
            border-radius: 10px 10px 0 0;
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
        /* $bd_radius: 10px */
        .pine-list-inset-grouped {
            margin: 8px;
            border-radius: 10px;
            background: rgba(255,255,255,0.03);
            border: 1px solid rgba(255,255,255,0.06);
        }
        .pine-list-bordered {
            border: 1px solid rgba(255,255,255,0.12);
            border-radius: 10px;
        }

        /* ── Form ── */
        .pine-form { }

        /* ═══════════════════════════════════════════════════════════════
           Buttons — Liquid Glass
           $bt_radius: 6px
           $button_transition: all 100ms cubic-bezier(0.25, 0.46, 0.45, 0.94)
           ═══════════════════════════════════════════════════════════════ */

        /* button_bg: rgba(white, 0.06) */
        /* $shadow_3: 0 1px 1px 0 rgba(black,0.03), 0 1px 2px 0 rgba(black,0.01) */
        .pine-btn {
            border-radius: 6px;
            background: rgba(255,255,255,0.06);
            border: none;
            box-shadow: 0 1px 1px 0 rgba(0,0,0,0.03),
                        0 1px 2px 0 rgba(0,0,0,0.01);
            transition: all 100ms cubic-bezier(0.25, 0.46, 0.45, 0.94);
        }

        /* button_hover: rgba(white, 0.1) */
        /* hover shadow: 0 6px 20px rgba(black,0.15), inset glass highlights */
        .pine-btn:hover {
            background: rgba(255,255,255,0.1);
            box-shadow: 0 6px 20px rgba(0,0,0,0.15),
                        inset 1px 2px 1px -1px rgba(255,255,255,0.08),
                        inset -1px -1px 1px 0 rgba(255,255,255,0.08);
            transition: all 100ms cubic-bezier(0.25, 0.46, 0.45, 0.94);
        }

        /* button_active: rgba(white, 0.25) */
        .pine-btn:active {
            background: rgba(255,255,255,0.25);
            box-shadow: none;
            transition: all 100ms cubic-bezier(0.25, 0.46, 0.45, 0.94);
        }

        /* $bt_radius: 6px, border: rgba(white, 0.12) */
        .pine-btn-bordered {
            border-radius: 6px;
            border: 1px solid rgba(255,255,255,0.12);
            background: rgba(255,255,255,0.04);
            box-shadow: 0 1px 1px 0 rgba(0,0,0,0.03),
                        0 1px 2px 0 rgba(0,0,0,0.01);
            transition: all 100ms cubic-bezier(0.25, 0.46, 0.45, 0.94);
        }

        .pine-btn-bordered:hover {
            background: rgba(255,255,255,0.1);
            box-shadow: 0 6px 20px rgba(0,0,0,0.15),
                        inset 1px 2px 1px -1px rgba(255,255,255,0.08),
                        inset -1px -1px 1px 0 rgba(255,255,255,0.08);
            transition: all 100ms cubic-bezier(0.25, 0.46, 0.45, 0.94);
        }

        /* Glass button style — $circular_radius: 9999px pill */
        .pine-btn-glass {
            border-radius: 9999px;
            background: rgba(255,255,255,0.08);
            border: 1px solid rgba(255,255,255,0.12);
            box-shadow: 0 4px 16px rgba(0,0,0,0.12),
                        inset 0 1px 0 rgba(255,255,255,0.1);
            padding: 6px 16px;
            transition: all 100ms cubic-bezier(0.25, 0.46, 0.45, 0.94);
        }

        .pine-btn-glass:hover {
            background: rgba(255,255,255,0.1);
            box-shadow: 0 6px 20px rgba(0,0,0,0.15),
                        inset 1px 2px 1px -1px rgba(255,255,255,0.08),
                        inset -1px -1px 1px 0 rgba(255,255,255,0.08);
            transition: all 100ms cubic-bezier(0.25, 0.46, 0.45, 0.94);
        }

        /* suggested: accent #0088FF, pill shape */
        .pine-btn-glass-prominent {
            border-radius: 9999px;
            background: #0088FF;
            border: none;
            box-shadow: 0 2px 8px rgba(0,136,255,0.25),
                        inset 0 1px 0 rgba(255,255,255,0.2);
            color: white;
            padding: 6px 16px;
            transition: all 100ms cubic-bezier(0.25, 0.46, 0.45, 0.94);
        }

        .pine-btn-glass-prominent:hover {
            background: #0088FF;
            box-shadow: 0 4px 16px rgba(0,136,255,0.35),
                        inset 0 1px 0 rgba(255,255,255,0.25);
            transition: all 100ms cubic-bezier(0.25, 0.46, 0.45, 0.94);
        }

        /* ── Suggested/destructive action buttons (Adwaita overrides) ── */
        /* $circular_radius pill, accent #0088FF, destructive #ED5F5D */
        .suggested-action {
            background: #0088FF;
            color: white;
            border-radius: 9999px;
            box-shadow: 0 2px 8px rgba(0,136,255,0.2);
            transition: all 100ms cubic-bezier(0.25, 0.46, 0.45, 0.94);
        }

        .destructive-action {
            background: #ED5F5D;
            color: white;
            border-radius: 9999px;
            box-shadow: 0 2px 8px rgba(237,95,93,0.2);
            transition: all 100ms cubic-bezier(0.25, 0.46, 0.45, 0.94);
        }

        /* ═══════════════════════════════════════════════════════════════
           Text & Editor
           ═══════════════════════════════════════════════════════════════ */

        /* entry_bg: rgba(white, 0.06), border: rgba(white, 0.12) */
        /* $base_border_radius: 8px */
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
            border-radius: 9999px;
        }

        /* ═══════════════════════════════════════════════════════════════
           Table
           ═══════════════════════════════════════════════════════════════ */

        /* table header: bg rgba(#282828, 0.6), alt_fg: #afafaf */
        .pine-table-header {
            font-weight: 600;
            font-size: 0.85em;
            color: #afafaf;
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
        /* $po_radius: 16px, border: rgba(white, 0.12) */
        .pine-glass {
            background: rgba(255,255,255,0.08);
            border: 1px solid rgba(255,255,255,0.12);
            border-radius: 16px;
            box-shadow: 0 4px 16px rgba(0,0,0,0.12),
                        inset 0 1px 0 rgba(255,255,255,0.1),
                        inset 0 0 0 1px rgba(255,255,255,0.02);
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

        /* ── Tab view — sunken pill glass tabs ── */
        /* $base_border_radius: 8px → pill-like with 9999px on checked */
        notebook header tab {
            border-radius: 9999px;
            padding: 4px 16px;
            margin: 2px 3px;
            min-height: 28px;
            transition: all 150ms cubic-bezier(0.0, 0.0, 0.2, 1);
        }

        notebook header tab:checked {
            background: rgba(255,255,255,0.1);
            border-radius: 9999px;
            /* $shadow_3: subtle normal shadow */
            box-shadow: 0 1px 1px 0 rgba(0,0,0,0.03),
                        0 1px 2px 0 rgba(0,0,0,0.01),
                        inset 0 1px 0 rgba(255,255,255,0.06);
        }

        /* ── Switch / Toggle — glass pill (BIGGER per Tahoe spec) ── */
        /* track: $circular_radius pill, min-height: 26px, min-width: 48px */
        switch {
            border-radius: 9999px;
            min-height: 26px;
            min-width: 48px;
            /* $shadow_transition: box-shadow 150ms cubic-bezier(0.0, 0.0, 0.2, 1) */
            transition: all 150ms cubic-bezier(0.0, 0.0, 0.2, 1);
        }

        /* checked track: accent #0088FF */
        switch:checked {
            background: #0088FF;
        }

        /* thumb: white, $circular_radius, $shadow_5 */
        /* $shadow_5: 0 1px 2px 0 rgba(black,0.15), 0 2px 3px 0 rgba(black,0.1) */
        switch slider {
            border-radius: 9999px;
            background: white;
            box-shadow: 0 1px 2px 0 rgba(0,0,0,0.15),
                        0 2px 3px 0 rgba(0,0,0,0.1);
            transition: all 150ms cubic-bezier(0.0, 0.0, 0.2, 1);
        }

        /* thumb hover: $shadow_4 */
        /* $shadow_4: 0 2px 3px 0 rgba(black,0.2), 0 3px 5px 0 rgba(black,0.15) */
        switch slider:hover {
            box-shadow: 0 2px 3px 0 rgba(0,0,0,0.2),
                        0 3px 5px 0 rgba(0,0,0,0.15);
        }

        /* ── Entry / TextField — glass input ── */
        /* $bt_radius: 6px, entry_bg: rgba(white, 0.06) */
        /* focus-ring: inset box-shadow instead of border */
        entry {
            border-radius: 6px;
            border: none;
            background: rgba(255,255,255,0.06);
            min-height: 32px;
            /* inset 0 0 0 2px transparent (not visible until focus) */
            box-shadow: inset 0 0 0 2px transparent;
            transition: all 150ms cubic-bezier(0.0, 0.0, 0.2, 1);
        }

        /* focus: inset ring rgba(#0088FF, 0.75) — 2px inset box-shadow */
        entry:focus {
            box-shadow: inset 0 0 0 2px rgba(0,136,255,0.75);
            background: rgba(255,255,255,0.08);
        }

        /* ── Dropdown — glass picker ── */
        /* $bt_radius: 6px, entry_bg: rgba(white, 0.06), border: rgba(white, 0.12) */
        dropdown button {
            border-radius: 6px;
            border: 1px solid rgba(255,255,255,0.12);
            background: rgba(255,255,255,0.06);
            transition: all 100ms cubic-bezier(0.25, 0.46, 0.45, 0.94);
        }

        dropdown button:hover {
            background: rgba(255,255,255,0.1);
        }

        /* ── Scale / Slider — glass track (BIGGER thumbs per Tahoe spec) ── */
        /* trough: bg rgba(black, 0.2) — NOT rgba(white, 0.06)! */
        /* trough: $circular_radius, min-height: 6px */
        scale trough {
            border-radius: 9999px;
            background: rgba(0,0,0,0.2);
            min-height: 6px;
            transition: all 150ms cubic-bezier(0.0, 0.0, 0.2, 1);
        }

        /* highlight/fill: accent #0088FF, $circular_radius */
        scale highlight {
            border-radius: 9999px;
            background: #0088FF;
        }

        /* thumb: white, $circular_radius, min-width: 24px, min-height: 26px */
        /* $shadow_2: 0 1px 2px 0 rgba(black,0.05), 0 3px 8px 0 rgba(black,0.03) */
        scale slider {
            border-radius: 9999px;
            background: white;
            min-width: 24px;
            min-height: 26px;
            box-shadow: 0 1px 2px 0 rgba(0,0,0,0.05),
                        0 3px 8px 0 rgba(0,0,0,0.03);
            /* $shadow_transition: box-shadow 150ms cubic-bezier(0.0, 0.0, 0.2, 1) */
            transition: box-shadow 150ms cubic-bezier(0.0, 0.0, 0.2, 1);
        }

        /* thumb hover: $shadow_0 */
        /* $shadow_0: 0 1px 2px 0 rgba(black,0.05), 0 3px 12px 0 rgba(black,0.1) */
        scale slider:hover {
            box-shadow: 0 1px 2px 0 rgba(0,0,0,0.05),
                        0 3px 12px 0 rgba(0,0,0,0.1);
        }

        /* ── Popover — glass floating panel ── */
        /* $po_radius: 16px, bg: rgba(#242424, 0.92) */
        /* shadow: 0 3px 8px 1px rgba(black,0.08), 0 10px 30px rgba(black,0.12) */
        popover contents {
            border-radius: 16px;
            background: rgba(36,36,36,0.92);
            border: 1px solid rgba(255,255,255,0.1);
            box-shadow: 0 3px 8px 1px rgba(0,0,0,0.08),
                        0 10px 30px rgba(0,0,0,0.12);
            padding: 4px;
        }

        /* ── Menu — glass context menu ── */
        /* $mn_radius: 14px, bg: rgba(#333333, 0.92) */
        /* $menuitem_size: 32px */
        menu {
            border-radius: 14px;
            background: rgba(51,51,51,0.92);
            border: 1px solid rgba(255,255,255,0.1);
            box-shadow: 0 3px 8px 1px rgba(0,0,0,0.08),
                        0 10px 30px rgba(0,0,0,0.12);
            padding: 4px;
        }

        menuitem {
            border-radius: 8px;
            min-height: 32px;
            padding: 0 8px;
            transition: all 100ms cubic-bezier(0.25, 0.46, 0.45, 0.94);
        }

        menuitem:hover {
            background: rgba(255,255,255,0.08);
        }

        /* ── Scrollbar — thin overlay style ── */
        /* bg: rgba(white, 0.25), hover: rgba(white, 0.4) */
        scrollbar slider {
            border-radius: 9999px;
            min-width: 6px;
            min-height: 6px;
            background: rgba(255,255,255,0.25);
            transition: all 150ms cubic-bezier(0.0, 0.0, 0.2, 1);
        }

        scrollbar slider:hover {
            background: rgba(255,255,255,0.4);
            min-width: 8px;
        }

        /* ── Progress bar — glass track ── */
        /* track: rgba(black, 0.2) per scale trough convention, fill: #0088FF */
        progressbar trough {
            border-radius: 9999px;
            background: rgba(0,0,0,0.2);
            min-height: 6px;
        }

        progressbar progress {
            border-radius: 9999px;
            background: #0088FF;
        }

        /* ── Spinner ── */
        spinner {
            color: #0088FF;
        }

        /* ── Calendar — glass date picker ── */
        /* $modal_radius: 16px */
        calendar {
            border-radius: 16px;
            border: 1px solid rgba(255,255,255,0.1);
            background: rgba(255,255,255,0.03);
        }

        calendar day {
            border-radius: 9999px;
        }

        calendar day:selected {
            background: #0088FF;
            color: white;
        }

        /* ── Window rounding ── */
        /* $wm_radius: 26px (NOT 12px!) */
        /* $wm_shadow: 0 0 0 2px rgba(black,0.1), 0 0 0 1px rgba(black,0.75) */
        window {
            border-radius: 26px;
        }

        /* ── Dialog / Modal ── */
        /* $modal_radius: 16px */
        dialog {
            border-radius: 16px;
        }

        /* ═══════════════════════════════════════════════════════════════
           Linked Controls (SegmentedControl, ControlGroup)
           $bt_radius: 6px on endpoints
           ═══════════════════════════════════════════════════════════════ */

        .linked button {
            border-radius: 0;
            border-right: 1px solid rgba(255,255,255,0.1);
            box-shadow: 0 1px 1px 0 rgba(0,0,0,0.03),
                        0 1px 2px 0 rgba(0,0,0,0.01);
            transition: all 100ms cubic-bezier(0.25, 0.46, 0.45, 0.94);
        }

        .linked button:first-child {
            border-radius: 6px 0 0 6px;
        }

        .linked button:last-child {
            border-radius: 0 6px 6px 0;
            border-right: none;
        }

        .linked button:only-child {
            border-radius: 6px;
            border-right: none;
        }

        /* ── GroupBox / FrameBox ── */
        /* $bd_radius: 10px, subtle inner glass shadow */
        frame {
            border-radius: 10px;
            border: 1px solid rgba(255,255,255,0.08);
            background: rgba(255,255,255,0.03);
            box-shadow: inset 0 1px 0 rgba(255,255,255,0.04),
                        inset 0 0 0 1px rgba(255,255,255,0.01);
        }

        frame > border {
            border-radius: 10px;
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
            UInt32(GTK_STYLE_PROVIDER_PRIORITY_USER)
        )
    }
}
