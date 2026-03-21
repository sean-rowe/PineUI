// PineSidebar.swift — macOS-style source list sidebar.

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

    public init() {}

    @discardableResult
    public func section(_ title: String, items: [SidebarItem]) -> PineSidebar {
        sections.append(SidebarSection(title, items: items))
        return self
    }

    @discardableResult
    public func width(_ w: Int32) -> PineSidebar { self.sidebarWidth = w; return self }

    func build() -> WidgetPtr {
        let sidebar = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 0)
        setSizeRequest(sidebar, width: sidebarWidth, height: -1)
        addCssClass(sidebar, "pine-sidebar")

        let scroll = makeScrolledWindow()
        scrolledWindowSetPolicy(scroll, h: GTK_POLICY_NEVER, v: GTK_POLICY_AUTOMATIC)
        setVExpand(scroll)

        let listBox = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 0)
        addCssClass(listBox, "pine-sidebar-list")

        for section in sections {
            let header = makeLabel(section.title)
            addCssClass(header, "pine-sidebar-section-header")
            setHAlign(header, align: GTK_ALIGN_START)
            boxAppend(listBox, child: header)

            for item in section.items {
                boxAppend(listBox, child: buildItemRow(item))
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
        return button
    }
}
