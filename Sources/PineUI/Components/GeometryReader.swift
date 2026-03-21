// GeometryReader.swift — Provides size information to child views.
//
// GeometryReader wraps a GTK fixed/overlay container and, after the widget
// is first shown (the "map" signal fires and GTK has allocated space),
// reads gtk_widget_get_width/height and rebuilds the child with the real size.
// The initial render uses a zero-size proxy so the API is always callable.
//
// CGSize comes from Foundation so it matches the SwiftUI / Apple SDK type exactly.

import CGTK4
import Foundation

// MARK: - GeometryProxy

/// Provides size and layout information to the closure passed to GeometryReader.
/// Matches the SwiftUI type of the same name.
public struct GeometryProxy {
    /// The size allocated to the GeometryReader's container widget.
    public let size: CGSize

    public init(size: CGSize) {
        self.size = size
    }
}

// MARK: - GeometryReader

/// A container that provides size information about the available space
/// to its content closure via a `GeometryProxy`.
///
/// ## GTK4 implementation notes
///
/// GTK4 removed the `size-allocate` signal from GtkWidget's public signal
/// list and made allocation internal to layout managers. The cleanest public
/// hook is the `map` signal, which fires exactly when the widget becomes
/// visible for the first time and its size has been negotiated.
///
/// On `map` the implementation:
/// 1. Reads `gtk_widget_get_width` / `gtk_widget_get_height` on the container.
/// 2. Rebuilds the content closure with a real GeometryProxy.
/// 3. Replaces the placeholder child widget in the container.
///
/// If the window is later resized the content is NOT automatically rebuilt
/// (that would require a GtkLayoutManager subclass). The initial size on
/// map is sufficient for the most common GeometryReader use-cases: sizing
/// an inner view to fill its parent or querying the available width for a
/// text wrapping calculation.
public struct GeometryReader<Content: View>: View, GTKRenderable {
    let content: (GeometryProxy) -> Content

    public init(@ViewBuilder content: @escaping (GeometryProxy) -> Content) {
        self.content = content
    }

    public var body: Never { fatalError("GeometryReader is a primitive") }

    public func renderGTK() -> WidgetPtr {
        // Outer container — expands to fill available space so GTK gives us
        // the full allocated width/height when we read it in the map handler.
        let container = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 0)
        setHExpand(container)
        setVExpand(container)

        // Render an initial placeholder with zero size.  This is immediately
        // visible if the window opens before the map signal fires.
        let initialProxy = GeometryProxy(size: .zero)
        let initialWidget = render(content(initialProxy))
        boxAppend(container, child: initialWidget)

        // Capture the content closure and container pointer for the handler.
        // We use the type-erased AnyGeometryMapHandler so the @convention(c)
        // callback does not need to name the generic Content parameter.
        let handler = AnyGeometryMapHandler(container: container) { [content] size in
            render(content(GeometryProxy(size: size)))
        }
        let ptr = Unmanaged.passRetained(handler).toOpaque()

        // "map" fires once the widget has been allocated and is about to be
        // drawn for the first time.  Signature: (GtkWidget*, gpointer) -> void.
        let mapCallback: @convention(c) (WidgetPtr?, gpointer?) -> Void = { widget, userData in
            guard let widget = widget, let userData = userData else { return }
            let h = Unmanaged<AnyGeometryMapHandler>.fromOpaque(userData).takeUnretainedValue()

            // Guard: only rebuild once (subsequent map calls e.g. from tab
            // switching use the last allocated size).
            guard !h.hasUpdated else { return }
            h.hasUpdated = true

            // Read the allocated dimensions.
            let w = Double(gtk_widget_get_width(widget))
            let ht = Double(gtk_widget_get_height(widget))

            // Only rebuild if we actually have real dimensions.
            guard w > 0 || ht > 0 else { return }

            let newChild = h.makeChild(CGSize(width: w, height: ht))

            // Remove the existing child and insert the real content.
            let box = UnsafeMutableRawPointer(h.container)
                .assumingMemoryBound(to: _GtkBox.self)
            // gtk_widget_get_first_child / gtk_box_remove are available in GTK4.
            if let old = gtk_widget_get_first_child(h.container) {
                gtk_box_remove(box, old)
            }
            gtk_box_append(box, newChild)
        }

        g_signal_connect_data(
            UnsafeMutableRawPointer(container),
            "map",
            unsafeBitCast(mapCallback, to: GCallback.self),
            ptr,
            { userData, _ in
                guard let userData = userData else { return }
                Unmanaged<AnyGeometryMapHandler>.fromOpaque(userData).release()
            },
            GConnectFlags(rawValue: 0)
        )

        return container
    }
}

// MARK: - AnyGeometryMapHandler (type-erased reference type for signal user-data)
//
// GeometryMapHandler was originally generic over Content. However, Swift
// @convention(c) callbacks cannot capture or name generic types — the closure
// must reference a concrete (non-generic) class. We type-erase the content
// builder into a `(CGSize) -> WidgetPtr` closure so the callback only needs
// to know about AnyGeometryMapHandler.

private class AnyGeometryMapHandler {
    let container: WidgetPtr
    /// Builds a new child widget for the given allocated size.
    let makeChild: (CGSize) -> WidgetPtr
    var hasUpdated: Bool = false

    init(container: WidgetPtr, makeChild: @escaping (CGSize) -> WidgetPtr) {
        self.container = container
        self.makeChild = makeChild
    }
}
