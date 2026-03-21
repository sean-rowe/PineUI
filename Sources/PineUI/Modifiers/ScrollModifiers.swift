// ScrollModifiers.swift — SwiftUI-compatible scroll modifiers for PineUI.
//
// Implements 6 scroll modifiers:
//   scrollIndicators, scrollDisabled, scrollDismissesKeyboard,
//   scrollPosition, scrollTargetLayout, scrollClipDisabled

import CGTK4

// MARK: - Supporting Types

/// Scroll indicator visibility, matching SwiftUI's ScrollIndicatorVisibility.
public enum ScrollIndicatorVisibility {
    /// Show indicators when the user scrolls, hide when idle (system default).
    case automatic
    /// Always show scroll indicators.
    case visible
    /// Hide indicators except when interaction begins.
    case hidden
    /// Never show scroll indicators.
    case never
}

/// Scroll dismisses keyboard mode, matching SwiftUI's ScrollDismissesKeyboardMode.
public enum ScrollDismissesKeyboardMode {
    /// System-determined behavior.
    case automatic
    /// Dismiss the keyboard immediately when scrolling begins.
    case immediately
    /// Dismiss the keyboard interactively as the user scrolls.
    case interactively
    /// Never dismiss the keyboard due to scrolling.
    case never
}

// MARK: - Scroll Modifiers

extension View {

    // MARK: 11. scrollIndicators

    /// Controls scroll indicator (scrollbar) visibility for a scrolled window widget.
    ///
    /// NOTE: The widget must be a GtkScrolledWindow for this to take effect.
    /// Passes through directly to `gtk_scrolled_window_set_policy`.
    ///
    /// - `.automatic`: `GTK_POLICY_AUTOMATIC` — show only when content overflows.
    /// - `.visible`:   `GTK_POLICY_ALWAYS` — always show the scrollbar.
    /// - `.hidden`:    `GTK_POLICY_AUTOMATIC` — same as automatic (best effort).
    /// - `.never`:     `GTK_POLICY_NEVER` — never show the scrollbar.
    public func scrollIndicators(_ visibility: ScrollIndicatorVisibility) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            let policy: GtkPolicyType
            switch visibility {
            case .automatic:
                policy = GTK_POLICY_AUTOMATIC
            case .visible:
                policy = GTK_POLICY_ALWAYS
            case .hidden:
                // GTK4 has no "hide-until-hover" policy; automatic is the closest.
                policy = GTK_POLICY_AUTOMATIC
            case .never:
                policy = GTK_POLICY_NEVER
            }
            // Apply to both axes. If the widget is not a GtkScrolledWindow this is a no-op
            // because OpaquePointer simply points to a different widget type.
            gtk_scrolled_window_set_policy(OpaquePointer(w), policy, policy)
        }
    }

    // MARK: 12. scrollDisabled

    /// Disables scrolling by setting both scroll policies to NEVER when `true`.
    ///
    /// NOTE: The widget must be a GtkScrolledWindow for this to take effect.
    public func scrollDisabled(_ disabled: Bool) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            let policy: GtkPolicyType = disabled ? GTK_POLICY_NEVER : GTK_POLICY_AUTOMATIC
            gtk_scrolled_window_set_policy(OpaquePointer(w), policy, policy)
        }
    }

    // MARK: 13. scrollDismissesKeyboard (stub)

    /// Controls how the keyboard is dismissed when the user scrolls.
    ///
    /// STUB: iOS/macOS-specific behavior. GTK4 on Linux does not have an on-screen
    /// keyboard that scrolling needs to dismiss. Retained for API compatibility.
    public func scrollDismissesKeyboard(_ mode: ScrollDismissesKeyboardMode) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: no GTK4 equivalent — on-screen keyboard management is handled
            // by the input method framework, not by individual widgets.
            _ = mode
        }
    }

    // MARK: 14. scrollPosition (stub)

    /// Binds the scroll view's position to a value identified by `id`.
    ///
    /// STUB: Requires GTK4 GtkAdjustment manipulation and a mapping from IDs
    /// to scroll offsets, which is not implemented in the current architecture.
    public func scrollPosition(id: StateStore<AnyHashable?>) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: no GTK4 equivalent — scroll position anchoring requires
            // GtkAdjustment API and a coordinate-to-ID mapping system.
            _ = id
        }
    }

    // MARK: 15. scrollTargetLayout (stub)

    /// Marks the layout as the target for scroll snapping.
    ///
    /// STUB: GTK4 does not support scroll snapping natively. This modifier is
    /// retained for API compatibility with SwiftUI.
    public func scrollTargetLayout() -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: no GTK4 equivalent — scroll target layouts require scroll-snap
            // support which is not available in GTK4's widget model.
        }
    }

    // MARK: 16. scrollClipDisabled

    /// Controls whether content clips to the scroll view's bounds.
    ///
    /// When `true`, sets `overflow: visible` via CSS so content may draw outside
    /// the scroll view's bounds (e.g., for shadows or badges that extend beyond edges).
    /// When `false`, restores the default `overflow: hidden`.
    public func scrollClipDisabled(_ disabled: Bool = true) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            if disabled {
                applyCss(w, "overflow: visible;")
            } else {
                applyCss(w, "overflow: hidden;")
            }
        }
    }
}
