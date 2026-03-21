// Text.swift — SwiftUI-compatible Text view.
//
// Usage:
//   Text("Hello, World!")
//   Text("Title").font(.title).bold()

import CGTK4

public struct Text: View, GTKRenderable {
    let content: String
    var cssClasses: [String] = []
    var alignment: GtkAlign = GTK_ALIGN_START
    var wrapping: Bool = false

    public init(_ content: String) {
        self.content = content
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let label = makeLabel(content)
        setHAlign(label, align: alignment)
        if wrapping { labelSetWrap(label, wrap: true) }
        for cls in cssClasses { addCssClass(label, cls) }
        return label
    }

    // MARK: - Modifiers (return modified copy)

    public func font(_ style: Font) -> Text {
        var copy = self
        copy.cssClasses.append(style.cssClass)
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

// MARK: - Font enum (maps to CSS classes)

public enum Font {
    case largeTitle, title, title2, title3
    case headline, subheadline
    case body, callout, caption, caption2, footnote

    var cssClass: String {
        switch self {
        case .largeTitle: return "pine-large-title"
        case .title: return "pine-title"
        case .title2: return "pine-title2"
        case .title3: return "pine-title3"
        case .headline: return "pine-headline"
        case .subheadline: return "pine-subheadline"
        case .body: return "pine-body"
        case .callout: return "pine-callout"
        case .caption: return "pine-caption"
        case .caption2: return "pine-caption2"
        case .footnote: return "pine-footnote"
        }
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
