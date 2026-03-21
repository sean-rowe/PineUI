// InteractionModifiers.swift — SwiftUI-compatible interaction modifiers for PineUI.
//
// Implements 20 interaction modifiers:
//   onLongPressGesture, gesture, highPriorityGesture, simultaneousGesture,
//   allowsHitTesting, contentShape, hoverEffect, onHover, focusable, focused,
//   defaultFocus, prefersDefaultFocus, onKeyPress, onSubmit, swipeActions,
//   selectionDisabled, onDrag, onDrop, draggable, dropDestination

import CGTK4

// MARK: - Handler Classes

/// Handler for long-press gestures.
private class LongPressHandler {
    let action: () -> Void
    init(action: @escaping () -> Void) { self.action = action }
}

/// Handler for hover (enter/leave) events.
private class HoverHandler {
    let onEnter: () -> Void
    let onLeave: () -> Void
    init(onEnter: @escaping () -> Void, onLeave: @escaping () -> Void) {
        self.onEnter = onEnter
        self.onLeave = onLeave
    }
}

/// Handler for key-press events.
private class KeyPressHandler {
    let action: (UInt32) -> Bool
    init(action: @escaping (UInt32) -> Bool) { self.action = action }
}

/// Handler for submit (activate) events.
private class SubmitHandler {
    let action: () -> Void
    init(action: @escaping () -> Void) { self.action = action }
}

/// Handler for focus-on-map events.
private class FocusHandler {
    let widget: WidgetPtr
    init(widget: WidgetPtr) { self.widget = widget }
}

// MARK: - Interaction Modifiers

extension View {

    // MARK: 1. onLongPressGesture

    /// Adds a long-press gesture to the view.
    ///
    /// Uses `GtkGestureLongPress` and connects the "pressed" signal.
    public func onLongPressGesture(perform action: @escaping () -> Void) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            let gesture = gtk_gesture_long_press_new()!
            gtk_event_controller_set_propagation_phase(gesture, GTK_PHASE_BUBBLE)
            let handler = LongPressHandler(action: action)
            let ptr = Unmanaged.passRetained(handler).toOpaque()
            let callback: @convention(c) (OpaquePointer?, Double, Double, gpointer?) -> Void = {
                _, _, _, userData in
                guard let userData = userData else { return }
                Unmanaged<LongPressHandler>.fromOpaque(userData).takeUnretainedValue().action()
            }
            g_signal_connect_data(
                UnsafeMutableRawPointer(gesture), "pressed",
                unsafeBitCast(callback, to: GCallback.self),
                ptr,
                { userData, _ in
                    guard let userData = userData else { return }
                    Unmanaged<LongPressHandler>.fromOpaque(userData).release()
                },
                GConnectFlags(rawValue: 0)
            )
            gtk_widget_add_controller(w, gesture)
        }
    }

    // MARK: 2. gesture

    /// Attaches a pre-configured GTK gesture (OpaquePointer) to the view.
    public func gesture(_ gesture: OpaquePointer) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            gtk_widget_add_controller(w, gesture)
        }
    }

    // MARK: 3. highPriorityGesture

    /// Attaches a gesture with capture-phase propagation (fires before children).
    public func highPriorityGesture(_ gesture: OpaquePointer) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            gtk_event_controller_set_propagation_phase(gesture, GTK_PHASE_CAPTURE)
            gtk_widget_add_controller(w, gesture)
        }
    }

    // MARK: 4. simultaneousGesture

    /// Attaches a gesture alongside existing gestures without replacing them.
    public func simultaneousGesture(_ gesture: OpaquePointer) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            gtk_widget_add_controller(w, gesture)
        }
    }

    // MARK: 5. allowsHitTesting

    /// Controls whether the view participates in hit testing.
    ///
    /// When `false`, pointer events pass through to widgets below.
    public func allowsHitTesting(_ enabled: Bool) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            gtk_widget_set_can_target(w, enabled ? 1 : 0)
        }
    }

    // MARK: 6. contentShape

    /// Defines the hit-testing shape of the view.
    // STUB: no GTK4 equivalent — GTK4 uses rectangular hit regions only.
    public func contentShape(_ shape: ClipShape) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: no GTK4 equivalent — GTK4 hit testing is always rectangular.
        }
    }

    // MARK: 7. hoverEffect

    /// Applies a visual effect when the pointer hovers over the view.
    ///
    /// NOTE: CSS pseudo-classes cannot be injected via applyCss (which uses
    /// class-scoped rules). This adds a semantic CSS class for theme styling.
    public func hoverEffect(_ effect: HoverEffect = .automatic) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            switch effect {
            case .automatic:
                addCssClass(w, "hover-highlight")
            case .lift:
                addCssClass(w, "hover-lift")
            case .none:
                break
            }
        }
    }

    // MARK: 8. onHover

    /// Calls `perform` with `true` when the pointer enters and `false` when it leaves.
    ///
    /// Uses `GtkEventControllerMotion` — "enter" fires with (controller, x, y, userData),
    /// "leave" fires with (controller, userData).
    public func onHover(perform action: @escaping (Bool) -> Void) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            let controller = gtk_event_controller_motion_new()!
            let handler = HoverHandler(
                onEnter: { action(true) },
                onLeave: { action(false) }
            )

            // "enter" callback: (OpaquePointer?, Double, Double, gpointer?) -> Void
            let enterCallback: @convention(c) (
                OpaquePointer?, Double, Double, gpointer?
            ) -> Void = { _, _, _, userData in
                guard let userData = userData else { return }
                Unmanaged<HoverHandler>.fromOpaque(userData).takeUnretainedValue().onEnter()
            }

            // "leave" callback: (OpaquePointer?, gpointer?) -> Void
            let leaveCallback: @convention(c) (
                OpaquePointer?, gpointer?
            ) -> Void = { _, userData in
                guard let userData = userData else { return }
                Unmanaged<HoverHandler>.fromOpaque(userData).takeUnretainedValue().onLeave()
            }

            // Retain once per signal connection so each can release independently.
            let enterPtr = Unmanaged.passRetained(handler).toOpaque()
            let leavePtr = Unmanaged.passRetained(handler).toOpaque()

            g_signal_connect_data(
                UnsafeMutableRawPointer(controller), "enter",
                unsafeBitCast(enterCallback, to: GCallback.self),
                enterPtr,
                { userData, _ in
                    guard let userData = userData else { return }
                    Unmanaged<HoverHandler>.fromOpaque(userData).release()
                },
                GConnectFlags(rawValue: 0)
            )
            g_signal_connect_data(
                UnsafeMutableRawPointer(controller), "leave",
                unsafeBitCast(leaveCallback, to: GCallback.self),
                leavePtr,
                { userData, _ in
                    guard let userData = userData else { return }
                    Unmanaged<HoverHandler>.fromOpaque(userData).release()
                },
                GConnectFlags(rawValue: 0)
            )

            gtk_widget_add_controller(w, controller)
        }
    }

    // MARK: 9. focusable

    /// Controls whether the view can receive keyboard focus.
    public func focusable(_ canFocus: Bool = true) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            gtk_widget_set_focusable(w, canFocus ? 1 : 0)
        }
    }

    // MARK: 10. focused

    /// Requests focus for this view when it maps to the screen.
    ///
    /// Connects a one-shot "map" signal; calls `gtk_widget_grab_focus` when `isFocused` is true.
    public func focused(_ isFocused: Bool) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            guard isFocused else { return }
            // Capture a raw pointer for use in the C callback (no Unmanaged needed
            // since the widget lifetime is managed by GTK).
            let rawWidget = UnsafeMutableRawPointer(w)
            let mapCallback: @convention(c) (WidgetPtr?, gpointer?) -> Void = { widget, _ in
                guard let widget = widget else { return }
                gtk_widget_grab_focus(widget)
            }
            g_signal_connect_data(
                rawWidget, "map",
                unsafeBitCast(mapCallback, to: GCallback.self),
                nil, nil,
                GConnectFlags(rawValue: 0)
            )
        }
    }

    // MARK: 11. defaultFocus

    /// Marks this view as the default focus target in its container.
    // STUB: no GTK4 equivalent — default focus is managed at the window level.
    public func defaultFocus() -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: no GTK4 equivalent — use gtk_window_set_default_widget at the window level.
        }
    }

    // MARK: 12. prefersDefaultFocus

    /// Hints that this view prefers to receive default focus.
    // STUB: no GTK4 equivalent — GTK4 does not have per-widget default focus preference.
    public func prefersDefaultFocus(_ prefers: Bool = true) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: no GTK4 equivalent
        }
    }

    // MARK: 13. onKeyPress

    /// Calls `perform` when a key is pressed while this view has focus.
    ///
    /// Uses `GtkEventControllerKey`. The callback receives the GTK keyval.
    /// Return `true` from `perform` to consume the event (stop propagation).
    public func onKeyPress(perform action: @escaping (UInt32) -> Bool) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            let controller = gtk_event_controller_key_new()!
            let handler = KeyPressHandler(action: action)
            let ptr = Unmanaged.passRetained(handler).toOpaque()

            // key-pressed callback: (OpaquePointer?, guint, guint, GdkModifierType, gpointer?) -> gboolean
            let callback: @convention(c) (
                OpaquePointer?, guint, guint, GdkModifierType, gpointer?
            ) -> gboolean = { _, keyval, _, _, userData in
                guard let userData = userData else { return 0 }
                let handled = Unmanaged<KeyPressHandler>.fromOpaque(userData)
                    .takeUnretainedValue().action(keyval)
                return handled ? 1 : 0
            }

            g_signal_connect_data(
                UnsafeMutableRawPointer(controller), "key-pressed",
                unsafeBitCast(callback, to: GCallback.self),
                ptr,
                { userData, _ in
                    guard let userData = userData else { return }
                    Unmanaged<KeyPressHandler>.fromOpaque(userData).release()
                },
                GConnectFlags(rawValue: 0)
            )

            gtk_widget_add_controller(w, controller)
        }
    }

    // MARK: 14. onSubmit

    /// Calls `perform` when the user submits (e.g. presses Return in a text field).
    ///
    /// Connects the GTK "activate" signal on the widget.
    public func onSubmit(perform action: @escaping () -> Void) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            let handler = SubmitHandler(action: action)
            let ptr = Unmanaged.passRetained(handler).toOpaque()
            let callback: @convention(c) (WidgetPtr?, gpointer?) -> Void = { _, userData in
                guard let userData = userData else { return }
                Unmanaged<SubmitHandler>.fromOpaque(userData).takeUnretainedValue().action()
            }
            g_signal_connect_data(
                UnsafeMutableRawPointer(w), "activate",
                unsafeBitCast(callback, to: GCallback.self),
                ptr,
                { userData, _ in
                    guard let userData = userData else { return }
                    Unmanaged<SubmitHandler>.fromOpaque(userData).release()
                },
                GConnectFlags(rawValue: 0)
            )
        }
    }

    // MARK: 15. swipeActions

    /// Adds swipe actions to a list row.
    // STUB: no GTK4 equivalent — swipe actions require AdwActionRow from libadwaita.
    public func swipeActions<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> ModifiedView<Self> {
        let _ = content()
        return ModifiedView(content: self) { _ in
            // STUB: no GTK4 equivalent — swipe actions require libadwaita AdwActionRow.
        }
    }

    // MARK: 16. selectionDisabled

    /// Disables selection for this view or its children.
    // STUB: no GTK4 equivalent — selection behavior is list/model-level, not widget-level.
    public func selectionDisabled(_ disabled: Bool = true) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: no GTK4 equivalent — selection is managed by GtkSelectionModel.
        }
    }

    // MARK: 17. onDrag

    /// Provides data for a drag operation initiated from this view.
    // STUB: GtkDragSource setup is complex; full drag-and-drop requires content providers.
    public func onDrag(data: @escaping () -> String) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: GtkDragSource is complex — requires GdkContentProvider and type registration.
        }
    }

    // MARK: 18. onDrop

    /// Handles items dropped onto this view.
    // STUB: GtkDropTarget setup is complex; full drag-and-drop requires type registration.
    public func onDrop(perform action: @escaping ([String]) -> Bool) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: GtkDropTarget is complex — requires GdkContentFormats and type negotiation.
        }
    }

    // MARK: 19. draggable

    /// Makes this view draggable.
    // STUB: GtkDragSource requires GdkContentProvider — complex setup deferred.
    public func draggable() -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: GtkDragSource requires GdkContentProvider — see onDrag stub.
        }
    }

    // MARK: 20. dropDestination

    /// Makes this view a drop destination for items of a given type.
    // STUB: GtkDropTarget requires GdkContentFormats — complex setup deferred.
    public func dropDestination<T>(
        for type: T.Type,
        action: @escaping ([T], CGPoint) -> Bool
    ) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: GtkDropTarget requires GdkContentFormats — see onDrop stub.
        }
    }
}

// MARK: - Supporting Types

/// Visual effects for the hoverEffect modifier, matching SwiftUI's HoverEffect.
public enum HoverEffect {
    case automatic
    case lift
    case none
}

/// A point in 2D space, matching CGPoint for API compatibility.
public struct CGPoint {
    public let x: Double
    public let y: Double
    public init(x: Double = 0, y: Double = 0) { self.x = x; self.y = y }
}
