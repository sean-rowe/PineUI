// Text.swift — SwiftUI-compatible Text view.
//
// Usage:
//   Text("Hello, World!")
//   Text("Title").font(.title).bold()
//   Text("Code").font(.body.monospaced())
//   Text("Big").font(.title.weight(.heavy).italic())

import CGTK4

public struct Text: View, GTKRenderable {
    let content: String
    var cssClasses: [String] = []
    var alignment: GtkAlign = GTK_ALIGN_START
    var wrapping: Bool = false

    // Captured from chained Font modifiers; applied as inline CSS in
    // renderGTK because they're font-property overrides rather than
    // additional class names.
    var inlineFontWeight: FontWeight? = nil
    var inlineFontDesign: FontDesign? = nil
    var inlineItalic: Bool = false

    public init(_ content: String) {
        self.content = content
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let label = makeLabel(content)
        setHAlign(label, align: alignment)
        if wrapping { labelSetWrap(label, wrap: true) }
        for cls in cssClasses { addCssClass(label, cls) }
        if let w = inlineFontWeight {
            applyCss(label, "font-weight: \(w.rawValue);")
        }
        if let d = inlineFontDesign {
            applyCss(label, "font-family: \(d.rawValue);")
        }
        if inlineItalic {
            applyCss(label, "font-style: italic;")
        }
        return label
    }

    // MARK: - Modifiers (return modified copy)

    public func font(_ style: Font) -> Text {
        var copy = self
        copy.cssClasses.append(style.cssClass)
        // Inherit any chained Font modifiers (weight/design/italic) so
        // .font(.body.weight(.semibold).italic()) works in one call.
        if let w = style.weight { copy.inlineFontWeight = w }
        if let d = style.design { copy.inlineFontDesign = d }
        if style.isItalic { copy.inlineItalic = true }
        return copy
    }

    public func bold() -> Text {
        var copy = self
        copy.cssClasses.append("pine-bold")
        return copy
    }

    public func foregroundStyle(_ style: ForegroundStyle) -> Text {
        var copy = self
        copy.cssClasses.append(style.cssClass)
        return copy
    }

    public func multilineTextAlignment(_ alignment: TextAlignment) -> Text {
        var copy = self
        copy.alignment = alignment.gtkAlign
        copy.wrapping = true
        return copy
    }
}

// MARK: - Font (SwiftUI-compatible chained API)
//
// SwiftUI's Font supports method chaining: `.font(.body.weight(.semibold))`,
// `.font(.caption.monospaced())`, `.font(.title.italic())`. PineUI mirrors
// this with a struct that carries the base size class plus optional
// weight/design/italic overrides. The static instances (`.body`, `.title`,
// etc.) keep the SwiftUI call-site syntax `.font(.body)` working unchanged.
//
// Weight, design, and italic CAN still be applied as standalone modifiers
// via .fontWeight(_:), .fontDesign(_:), and .italic() on any View — those
// are kept in Modifiers/TextModifiers.swift. The struct fields here are
// for the chained Font.X.weight(.Y) form, which the Text view consumes
// directly in renderGTK.
public struct Font {
    public let cssClass: String
    public var weight: FontWeight? = nil
    public var design: FontDesign? = nil
    public var isItalic: Bool = false

    // Static size instances — match SwiftUI's Font.body, Font.title, etc.
    public static let largeTitle  = Font(cssClass: "pine-large-title")
    public static let title       = Font(cssClass: "pine-title")
    public static let title2      = Font(cssClass: "pine-title2")
    public static let title3      = Font(cssClass: "pine-title3")
    public static let headline    = Font(cssClass: "pine-headline")
    public static let subheadline = Font(cssClass: "pine-subheadline")
    public static let body        = Font(cssClass: "pine-body")
    public static let callout     = Font(cssClass: "pine-callout")
    public static let caption     = Font(cssClass: "pine-caption")
    public static let caption2    = Font(cssClass: "pine-caption2")
    public static let footnote    = Font(cssClass: "pine-footnote")

    // MARK: - Chained modifiers

    public func weight(_ w: FontWeight) -> Font {
        var copy = self
        copy.weight = w
        return copy
    }

    public func monospaced() -> Font {
        var copy = self
        copy.design = .monospaced
        return copy
    }

    public func italic() -> Font {
        var copy = self
        copy.isItalic = true
        return copy
    }

    public func bold() -> Font {
        weight(.bold)
    }
}

public enum ForegroundStyle {
    case primary, secondary, tertiary, quaternary
    case accent

    var cssClass: String {
        switch self {
        case .primary: return "pine-fg-primary"
        case .secondary: return "pine-fg-secondary"
        case .tertiary: return "pine-fg-tertiary"
        case .quaternary: return "pine-fg-quaternary"
        case .accent: return "pine-fg-accent"
        }
    }
}

public enum TextAlignment {
    case leading, center, trailing

    var gtkAlign: GtkAlign {
        switch self {
        case .leading: return GTK_ALIGN_START
        case .center: return GTK_ALIGN_CENTER
        case .trailing: return GTK_ALIGN_END
        }
    }
}
