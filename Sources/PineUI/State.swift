// State.swift — Reactive state for PineUI views.
//
// Usage:
//   class MyState: ObservableObject {
//       var count = 0
//   }
//
//   let state = MyState()
//   Button("Count: \(state.count)") { state.count += 1 }

import CGTK4

// MARK: - Binding

/// A two-way reference to a mutable value.
/// Mirrors SwiftUI's Binding type.
public struct Binding<Value> {
    public let get: () -> Value
    public let set: (Value) -> Void

    public init(get: @escaping () -> Value, set: @escaping (Value) -> Void) {
        self.get = get
        self.set = set
    }

    public var wrappedValue: Value {
        get { get() }
        nonmutating set { set(newValue) }
    }
}

// MARK: - StateStore

/// Reference-type wrapper around a value that notifies on change.
/// This is what powers reactive updates — when the value changes,
/// the onChange callback triggers a widget rebuild.
public class StateStore<Value> {
    public var value: Value {
        didSet { onChange?(value) }
    }
    public var onChange: ((Value) -> Void)?

    public init(_ initial: Value) {
        self.value = initial
    }

    /// Create a Binding to this store's value.
    public var binding: Binding<Value> {
        Binding(
            get: { [weak self] in self!.value },
            set: { [weak self] in self?.value = $0 }
        )
    }
}

// MARK: - Reactive widget helpers

/// Replace a widget's content when state changes.
/// Removes the old child and appends a new one built from the closure.
public func reactive<Value>(
    in container: WidgetPtr,
    state: StateStore<Value>,
    build: @escaping (Value) -> WidgetPtr
) {
    // Initial render.
    let initial = build(state.value)
    boxAppend(container, child: initial)

    var currentChild = initial

    state.onChange = { newValue in
        // Remove old child, add new one.
        let parent = UnsafeMutableRawPointer(container).assumingMemoryBound(to: _GtkBox.self)
        gtk_box_remove(parent, currentChild)
        let newChild = build(newValue)
        gtk_box_append(parent, newChild)
        currentChild = newChild
    }
}

// MARK: - Toggle with Binding

/// A toggle switch bound to reactive state.
public struct ReactiveToggle: View, GTKRenderable {
    let title: String
    let state: StateStore<Bool>

    public init(_ title: String, isOn: StateStore<Bool>) {
        self.title = title
        self.state = isOn
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let row = makeBox(GTK_ORIENTATION_HORIZONTAL, spacing: 8)
        setHExpand(row)

        let label = makeLabel(title)
        setHExpand(label)
        setHAlign(label, align: GTK_ALIGN_START)
        boxAppend(row, child: label)

        let toggle = gtk_switch_new()!
        gtk_switch_set_active(OpaquePointer(toggle), state.value ? 1 : 0)

        // Connect state-set signal.
        let stateRef = Unmanaged.passRetained(state).toOpaque()
        let callback: @convention(c) (OpaquePointer?, gboolean, gpointer?) -> gboolean = { sw, newState, userData in
            guard let userData = userData else { return 0 }
            let store = Unmanaged<StateStore<Bool>>.fromOpaque(userData).takeUnretainedValue()
            store.value = newState != 0
            return 0
        }
        g_signal_connect_data(
            UnsafeMutableRawPointer(toggle), "state-set",
            unsafeBitCast(callback, to: GCallback.self),
            stateRef, { userData, _ in
                guard let userData = userData else { return }
                Unmanaged<StateStore<Bool>>.fromOpaque(userData).release()
            }, GConnectFlags(rawValue: 0)
        )

        boxAppend(row, child: toggle)
        return row
    }
}

// MARK: - Reactive Button

/// A button that rebuilds its label when state changes.
public struct ReactiveButton<Value>: View, GTKRenderable {
    let state: StateStore<Value>
    let labelBuilder: (Value) -> String
    let action: () -> Void

    public init(
        state: StateStore<Value>,
        label: @escaping (Value) -> String,
        action: @escaping () -> Void
    ) {
        self.state = state
        self.labelBuilder = label
        self.action = action
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let btn = gtk_button_new_with_label(labelBuilder(state.value))!

        // Connect click.
        let handler = ReactiveClickHandler(action: action)
        let ptr = Unmanaged.passRetained(handler).toOpaque()
        let callback: @convention(c) (UnsafeMutablePointer<_GtkButton>?, gpointer?) -> Void = { _, userData in
            guard let userData = userData else { return }
            Unmanaged<ReactiveClickHandler>.fromOpaque(userData).takeUnretainedValue().action()
        }
        g_signal_connect_data(
            UnsafeMutableRawPointer(btn), "clicked",
            unsafeBitCast(callback, to: GCallback.self),
            ptr, { userData, _ in
                guard let userData = userData else { return }
                Unmanaged<ReactiveClickHandler>.fromOpaque(userData).release()
            }, GConnectFlags(rawValue: 0)
        )

        // Update label when state changes.
        let btnPtr = btn
        state.onChange = { newValue in
            let b = UnsafeMutableRawPointer(btnPtr).assumingMemoryBound(to: _GtkButton.self)
            gtk_button_set_label(b, self.labelBuilder(newValue))
        }

        return btn
    }
}

private class ReactiveClickHandler {
    let action: () -> Void
    init(action: @escaping () -> Void) { self.action = action }
}
