// LazyStacks.swift — LazyVStack, LazyHStack, LazyHGrid layout containers.
//
// In SwiftUI, lazy stacks only render visible children. On GTK4 we approximate
// this with the same GtkBox/GtkGrid implementation as VStack/HStack/LazyVGrid,
// since GTK handles scrolling efficiency internally.
//
// Usage:
//   LazyVStack(alignment: .leading, spacing: 12) {
//       Text("Hello")
//       Text("World")
//   }
//
//   LazyHGrid(rows: 3, spacing: 8, data: items) { item in
//       Text(item.name)
//   }

import CGTK4

// MARK: - PinnedScrollableViews

/// Option set that controls which supplementary views are pinned while scrolling.
/// Mirrors SwiftUI's PinnedScrollableViews — on GTK4 this is stored but not
/// applied (GTK ListBox headers can be used for a future enhancement).
public struct PinnedScrollableViews: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// Pin section headers during scrolling.
    public static let sectionHeaders = PinnedScrollableViews(rawValue: 1 << 0)
    /// Pin section footers during scrolling.
    public static let sectionFooters = PinnedScrollableViews(rawValue: 1 << 1)
}

// MARK: - LazyVStack

/// A lazy vertical stack — arranges children top to bottom.
/// Identical rendering to VStack; the "lazy" qualifier is semantic.
public struct LazyVStack<Content: View>: View, GTKRenderable {
    let alignment: GtkAlign
    let spacing: Int32
    let pinnedViews: PinnedScrollableViews
    let content: Content

    public init(
        alignment: HorizontalAlignment = .center,
        spacing: Int32? = nil,
        pinnedViews: PinnedScrollableViews = [],
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment.gtkAlign
        self.spacing = spacing ?? 8
        self.pinnedViews = pinnedViews
        self.content = content()
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let box = makeBox(GTK_ORIENTATION_VERTICAL, spacing: spacing)
        setHAlign(box, align: alignment)

        if let multi = content as? MultiChildView {
            for child in multi.renderChildrenForAxis(GTK_ORIENTATION_VERTICAL) {
                boxAppend(box, child: child)
            }
        } else {
            boxAppend(box, child: renderChildForAxis(content, axis: GTK_ORIENTATION_VERTICAL))
        }
        return box
    }
}

// MARK: - LazyHStack

/// A lazy horizontal stack — arranges children left to right.
/// Identical rendering to HStack; the "lazy" qualifier is semantic.
public struct LazyHStack<Content: View>: View, GTKRenderable {
    let alignment: GtkAlign
    let spacing: Int32
    let pinnedViews: PinnedScrollableViews
    let content: Content

    public init(
        alignment: VerticalAlignment = .center,
        spacing: Int32? = nil,
        pinnedViews: PinnedScrollableViews = [],
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment.gtkAlign
        self.spacing = spacing ?? 8
        self.pinnedViews = pinnedViews
        self.content = content()
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let box = makeBox(GTK_ORIENTATION_HORIZONTAL, spacing: spacing)
        setVAlign(box, align: alignment)

        if let multi = content as? MultiChildView {
            for child in multi.renderChildrenForAxis(GTK_ORIENTATION_HORIZONTAL) {
                boxAppend(box, child: child)
            }
        } else {
            boxAppend(box, child: renderChildForAxis(content, axis: GTK_ORIENTATION_HORIZONTAL))
        }
        return box
    }
}

// MARK: - LazyHGrid

/// A lazy horizontal grid — flows items across rows, adding columns as needed.
/// Items are laid out row-by-row: column index advances per item and wraps at
/// the given `rows` count, incrementing the column and resetting the row index.
public struct LazyHGrid<Data, Content: View>: View, GTKRenderable
where Data: RandomAccessCollection {
    let rows: Int
    let spacing: Int32
    let data: Data
    let content: (Data.Element) -> Content

    public init(
        rows: Int,
        spacing: Int32 = 8,
        data: Data,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.rows = rows
        self.spacing = spacing
        self.data = data
        self.content = content
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let grid = gtk_grid_new()!
        let g: UnsafeMutablePointer<GtkGrid> = typed(grid)
        gtk_grid_set_column_spacing(g, guint(spacing))
        gtk_grid_set_row_spacing(g, guint(spacing))
        gtk_grid_set_row_homogeneous(g, 1)
        setHExpand(grid)

        // LazyHGrid flows items down rows first, then across columns.
        // col is the "major" axis (horizontal), row is the "minor" axis (vertical).
        var col: Int32 = 0
        var row: Int32 = 0
        for item in data {
            let widget = render(content(item))
            setVExpand(widget)
            gtk_grid_attach(g, widget, col, row, 1, 1)
            row += 1
            if row >= Int32(rows) {
                row = 0
                col += 1
            }
        }

        return grid
    }
}
