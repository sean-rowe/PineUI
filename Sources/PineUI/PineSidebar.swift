// PineSidebar.swift — macOS-style source list sidebar with selection.

import CGTK4

public struct SidebarItem {
    public let label: String
    public let iconName: String
    public let badge: Int?
    public let id: String

    public init(_ label: String, icon: String, badge: Int? = nil, id: String? = nil) {
        self.label = label
        self.iconName = resolveSFSymbol(icon)
        self.badge = badge
        self.id = id ?? String(label.lowercased().map { $0 == " " ? "-" : $0 })
    }
}

public struct SidebarSection {
    public let title: String
    public let items: [SidebarItem]

    public init(_ title: String, items: [SidebarItem]) {
        self.title = title
        self.items = items
    }
}

public class PineSidebar {
    private var sections: [SidebarSection] = []
    private var sidebarWidth: Int32 = 220
    private var onSelect: ((String) -> Void)?
    private var selectedId: String?
    private var itemButtons: [(String, WidgetPtr)] = []

    public init() {}

    @discardableResult
    public func section(_ title: String, items: [SidebarItem]) -> PineSidebar {
        sections.append(SidebarSection(title, items: items))
        return self
    }

    @discardableResult
    public func width(_ w: Int32) -> PineSidebar { self.sidebarWidth = w; return self }

    /// Set a callback for when a sidebar item is selected.
    @discardableResult
    public func onSelection(_ handler: @escaping (String) -> Void) -> PineSidebar {
        self.onSelect = handler
        return self
    }

    /// Select an item by id programmatically.
    public func select(_ id: String) {
        // Remove active class from previous selection.
        for (itemId, btn) in itemButtons {
            if itemId == selectedId {
                gtk_widget_remove_css_class(btn, "pine-sidebar-item-active")
            }
            if itemId == id {
                addCssClass(btn, "pine-sidebar-item-active")
            }
        }
        selectedId = id
    }

    func build() -> WidgetPtr {
        let sidebar = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 0)
        setSizeRequest(sidebar, width: sidebarWidth, height: -1)
        addCssClass(sidebar, "pine-sidebar")

        let scroll = makeScrolledWindow()
        scrolledWindowSetPolicy(scroll, h: GTK_POLICY_NEVER, v: GTK_POLICY_AUTOMATIC)
        setVExpand(scroll)

        let listBox = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 0)
        addCssClass(listBox, "pine-sidebar-list")

        var isFirst = true
        for section in sections {
            let header = makeLabel(section.title)
            addCssClass(header, "pine-sidebar-section-header")
            setHAlign(header, align: GTK_ALIGN_START)
            boxAppend(listBox, child: header)

            for item in section.items {
                let btn = buildItemRow(item)
                itemButtons.append((item.id, btn))

                // Auto-select first item.
                if isFirst {
                    addCssClass(btn, "pine-sidebar-item-active")
                    selectedId = item.id
                    isFirst = false
                }

                boxAppend(listBox, child: btn)
            }
        }

        scrolledWindowSetChild(scroll, child: listBox)
        boxAppend(sidebar, child: scroll)
        return sidebar
    }

    private func buildItemRow(_ item: SidebarItem) -> WidgetPtr {
        let button = makeButton()
        addCssClass(button, "pine-sidebar-item")
        buttonSetHasFrame(button, hasFrame: false)

        let row = makeBox(GTK_ORIENTATION_HORIZONTAL, spacing: 8)
        let icon = makeImage(iconName: item.iconName)
        boxAppend(row, child: icon)

        let label = makeLabel(item.label)
        setHAlign(label, align: GTK_ALIGN_START)
        setHExpand(label)
        boxAppend(row, child: label)

        if let badge = item.badge, badge > 0 {
            let badgeLabel = makeLabel("\(badge)")
            addCssClass(badgeLabel, "pine-sidebar-badge")
            boxAppend(row, child: badgeLabel)
        }

        buttonSetChild(button, child: row)

        // Connect click for selection.
        let handler = SidebarClickHandler(sidebar: self, itemId: item.id)
        let ptr = Unmanaged.passRetained(handler).toOpaque()
        let callback: @convention(c) (UnsafeMutablePointer<_GtkButton>?, gpointer?) -> Void = { _, userData in
            guard let userData = userData else { return }
            let h = Unmanaged<SidebarClickHandler>.fromOpaque(userData).takeUnretainedValue()
            h.sidebar.select(h.itemId)
            h.sidebar.onSelect?(h.itemId)
        }
        g_signal_connect_data(
            UnsafeMutableRawPointer(button), "clicked",
            unsafeBitCast(callback, to: GCallback.self),
            ptr, { userData, _ in
                guard let userData = userData else { return }
                Unmanaged<SidebarClickHandler>.fromOpaque(userData).release()
            }, GConnectFlags(rawValue: 0)
        )

        return button
    }
}

private class SidebarClickHandler {
    let sidebar: PineSidebar
    let itemId: String
    init(sidebar: PineSidebar, itemId: String) {
        self.sidebar = sidebar
        self.itemId = itemId
    }
}
