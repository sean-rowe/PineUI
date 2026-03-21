// TextModifiers.swift — SwiftUI-compatible text and typography modifiers for PineUI.
//
// Implements 17 text/typography modifiers:
//   fontWeight, fontDesign, italic, strikethrough, underline, kerning, tracking,
//   baselineOffset, lineLimit, lineSpacing, minimumScaleFactor, truncationMode,
//   textCase, textSelection, allowsTightening, labelIconToTitleSpacing,
//   typesettingLanguage

import CGTK4

// MARK: - Supporting Enums

/// Font weight values matching SwiftUI's Font.Weight, mapped to CSS font-weight values.
public enum FontWeight: Int {
    case ultraLight = 100
    case thin       = 200
    case light      = 300
    case regular    = 400
    case medium     = 500
    case semibold   = 600
    case bold       = 700
    case heavy      = 800
    case black      = 900
}

/// Font design matching SwiftUI's Font.Design, mapped to CSS font-family values.
public enum FontDesign: String {
    case `default`  = "inherit"
    case rounded    = "system-ui"
    case serif      = "serif"
    case monospaced = "monospace"
}

/// Truncation mode matching SwiftUI's Text.TruncationMode.
public enum TruncationMode {
    case head
    case middle
    case tail
}

/// Text case transformation matching SwiftUI's Text.Case.
public enum TextCase: String {
    case uppercase = "uppercase"
    case lowercase = "lowercase"
}

// MARK: - Text & Typography Modifiers

extension View {

    // MARK: 1. fontWeight

    /// Sets the font weight via CSS `font-weight`.
    public func fontWeight(_ weight: FontWeight) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "font-weight: \(weight.rawValue);")
        }
    }

    // MARK: 2. fontDesign

    /// Sets the font design (family) via CSS `font-family`.
    public func fontDesign(_ design: FontDesign) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "font-family: \(design.rawValue);")
        }
    }

    // MARK: 3. italic

    /// Applies italic style via CSS `font-style: italic`.
    public func italic() -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "font-style: italic;")
        }
    }

    // MARK: 4. strikethrough

    /// Applies a strikethrough decoration via CSS `text-decoration`.
    ///
    /// - Parameters:
    ///   - active: Whether the strikethrough is active (default: `true`).
    ///   - color: Optional color for the strikethrough line.
    public func strikethrough(_ active: Bool = true, color: Color? = nil) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            guard active else { return }
            if let color = color {
                applyCss(w, "text-decoration: line-through; text-decoration-color: \(color.cssValue);")
            } else {
                applyCss(w, "text-decoration: line-through;")
            }
        }
    }

    // MARK: 5. underline

    /// Applies an underline decoration via CSS `text-decoration`.
    ///
    /// - Parameters:
    ///   - active: Whether the underline is active (default: `true`).
    ///   - color: Optional color for the underline.
    public func underline(_ active: Bool = true, color: Color? = nil) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            guard active else { return }
            if let color = color {
                applyCss(w, "text-decoration: underline; text-decoration-color: \(color.cssValue);")
            } else {
                applyCss(w, "text-decoration: underline;")
            }
        }
    }

    // MARK: 6. kerning

    /// Adjusts character spacing via CSS `letter-spacing`.
    ///
    /// - Parameter amount: The additional spacing in points.
    public func kerning(_ amount: Double) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "letter-spacing: \(amount)px;")
        }
    }

    // MARK: 7. tracking

    /// Adjusts tracking (character spacing) via CSS `letter-spacing`.
    ///
    /// - Parameter amount: The tracking amount in points.
    public func tracking(_ amount: Double) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "letter-spacing: \(amount)px;")
        }
    }

    // MARK: 8. baselineOffset

    /// Shifts text baseline via CSS `vertical-align`.
    ///
    /// - Parameter offset: The vertical offset in points (positive = up).
    public func baselineOffset(_ offset: Double) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "vertical-align: \(offset)px;")
        }
    }

    // MARK: 9. lineLimit

    /// Sets the maximum number of lines for a label.
    ///
    /// Calls `gtk_label_set_lines` and `gtk_label_set_ellipsize` on the widget.
    /// Pass `nil` to remove the line limit.
    ///
    /// - Parameter limit: The maximum number of lines, or `nil` for unlimited.
    public func lineLimit(_ limit: Int?) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            let lbl = OpaquePointer(w)
            if let limit = limit {
                gtk_label_set_lines(lbl, Int32(limit))
                gtk_label_set_ellipsize(lbl, PANGO_ELLIPSIZE_END)
            } else {
                gtk_label_set_lines(lbl, -1)
                gtk_label_set_ellipsize(lbl, PANGO_ELLIPSIZE_NONE)
            }
        }
    }

    // MARK: 10. lineSpacing

    /// Sets line height via CSS `line-height`.
    ///
    /// - Parameter spacing: The line spacing multiplier or pixel value.
    public func lineSpacing(_ spacing: Double) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "line-height: \(spacing);")
        }
    }

    // MARK: 11. minimumScaleFactor

    /// Sets a minimum scale factor for text.
    ///
    /// NOTE: GTK4 does not support dynamic font size reduction; this is a stub.
    // STUB: no GTK4 equivalent — GTK4 does not auto-scale text to fit its container.
    public func minimumScaleFactor(_ factor: Double) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: no GTK4 equivalent
        }
    }

    // MARK: 12. truncationMode

    /// Sets how text is truncated when it exceeds available space.
    ///
    /// Maps to `gtk_label_set_ellipsize` with the corresponding PangoEllipsizeMode.
    ///
    /// - Parameter mode: The truncation mode (.head, .middle, or .tail).
    public func truncationMode(_ mode: TruncationMode) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            let lbl = OpaquePointer(w)
            switch mode {
            case .head:
                gtk_label_set_ellipsize(lbl, PANGO_ELLIPSIZE_START)
            case .middle:
                gtk_label_set_ellipsize(lbl, PANGO_ELLIPSIZE_MIDDLE)
            case .tail:
                gtk_label_set_ellipsize(lbl, PANGO_ELLIPSIZE_END)
            }
        }
    }

    // MARK: 13. textCase

    /// Transforms text case via CSS `text-transform`.
    ///
    /// Pass `nil` to remove any case transformation.
    ///
    /// - Parameter textCase: The desired case transformation, or `nil` to reset.
    public func textCase(_ textCase: TextCase?) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            if let textCase = textCase {
                applyCss(w, "text-transform: \(textCase.rawValue);")
            } else {
                applyCss(w, "text-transform: none;")
            }
        }
    }

    // MARK: 14. textSelection

    /// Controls whether the user can select the label's text.
    ///
    /// Calls `gtk_label_set_selectable` on the widget.
    ///
    /// - Parameter enabled: Whether text selection is enabled.
    public func textSelection(_ enabled: Bool) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            gtk_label_set_selectable(OpaquePointer(w), enabled ? 1 : 0)
        }
    }

    // MARK: 15. allowsTightening

    /// Allows the spacing between characters to be tightened to fit text in a line.
    ///
    /// NOTE: GTK4 does not expose per-widget glyph tightening control; this is a stub.
    // STUB: no GTK4 equivalent — character-level tightening is not available in GTK4 CSS.
    public func allowsTightening(_ flag: Bool) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: no GTK4 equivalent
        }
    }

    // MARK: 16. labelIconToTitleSpacing

    /// Sets the spacing between an icon and title label in a button-style widget.
    ///
    /// NOTE: GTK4 does not expose icon-to-title spacing directly; this is a stub.
    // STUB: no GTK4 equivalent — icon-to-title spacing is internal to GtkButton layout.
    public func labelIconToTitleSpacing(_ spacing: Int32) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: no GTK4 equivalent
        }
    }

    // MARK: 17. typesettingLanguage

    /// Sets the language for typesetting (hyphenation, ligatures, etc.).
    ///
    /// NOTE: GTK4 Pango language tags are not settable per-widget from CSS; this is a stub.
    // STUB: no GTK4 equivalent — Pango language requires layout-level access not available via CSS.
    public func typesettingLanguage(_ language: String) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: no GTK4 equivalent
        }
    }
}
