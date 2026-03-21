// ZStack.swift — Overlapping views using GtkOverlay.

import CGTK4

/// Overlapping stack — layers children on top of each other.
public struct ZStack<Content: View>: View, GTKRenderable {
    let alignment: GtkAlign
    let content: Content

    public init(
        alignment: Alignment = .center,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment.gtkAlign
        self.content = content()
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let overlay = gtk_overlay_new()!
        setHExpand(overlay)
        setVExpand(overlay)

        if let multi = content as? MultiChildView {
            let children = multi.renderChildren()
            if let first = children.first {
                // First child is the base.
                setHExpand(first)
                setVExpand(first)
                gtk_overlay_set_child(OpaquePointer(overlay), first)

                // Remaining children are overlays.
                for child in children.dropFirst() {
                    setHAlign(child, align: alignment)
                    setVAlign(child, align: alignment)
                    gtk_overlay_add_overlay(OpaquePointer(overlay), child)
                }
            }
        } else {
            let child = render(content)
            setHExpand(child)
            setVExpand(child)
            gtk_overlay_set_child(OpaquePointer(overlay), child)
        }

        return overlay
    }
}

public enum Alignment {
    case center, topLeading, top, topTrailing
    case leading, trailing
    case bottomLeading, bottom, bottomTrailing

    var gtkAlign: GtkAlign {
        switch self {
        case .center: return GTK_ALIGN_CENTER
        case .topLeading, .leading, .bottomLeading: return GTK_ALIGN_START
        case .topTrailing, .trailing, .bottomTrailing: return GTK_ALIGN_END
        case .top, .bottom: return GTK_ALIGN_CENTER
        }
    }
}
