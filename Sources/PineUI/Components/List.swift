// List.swift — SwiftUI-compatible List view.
//
// Usage:
//   List {
//       Text("Item 1")
//       Text("Item 2")
//   }
//
//   ForEach(items) { item in
//       Label(item.name, systemImage: item.icon)
//   }

import CGTK4

/// A scrollable list of items.
public struct List<Content: View>: View, GTKRenderable {
    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let scroll = makeScrolledWindow()
        scrolledWindowSetPolicy(scroll, h: GTK_POLICY_NEVER, v: GTK_POLICY_AUTOMATIC)
        setVExpand(scroll)

        let listBox = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 0)
        addCssClass(listBox, "pine-list")

        let rendered = render(content)
        boxAppend(listBox, child: rendered)

        scrolledWindowSetChild(scroll, child: listBox)
        return scroll
    }
}

/// A section within a list with an optional header.
public struct Section<Content: View>: View, GTKRenderable {
    let title: String?
    let content: Content

    public init(_ title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let section = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 0)

        if let title = title {
            let header = makeLabel(title)
            addCssClass(header, "pine-sidebar-section-header")
            setHAlign(header, align: GTK_ALIGN_START)
            boxAppend(section, child: header)
        }

        let rendered = render(content)
        boxAppend(section, child: rendered)
        return section
    }
}

/// Iterate over a collection and produce views.
/// Simplified version — SwiftUI's ForEach is more complex.
public struct ForEach<Data, Content: View>: View, GTKRenderable, MultiChildView
where Data: RandomAccessCollection {
    let data: Data
    let content: (Data.Element) -> Content

    public init(_ data: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.content = content
    }

    public var body: Never { fatalError() }

    public func renderChildren() -> [WidgetPtr] {
        data.map { render(content($0)) }
    }

    public func renderGTK() -> WidgetPtr {
        let box = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 0)
        for child in renderChildren() { boxAppend(box, child: child) }
        return box
    }
}

/// A container that visually groups content (like macOS GroupBox).
public struct GroupBox<Content: View>: View, GTKRenderable {
    let title: String?
    let content: Content

    public init(_ title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let box = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 4)
        addCssClass(box, "pine-card")

        if let title = title {
            let header = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 0)
            addCssClass(header, "pine-card-header")
            let label = makeLabel(title)
            addCssClass(label, "pine-headline")
            setHAlign(label, align: GTK_ALIGN_START)
            boxAppend(header, child: label)
            boxAppend(box, child: header)
        }

        let body = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 8)
        addCssClass(body, "pine-card-body")
        boxAppend(body, child: render(content))
        boxAppend(box, child: body)

        return box
    }
}

/// A form container (like macOS Settings forms).
public struct Form<Content: View>: View, GTKRenderable {
    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let box = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 12)
        addCssClass(box, "pine-form")
        setMargins(box, start: 16, end: 16, top: 16, bottom: 16)
        boxAppend(box, child: render(content))
        return box
    }
}
