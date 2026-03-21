// ListModifiers.swift — SwiftUI-compatible list modifiers for PineUI.
//
// Implements 10 list modifiers:
//   listStyle, listRowBackground, listRowSeparator, listRowInsets,
//   listSectionSeparator, searchable, refreshable, badge (Int),
//   badge (String), privacySensitive

import CGTK4

// MARK: - Supporting Types

/// List style variants matching SwiftUI's ListStyle protocol cases.
public enum ListStyle {
    case sidebar
    case plain
    case inset
    case insetGrouped
    case bordered
}

/// Visibility control matching SwiftUI's Visibility enum.
public enum Visibility {
    case visible
    case hidden
    case automatic
}

/// Edge insets for list row padding, matching SwiftUI's EdgeInsets.
public struct EdgeInsets {
    public var top: Double
    public var leading: Double
    public var bottom: Double
    public var trailing: Double

    public init(top: Double = 0, leading: Double = 0, bottom: Double = 0, trailing: Double = 0) {
        self.top = top
        self.leading = leading
        self.bottom = bottom
        self.trailing = trailing
    }

    /// Uniform insets on all edges.
    public init(_ value: Double) {
        self.top = value
        self.leading = value
        self.bottom = value
        self.trailing = value
    }
}

// MARK: - List Modifiers

extension View {

    // MARK: 1. listStyle

    /// Applies a list style by adding a CSS class based on the style variant.
    ///
    /// The corresponding CSS classes are defined in PineTheme:
    ///   pine-list-sidebar, pine-list-plain, pine-list-inset,
    ///   pine-list-inset-grouped, pine-list-bordered
    public func listStyle(_ style: ListStyle) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            let className: String
            switch style {
            case .sidebar:        className = "pine-list-sidebar"
            case .plain:          className = "pine-list-plain"
            case .inset:          className = "pine-list-inset"
            case .insetGrouped:   className = "pine-list-inset-grouped"
            case .bordered:       className = "pine-list-bordered"
            }
            addCssClass(w, className)
        }
    }

    // MARK: 2. listRowBackground

    /// Sets the background color of a list row via CSS.
    public func listRowBackground(_ color: Color) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "background: \(color.cssValue);")
        }
    }

    // MARK: 3. listRowSeparator

    /// Controls the visibility of the separator below a list row.
    ///
    /// - `.visible`:   Forces a visible bottom border.
    /// - `.hidden`:    Removes the bottom border.
    /// - `.automatic`: Inherits the separator style from the enclosing list.
    public func listRowSeparator(_ visibility: Visibility) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            switch visibility {
            case .visible:
                applyCss(w, "border-bottom: 1px solid alpha(@borders, 0.3);")
            case .hidden:
                applyCss(w, "border-bottom: none;")
            case .automatic:
                // Inherits from the containing list — no override needed.
                break
            }
        }
    }

    // MARK: 4. listRowInsets

    /// Applies custom insets (padding) to a list row.
    ///
    /// Passing `nil` resets to zero padding.
    public func listRowInsets(_ insets: EdgeInsets?) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            let i = insets ?? EdgeInsets()
            applyCss(
                w,
                "padding: \(i.top)px \(i.trailing)px \(i.bottom)px \(i.leading)px;"
            )
        }
    }

    // MARK: 5. listSectionSeparator

    /// Controls the visibility of the separator below a list section.
    ///
    /// - `.visible`:   Forces a visible bottom border on the section.
    /// - `.hidden`:    Removes the section bottom border.
    /// - `.automatic`: Inherits from the enclosing list style.
    public func listSectionSeparator(_ visibility: Visibility) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            switch visibility {
            case .visible:
                applyCss(w, "border-bottom: 1px solid alpha(@borders, 0.5);")
            case .hidden:
                applyCss(w, "border-bottom: none;")
            case .automatic:
                // Inherits from the containing list — no override needed.
                break
            }
        }
    }

    // MARK: 6. searchable (stub)

    /// Makes the enclosing list or navigation view searchable.
    ///
    /// STUB: Full implementation requires injecting a SearchField into the
    /// navigation hierarchy (e.g., as a header in a GtkScrolledWindow or as a
    /// GtkSearchBar in the window). The `text` StateStore would drive the filter.
    public func searchable(
        text: StateStore<String>,
        prompt: String = "Search"
    ) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: no GTK4 equivalent — would require injecting a GtkSearchBar
            // or GtkSearchEntry into the parent navigation container.
            _ = text
            _ = prompt
        }
    }

    // MARK: 7. refreshable (stub)

    /// Marks the view as refreshable via a pull-to-refresh gesture.
    ///
    /// STUB: GTK4 does not provide a native pull-to-refresh widget.
    /// Implementation would require a custom GtkGestureDrag attached to the
    /// scrolled window with a threshold-based trigger.
    public func refreshable(action: @escaping () async -> Void) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: no GTK4 equivalent — pull-to-refresh is not a native GTK4 pattern.
            _ = action
        }
    }

    // MARK: 8. badge (Int)

    /// Displays an integer badge on the list row or navigation item.
    ///
    /// STUB: Full implementation would append a styled GtkLabel badge widget
    /// to the row's trailing area. Currently a no-op.
    public func badge(_ count: Int) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: no GTK4 equivalent — badge requires appending a styled
            // GtkLabel to the list row's trailing container.
            _ = count
        }
    }

    // MARK: 9. badge (String)

    /// Displays a string badge on the list row or navigation item.
    ///
    /// STUB: String overload of badge(_:Int). Same implementation constraints apply.
    public func badge(_ label: String?) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: no GTK4 equivalent — badge requires appending a styled
            // GtkLabel to the list row's trailing container.
            _ = label
        }
    }

    // MARK: 10. privacySensitive (stub)

    /// Marks the view as containing privacy-sensitive content.
    ///
    /// STUB: In SwiftUI this participates in the redaction system. In PineUI,
    /// redaction is applied via .redacted(reason: .privacy). This modifier is
    /// present for API compatibility only.
    public func privacySensitive(_ sensitive: Bool = true) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: no GTK4 equivalent — use .redacted(reason: .privacy) to
            // visually obscure content.
            _ = sensitive
        }
    }
}
