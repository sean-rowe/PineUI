// LifecycleModifiers.swift — SwiftUI-compatible lifecycle modifiers for PineUI.
//
// Implements 7 lifecycle modifiers:
//   onAppear, onDisappear, onChange(of:perform:), task, id, tag, equatable

import CGTK4

// MARK: - Handler

private class LifecycleHandler {
    let action: () -> Void
    init(action: @escaping () -> Void) { self.action = action }
}

// MARK: - Lifecycle Modifiers

extension View {

    // MARK: 1. onAppear

    /// Called when the view appears (GTK4 "map" signal).
    public func onAppear(perform action: @escaping () -> Void) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            let handler = LifecycleHandler(action: action)
            let ptr = Unmanaged.passRetained(handler).toOpaque()
            let callback: @convention(c) (WidgetPtr?, gpointer?) -> Void = { _, userData in
                guard let userData = userData else { return }
                Unmanaged<LifecycleHandler>.fromOpaque(userData).takeUnretainedValue().action()
            }
            g_signal_connect_data(
                UnsafeMutableRawPointer(w), "map",
                unsafeBitCast(callback, to: GCallback.self),
                ptr, { userData, _ in
                    guard let userData = userData else { return }
                    Unmanaged<LifecycleHandler>.fromOpaque(userData).release()
                }, GConnectFlags(rawValue: 0)
            )
        }
    }

    // MARK: 2. onDisappear

    /// Called when the view disappears (GTK4 "unmap" signal).
    public func onDisappear(perform action: @escaping () -> Void) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            let handler = LifecycleHandler(action: action)
            let ptr = Unmanaged.passRetained(handler).toOpaque()
            let callback: @convention(c) (WidgetPtr?, gpointer?) -> Void = { _, userData in
                guard let userData = userData else { return }
                Unmanaged<LifecycleHandler>.fromOpaque(userData).takeUnretainedValue().action()
            }
            g_signal_connect_data(
                UnsafeMutableRawPointer(w), "unmap",
                unsafeBitCast(callback, to: GCallback.self),
                ptr, { userData, _ in
                    guard let userData = userData else { return }
                    Unmanaged<LifecycleHandler>.fromOpaque(userData).release()
                }, GConnectFlags(rawValue: 0)
            )
        }
    }

    // MARK: 3. onChange(of:perform:)

    /// Observes changes on a StateStore and calls the action with the new value.
    ///
    /// Sets `store.onChange` on the underlying StateStore so the action fires
    /// whenever the store's value mutates.
    public func onChange<Value>(
        of store: StateStore<Value>,
        perform action: @escaping (Value) -> Void
    ) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            store.onChange = { newValue in action(newValue) }
        }
    }

    // MARK: 4. task

    /// Runs a synchronous action when the view appears.
    ///
    /// Alias for onAppear — SwiftUI's .task runs async on appear;
    /// we simplify to sync on GTK4 "map".
    public func task(perform action: @escaping () -> Void) -> ModifiedView<Self> {
        onAppear(perform: action)
    }

    // MARK: 5. id

    /// Sets a unique string identifier on the widget via `gtk_widget_set_name`.
    public func id(_ identifier: String) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            gtk_widget_set_name(w, identifier)
        }
    }

    // MARK: 6. tag

    /// Attaches an integer tag to the widget via `g_object_set_data`.
    ///
    /// The tag is stored under the key "pine-tag" and can be retrieved
    /// via `g_object_get_data(widget, "pine-tag")`.
    public func tag(_ value: Int) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            g_object_set_data(
                UnsafeMutableRawPointer(w).assumingMemoryBound(to: GObject.self),
                "pine-tag",
                UnsafeMutableRawPointer(bitPattern: value)
            )
        }
    }

    // MARK: 7. equatable (stub)

    /// Marks this view as equatable for optimization purposes.
    // STUB: no GTK4 equivalent — SwiftUI uses this to skip re-renders when inputs
    // haven't changed; GTK4 does not have a comparable diffing mechanism.
    public func equatable() -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: no GTK4 equivalent
        }
    }
}
