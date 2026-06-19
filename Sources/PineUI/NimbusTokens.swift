// NimbusTokens.swift — Canonical "Nimbus" purple-glass design tokens.
//
// Single source of truth for the Nimbus desktop look: macOS Tahoe Liquid Glass
// with a violet tint.  Extracted from the "Nimbus Desktop" design
// (claude.ai/design — "macOS Tahoe Linux recreation").  Every component builds
// its GTK CSS by interpolating these strings, so menus, popovers, windows, and
// the dock all share one palette and never drift.
//
// Values are CSS-ready strings (drop straight into a GtkCssProvider stylesheet).
// Radii are unitless Ints — append "px" at the call site.  Cairo-drawn surfaces
// use the matching `*RGBA` component tuples.
//
// This is the retint layer that sits on top of `PineTheme` (the neutral Tahoe
// base): where PineTheme uses #0088FF, Nimbus surfaces use `accent`.

public enum NimbusTokens {

    // ── Glass surfaces ──────────────────────────────────────────────────────

    /// Menu / popover frosted-glass fill (dropdowns, Control Center, status panels).
    public static let menuGlass = "rgba(34, 28, 64, 0.82)"

    /// Window / large-surface glass fill (app windows, sheets, sidebars).
    public static let windowGlass = "rgba(28, 24, 54, 0.72)"

    // ── Accent (violet) ─────────────────────────────────────────────────────

    /// Primary accent — selection, focus ring, active menu title.
    public static let accent = "#7c6cf0"

    /// Accent used as a hover / selection background (slightly translucent so the
    /// glass blur still reads through it).
    public static let accentSolid = "rgba(124, 108, 240, 0.85)"

    /// Accent as Cairo RGBA components (0–1), for drawing-area surfaces.
    public static let accentRGBA: (r: Double, g: Double, b: Double, a: Double) =
        (124.0 / 255.0, 108.0 / 255.0, 240.0 / 255.0, 1.0)

    /// Text / glyph color drawn on top of `accentSolid`.
    public static let onAccent = "#ffffff"

    // ── Text ────────────────────────────────────────────────────────────────

    public static let textPrimary = "#ffffff"

    /// Menu-item text on glass — soft lavender-white (design value).
    public static let textOnGlass = "#ece9ff"

    public static let textSecondary = "rgba(236, 233, 255, 0.62)"

    // ── Borders & dividers ──────────────────────────────────────────────────

    public static let border = "rgba(255, 255, 255, 0.12)"
    public static let separator = "rgba(255, 255, 255, 0.10)"

    // ── Radii (px, unitless — append "px") ──────────────────────────────────

    public static let radiusPopover = 12
    public static let radiusWindow = 14
    public static let radiusRow = 7
    public static let radiusControl = 6

    // ── Shadows ─────────────────────────────────────────────────────────────

    public static let shadowPopover = "0 18px 50px rgba(0, 0, 0, 0.5)"
    public static let shadowWindow = "0 30px 80px rgba(0, 0, 0, 0.55)"

    // ── Traffic lights (pastel) ─────────────────────────────────────────────

    public static let trafficClose = "#ec6a8c"
    public static let trafficMin = "#e0a23a"
    public static let trafficMax = "#5ec98a"
}
