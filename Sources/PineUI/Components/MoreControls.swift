// MoreControls.swift — Slider, Stepper, Picker, SecureField, TextEditor, Link, Menu.

import CGTK4

/// A horizontal slider control.
public struct Slider: View, GTKRenderable {
    let min: Double
    let max: Double
    let step: Double
    let label: String?

    public init(
        value: Double = 0.5,
        in range: ClosedRange<Double> = 0...1,
        step: Double = 0.01,
        label: String? = nil
    ) {
        self.min = range.lowerBound
        self.max = range.upperBound
        self.step = step
        self.label = label
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
        gtk_scale_set_draw_value(typed(scale) as UnsafeMutablePointer<_GtkScale>, 0)
        boxAppend(row, child: scale)
        return row
    }
}

/// A +/- stepper control.
public struct Stepper: View, GTKRenderable {
    let label: String
    let min: Int32
    let max: Int32

    public init(_ label: String, in range: ClosedRange<Int32> = 0...100) {
        self.label = label
        self.min = range.lowerBound
        self.max = range.upperBound
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let row = makeBox(GTK_ORIENTATION_HORIZONTAL, spacing: 8)
        setHExpand(row)

        let lbl = makeLabel(label)
        setHExpand(lbl)
        setHAlign(lbl, align: GTK_ALIGN_START)
        boxAppend(row, child: lbl)

        let spin = gtk_spin_button_new_with_range(Double(min), Double(max), 1.0)!
        boxAppend(row, child: spin)
        return row
    }
}

/// A dropdown picker.
public struct Picker: View, GTKRenderable {
    let title: String
    let options: [String]

    public init(_ title: String, options: [String]) {
        self.title = title
        self.options = options
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let row = makeBox(GTK_ORIENTATION_HORIZONTAL, spacing: 8)
        setHExpand(row)

        let lbl = makeLabel(title)
        setHExpand(lbl)
        setHAlign(lbl, align: GTK_ALIGN_START)
        boxAppend(row, child: lbl)

        // Build string list for GtkDropDown.
        let strs = options.map { strdup($0) } + [nil]
        let dropdown = strs.withUnsafeBufferPointer { buf -> WidgetPtr in
            // gtk_drop_down_new_from_strings takes a null-terminated array.
            let raw = UnsafeMutablePointer<UnsafePointer<CChar>?>.allocate(capacity: strs.count)
            for (i, s) in buf.enumerated() {
                raw[i] = UnsafePointer(s)
            }
            let dd = gtk_drop_down_new_from_strings(raw)!
            raw.deallocate()
            return dd
        }
        // Free strdup'd strings.
        for s in strs { if let s = s { free(s) } }

        boxAppend(row, child: dropdown)
        return row
    }
}

/// A password input field.
public struct SecureField: View, GTKRenderable {
    let placeholder: String

    public init(_ placeholder: String) {
        self.placeholder = placeholder
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let entry = gtk_password_entry_new()!
        // PasswordEntry API uses OpaquePointer in Swift import.
        gtk_password_entry_set_show_peek_icon(OpaquePointer(entry), 1)
        return entry
    }
}

/// A multi-line text editor.
public struct TextEditor: View, GTKRenderable {
    let initialText: String

    public init(text: String = "") {
        self.initialText = text
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let scroll = makeScrolledWindow()
        setVExpand(scroll)
        setHExpand(scroll)
        scrolledWindowSetPolicy(scroll, h: GTK_POLICY_AUTOMATIC, v: GTK_POLICY_AUTOMATIC)

        let textView = gtk_text_view_new()!
        let tv: UnsafeMutablePointer<GtkTextView> = typed(textView)
        gtk_text_view_set_wrap_mode(tv, GTK_WRAP_WORD_CHAR)
        gtk_text_view_set_left_margin(tv, 8)
        gtk_text_view_set_right_margin(tv, 8)
        gtk_text_view_set_top_margin(tv, 8)
        gtk_text_view_set_bottom_margin(tv, 8)
        addCssClass(textView, "pine-text-editor")

        if !initialText.isEmpty {
            let buffer = gtk_text_view_get_buffer(tv)
            gtk_text_buffer_set_text(buffer, initialText, Int32(initialText.utf8.count))
        }

        scrolledWindowSetChild(scroll, child: textView)
        return scroll
    }
}

/// A clickable link.
public struct Link: View, GTKRenderable {
    let title: String
    let url: String

    public init(_ title: String, destination: String) {
        self.title = title
        self.url = destination
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let btn = gtk_link_button_new_with_label(url, title)!
        return btn
    }
}
