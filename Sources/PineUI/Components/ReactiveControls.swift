// ReactiveControls.swift — Two-way bound controls for PineUI.
//
// These are the controls that bind to StateStore for reactive updates.
// They complement the static controls in Controls.swift and MoreControls.swift.

import CGTK4

// MARK: - Reactive Toggle (bound to StateStore<Bool>)

/// A toggle switch with two-way binding to a StateStore<Bool>.
public struct BoundToggle: View, GTKRenderable {
    let title: String
    let store: StateStore<Bool>

    public init(_ title: String, isOn: StateStore<Bool>) {
        self.title = title
        self.store = isOn
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
        gtk_switch_set_active(OpaquePointer(toggle), store.value ? 1 : 0)

        let stateRef = Unmanaged.passRetained(store).toOpaque()
        let callback: @convention(c) (OpaquePointer?, gboolean, gpointer?) -> gboolean = { _, newState, userData in
            guard let userData = userData else { return 0 }
            let s = Unmanaged<StateStore<Bool>>.fromOpaque(userData).takeUnretainedValue()
            s.value = newState != 0
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

        // Update widget when store changes externally.
        let togglePtr = toggle
        store.onChange = { newValue in
            gtk_switch_set_active(OpaquePointer(togglePtr), newValue ? 1 : 0)
        }

        boxAppend(row, child: toggle)
        return row
    }
}

// MARK: - Reactive Slider (bound to StateStore<Double>)

/// A slider with two-way binding to a StateStore<Double>.
public struct BoundSlider: View, GTKRenderable {
    let label: String?
    let store: StateStore<Double>
    let min: Double
    let max: Double
    let step: Double

    public init(_ label: String? = nil, value: StateStore<Double>, in range: ClosedRange<Double> = 0...1, step: Double = 0.01) {
        self.label = label
        self.store = value
        self.min = range.lowerBound
        self.max = range.upperBound
        self.step = step
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let row = makeBox(GTK_ORIENTATION_HORIZONTAL, spacing: 8)
        setHExpand(row)

        if let label = label {
            let lbl = makeLabel(label)
            setHAlign(lbl, align: GTK_ALIGN_START)
            boxAppend(row, child: lbl)
        }

        let scale = gtk_scale_new_with_range(GTK_ORIENTATION_HORIZONTAL, min, max, step)!
        setHExpand(scale)
        let s: UnsafeMutablePointer<_GtkScale> = typed(scale)
        gtk_scale_set_draw_value(s, 0)

        let range = UnsafeMutableRawPointer(scale).assumingMemoryBound(to: _GtkRange.self)
        gtk_range_set_value(range, store.value)

        // Connect value-changed.
        let stateRef = Unmanaged.passRetained(store).toOpaque()
        let callback: @convention(c) (UnsafeMutablePointer<_GtkRange>?, gpointer?) -> Void = { range, userData in
            guard let range = range, let userData = userData else { return }
            let val = gtk_range_get_value(range)
            Unmanaged<StateStore<Double>>.fromOpaque(userData).takeUnretainedValue().value = val
        }
        g_signal_connect_data(
            UnsafeMutableRawPointer(scale), "value-changed",
            unsafeBitCast(callback, to: GCallback.self),
            stateRef, { userData, _ in
                guard let userData = userData else { return }
                Unmanaged<StateStore<Double>>.fromOpaque(userData).release()
            }, GConnectFlags(rawValue: 0)
        )

        boxAppend(row, child: scale)
        return row
    }
}

// MARK: - Reactive Picker (bound to StateStore<Int>)

/// A dropdown picker with two-way binding to a StateStore<Int> (selected index).
public struct BoundPicker: View, GTKRenderable {
    let title: String
    let options: [String]
    let store: StateStore<Int>

    public init(_ title: String, selection: StateStore<Int>, options: [String]) {
        self.title = title
        self.options = options
        self.store = selection
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let row = makeBox(GTK_ORIENTATION_HORIZONTAL, spacing: 8)
        setHExpand(row)

        let lbl = makeLabel(title)
        setHExpand(lbl)
        setHAlign(lbl, align: GTK_ALIGN_START)
        boxAppend(row, child: lbl)

        let strs = options.map { strdup($0) } + [nil]
        let dropdown = strs.withUnsafeBufferPointer { buf -> WidgetPtr in
            let raw = UnsafeMutablePointer<UnsafePointer<CChar>?>.allocate(capacity: strs.count)
            for (i, s) in buf.enumerated() { raw[i] = UnsafePointer(s) }
            let dd = gtk_drop_down_new_from_strings(raw)!
            raw.deallocate()
            return dd
        }
        for s in strs { if let s = s { free(s) } }

        gtk_drop_down_set_selected(OpaquePointer(dropdown), guint(store.value))

        // Connect notify::selected.
        let stateRef = Unmanaged.passRetained(store).toOpaque()
        let callback: @convention(c) (OpaquePointer?, OpaquePointer?, gpointer?) -> Void = { dd, _, userData in
            guard let dd = dd, let userData = userData else { return }
            let idx = gtk_drop_down_get_selected(dd)
            Unmanaged<StateStore<Int>>.fromOpaque(userData).takeUnretainedValue().value = Int(idx)
        }
        g_signal_connect_data(
            UnsafeMutableRawPointer(dropdown), "notify::selected",
            unsafeBitCast(callback, to: GCallback.self),
            stateRef, { userData, _ in
                guard let userData = userData else { return }
                Unmanaged<StateStore<Int>>.fromOpaque(userData).release()
            }, GConnectFlags(rawValue: 0)
        )

        boxAppend(row, child: dropdown)
        return row
    }
}

// MARK: - Reactive TextField (bound to StateStore<String>)

/// A text field with two-way binding to a StateStore<String>.
public struct BoundTextField: View, GTKRenderable {
    let placeholder: String
    let store: StateStore<String>

    public init(_ placeholder: String, text: StateStore<String>) {
        self.placeholder = placeholder
        self.store = text
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let entry = gtk_entry_new()!
        let e = UnsafeMutableRawPointer(entry).assumingMemoryBound(to: _GtkEntry.self)
        gtk_entry_set_placeholder_text(e, placeholder)

        // Set initial text.
        let editable = OpaquePointer(entry)
        gtk_editable_set_text(editable, store.value)

        // Connect changed signal.
        let stateRef = Unmanaged.passRetained(store).toOpaque()
        let callback: @convention(c) (OpaquePointer?, gpointer?) -> Void = { editable, userData in
            guard let editable = editable, let userData = userData else { return }
            let text = String(cString: gtk_editable_get_text(editable))
            Unmanaged<StateStore<String>>.fromOpaque(userData).takeUnretainedValue().value = text
        }
        g_signal_connect_data(
            UnsafeMutableRawPointer(entry), "changed",
            unsafeBitCast(callback, to: GCallback.self),
            stateRef, { userData, _ in
                guard let userData = userData else { return }
                Unmanaged<StateStore<String>>.fromOpaque(userData).release()
            }, GConnectFlags(rawValue: 0)
        )

        return entry
    }
}

// MARK: - EmptyView

/// A view that displays nothing. Used as a placeholder.
public struct EmptyView: View, GTKRenderable {
    public init() {}
    public var body: Never { fatalError() }
    public func renderGTK() -> WidgetPtr {
        let box = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 0)
        gtk_widget_set_visible(box, 0)
        return box
    }
}

// MARK: - LazyVGrid

/// A vertical grid that flows items into columns — like SwiftUI's LazyVGrid.
public struct LazyVGrid<Data, Content: View>: View, GTKRenderable
where Data: RandomAccessCollection {
    let columns: Int
    let spacing: Int32
    let data: Data
    let content: (Data.Element) -> Content

    public init(
        columns: Int,
        spacing: Int32 = 8,
        data: Data,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.columns = columns
        self.spacing = spacing
        self.data = data
        self.content = content
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let grid = gtk_grid_new()!
        let g: UnsafeMutablePointer<GtkGrid> = typed(grid)
        gtk_grid_set_column_spacing(g, guint(spacing))
        gtk_grid_set_row_spacing(g, guint(spacing))
        gtk_grid_set_column_homogeneous(g, 1)
        setHExpand(grid)

        var col: Int32 = 0
        var row: Int32 = 0
        for item in data {
            let widget = render(content(item))
            setHExpand(widget)
            gtk_grid_attach(g, widget, col, row, 1, 1)
            col += 1
            if col >= Int32(columns) {
                col = 0
                row += 1
            }
        }

        return grid
    }
}

// MARK: - Separator with label

/// A labeled separator — like "── OR ──" dividers.
public struct LabeledDivider: View, GTKRenderable {
    let label: String

    public init(_ label: String) {
        self.label = label
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let row = makeBox(GTK_ORIENTATION_HORIZONTAL, spacing: 8)
        setHExpand(row)

        let leftSep = gtk_separator_new(GTK_ORIENTATION_HORIZONTAL)!
        setHExpand(leftSep)
        boxAppend(row, child: leftSep)

        let lbl = makeLabel(label)
        addCssClass(lbl, "pine-caption")
        boxAppend(row, child: lbl)

        let rightSep = gtk_separator_new(GTK_ORIENTATION_HORIZONTAL)!
        setHExpand(rightSep)
        boxAppend(row, child: rightSep)

        return row
    }
}

// MARK: - Avatar / Circle Image

/// A circular avatar image — like macOS contact photos.
public struct Avatar: View, GTKRenderable {
    let initials: String
    let size: Int32

    public init(_ initials: String, size: Int32 = 40) {
        self.initials = initials
        self.size = size
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let frame = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 0)
        setSizeRequest(frame, width: size, height: size)

        let label = makeLabel(initials)
        addCssClass(label, "pine-headline")
        setHAlign(label, align: GTK_ALIGN_CENTER)
        setVAlign(label, align: GTK_ALIGN_CENTER)
        setHExpand(label)
        setVExpand(label)
        boxAppend(frame, child: label)

        applyCss(frame, """
            border-radius: \(size / 2)px;
            background: @accent_bg_color;
            color: white;
            min-width: \(size)px;
            min-height: \(size)px;
        """)

        return frame
    }
}
