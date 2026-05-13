// Shapes.swift — SwiftUI-compatible shape views for PineUI.
//
// Implements the Shape protocol and 6 concrete shape views:
//   Rectangle, RoundedRectangle, Circle, Ellipse, Capsule, Path
//
// Shapes render as GtkBox widgets styled with CSS for visual appearance.
// The .fill() and .stroke() modifiers are provided via Shape extension.
//
// CGRect is sourced from Foundation; importing it here avoids redeclaration
// conflicts with Foundation's own CGRect in the test target.

import CGTK4
import Foundation

// MARK: - Shape Protocol

/// A protocol for views that define a geometric shape.
/// Mirrors SwiftUI's Shape protocol. Shapes are Views that render as
/// styled regions and support .fill() and .stroke() modifiers.
public protocol Shape: View, GTKRenderable {
    /// Describes the shape's path within the given rect. Stub for API compatibility.
    func path(in rect: CGRect)
}

// MARK: - Shape Modifiers

extension Shape {

    /// Fills the shape with the given color.
    public func fill(_ color: Color) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "background: \(color.cssValue);")
        }
    }

    /// Strokes the shape's outline with the given color and line width.
    public func stroke(_ color: Color, lineWidth: Int32 = 1) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "background: transparent; border: \(lineWidth)px solid \(color.cssValue);")
        }
    }
}

// MARK: - Shape Base Widget
//
// CRITICAL: GtkBox is "transparent passthrough" by default and an EMPTY
// GtkBox (no children) doesn't snapshot at all — CSS `background` set
// on a bare GtkBox renders invisible. The `.background(_:in:Shape)` path
// works only because it applies to a container that HAS children, which
// forces allocation.
//
// Shapes (Rectangle, Circle, Capsule, etc.) are leaf primitives — they
// never have children. So they need a widget that always paints. GtkLabel
// fits: it's a leaf widget that always snapshots its allocation and
// renders CSS background reliably, even with empty text. Using GtkLabel
// as the shape base instead of GtkBox is what makes chart bars, status
// dots, progress fills, and divider rules actually visible.

private func makeShapeWidget() -> WidgetPtr {
    // GtkLabel is the GTK4 leaf widget that reliably snapshots its
    // allocation and renders CSS background — empty GtkBox doesn't paint
    // its background at all. The setup that works:
    //   * hexpand/vexpand=1 so the parent gives extra space.
    //   * halign/valign=FILL so the label claims the full allocation.
    //   * size_request(1, 1) for the minimum floor.
    //
    // KNOWN LIMITATION: empty GtkLabel reports 0×0 natural size and
    // doesn't reliably grow to fill flex-width slots even with hexpand.
    // For "rectangle of unknown width" use cases (chart bars at
    // `.frame(maxWidth: .infinity)`), the bars end up at the
    // size_request minimum. Callers needing visible flex-width shapes
    // should use explicit `.frame(width: N)` for now; a proper fix
    // would adopt GtkDrawingArea or a custom snapshottable widget.
    let label = makeLabel("")
    setHExpand(label)
    setVExpand(label)
    setHAlign(label, align: GTK_ALIGN_FILL)
    setVAlign(label, align: GTK_ALIGN_FILL)
    gtk_widget_set_size_request(label, 1, 1)
    return label
}

// MARK: - Rectangle

/// A rectangular shape that fills its available space.
///
/// Renders as a GtkBox with the accent background color. Forces overflow
/// hidden so the box snapshots its allocation and paints its CSS
/// background — without this, Rectangle inside an HStack/VStack renders
/// invisible (the GTK4 layout-container transparent-passthrough gotcha).
/// Use `.fill(_:)` to override the color.
public struct Rectangle: Shape {
    public init() {}

    public var body: Never { fatalError("Rectangle is a primitive") }

    public func path(in rect: CGRect) {}

    public func renderGTK() -> WidgetPtr {
        let widget = makeShapeWidget()
        applyCss(widget, "background: @accent_bg_color;")
        return widget
    }
}

// MARK: - RoundedRectangle

/// A rectangle with rounded corners.
///
/// Renders as a GtkBox with CSS border-radius matching the given corner
/// radius. Forces overflow hidden so the rounded background paints —
/// border-radius alone doesn't trigger GtkBox snapshot.
public struct RoundedRectangle: Shape {
    let cornerRadius: Int32

    public init(cornerRadius: Int32) {
        self.cornerRadius = cornerRadius
    }

    public var body: Never { fatalError("RoundedRectangle is a primitive") }

    public func path(in rect: CGRect) {}

    public func renderGTK() -> WidgetPtr {
        let widget = makeShapeWidget()
        applyCss(widget, "background: @accent_bg_color; border-radius: \(cornerRadius)px;")
        return widget
    }
}

// MARK: - Circle

/// A circle that maintains a 1:1 aspect ratio within its frame.
///
/// Renders as a GtkBox with CSS border-radius: 50%. Forces overflow
/// hidden so the round background paints.
///
/// Does NOT request hexpand/vexpand — a 0-sized empty GtkBox with both
/// expand flags collapses to invisible in mixed-content containers
/// (e.g. an 8×8 indicator dot inside an HStack of text widgets). The
/// `.frame(width:height:)` modifier is the canonical way to size a
/// Circle; default size is the GTK widget request minimum (0×0) so
/// without a frame the Circle is intentionally invisible.
public struct Circle: Shape {
    public init() {}

    public var body: Never { fatalError("Circle is a primitive") }

    public func path(in rect: CGRect) {}

    public func renderGTK() -> WidgetPtr {
        // Circle deliberately doesn't request hexpand/vexpand — uses the
        // shape widget without those flags so an 8×8 dot doesn't collapse
        // in mixed-content HStacks. Frame-size it explicitly via the
        // `.frame(width:height:)` modifier.
        let label = makeLabel("")
        applyCss(label, "background: @accent_bg_color; border-radius: 50%;")
        return label
    }
}

// MARK: - Ellipse

/// An ellipse that fills its container with a 50% border-radius.
///
/// Unlike Circle, Ellipse does not enforce a 1:1 aspect ratio — it
/// stretches to fill whatever frame it is placed in. Forces overflow
/// hidden so the elliptical background paints.
public struct Ellipse: Shape {
    public init() {}

    public var body: Never { fatalError("Ellipse is a primitive") }

    public func path(in rect: CGRect) {}

    public func renderGTK() -> WidgetPtr {
        let widget = makeShapeWidget()
        applyCss(widget, "background: @accent_bg_color; border-radius: 50%;")
        return widget
    }
}

// MARK: - Capsule

/// A rounded shape with the maximum possible corner radius, producing a
/// pill/stadium shape. Uses a large fixed border-radius so the short axis
/// fully rounds regardless of size. Forces overflow hidden so the
/// pill background paints.
public struct Capsule: Shape {
    public init() {}

    public var body: Never { fatalError("Capsule is a primitive") }

    public func path(in rect: CGRect) {}

    public func renderGTK() -> WidgetPtr {
        let widget = makeShapeWidget()
        applyCss(widget, "background: @accent_bg_color; border-radius: 9999px;")
        return widget
    }
}

// MARK: - Path

/// A stub for custom path-based drawing.
///
/// SwiftUI's Path uses CGPath under the hood. In PineUI this is a stub
/// that renders as an empty box — custom vector drawing is not available
/// via GTK4's CSS subset.
// STUB: custom path drawing is not available in GTK4 CSS — renders as an empty box.
public struct Path: Shape {
    public init() {}

    /// Path builder closure (stored but not rendered — API compatibility only).
    public init(_ build: (inout Path) -> Void) {
        var p = Path()
        build(&p)
    }

    public var body: Never { fatalError("Path is a primitive") }

    public func path(in rect: CGRect) {}

    public func renderGTK() -> WidgetPtr {
        // STUB: no GTK4 CSS equivalent for custom vector paths.
        let box = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 0)
        setHExpand(box)
        setVExpand(box)
        return box
    }
}
