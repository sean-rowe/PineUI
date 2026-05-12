// Modifiers.swift — SwiftUI-compatible view modifiers.
//
// Usage:
//   Text("Hello")
//       .padding()
//       .frame(width: 200)
//       .background(Color.blue)
//       .cornerRadius(8)
//       .opacity(0.8)

import CGTK4

// MARK: - ModifiedView

/// A view with a modifier applied. The modifier transforms the rendered GTK widget.
public struct ModifiedView<Content: View>: View, GTKRenderable {
    let content: Content
    let modifier: (WidgetPtr) -> Void

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let widget = render(content)
        modifier(widget)
        return widget
    }
}

// MARK: - View extension for modifiers

extension View {
    /// Add padding around the view.
    public func padding(_ amount: Int32 = 12) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            setMargins(w, start: amount, end: amount, top: amount, bottom: amount)
        }
    }

    /// Add specific edge padding.
    public func padding(_ edges: Edge.Set, _ amount: Int32 = 12) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            if edges.contains(.leading) { gtk_widget_set_margin_start(w, amount) }
            if edges.contains(.trailing) { gtk_widget_set_margin_end(w, amount) }
            if edges.contains(.top) { gtk_widget_set_margin_top(w, amount) }
            if edges.contains(.bottom) { gtk_widget_set_margin_bottom(w, amount) }
        }
    }

    /// Set the frame size. Low-level overload taking raw GtkAlign — keeps
    /// working for direct GTK4 callers.
    public func frame(
        width: Int32? = nil,
        height: Int32? = nil,
        alignment: GtkAlign = GTK_ALIGN_CENTER
    ) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            if let width = width { gtk_widget_set_size_request(w, width, -1) }
            if let height = height {
                let current = width ?? -1
                gtk_widget_set_size_request(w, current, height)
            }
            gtk_widget_set_halign(w, alignment)
        }
    }

    /// SwiftUI-compatible frame overload. Sets width/height and aligns the
    /// view within its allocated space using the existing two-axis
    /// `Alignment` enum (defined in ZStack.swift).
    public func frame(
        width: Int32? = nil,
        height: Int32? = nil,
        alignment: Alignment
    ) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            if let width = width { gtk_widget_set_size_request(w, width, -1) }
            if let height = height {
                let current = width ?? -1
                gtk_widget_set_size_request(w, current, height)
            }
            gtk_widget_set_halign(w, alignment.horizontalAlign)
            gtk_widget_set_valign(w, alignment.verticalAlign)
        }
    }

    /// Set max width with expansion.
    public func frame(maxWidth: MaxDimension) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            if case .infinity = maxWidth {
                setHExpand(w)
            }
        }
    }

    /// SwiftUI-compatible: set max width with expansion and align horizontally.
    public func frame(
        maxWidth: MaxDimension,
        alignment: HorizontalAlignment
    ) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            if case .infinity = maxWidth {
                setHExpand(w)
            }
            gtk_widget_set_halign(w, alignment.gtkAlign)
        }
    }

    /// SwiftUI-compatible: set max height with expansion and align vertically.
    public func frame(
        maxHeight: MaxDimension,
        alignment: VerticalAlignment
    ) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            if case .infinity = maxHeight {
                setVExpand(w)
            }
            gtk_widget_set_valign(w, alignment.gtkAlign)
        }
    }

    /// Set opacity (0.0 to 1.0).
    public func opacity(_ value: Double) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            gtk_widget_set_opacity(w, value)
        }
    }

    /// Disable the view.
    public func disabled(_ isDisabled: Bool = true) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            gtk_widget_set_sensitive(w, isDisabled ? 0 : 1)
        }
    }

    /// Add a CSS class (for custom styling).
    public func cssClass(_ name: String) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            addCssClass(w, name)
        }
    }

    /// Set visibility.
    public func hidden(_ isHidden: Bool = true) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            gtk_widget_set_visible(w, isHidden ? 0 : 1)
        }
    }

    /// Set tooltip.
    public func help(_ text: String) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            gtk_widget_set_tooltip_text(w, text)
        }
    }

    /// Set corner radius via CSS.
    public func cornerRadius(_ radius: Int32) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "border-radius: \(radius)px;")
        }
    }

    /// Set background color via CSS.
    public func background(_ color: Color) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "background: \(color.cssValue);")
        }
    }

    /// Fill the given `ClipShape` with the given color in one modifier.
    ///
    /// SwiftUI-equivalent of `.background(color, in: Capsule())` — combines
    /// background-color and shape clipping so the color is bounded by the
    /// shape's outline. Used heavily for pill buttons and badge-style UI.
    public func background(_ color: Color, in shape: ClipShape) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "background: \(color.cssValue);")
            gtk_widget_set_overflow(w, GTK_OVERFLOW_HIDDEN)
            switch shape {
            case .circle:
                applyCss(w, "border-radius: 50%;")
            case .capsule:
                applyCss(w, "border-radius: 9999px;")
            case .roundedRectangle(let radius):
                applyCss(w, "border-radius: \(radius)px;")
            case .rectangle:
                break
            }
        }
    }

    /// Fill the given `ClipShape` with the given material in one modifier.
    ///
    /// SwiftUI-equivalent of `.background(.regularMaterial, in: Rounded...)`.
    public func background(_ material: Material, in shape: ClipShape) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "background: \(material.cssValue);")
            gtk_widget_set_overflow(w, GTK_OVERFLOW_HIDDEN)
            switch shape {
            case .circle:
                applyCss(w, "border-radius: 50%;")
            case .capsule:
                applyCss(w, "border-radius: 9999px;")
            case .roundedRectangle(let radius):
                applyCss(w, "border-radius: \(radius)px;")
            case .rectangle:
                break
            }
        }
    }

    /// Set a border via CSS.
    public func border(_ color: Color, width: Int32 = 1) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "border: \(width)px solid \(color.cssValue);")
        }
    }

    /// Set foreground color on text views via CSS.
    public func foregroundColor(_ color: Color) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "color: \(color.cssValue);")
        }
    }

    /// Attach a tap gesture to any view.
    public func onTapGesture(_ action: @escaping () -> Void) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            attachClickGesture(to: w, action: action)
        }
    }
}

// MARK: - Edge types

public enum Edge {
    case top, bottom, leading, trailing

    public struct Set: OptionSet {
        public let rawValue: Int
        public init(rawValue: Int) { self.rawValue = rawValue }

        public static let top = Set(rawValue: 1 << 0)
        public static let bottom = Set(rawValue: 1 << 1)
        public static let leading = Set(rawValue: 1 << 2)
        public static let trailing = Set(rawValue: 1 << 3)

        public static let horizontal: Set = [.leading, .trailing]
        public static let vertical: Set = [.top, .bottom]
        public static let all: Set = [.top, .bottom, .leading, .trailing]
    }
}

public enum MaxDimension {
    case infinity
}

// Alignment types live elsewhere:
//   - HorizontalAlignment / VerticalAlignment in Stacks.swift (used by
//     VStack(alignment:) and HStack(alignment:))
//   - Alignment (the 9-case 2D enum) in ZStack.swift (used by ZStack)
// The SwiftUI-shaped frame(...) overloads below reuse those types so
// there's a single source of truth for alignment values across PineUI.

// MARK: - Color

/// A color type matching SwiftUI's Color API.
public struct Color {
    let cssValue: String

    public init(red: Double, green: Double, blue: Double, opacity: Double = 1.0) {
        let r = Int(red * 255), g = Int(green * 255), b = Int(blue * 255)
        if opacity < 1.0 {
            self.cssValue = "rgba(\(r), \(g), \(b), \(opacity))"
        } else {
            self.cssValue = "rgb(\(r), \(g), \(b))"
        }
    }

    public init(css: String) {
        self.cssValue = css
    }

    // Standard colors matching SwiftUI.
    public static let black = Color(css: "rgb(0, 0, 0)")
    public static let white = Color(css: "rgb(255, 255, 255)")
    public static let gray = Color(css: "rgb(142, 142, 147)")
    public static let red = Color(css: "rgb(255, 59, 48)")
    public static let orange = Color(css: "rgb(255, 149, 0)")
    public static let yellow = Color(css: "rgb(255, 204, 0)")
    public static let green = Color(css: "rgb(52, 199, 89)")
    public static let mint = Color(css: "rgb(0, 199, 190)")
    public static let teal = Color(css: "rgb(48, 176, 199)")
    public static let cyan = Color(css: "rgb(50, 173, 230)")
    public static let blue = Color(css: "rgb(0, 122, 255)")
    public static let indigo = Color(css: "rgb(88, 86, 214)")
    public static let purple = Color(css: "rgb(175, 82, 222)")
    public static let pink = Color(css: "rgb(255, 45, 85)")
    public static let brown = Color(css: "rgb(162, 132, 94)")
    public static let clear = Color(css: "transparent")

    // Semantic colors — use GTK theme variables. The grayscale hierarchy
    // mirrors SwiftUI's 4-level foreground color system; alpha values
    // approximate the visual weight of each tier on macOS.
    public static let accentColor = Color(css: "@accent_bg_color")
    public static let primary = Color(css: "@window_fg_color")
    public static let secondary = Color(css: "alpha(@window_fg_color, 0.6)")
    public static let tertiary = Color(css: "alpha(@window_fg_color, 0.3)")
    public static let quaternary = Color(css: "alpha(@window_fg_color, 0.2)")

    /// Adjust opacity.
    public func opacity(_ value: Double) -> Color {
        Color(css: "alpha(\(cssValue), \(value))")
    }
}

// MARK: - Gesture handler

class GestureHandler {
    let action: () -> Void
    init(action: @escaping () -> Void) { self.action = action }
}
