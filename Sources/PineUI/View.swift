// View.swift — The core View protocol, matching SwiftUI's design.
//
// Every PineUI component conforms to View and produces a WidgetPtr
// via its `body` property. This is the foundation of the declarative API.

import CGTK4

/// The core protocol for all PineUI views.
/// Mirrors SwiftUI's View protocol.
public protocol View {
    associatedtype Body: View
    @ViewBuilder var body: Body { get }
}

// MARK: - Primitive views (leaf nodes that produce GTK widgets directly)

/// A view that wraps a raw GTK widget. Used internally.
public struct GTKWidget: View {
    let widget: WidgetPtr

    public init(_ widget: WidgetPtr) {
        self.widget = widget
    }

    public var body: Never { fatalError("GTKWidget is a primitive") }
}

// Make Never conform to View (same as SwiftUI).
extension Never: View {
    public typealias Body = Never
    public var body: Never { fatalError() }
}

// MARK: - View rendering

/// Render a View into a GTK widget.
public func render<V: View>(_ view: V) -> WidgetPtr {
    if let gtk = view as? GTKWidget {
        return gtk.widget
    }
    if let renderable = view as? GTKRenderable {
        return renderable.renderGTK()
    }
    // Recurse into body.
    return render(view.body)
}

/// Protocol for views that can directly produce GTK widgets.
/// Conforming types skip the body recursion.
public protocol GTKRenderable {
    func renderGTK() -> WidgetPtr
}
