// MissingViews.swift — Remaining SwiftUI view types for PineUI.
//
// Implements: LabeledContent, ControlGroup, ViewThatFits, TimelineView,
// OutlineGroup, Menu (view), GridRow, ShareLink, AsyncImage, ColorView,
// and Material background modifier.

import CGTK4

// MARK: - LabeledContent

/// A label-value pair row — like SwiftUI's LabeledContent.
public struct LabeledContent<LabelContent: View, Content: View>: View, GTKRenderable {
    let labelView: LabelContent
    let content: Content

    public init(
        @ViewBuilder label: () -> LabelContent,
        @ViewBuilder content: () -> Content
    ) {
        self.labelView = label()
        self.content = content()
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let row = makeBox(GTK_ORIENTATION_HORIZONTAL, spacing: 8)
        setHExpand(row)

        let labelWidget = render(labelView)
        setHAlign(labelWidget, align: GTK_ALIGN_START)
        boxAppend(row, child: labelWidget)

        let spacer = makeBox(GTK_ORIENTATION_HORIZONTAL, spacing: 0)
        setHExpand(spacer)
        boxAppend(row, child: spacer)

        let contentWidget = render(content)
        setHAlign(contentWidget, align: GTK_ALIGN_END)
        boxAppend(row, child: contentWidget)

        return row
    }
}

extension LabeledContent where LabelContent == Text, Content == Text {
    /// Convenience initialiser for a plain string label and value.
    public init(_ title: String, value: String) {
        self.labelView = Text(title)
        self.content = Text(value)
    }
}

// MARK: - ControlGroup

/// Groups controls together visually with a "linked" button style.
public struct ControlGroup<Content: View>: View, GTKRenderable {
    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let box = makeBox(GTK_ORIENTATION_HORIZONTAL, spacing: 0)
        addCssClass(box, "linked")

        if let multi = content as? MultiChildView {
            for child in multi.renderChildren() {
                boxAppend(box, child: child)
            }
        } else {
            boxAppend(box, child: render(content))
        }

        return box
    }
}

// MARK: - ViewThatFits

/// Shows the first child that fits in available space.
/// Simplified: renders the first child only.
public struct ViewThatFits<Content: View>: View, GTKRenderable {
    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        if let multi = content as? MultiChildView {
            let children = multi.renderChildren()
            if let first = children.first {
                return first
            }
        }
        return render(content)
    }
}

// MARK: - TimelineSchedule

/// Controls how often a TimelineView updates.
public enum TimelineSchedule {
    case animation
    case everyMinute
    case periodic(from: Double, by: Double)
    case explicit([Double])
}

// MARK: - TimelineView

/// Periodically refreshes content based on a schedule.
/// Simplified: renders content once without periodic updates.
public struct TimelineView<Content: View>: View, GTKRenderable {
    let schedule: TimelineSchedule
    let content: Content

    public init(_ schedule: TimelineSchedule = .everyMinute, @ViewBuilder content: () -> Content) {
        self.schedule = schedule
        self.content = content()
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        render(content)
    }
}

// MARK: - OutlineGroup

/// Tree/outline view — simplified to a flat list.
public struct OutlineGroup<Data: RandomAccessCollection, Content: View>: View, GTKRenderable {
    let data: Data
    let content: (Data.Element) -> Content

    public init(
        _ data: Data,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.content = content
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let box = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 4)
        for item in data {
            let child = render(content(item))
            setMargins(child, start: 16, end: 0, top: 0, bottom: 0)
            boxAppend(box, child: child)
        }
        return box
    }
}

// MARK: - Menu (view)

/// A button that opens a popover menu — like SwiftUI's Menu.
public struct MenuView<LabelContent: View, Content: View>: View, GTKRenderable {
    let labelView: LabelContent
    let content: Content

    public init(
        @ViewBuilder content: () -> Content,
        @ViewBuilder label: () -> LabelContent
    ) {
        self.content = content()
        self.labelView = label()
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let btn = gtk_menu_button_new()!
        let labelWidget = render(labelView)
        gtk_menu_button_set_child(OpaquePointer(btn), labelWidget)

        let popover = gtk_popover_new()!
        let pop: UnsafeMutablePointer<_GtkPopover> = typed(popover)

        let contentBox = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 4)
        setMargins(contentBox, start: 8, end: 8, top: 8, bottom: 8)

        if let multi = content as? MultiChildView {
            for child in multi.renderChildren() {
                boxAppend(contentBox, child: child)
            }
        } else {
            boxAppend(contentBox, child: render(content))
        }

        gtk_popover_set_child(pop, contentBox)
        gtk_menu_button_set_popover(
            OpaquePointer(btn),
            UnsafeMutableRawPointer(pop).assumingMemoryBound(to: GtkWidget.self)
        )

        return btn
    }
}

extension MenuView where LabelContent == Text {
    /// Convenience: Menu with a string title as label.
    public init(_ title: String, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.labelView = Text(title)
    }
}

// MARK: - GridRow

/// Defines a row inside a Grid — used with multi-child extraction.
public struct GridRow<Content: View>: View, GTKRenderable, MultiChildView {
    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Never { fatalError() }

    /// Render as a horizontal box for standalone use.
    public func renderGTK() -> WidgetPtr {
        let row = makeBox(GTK_ORIENTATION_HORIZONTAL, spacing: 8)
        for child in renderChildren() {
            boxAppend(row, child: child)
        }
        return row
    }

    /// Expose children for grid placement.
    public func renderChildren() -> [WidgetPtr] {
        if let multi = content as? MultiChildView {
            return multi.renderChildren()
        }
        return [render(content)]
    }
}

// MARK: - ShareLink

/// A stub share button — no real sharing on Linux/GTK.
public struct ShareLink: View, GTKRenderable {
    let title: String

    public init(_ title: String = "Share") {
        self.title = title
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let row = makeBox(GTK_ORIENTATION_HORIZONTAL, spacing: 6)
        let icon = makeImage(iconName: resolveSFSymbol("square.and.arrow.up"))
        boxAppend(row, child: icon)
        let label = makeLabel(title)
        boxAppend(row, child: label)

        let btn = makeButton()
        buttonSetChild(btn, child: row)
        addCssClass(btn, "pine-btn")
        return btn
    }
}

// MARK: - AsyncImage

/// A stub async image view — no network loading on Linux/GTK.
/// Displays a placeholder icon.
public struct AsyncImage: View, GTKRenderable {
    let url: String?

    public init(url: String?) {
        self.url = url
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let box = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 4)
        addCssClass(box, "pine-async-image-placeholder")
        applyCss(box, """
            background: alpha(@window_fg_color, 0.08);
            border-radius: 6px;
            min-width: 64px;
            min-height: 64px;
        """)
        setHAlign(box, align: GTK_ALIGN_CENTER)
        setVAlign(box, align: GTK_ALIGN_CENTER)

        let icon = makeImage(iconName: resolveSFSymbol("photo"))
        setHAlign(icon, align: GTK_ALIGN_CENTER)
        setVAlign(icon, align: GTK_ALIGN_CENTER)
        setMargins(icon, start: 12, end: 12, top: 12, bottom: 12)
        boxAppend(box, child: icon)

        return box
    }
}

// MARK: - ColorView

/// A solid-color rectangle — like using Color as a View in SwiftUI.
public struct ColorView: View, GTKRenderable {
    let color: Color

    public init(_ color: Color) {
        self.color = color
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let box = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 0)
        setHExpand(box)
        setVExpand(box)
        applyCss(box, "background: \(color.cssValue);")
        return box
    }
}

// MARK: - Separator (typealias for Divider)

/// Alias for Divider — provided for SwiftUI API compatibility.
public typealias Separator = Divider

// MARK: - Material

/// Background material for translucency/blur effects.
public enum Material {
    case ultraThinMaterial
    case thinMaterial
    case regularMaterial
    case thickMaterial
    case ultraThickMaterial

    var cssValue: String {
        switch self {
        case .ultraThinMaterial:
            return "alpha(@window_bg_color, 0.55)"
        case .thinMaterial:
            return "alpha(@window_bg_color, 0.65)"
        case .regularMaterial:
            return "alpha(@window_bg_color, 0.75)"
        case .thickMaterial:
            return "alpha(@window_bg_color, 0.85)"
        case .ultraThickMaterial:
            return "alpha(@window_bg_color, 0.95)"
        }
    }
}

extension View {
    /// Apply a translucent material background.
    public func background(_ material: Material) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "background: \(material.cssValue);")
        }
    }
}
