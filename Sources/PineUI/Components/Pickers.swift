// Pickers.swift — DatePicker, ColorPicker, SegmentedControl.

import CGTK4

// MARK: - DatePicker

/// A date picker using GtkCalendar.
public struct DatePicker: View, GTKRenderable {
    let title: String
    let onDateChanged: ((Int32, Int32, Int32) -> Void)?  // year, month, day

    public init(_ title: String = "", onDateChanged: ((Int32, Int32, Int32) -> Void)? = nil) {
        self.title = title
        self.onDateChanged = onDateChanged
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let box = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 4)

        if !title.isEmpty {
            let lbl = makeLabel(title)
            addCssClass(lbl, "pine-headline")
            setHAlign(lbl, align: GTK_ALIGN_START)
            boxAppend(box, child: lbl)
        }

        let calendar = gtk_calendar_new()!
        boxAppend(box, child: calendar)

        if let onDateChanged = onDateChanged {
            let handler = DateChangedHandler(callback: onDateChanged)
            let ptr = Unmanaged.passRetained(handler).toOpaque()
            let callback: @convention(c) (OpaquePointer?, gpointer?) -> Void = { cal, userData in
                guard let cal = cal, let userData = userData else { return }
                let dt = gtk_calendar_get_date(cal)!
                let year = g_date_time_get_year(dt)
                let month = g_date_time_get_month(dt)
                let day = g_date_time_get_day_of_month(dt)
                Unmanaged<DateChangedHandler>.fromOpaque(userData).takeUnretainedValue().callback(year, month, day)
            }
            g_signal_connect_data(
                UnsafeMutableRawPointer(calendar), "day-selected",
                unsafeBitCast(callback, to: GCallback.self),
                ptr, { userData, _ in
                    guard let userData = userData else { return }
                    Unmanaged<DateChangedHandler>.fromOpaque(userData).release()
                }, GConnectFlags(rawValue: 0)
            )
        }

        return box
    }
}

private class DateChangedHandler {
    let callback: (Int32, Int32, Int32) -> Void
    init(callback: @escaping (Int32, Int32, Int32) -> Void) { self.callback = callback }
}

// MARK: - ColorPicker

/// A color picker button that opens a color chooser dialog.
public struct ColorPicker: View, GTKRenderable {
    let title: String
    let onColorChanged: ((Double, Double, Double, Double) -> Void)?

    public init(_ title: String = "Color", onColorChanged: ((Double, Double, Double, Double) -> Void)? = nil) {
        self.title = title
        self.onColorChanged = onColorChanged
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let row = makeBox(GTK_ORIENTATION_HORIZONTAL, spacing: 8)
        setHExpand(row)

        let lbl = makeLabel(title)
        setHExpand(lbl)
        setHAlign(lbl, align: GTK_ALIGN_START)
        boxAppend(row, child: lbl)

        let colorBtn = gtk_color_button_new()!
        boxAppend(row, child: colorBtn)

        if let onColorChanged = onColorChanged {
            let handler = ColorChangedHandler(callback: onColorChanged)
            let ptr = Unmanaged.passRetained(handler).toOpaque()
            let callback: @convention(c) (OpaquePointer?, gpointer?) -> Void = { btn, userData in
                guard let btn = btn, let userData = userData else { return }
                var color = GdkRGBA()
                gtk_color_chooser_get_rgba(btn, &color)
                let h = Unmanaged<ColorChangedHandler>.fromOpaque(userData).takeUnretainedValue()
                h.callback(Double(color.red), Double(color.green), Double(color.blue), Double(color.alpha))
            }
            g_signal_connect_data(
                UnsafeMutableRawPointer(colorBtn), "color-set",
                unsafeBitCast(callback, to: GCallback.self),
                ptr, { userData, _ in
                    guard let userData = userData else { return }
                    Unmanaged<ColorChangedHandler>.fromOpaque(userData).release()
                }, GConnectFlags(rawValue: 0)
            )
        }

        return row
    }
}

private class ColorChangedHandler {
    let callback: (Double, Double, Double, Double) -> Void
    init(callback: @escaping (Double, Double, Double, Double) -> Void) { self.callback = callback }
}

// MARK: - SegmentedControl

/// A segmented picker — like macOS segmented controls.
public struct SegmentedControl: View, GTKRenderable {
    let segments: [String]
    let store: StateStore<Int>?
    let onChange: ((Int) -> Void)?

    public init(_ segments: [String], selection: StateStore<Int>? = nil, onChange: ((Int) -> Void)? = nil) {
        self.segments = segments
        self.store = selection
        self.onChange = onChange
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let row = makeBox(GTK_ORIENTATION_HORIZONTAL, spacing: 0)
        addCssClass(row, "linked")

        for (i, segment) in segments.enumerated() {
            let btn = gtk_toggle_button_new_with_label(segment)!
            addCssClass(btn, "flat")

            if i == (store?.value ?? 0) {
                let tb: UnsafeMutablePointer<_GtkToggleButton> = typed(btn)
                gtk_toggle_button_set_active(tb, 1)
            }

            let handler = SegmentHandler(index: i, store: store, onChange: onChange)
            let ptr = Unmanaged.passRetained(handler).toOpaque()
            let callback: @convention(c) (UnsafeMutablePointer<_GtkToggleButton>?, gpointer?) -> Void = { btn, userData in
                guard let btn = btn, let userData = userData else { return }
                let active = gtk_toggle_button_get_active(btn)
                if active != 0 {
                    let h = Unmanaged<SegmentHandler>.fromOpaque(userData).takeUnretainedValue()
                    h.store?.value = h.index
                    h.onChange?(h.index)
                }
            }
            g_signal_connect_data(
                UnsafeMutableRawPointer(btn), "toggled",
                unsafeBitCast(callback, to: GCallback.self),
                ptr, { userData, _ in
                    guard let userData = userData else { return }
                    Unmanaged<SegmentHandler>.fromOpaque(userData).release()
                }, GConnectFlags(rawValue: 0)
            )

            boxAppend(row, child: btn)
        }

        return row
    }
}

private class SegmentHandler {
    let index: Int
    let store: StateStore<Int>?
    let onChange: ((Int) -> Void)?
    init(index: Int, store: StateStore<Int>?, onChange: ((Int) -> Void)?) {
        self.index = index
        self.store = store
        self.onChange = onChange
    }
}

// MARK: - ContextMenu

/// Attach a right-click context menu to any view.
extension View {
    public func contextMenu(items: [MenuItem]) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            let gesture = gtk_gesture_click_new()!
            // Set to right-click (button 3) via C shim wrapper.
            pine_gesture_single_set_button(UnsafeMutableRawPointer(gesture), 3)
            gtk_event_controller_set_propagation_phase(gesture, GTK_PHASE_CAPTURE)

            let handler = ContextMenuHandler(widget: w, items: items)
            let ptr = Unmanaged.passRetained(handler).toOpaque()
            let callback: @convention(c) (
                OpaquePointer?, Int32, Double, Double, gpointer?
            ) -> Void = { _, _, x, y, userData in
                guard let userData = userData else { return }
                let h = Unmanaged<ContextMenuHandler>.fromOpaque(userData).takeUnretainedValue()

                let popover = gtk_popover_new()!
                let pop: UnsafeMutablePointer<_GtkPopover> = typed(popover)

                let box = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 0)
                setMargins(box, start: 4, end: 4, top: 4, bottom: 4)

                for item in h.items {
                    let btn = gtk_button_new_with_label(item.title)!
                    buttonSetHasFrame(btn, hasFrame: false)
                    setHAlign(btn, align: GTK_ALIGN_FILL)
                    setHExpand(btn)

                    if let action = item.action {
                        let actionHandler = ContextMenuActionHandler(action: action, popover: popover)
                        let actionPtr = Unmanaged.passRetained(actionHandler).toOpaque()
                        let actionCb: @convention(c) (UnsafeMutablePointer<_GtkButton>?, gpointer?) -> Void = { _, userData in
                            guard let userData = userData else { return }
                            let ah = Unmanaged<ContextMenuActionHandler>.fromOpaque(userData).takeRetainedValue()
                            let p: UnsafeMutablePointer<_GtkPopover> = typed(ah.popover)
                            gtk_popover_popdown(p)
                            ah.action()
                        }
                        g_signal_connect_data(
                            UnsafeMutableRawPointer(btn), "clicked",
                            unsafeBitCast(actionCb, to: GCallback.self),
                            actionPtr, nil, GConnectFlags(rawValue: 0)
                        )
                    }

                    boxAppend(box, child: btn)
                }

                gtk_popover_set_child(pop, box)
                gtk_widget_set_parent(popover, h.widget)
                gtk_popover_set_has_arrow(pop, 0)

                // Position near click point.
                var rect = GdkRectangle(x: Int32(x), y: Int32(y), width: 1, height: 1)
                gtk_popover_set_pointing_to(pop, &rect)
                gtk_popover_popup(pop)
            }
            g_signal_connect_data(
                UnsafeMutableRawPointer(gesture), "pressed",
                unsafeBitCast(callback, to: GCallback.self),
                ptr, { userData, _ in
                    guard let userData = userData else { return }
                    Unmanaged<ContextMenuHandler>.fromOpaque(userData).release()
                }, GConnectFlags(rawValue: 0)
            )

            gtk_widget_add_controller(w, gesture)
        }
    }
}

private class ContextMenuHandler {
    let widget: WidgetPtr
    let items: [MenuItem]
    init(widget: WidgetPtr, items: [MenuItem]) { self.widget = widget; self.items = items }
}

private class ContextMenuActionHandler {
    let action: () -> Void
    let popover: WidgetPtr
    init(action: @escaping () -> Void, popover: WidgetPtr) { self.action = action; self.popover = popover }
}
