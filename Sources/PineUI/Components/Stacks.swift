// Stacks.swift — VStack, HStack, ZStack layout containers.
//
// Usage:
//   VStack(spacing: 8) {
//       Text("Hello")
//       Text("World")
//   }

import CGTK4

/// Vertical stack — arranges children top to bottom.
public struct VStack<Content: View>: View, GTKRenderable {
    let alignment: GtkAlign
    let spacing: Int32
    let content: Content

    public init(
        alignment: HorizontalAlignment = .center,
        spacing: Int32 = 8,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment.gtkAlign
        self.spacing = spacing
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

/// Horizontal stack — arranges children left to right.
public struct HStack<Content: View>: View, GTKRenderable {
    let alignment: GtkAlign
    let spacing: Int32
    let content: Content

    public init(
        alignment: VerticalAlignment = .center,
        spacing: Int32 = 8,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment.gtkAlign
        self.spacing = spacing
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

// MARK: - Alignment types

public enum HorizontalAlignment {
    case leading, center, trailing

    var gtkAlign: GtkAlign {
        switch self {
        case .leading: return GTK_ALIGN_START
        case .center: return GTK_ALIGN_CENTER
        case .trailing: return GTK_ALIGN_END
        }
    }
}

public enum VerticalAlignment {
    case top, center, bottom

    var gtkAlign: GtkAlign {
        switch self {
        case .top: return GTK_ALIGN_START
        case .center: return GTK_ALIGN_CENTER
        case .bottom: return GTK_ALIGN_END
        }
    }
}

// MARK: - Spacer and Divider

/// Flexible space that expands to fill available room.
/// Expands in both directions by default — the parent stack
/// constrains it to the relevant axis via renderForAxis().
public struct Spacer: View, GTKRenderable, AxisAwareSpacer {
    let minLength: Int32?

    public init(minLength: Int32? = nil) {
        self.minLength = minLength
    }

    public var body: Never { fatalError() }

    /// Default render (both axes — used when Spacer is standalone).
    public func renderGTK() -> WidgetPtr {
        renderForAxis(nil)
    }

    /// Render constrained to a specific axis.
    public func renderForAxis(_ axis: GtkOrientation?) -> WidgetPtr {
        let spacer = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 0)
        if axis == GTK_ORIENTATION_HORIZONTAL {
            setHExpand(spacer)
        } else if axis == GTK_ORIENTATION_VERTICAL {
            setVExpand(spacer)
        } else {
            setHExpand(spacer)
            setVExpand(spacer)
        }
        if let min = minLength {
            setSizeRequest(spacer, width: min, height: min)
        }
        return spacer
    }
}

/// Protocol for spacers that can be told their parent axis.
public protocol AxisAwareSpacer {
    func renderForAxis(_ axis: GtkOrientation?) -> WidgetPtr
}

/// A thin horizontal line separator.
public struct Divider: View, GTKRenderable {
    public init() {}
    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let sep = gtk_separator_new(GTK_ORIENTATION_HORIZONTAL)!
        return sep
    }
}
