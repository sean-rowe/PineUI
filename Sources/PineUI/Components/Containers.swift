// Containers.swift — TabView, DisclosureGroup, ScrollView, Grid.

import CGTK4

/// Protocol for views that can be added as notebook pages.
public protocol TabItemView {
    var tabTitle: String { get }
    var tabIconName: String? { get }
    func renderTabContent() -> WidgetPtr
}

/// A tabbed view — like macOS TabView.
/// Detects Tab children and creates separate GtkNotebook pages.
public struct TabView<Content: View>: View, GTKRenderable {
    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let notebook = gtk_notebook_new()!
        let nb = OpaquePointer(notebook)
        setHExpand(notebook)
        setVExpand(notebook)

        // Collect tab items from content.
        let tabs = collectTabs(from: content)

        if tabs.isEmpty {
            // Fallback: no Tab children found, render as single page.
            let page = render(content)
            let label = makeLabel("Tab")
            gtk_notebook_append_page(nb, page, label)
        } else {
            for tab in tabs {
                let page = tab.renderTabContent()
                let tabLabel: WidgetPtr
                if let icon = tab.tabIconName {
                    let row = makeBox(GTK_ORIENTATION_HORIZONTAL, spacing: 6)
                    let img = makeImage(iconName: resolveSFSymbol(icon))
                    boxAppend(row, child: img)
                    let lbl = makeLabel(tab.tabTitle)
                    boxAppend(row, child: lbl)
                    tabLabel = row
                } else {
                    tabLabel = makeLabel(tab.tabTitle)
                }
                gtk_notebook_append_page(nb, page, tabLabel)
            }
        }

        return notebook
    }
}

/// Recursively collects TabItemView instances from a view tree.
private func collectTabs<V: View>(from view: V) -> [TabItemView] {
    if let tab = view as? TabItemView {
        return [tab]
    }
    if let multi = view as? MultiChildTabView {
        return multi.collectTabItems()
    }
    return []
}

/// Protocol for multi-child views that can expose tab items.
public protocol MultiChildTabView {
    func collectTabItems() -> [TabItemView]
}

/// A tab item — wraps content with a label for TabView.
public struct Tab<Content: View>: View, GTKRenderable, TabItemView {
    public let tabTitle: String
    public let tabIconName: String?
    let content: Content

    public init(_ title: String, systemImage: String? = nil, @ViewBuilder content: () -> Content) {
        self.tabTitle = title
        self.tabIconName = systemImage
        self.content = content()
    }

    public var body: Never { fatalError() }

    public func renderTabContent() -> WidgetPtr {
        render(content)
    }

    public func renderGTK() -> WidgetPtr {
        render(content)
    }
}

/// An expandable/collapsible section.
public struct DisclosureGroup<Content: View>: View, GTKRenderable {
    let title: String
    let content: Content

    public init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let expander = gtk_expander_new(title)!
        gtk_expander_set_expanded(OpaquePointer(expander), 1)
        let child = render(content)
        gtk_expander_set_child(OpaquePointer(expander), child)
        return expander
    }
}

/// A scrollable container.
public struct ScrollView<Content: View>: View, GTKRenderable {
    let axes: ScrollAxes
    let content: Content

    public init(_ axes: ScrollAxes = .vertical, @ViewBuilder content: () -> Content) {
        self.axes = axes
        self.content = content()
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let scroll = makeScrolledWindow()
        setHExpand(scroll)
        setVExpand(scroll)
        let hPolicy: GtkPolicyType = axes == .horizontal || axes == .both ? GTK_POLICY_AUTOMATIC : GTK_POLICY_NEVER
        let vPolicy: GtkPolicyType = axes == .vertical || axes == .both ? GTK_POLICY_AUTOMATIC : GTK_POLICY_NEVER
        scrolledWindowSetPolicy(scroll, h: hPolicy, v: vPolicy)
        scrolledWindowSetChild(scroll, child: render(content))
        return scroll
    }
}

public enum ScrollAxes {
    case vertical, horizontal, both
}

/// A transparent grouping container — passes children through to the parent.
/// Use to bypass the 10-child ViewBuilder limit or for conditional groups.
public struct Group<Content: View>: View, GTKRenderable, MultiChildView {
    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Never { fatalError() }

    public func renderChildren() -> [WidgetPtr] {
        if let multi = content as? MultiChildView {
            return multi.renderChildren()
        }
        return [render(content)]
    }

    public func renderChildrenForAxis(_ axis: GtkOrientation) -> [WidgetPtr] {
        if let multi = content as? MultiChildView {
            return multi.renderChildrenForAxis(axis)
        }
        return [renderChildForAxis(content, axis: axis)]
    }

    public func renderGTK() -> WidgetPtr {
        render(content)
    }
}

/// A grid layout with rows and columns.
public struct Grid<Content: View>: View, GTKRenderable {
    let columns: Int32
    let spacing: Int32
    let content: Content

    public init(columns: Int32 = 2, spacing: Int32 = 8, @ViewBuilder content: () -> Content) {
        self.columns = columns
        self.spacing = spacing
        self.content = content()
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let grid = gtk_grid_new()!
        let g: UnsafeMutablePointer<GtkGrid> = typed(grid)
        gtk_grid_set_column_spacing(g, guint(spacing))
        gtk_grid_set_row_spacing(g, guint(spacing))
        setHExpand(grid)

        // Render content and attach to grid.
        // Simplified: just wrap in a flow layout.
        let rendered = render(content)
        gtk_grid_attach(g, rendered, 0, 0, columns, 1)
        return grid
    }
}
