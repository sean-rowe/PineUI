// AccessibilityModifiers.swift — SwiftUI-compatible accessibility modifiers for PineUI.
//
// All 8 modifiers are STUBS. GTK4 uses the GtkAccessible interface, but its
// primary mutation function — gtk_accessible_update_property — is a variadic C
// function (takes a sentinel-terminated va_list). Swift cannot call variadic C
// functions directly, so every modifier accepts the SwiftUI API surface for
// source compatibility but performs no runtime operation.
//
// Implements:
//   accessibilityLabel, accessibilityHint, accessibilityValue,
//   accessibilityHidden, accessibilityAction, accessibilityElement(children:),
//   accessibilityAddTraits, accessibilitySortPriority

// MARK: - Accessibility Modifiers

extension View {

    // MARK: 1. accessibilityLabel

    /// Sets the accessibility label via C shim wrapper.
    public func accessibilityLabel(_ label: String) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            pine_accessible_set_label(w, label)
        }
    }

    // MARK: 2. accessibilityHint

    /// Sets the accessibility description (hint) via C shim wrapper.
    public func accessibilityHint(_ hint: String) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            pine_accessible_set_description(w, hint)
        }
    }

    // MARK: 3. accessibilityValue

    /// Sets the accessibility value text via C shim wrapper.
    public func accessibilityValue(_ value: String) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            pine_accessible_set_value_text(w, value)
        }
    }

    // MARK: 4. accessibilityHidden

    /// Sets the accessibility hidden state via C shim wrapper.
    public func accessibilityHidden(_ hidden: Bool) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            pine_accessible_set_hidden(w, hidden ? 1 : 0)
        }
    }

    // MARK: 5. accessibilityAction

    /// STUB: GTK4's gtk_accessible_update_relation is variadic and uncallable from Swift.
    /// Accepts the SwiftUI API for source compatibility.
    public func accessibilityAction(_ name: String, perform action: @escaping () -> Void) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: GTK4 accessible actions require gtk_accessible_update_relation (variadic)
            // and custom GtkAccessibleInterface implementations — uncallable from Swift.
        }
    }

    // MARK: 6. accessibilityElement(children:)

    /// STUB: GTK4's accessible child relationship requires variadic C functions uncallable from Swift.
    /// Accepts the SwiftUI API for source compatibility.
    public func accessibilityElement(children behavior: AccessibilityChildBehavior = .ignore) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: gtk_accessible_update_relation(widget, GTK_ACCESSIBLE_RELATION_OWNS, ..., -1)
            // is variadic — Swift cannot call variadic C functions.
        }
    }

    // MARK: 7. accessibilityAddTraits

    /// STUB: GTK4's gtk_accessible_update_property is variadic and uncallable from Swift.
    /// Accepts the SwiftUI API for source compatibility.
    public func accessibilityAddTraits(_ traits: AccessibilityTraits) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: mapping AccessibilityTraits to GTK_ACCESSIBLE_ROLE requires
            // gtk_accessible_update_property (variadic) — uncallable from Swift.
        }
    }

    // MARK: 8. accessibilitySortPriority

    /// STUB: GTK4 has no equivalent sort-priority concept in its accessible API.
    /// Accepts the SwiftUI API for source compatibility.
    public func accessibilitySortPriority(_ priority: Double) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: GTK4 GtkAccessible has no sort-priority property.
        }
    }
}

// MARK: - Supporting Types

/// Controls how an accessibility element treats its child views.
/// Mirrors SwiftUI's AccessibilityChildBehavior.
public struct AccessibilityChildBehavior: Equatable {
    private let rawValue: Int

    private init(_ rawValue: Int) { self.rawValue = rawValue }

    /// The accessibility element contains its children as separate elements.
    public static let contain = AccessibilityChildBehavior(0)

    /// The accessibility element combines its children into a single element.
    public static let combine = AccessibilityChildBehavior(1)

    /// The accessibility element ignores its children.
    public static let ignore = AccessibilityChildBehavior(2)
}

/// A set of accessibility traits that describe how an element behaves.
/// Mirrors SwiftUI's AccessibilityTraits using the OptionSet pattern.
public struct AccessibilityTraits: OptionSet {
    public let rawValue: UInt

    public init(rawValue: UInt) { self.rawValue = rawValue }

    /// The element behaves as a button.
    public static let isButton = AccessibilityTraits(rawValue: 1 << 0)

    /// The element behaves as a header.
    public static let isHeader = AccessibilityTraits(rawValue: 1 << 1)

    /// The element behaves as a link.
    public static let isLink = AccessibilityTraits(rawValue: 1 << 2)

    /// The element behaves as an image.
    public static let isImage = AccessibilityTraits(rawValue: 1 << 3)

    /// The element is currently selected.
    public static let isSelected = AccessibilityTraits(rawValue: 1 << 4)

    /// The element is static (non-interactive) text.
    public static let isStaticText = AccessibilityTraits(rawValue: 1 << 5)

    /// The element plays a sound.
    public static let playsSound = AccessibilityTraits(rawValue: 1 << 6)

    /// The element is a search field.
    public static let isSearchField = AccessibilityTraits(rawValue: 1 << 7)

    /// The element is a summary element.
    public static let isSummaryElement = AccessibilityTraits(rawValue: 1 << 8)
}
