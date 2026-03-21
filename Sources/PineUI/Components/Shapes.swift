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

// MARK: - Rectangle

/// A rectangular shape that fills its available space.
///
/// Renders as a GtkBox with the accent background color.
/// Use `.fill(_:)` to override the color.
public struct Rectangle: Shape {
    public init() {}

    public var body: Never { fatalError("Rectangle is a primitive") }

    public func path(in rect: CGRect) {}

    public func renderGTK() -> WidgetPtr {
        let box = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 0)
        setHExpand(box)
        setVExpand(box)
        applyCss(box, "background: @accent_bg_color;")
        return box
    }
}

// MARK: - RoundedRectangle

/// A rectangle with rounded corners.
///
/// Renders as a GtkBox with CSS border-radius matching the given corner radius.
public struct RoundedRectangle: Shape {
    let cornerRadius: Int32

    public init(cornerRadius: Int32) {
        self.cornerRadius = cornerRadius
    }

    public var body: Never { fatalError("RoundedRectangle is a primitive") }

    public func path(in rect: CGRect) {}

    public func renderGTK() -> WidgetPtr {
        let box = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 0)
        setHExpand(box)
        setVExpand(box)
        applyCss(box, "background: @accent_bg_color; border-radius: \(cornerRadius)px;")
        return box
    }
}

// MARK: - Circle

/// A circle that maintains a 1:1 aspect ratio within its frame.
///
/// Renders as a GtkBox with CSS aspect-ratio: 1 and border-radius: 50%.
public struct Circle: Shape {
    public init() {}

    public var body: Never { fatalError("Circle is a primitive") }

    public func path(in rect: CGRect) {}

    public func renderGTK() -> WidgetPtr {
        let box = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 0)
        setHExpand(box)
        setVExpand(box)
        applyCss(box, "background: @accent_bg_color; aspect-ratio: 1; border-radius: 50%;")
        return box
    }
}

// MARK: - Ellipse

/// An ellipse that fills its container with a 50% border-radius.
///
/// Unlike Circle, Ellipse does not enforce a 1:1 aspect ratio — it
/// stretches to fill whatever frame it is placed in.
public struct Ellipse: Shape {
    public init() {}

    public var body: Never { fatalError("Ellipse is a primitive") }

    public func path(in rect: CGRect) {}

    public func renderGTK() -> WidgetPtr {
        let box = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 0)
        setHExpand(box)
        setVExpand(box)
        applyCss(box, "background: @accent_bg_color; border-radius: 50%;")
        return box
    }
}

// MARK: - Capsule

/// A rounded shape with the maximum possible corner radius, producing a
/// pill/stadium shape. Uses a large fixed border-radius so the short axis
/// fully rounds regardless of size.
public struct Capsule: Shape {
    public init() {}

    public var body: Never { fatalError("Capsule is a primitive") }

    public func path(in rect: CGRect) {}

    public func renderGTK() -> WidgetPtr {
        let box = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 0)
        setHExpand(box)
        setVExpand(box)
        applyCss(box, "background: @accent_bg_color; border-radius: 9999px;")
        return box
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
