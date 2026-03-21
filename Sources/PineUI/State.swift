// State.swift — Reactive state for PineUI views.
//
// Usage:
//   @PineState var count = 0
//   ReactiveButton(state: $count, label: { "\($0)" }) { count += 1 }
//
//   // Or directly:
//   let count = StateStore<Int>(0)
//   ReactiveButton(state: count, label: { "\($0)" }) { count.value += 1 }

import CGTK4

// MARK: - @PineState property wrapper

/// A property wrapper that provides SwiftUI-like @State semantics.
/// The wrappedValue gives direct access to the value,
/// and projectedValue ($name) gives the underlying StateStore.
@propertyWrapper
public struct PineState<Value> {
    private let store: StateStore<Value>

    public init(wrappedValue: Value) {
        self.store = StateStore(wrappedValue)
    }

    public var wrappedValue: Value {
        get { store.value }
        nonmutating set { store.value = newValue }
    }

    /// Access the underlying StateStore via $name syntax.
    public var projectedValue: StateStore<Value> { store }
}

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

// MARK: - ReactiveView

/// A view container that rebuilds its content when state changes.
/// This is the most powerful reactive primitive — any view tree
/// inside it will be torn down and rebuilt on state change.
public struct ReactiveView<Value>: View, GTKRenderable {
    let state: StateStore<Value>
    let builder: (Value) -> WidgetPtr

    public init<V: View>(state: StateStore<Value>, @ViewBuilder content: @escaping (Value) -> V) {
        self.state = state
        self.builder = { value in render(content(value)) }
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let container = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 0)
        setHExpand(container)
        setVExpand(container)
        reactive(in: container, state: state, build: builder)
        return container
    }
}

// MARK: - ReactiveText

/// A text label that updates when state changes.
public struct ReactiveText<Value>: View, GTKRenderable {
    let state: StateStore<Value>
    let formatter: (Value) -> String
    var cssClasses: [String] = []

    public init(state: StateStore<Value>, _ formatter: @escaping (Value) -> String) {
        self.state = state
        self.formatter = formatter
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let label = makeLabel(formatter(state.value))
        for cls in cssClasses { addCssClass(label, cls) }

        let labelPtr = label
        state.onChange = { newValue in
            gtk_label_set_text(OpaquePointer(labelPtr), self.formatter(newValue))
        }
        return label
    }

    public func font(_ style: Font) -> ReactiveText {
        var copy = self
        copy.cssClasses.append(style.cssClass)
        return copy
    }

    public func foregroundStyle(_ style: ForegroundStyle) -> ReactiveText {
        var copy = self
        copy.cssClasses.append(style.cssClass)
        return copy
    }
}

// MARK: - SearchField

/// A search text input with icon — like macOS search fields.
public struct SearchField: View, GTKRenderable {
    let placeholder: String
    let onSearch: ((String) -> Void)?

    public init(_ placeholder: String = "Search...", onSearch: ((String) -> Void)? = nil) {
        self.placeholder = placeholder
        self.onSearch = onSearch
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let entry = gtk_search_entry_new()!

        // Set placeholder.
        let e = OpaquePointer(entry)
        gtk_editable_set_text(e, "")

        // Connect search-changed signal.
        if let onSearch = onSearch {
            let handler = SearchHandler(onSearch: onSearch)
            let ptr = Unmanaged.passRetained(handler).toOpaque()
            let callback: @convention(c) (OpaquePointer?, gpointer?) -> Void = { searchEntry, userData in
                guard let searchEntry = searchEntry, let userData = userData else { return }
                let text = String(cString: gtk_editable_get_text(searchEntry))
                Unmanaged<SearchHandler>.fromOpaque(userData).takeUnretainedValue().onSearch(text)
            }
            g_signal_connect_data(
                UnsafeMutableRawPointer(entry), "search-changed",
                unsafeBitCast(callback, to: GCallback.self),
                ptr, { userData, _ in
                    guard let userData = userData else { return }
                    Unmanaged<SearchHandler>.fromOpaque(userData).release()
                }, GConnectFlags(rawValue: 0)
            )
        }

        return entry
    }
}

private class SearchHandler {
    let onSearch: (String) -> Void
    init(onSearch: @escaping (String) -> Void) { self.onSearch = onSearch }
}

// MARK: - Menu

/// A popover menu triggered by a button — like macOS menus.
public struct MenuButton: View, GTKRenderable {
    let title: String
    let icon: String?
    let items: [MenuItem]

    public init(_ title: String, icon: String? = nil, items: [MenuItem]) {
        self.title = title
        self.icon = icon
        self.items = items
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let menuButton = gtk_menu_button_new()!

        if let icon = icon {
            let img = makeImage(iconName: resolveSFSymbol(icon))
            gtk_menu_button_set_child(OpaquePointer(menuButton), img)
        } else {
            let label = makeLabel(title)
            gtk_menu_button_set_child(OpaquePointer(menuButton), label)
        }

        // Build GMenu.
        let menu = g_menu_new()!
        for item in items {
            let menuItem = g_menu_item_new(item.title, nil)!
            g_menu_append_item(menu, menuItem)
            g_object_unref(gpointer(menuItem))
        }

        let menuModel: UnsafeMutablePointer<GMenuModel> = typed(UnsafeMutableRawPointer(menu).assumingMemoryBound(to: GtkWidget.self))
        let popover = gtk_popover_menu_new_from_model(menuModel)!
        let pop: UnsafeMutablePointer<_GtkPopover> = typed(popover)
        gtk_menu_button_set_popover(OpaquePointer(menuButton), UnsafeMutableRawPointer(pop).assumingMemoryBound(to: GtkWidget.self))
        g_object_unref(gpointer(menu))

        buttonSetHasFrame(menuButton, hasFrame: false)
        return menuButton
    }
}

public struct MenuItem {
    public let title: String
    public let icon: String?
    public let action: (() -> Void)?

    public init(_ title: String, icon: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.icon = icon
        self.action = action
    }
}

// MARK: - Popover

/// Show a popover attached to a widget.
public func showPopover<V: View>(
    on widget: WidgetPtr,
    @ViewBuilder content: () -> V
) {
    let popover = gtk_popover_new()!
    let contentWidget = render(content())
    setMargins(contentWidget, start: 12, end: 12, top: 12, bottom: 12)
    let pop: UnsafeMutablePointer<_GtkPopover> = typed(popover)
    gtk_popover_set_child(pop, contentWidget)
    gtk_widget_set_parent(popover, widget)
    gtk_popover_popup(pop)
}
