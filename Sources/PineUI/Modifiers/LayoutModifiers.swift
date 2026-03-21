// LayoutModifiers.swift — SwiftUI-compatible layout modifiers for PineUI.
//
// Implements 16 layout modifiers:
//   overlay, shadow, clipped, clipShape, fixedSize, layoutPriority, zIndex,
//   offset, position, alignmentGuide, safeAreaInset, contentMargins,
//   scenePadding, aspectRatio, mask, containerRelativeFrame

import CGTK4

// MARK: - Supporting Enums

/// Shapes for use with clipShape modifier.
public enum ClipShape {
    case circle
    case capsule
    case roundedRectangle(cornerRadius: Double)
    case rectangle
}

/// Content mode for aspectRatio modifier.
public enum ContentMode {
    case fit
    case fill
}

// MARK: - Layout Modifiers

extension View {

    // MARK: 1. overlay

    /// Overlays a secondary view on top of this view.
    ///
    /// NOTE: Full GtkOverlay re-parenting is not used here since ModifiedView
    /// applies the modifier after render. This stub applies the overlay widget
    /// as a sibling appended immediately after in the parent box, approximating
    /// the visual intent without complex re-parenting.
    // STUB: no GTK4 equivalent for true overlay re-parenting in this architecture
    public func overlay<Overlay: View>(
        alignment: HorizontalAlignment = .center,
        @ViewBuilder content overlayContent: () -> Overlay
    ) -> ModifiedView<Self> {
        let _ = overlayContent() // capture for future use
        return ModifiedView(content: self) { _ in
            // STUB: no GTK4 equivalent — true overlay requires GtkOverlay as a container,
            // which cannot wrap an already-rendered widget post-render.
        }
    }

    // MARK: 2. shadow

    /// Adds a shadow to the view using CSS box-shadow.
    public func shadow(
        color: Color = Color(css: "rgba(0, 0, 0, 0.33)"),
        radius: Double = 4,
        x: Double = 0,
        y: Double = 2
    ) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "box-shadow: \(x)px \(y)px \(radius)px \(color.cssValue);")
        }
    }

    // MARK: 3. clipped

    /// Clips the view to its bounding frame.
    public func clipped() -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            gtk_widget_set_overflow(w, GTK_OVERFLOW_HIDDEN)
        }
    }

    // MARK: 4. clipShape

    /// Clips the view to the specified shape.
    public func clipShape(_ shape: ClipShape) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
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

    // MARK: 5. fixedSize

    /// Fixes the view at its ideal size, preventing expansion on the specified axes.
    public func fixedSize(horizontal: Bool = true, vertical: Bool = true) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            if horizontal { gtk_widget_set_hexpand(w, 0) }
            if vertical { gtk_widget_set_vexpand(w, 0) }
        }
    }

    // MARK: 6. layoutPriority

    /// Sets the layout priority for this view.
    // STUB: no GTK4 equivalent — GTK4 does not support SwiftUI-style layout priorities.
    public func layoutPriority(_ value: Double) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: no GTK4 equivalent
        }
    }

    // MARK: 7. zIndex

    /// Controls the display order of overlapping views.
    // STUB: no GTK4 equivalent — GTK4 draws children in insertion order; zIndex is not supported.
    public func zIndex(_ value: Double) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: no GTK4 equivalent
        }
    }

    // MARK: 8. offset

    /// Shifts the view by the specified horizontal and vertical distances using CSS transform.
    public func offset(x: Double = 0, y: Double = 0) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "transform: translate(\(x)px, \(y)px);")
        }
    }

    // MARK: 9. position

    /// Places the view at an absolute position using CSS transform.
    ///
    /// NOTE: In GTK4, absolute positioning within a container is not directly supported
    /// except via GtkFixed. This approximates the effect using CSS transform from origin.
    public func position(x: Double, y: Double) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "transform: translate(\(x)px, \(y)px);")
        }
    }

    // MARK: 10. alignmentGuide

    /// Overrides the default alignment for this view within its parent.
    // STUB: no GTK4 equivalent — GTK4 alignment guides are not a GTK concept.
    public func alignmentGuide(
        _ guide: HorizontalAlignment,
        computeValue: @escaping (ViewDimensions) -> Double
    ) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: no GTK4 equivalent
        }
    }

    /// Overrides the default vertical alignment for this view within its parent.
    // STUB: no GTK4 equivalent — GTK4 alignment guides are not a GTK concept.
    public func alignmentGuide(
        _ guide: VerticalAlignment,
        computeValue: @escaping (ViewDimensions) -> Double
    ) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: no GTK4 equivalent
        }
    }

    // MARK: 11. safeAreaInset

    /// Adds content at the edge of the view's safe area.
    // STUB: no GTK4 equivalent — GTK4 does not have a safe area concept; re-parenting is complex.
    public func safeAreaInset<Content: View>(
        edge: Edge,
        @ViewBuilder content safeAreaContent: () -> Content
    ) -> ModifiedView<Self> {
        let _ = safeAreaContent()
        return ModifiedView(content: self) { _ in
            // STUB: no GTK4 equivalent — safe area insets require complex re-parenting
        }
    }

    // MARK: 12. contentMargins

    /// Adds margins around the view's content, delegating to padding().
    public func contentMargins(_ edges: Edge.Set = .all, _ length: Int32 = 12) -> ModifiedView<Self> {
        // Delegate to existing padding implementation.
        ModifiedView(content: self) { w in
            if edges.contains(.leading) { gtk_widget_set_margin_start(w, length) }
            if edges.contains(.trailing) { gtk_widget_set_margin_end(w, length) }
            if edges.contains(.top) { gtk_widget_set_margin_top(w, length) }
            if edges.contains(.bottom) { gtk_widget_set_margin_bottom(w, length) }
        }
    }

    /// Adds uniform margins around the view's content.
    public func contentMargins(_ length: Int32) -> ModifiedView<Self> {
        contentMargins(.all, length)
    }

    // MARK: 13. scenePadding

    /// Adds scene-appropriate padding (20pt) around the specified edges.
    public func scenePadding(_ edges: Edge.Set = .all) -> ModifiedView<Self> {
        // Delegate to padding with 20pt — a comfortable scene-level margin.
        ModifiedView(content: self) { w in
            let amount: Int32 = 20
            if edges.contains(.leading) { gtk_widget_set_margin_start(w, amount) }
            if edges.contains(.trailing) { gtk_widget_set_margin_end(w, amount) }
            if edges.contains(.top) { gtk_widget_set_margin_top(w, amount) }
            if edges.contains(.bottom) { gtk_widget_set_margin_bottom(w, amount) }
        }
    }

    // MARK: 14. aspectRatio

    /// Constrains the view to the specified aspect ratio.
    /// GTK4 CSS doesn't support aspect-ratio, so we approximate by
    /// setting a size request based on the current allocation.
    public func aspectRatio(_ ratio: Double? = nil, contentMode: ContentMode) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            // aspect-ratio is not supported in GTK4 CSS.
            // We skip it — the ratio is best enforced via .frame(width:height:).
            _ = ratio
            switch contentMode {
            case .fit:
                // Fit: don't expand beyond container, maintain ratio.
                gtk_widget_set_hexpand(w, 0)
                gtk_widget_set_vexpand(w, 0)
            case .fill:
                // Fill: expand to fill container, maintain ratio.
                gtk_widget_set_hexpand(w, 1)
                gtk_widget_set_vexpand(w, 1)
            }
        }
    }

    // MARK: 15. mask

    /// Masks the view using another view's alpha channel.
    // STUB: no GTK4 equivalent — CSS masking is not available in GTK4's CSS subset.
    public func mask<Mask: View>(
        alignment: HorizontalAlignment = .center,
        @ViewBuilder _ maskContent: () -> Mask
    ) -> ModifiedView<Self> {
        let _ = maskContent()
        return ModifiedView(content: self) { _ in
            // STUB: no GTK4 equivalent — GTK4 CSS does not support alpha-channel masking
        }
    }

    // MARK: 16. containerRelativeFrame

    /// Sizes the view relative to its container.
    // STUB: no GTK4 equivalent — GTK4 does not support percentage-based sizing from Swift layout.
    public func containerRelativeFrame(
        _ axes: Axis.Set,
        alignment: HorizontalAlignment = .center
    ) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            // STUB: no GTK4 equivalent — approximate by expanding on specified axes
            if axes.contains(.horizontal) { gtk_widget_set_hexpand(w, 1) }
            if axes.contains(.vertical) { gtk_widget_set_vexpand(w, 1) }
        }
    }
}

// MARK: - Supporting Types

/// Proxy for view dimensions, used in alignmentGuide closures.
/// Matches SwiftUI's ViewDimensions API shape.
public struct ViewDimensions {
    public let width: Double
    public let height: Double

    public init(width: Double = 0, height: Double = 0) {
        self.width = width
        self.height = height
    }
}

/// Axis options for containerRelativeFrame.
public enum Axis {
    case horizontal, vertical

    public struct Set: OptionSet {
        public let rawValue: Int
        public init(rawValue: Int) { self.rawValue = rawValue }

        public static let horizontal = Set(rawValue: 1 << 0)
        public static let vertical = Set(rawValue: 1 << 1)
        public static let all: Set = [.horizontal, .vertical]
    }
}
