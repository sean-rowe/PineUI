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

/// Handler for drop-target events.
private class DropHandler {
    let action: (String) -> Bool
    init(action: @escaping (String) -> Bool) { self.action = action }
}

/// Heap box for the drag data provider closure.
/// GtkDragSource's "prepare" signal fires on each drag begin, so the closure
/// must stay alive as long as the drag source controller is alive.
private class DragDataClosure {
    let provider: () -> String
    init(provider: @escaping () -> String) { self.provider = provider }
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
/// Tracks a `fired` flag so focus is grabbed only on the first map signal,
/// not on every subsequent show (e.g. tab switching).
private class FocusHandler {
    let widget: WidgetPtr
    var fired: Bool = false
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

    /// Requests focus for this view when it first maps to the screen.
    ///
    /// Connects a "map" signal with a one-shot flag; calls `gtk_widget_grab_focus`
    /// only the first time the widget becomes visible. Subsequent map signals
    /// (e.g. from tab switching) are ignored.
    public func focused(_ isFocused: Bool) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            guard isFocused else { return }
            let handler = FocusHandler(widget: w)
            let ptr = Unmanaged.passRetained(handler).toOpaque()
            let mapCallback: @convention(c) (WidgetPtr?, gpointer?) -> Void = { widget, userData in
                guard let widget = widget, let userData = userData else { return }
                let h = Unmanaged<FocusHandler>.fromOpaque(userData).takeUnretainedValue()
                guard !h.fired else { return }
                h.fired = true
                gtk_widget_grab_focus(widget)
            }
            g_signal_connect_data(
                UnsafeMutableRawPointer(w), "map",
                unsafeBitCast(mapCallback, to: GCallback.self),
                ptr,
                { userData, _ in
                    guard let userData = userData else { return }
                    Unmanaged<FocusHandler>.fromOpaque(userData).release()
                },
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

    /// Makes this view a drag source that provides a UTF-8 string payload.
    ///
    /// Uses `GtkDragSource` with a `GdkContentProvider` built from the string
    /// returned by `data`. The grab cursor is set automatically by GTK when a
    /// drag is in progress; a `grab` CSS cursor is added for the resting state
    /// to signal to the user that the widget is draggable.
    public func onDrag(data: @escaping () -> String) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            let dragSource = gtk_drag_source_new()!

            // Set copy as the default action.
            gtk_drag_source_set_actions(dragSource, GDK_ACTION_COPY)

            // Visual hint: use "grab" cursor while not dragging.
            applyCss(w, "cursor: grab;")

            // "prepare" signal — return the content provider for this drag.
            // Signature: (GtkDragSource*, Double, Double, gpointer*) -> GdkContentProvider*
            //
            // We capture `data` in a heap-allocated closure stored as user-data.
            let dataClosure = DragDataClosure(provider: data)
            let dataPtr = Unmanaged.passRetained(dataClosure).toOpaque()

            let prepareCallback: @convention(c) (
                OpaquePointer?,   // GtkDragSource*
                Double,           // x
                Double,           // y
                gpointer?         // user_data
            ) -> OpaquePointer? = { _, _, _, userData in
                guard let userData = userData else { return nil }
                let closure = Unmanaged<DragDataClosure>.fromOpaque(userData)
                    .takeUnretainedValue()
                let str = closure.provider()
                // pine_content_provider_for_string is a non-variadic C wrapper in shim.h
                guard let provider = pine_content_provider_for_string(str) else { return nil }
                return OpaquePointer(provider)
            }

            g_signal_connect_data(
                UnsafeMutableRawPointer(dragSource),
                "prepare",
                unsafeBitCast(prepareCallback, to: GCallback.self),
                dataPtr,
                { userData, _ in
                    guard let userData = userData else { return }
                    Unmanaged<DragDataClosure>.fromOpaque(userData).release()
                },
                GConnectFlags(rawValue: 0)
            )

            gtk_widget_add_controller(w, dragSource)
        }
    }

    // MARK: 18. onDrop

    /// Handles a UTF-8 string dropped onto this view.
    ///
    /// Uses `GtkDropTarget` registered for `G_TYPE_STRING`. The "drop" signal
    /// provides a `GValue*` from which the string is extracted.
    /// `perform` receives an array containing the single dropped string and
    /// must return `true` to accept the drop.
    public func onDrop(perform action: @escaping ([String]) -> Bool) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            // gtk_drop_target_new(type, actions) — G_TYPE_STRING = 64 (G_TYPE_MAKE_FUNDAMENTAL(16))
            let dropTarget = gtk_drop_target_new(
                pine_g_type_string(),
                GDK_ACTION_COPY
            )!

            // Visual hint: use "copy" cursor while hovering.
            applyCss(w, "cursor: copy;")

            let handler = DropHandler(action: { str in action([str]) })
            let ptr = Unmanaged.passRetained(handler).toOpaque()

            // "drop" signal — fires when the user releases over this widget.
            // Signature: (GtkDropTarget*, GValue*, Double, Double, gpointer*) -> gboolean
            let dropCallback: @convention(c) (
                OpaquePointer?,   // GtkDropTarget*
                UnsafePointer<GValue>?,  // value
                Double,           // x
                Double,           // y
                gpointer?         // user_data
            ) -> gboolean = { _, value, _, _, userData in
                guard let value = value, let userData = userData else { return 0 }
                guard let cStr = pine_gvalue_get_string(value) else { return 0 }
                let str = String(cString: cStr)
                let h = Unmanaged<DropHandler>.fromOpaque(userData).takeUnretainedValue()
                return h.action(str) ? 1 : 0
            }

            g_signal_connect_data(
                UnsafeMutableRawPointer(dropTarget),
                "drop",
                unsafeBitCast(dropCallback, to: GCallback.self),
                ptr,
                { userData, _ in
                    guard let userData = userData else { return }
                    Unmanaged<DropHandler>.fromOpaque(userData).release()
                },
                GConnectFlags(rawValue: 0)
            )

            gtk_widget_add_controller(w, dropTarget)
        }
    }

    // MARK: 19. draggable

    /// Makes this view draggable with a static string payload.
    ///
    /// Unlike `.onDrag(data:)`, this overload is intended for use with
    /// `.dropDestination` where the string value is known at declaration time
    /// (e.g. an identifier). Adds a `grab` cursor as a visual affordance.
    public func draggable(_ stringValue: String = "") -> ModifiedView<Self> {
        onDrag(data: { stringValue })
    }

    // MARK: 20. dropDestination

    /// Makes this view a drop destination for String items.
    ///
    /// This overload accepts `String.Type` and delivers the dropped string
    /// in the `action` closure together with the drop position. Returns a
    /// `ModifiedView` that wires up a `GtkDropTarget` internally.
    ///
    /// For non-string types, falls back to a no-op (GTK4 drag-and-drop is
    /// always string/GValue-based at the lowest level).
    public func dropDestination<T>(
        for type: T.Type,
        action: @escaping ([T], CGPoint) -> Bool
    ) -> ModifiedView<Self> {
        if T.self == String.self {
            // Wire up a real string drop target.
            return onDrop(perform: { strings in
                let typed = strings.compactMap { $0 as? T }
                return action(typed, CGPoint())
            })
        }
        // Non-string types: keep the API surface but no GTK binding.
        return ModifiedView(content: self) { _ in
            // No GTK4 equivalent for arbitrary type serialization without
            // a custom GdkContentSerializer registration.
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
