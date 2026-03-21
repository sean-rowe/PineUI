// NavigationSplitView.swift — macOS-style split view with sidebar.
//
// Usage:
//   NavigationSplitView {
//       // Sidebar content
//       List { ... }
//   } detail: {
//       // Detail content
//       Text("Select an item")
//   }

import CGTK4

/// A split view with sidebar and detail panes — the core macOS navigation pattern.
public struct NavigationSplitView<Sidebar: View, Detail: View>: View, GTKRenderable {
    let sidebar: Sidebar
    let detail: Detail
    let sidebarWidth: Int32

    public init(
        sidebarWidth: Int32 = 240,
        @ViewBuilder sidebar: () -> Sidebar,
        @ViewBuilder detail: () -> Detail
    ) {
        self.sidebarWidth = sidebarWidth
        self.sidebar = sidebar()
        self.detail = detail()
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let split = makeBox(GTK_ORIENTATION_HORIZONTAL, spacing: 0)
        setHExpand(split)
        setVExpand(split)

        // Sidebar.
        let sidebarBox = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 0)
        setSizeRequest(sidebarBox, width: sidebarWidth, height: -1)
        addCssClass(sidebarBox, "pine-sidebar")

        let sidebarScroll = makeScrolledWindow()
        scrolledWindowSetPolicy(sidebarScroll, h: GTK_POLICY_NEVER, v: GTK_POLICY_AUTOMATIC)
        setVExpand(sidebarScroll)

        let sidebarContent = render(sidebar)
        scrolledWindowSetChild(sidebarScroll, child: sidebarContent)
        boxAppend(sidebarBox, child: sidebarScroll)
        boxAppend(split, child: sidebarBox)

        // Detail.
        let detailBox = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 0)
        setHExpand(detailBox)
        setVExpand(detailBox)

        let detailContent = render(detail)
        setHExpand(detailContent)
        setVExpand(detailContent)
        boxAppend(detailBox, child: detailContent)
        boxAppend(split, child: detailBox)

        return split
    }
}
