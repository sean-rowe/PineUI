// Advanced.swift — Table, GeometryProxy, Overlay, HelpButton, Separator.

import CGTK4

// MARK: - Table

/// A multi-column table view — like macOS NSTableView.
public struct Table: View, GTKRenderable {
    let columns: [TableColumn]
    let rows: [[String]]

    public init(columns: [TableColumn], rows: [[String]]) {
        self.columns = columns
        self.rows = rows
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let scroll = makeScrolledWindow()
        setHExpand(scroll)
        setVExpand(scroll)
        scrolledWindowSetPolicy(scroll, h: GTK_POLICY_AUTOMATIC, v: GTK_POLICY_AUTOMATIC)

        // Build a grid-based table.
        let grid = gtk_grid_new()!
        let g: UnsafeMutablePointer<GtkGrid> = typed(grid)
        gtk_grid_set_column_spacing(g, 0)
        gtk_grid_set_row_spacing(g, 0)
        setHExpand(grid)

        // Header row.
        for (col, column) in columns.enumerated() {
            let header = makeLabel(column.title)
            addCssClass(header, "pine-table-header")
            setHExpand(header)
            setHAlign(header, align: GTK_ALIGN_START)
            setMargins(header, start: 8, end: 8, top: 6, bottom: 6)
            gtk_grid_attach(g, header, Int32(col), 0, 1, 1)
        }

        // Data rows.
        for (rowIdx, row) in rows.enumerated() {
            for (colIdx, cell) in row.enumerated() {
                let cellLabel = makeLabel(cell)
                setHExpand(cellLabel)
                setHAlign(cellLabel, align: GTK_ALIGN_START)
                setMargins(cellLabel, start: 8, end: 8, top: 4, bottom: 4)
                if rowIdx % 2 == 1 {
                    addCssClass(cellLabel, "pine-table-alt-row")
                }
                gtk_grid_attach(g, cellLabel, Int32(colIdx), Int32(rowIdx + 1), 1, 1)
            }
        }

        scrolledWindowSetChild(scroll, child: grid)
        return scroll
    }
}

public struct TableColumn {
    public let title: String
    public let width: Int32?

    public init(_ title: String, width: Int32? = nil) {
        self.title = title
        self.width = width
    }
}

// MARK: - ContentUnavailableView

/// A placeholder view for empty states — like SwiftUI's ContentUnavailableView.
public struct ContentUnavailableView: View, GTKRenderable {
    let title: String
    let systemImage: String
    let description: String?

    public init(_ title: String, systemImage: String, description: String? = nil) {
        self.title = title
        self.systemImage = systemImage
        self.description = description
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let box = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 12)
        setHExpand(box)
        setVExpand(box)
        setHAlign(box, align: GTK_ALIGN_CENTER)
        setVAlign(box, align: GTK_ALIGN_CENTER)

        let icon = makeImage(iconName: resolveSFSymbol(systemImage))
        applyCss(icon, "font-size: 48px; color: alpha(@window_fg_color, 0.3);")
        boxAppend(box, child: icon)

        let titleLabel = makeLabel(title)
        addCssClass(titleLabel, "pine-title3")
        addCssClass(titleLabel, "pine-fg-secondary")
        boxAppend(box, child: titleLabel)

        if let desc = description {
            let descLabel = makeLabel(desc)
            addCssClass(descLabel, "pine-caption")
            labelSetWrap(descLabel, wrap: true)
            setHAlign(descLabel, align: GTK_ALIGN_CENTER)
            boxAppend(box, child: descLabel)
        }

        return box
    }
}

// MARK: - InfoButton (i button like macOS)

/// A small info button that shows a popover on click.
public struct InfoButton<Content: View>: View, GTKRenderable {
    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let btn = gtk_menu_button_new()!
        let img = makeImage(iconName: resolveSFSymbol("info.circle"))
        gtk_menu_button_set_child(OpaquePointer(btn), img)
        buttonSetHasFrame(btn, hasFrame: false)

        let popover = gtk_popover_new()!
        let pop: UnsafeMutablePointer<_GtkPopover> = typed(popover)
        let rendered = render(content)
        setMargins(rendered, start: 12, end: 12, top: 12, bottom: 12)
        gtk_popover_set_child(pop, rendered)
        gtk_menu_button_set_popover(OpaquePointer(btn),
            UnsafeMutableRawPointer(pop).assumingMemoryBound(to: GtkWidget.self))

        return btn
    }
}

// MARK: - Card

/// A styled card with optional header — higher-level than GroupBox.
public struct Card<Content: View>: View, GTKRenderable {
    let title: String?
    let subtitle: String?
    let content: Content

    public init(_ title: String? = nil, subtitle: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let card = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 0)
        addCssClass(card, "pine-card")

        if title != nil || subtitle != nil {
            let header = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 2)
            addCssClass(header, "pine-card-header")

            if let title = title {
                let titleLabel = makeLabel(title)
                addCssClass(titleLabel, "pine-headline")
                setHAlign(titleLabel, align: GTK_ALIGN_START)
                boxAppend(header, child: titleLabel)
            }
            if let subtitle = subtitle {
                let subLabel = makeLabel(subtitle)
                addCssClass(subLabel, "pine-caption")
                setHAlign(subLabel, align: GTK_ALIGN_START)
                boxAppend(header, child: subLabel)
            }
            boxAppend(card, child: header)
        }

        let body = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 8)
        addCssClass(body, "pine-card-body")
        boxAppend(body, child: render(content))
        boxAppend(card, child: body)

        return card
    }
}

// MARK: - HSplitView / VSplitView

/// A resizable horizontal split view using GtkPaned.
public struct HSplitView<Leading: View, Trailing: View>: View, GTKRenderable {
    let leading: Leading
    let trailing: Trailing
    let position: Int32

    public init(
        position: Int32 = 300,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.position = position
        self.leading = leading()
        self.trailing = trailing()
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let paned = gtk_paned_new(GTK_ORIENTATION_HORIZONTAL)!
        let p = OpaquePointer(paned)
        setHExpand(paned)
        setVExpand(paned)

        let leadingWidget = render(leading)
        setHExpand(leadingWidget)
        setVExpand(leadingWidget)
        gtk_paned_set_start_child(p, leadingWidget)

        let trailingWidget = render(trailing)
        setHExpand(trailingWidget)
        setVExpand(trailingWidget)
        gtk_paned_set_end_child(p, trailingWidget)

        gtk_paned_set_position(p, position)
        return paned
    }
}

/// A resizable vertical split view using GtkPaned.
public struct VSplitView<Top: View, Bottom: View>: View, GTKRenderable {
    let top: Top
    let bottom: Bottom
    let position: Int32

    public init(
        position: Int32 = 300,
        @ViewBuilder top: () -> Top,
        @ViewBuilder bottom: () -> Bottom
    ) {
        self.position = position
        self.top = top()
        self.bottom = bottom()
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let paned = gtk_paned_new(GTK_ORIENTATION_VERTICAL)!
        let p = OpaquePointer(paned)
        setHExpand(paned)
        setVExpand(paned)

        let topWidget = render(top)
        setHExpand(topWidget)
        setVExpand(topWidget)
        gtk_paned_set_start_child(p, topWidget)

        let bottomWidget = render(bottom)
        setHExpand(bottomWidget)
        setVExpand(bottomWidget)
        gtk_paned_set_end_child(p, bottomWidget)

        gtk_paned_set_position(p, position)
        return paned
    }
}

// MARK: - Chip / Tag

/// A small rounded tag — like macOS tags or badges.
public struct Chip: View, GTKRenderable {
    let label: String
    let color: Color?

    public init(_ label: String, color: Color? = nil) {
        self.label = label
        self.color = color
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let chip = makeLabel(label)
        let bg = color?.cssValue ?? "@accent_bg_color"
        applyCss(chip, """
            background: \(bg);
            color: white;
            border-radius: 12px;
            padding: 2px 10px;
            font-size: 0.8em;
            font-weight: 600;
        """)
        return chip
    }
}

// MARK: - Toolbar Spacer (flexible/fixed)

/// A fixed-width spacer for toolbars.
public struct ToolbarSpacer: View, GTKRenderable {
    let width: Int32?

    public init(width: Int32? = nil) {
        self.width = width
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let spacer = makeBox(GTK_ORIENTATION_HORIZONTAL, spacing: 0)
        if let w = width {
            setSizeRequest(spacer, width: w, height: 1)
        } else {
            setHExpand(spacer)
        }
        return spacer
    }
}
