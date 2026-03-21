// PineTheme.swift — Shared macOS-like CSS theme for all PineOS apps.

import CGTK4

public enum PineTheme {
    private static var applied = false

    public static func apply() {
        guard !applied else { return }
        applied = true

        let provider = gtk_css_provider_new()!

        let css = """
        /* PineUI Theme — macOS-like design language for PineOS */

        /* ── Typography scale (matches SF Pro sizes) ── */
        .pine-large-title { font-size: 2.0em; font-weight: 700; }
        .pine-title  { font-size: 1.5em; font-weight: 700; }
        .pine-title2 { font-size: 1.3em; font-weight: 600; }
        .pine-title3 { font-size: 1.15em; font-weight: 600; }
        .pine-headline { font-size: 1.0em; font-weight: 600; }
        .pine-subheadline { font-size: 0.9em; font-weight: 400; }
        .pine-body { font-size: 1.0em; }
        .pine-callout { font-size: 0.95em; }
        .pine-caption { font-size: 0.85em; color: alpha(@window_fg_color, 0.6); }
        .pine-caption2 { font-size: 0.75em; color: alpha(@window_fg_color, 0.5); }
        .pine-footnote { font-size: 0.8em; color: alpha(@window_fg_color, 0.5); }
        .pine-bold { font-weight: 700; }

        /* ── Foreground styles ── */
        .pine-fg-primary { color: @window_fg_color; }
        .pine-fg-secondary { color: alpha(@window_fg_color, 0.6); }
        .pine-fg-tertiary { color: alpha(@window_fg_color, 0.4); }
        .pine-fg-quaternary { color: alpha(@window_fg_color, 0.25); }
        .pine-fg-accent { color: @accent_bg_color; }

        /* ── Sidebar ── */
        .pine-sidebar {
            background: alpha(@window_bg_color, 0.85);
            border-right: 1px solid alpha(@borders, 0.3);
            padding-top: 8px;
        }

        .pine-sidebar-section-header {
            font-size: 0.7em;
            font-weight: 700;
            text-transform: uppercase;
            color: alpha(@window_fg_color, 0.45);
            padding: 16px 16px 4px 16px;
            letter-spacing: 0.8px;
        }

        .pine-sidebar-item {
            border-radius: 6px;
            padding: 4px 12px;
            margin: 1px 8px;
            min-height: 28px;
        }

        .pine-sidebar-item:hover {
            background: alpha(@accent_bg_color, 0.1);
        }

        .pine-sidebar-item-active {
            background: alpha(@accent_bg_color, 0.2);
        }

        .pine-sidebar-badge {
            background: alpha(@window_fg_color, 0.12);
            color: alpha(@window_fg_color, 0.65);
            border-radius: 10px;
            padding: 0px 7px;
            font-size: 0.78em;
            font-weight: 600;
            min-width: 18px;
        }

        .pine-sidebar-list { padding-bottom: 12px; }

        /* ── Status Bar ── */
        .pine-status-bar {
            padding: 3px 16px;
            background: alpha(@window_bg_color, 0.95);
            border-top: 1px solid alpha(@borders, 0.2);
            min-height: 22px;
        }

        .pine-status-label {
            font-size: 0.78em;
            color: alpha(@window_fg_color, 0.55);
        }

        /* ── Cards ── */
        .pine-card {
            background: alpha(white, 0.045);
            border-radius: 10px;
            border: 1px solid alpha(white, 0.07);
        }

        .pine-card-header {
            background: alpha(white, 0.025);
            border-radius: 10px 10px 0 0;
            border-bottom: 1px solid alpha(white, 0.05);
            padding: 10px 16px;
        }

        .pine-card-body { padding: 12px 16px; }

        /* ── List ── */
        .pine-list { padding: 4px 0; }

        /* ── Form ── */
        .pine-form { }

        /* ── Buttons ── */
        .pine-btn { border-radius: 6px; }
        .pine-btn-bordered {
            border-radius: 6px;
            border: 1px solid alpha(@borders, 0.5);
        }

        /* ── Text editor ── */
        .pine-text-editor {
            background: alpha(white, 0.03);
            border-radius: 6px;
        }

        /* ── Disclosure group ── */
        expander title {
            font-weight: 600;
            padding: 4px 0;
        }

        /* ── Level bar (Gauge) ── */
        levelbar block.filled { background: @accent_bg_color; }

        /* ── Toolbar ── */
        .pine-toolbar {
            background: alpha(@headerbar_bg_color, 0.95);
            border-bottom: 1px solid alpha(@borders, 0.3);
            min-height: 36px;
        }

        /* ── Table ── */
        .pine-table-header {
            font-weight: 700;
            font-size: 0.85em;
            color: alpha(@window_fg_color, 0.6);
            background: alpha(@window_bg_color, 0.8);
            border-bottom: 1px solid alpha(@borders, 0.3);
        }

        .pine-table-alt-row {
            background: alpha(white, 0.02);
        }

        /* ── Window rounding ── */
        window { border-radius: 10px; }
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
