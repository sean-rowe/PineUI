// GtkHelpers.swift — GTK4 C API helpers for Swift.

import CGTK4

public typealias WidgetPtr = UnsafeMutablePointer<GtkWidget>

// MARK: - Constructors

public func makeBox(_ orientation: GtkOrientation, spacing: Int32) -> WidgetPtr { gtk_box_new(orientation, spacing)! }
public func makeLabel(_ text: String) -> WidgetPtr { gtk_label_new(text)! }
public func makeButton() -> WidgetPtr { gtk_button_new()! }
public func makeScrolledWindow() -> WidgetPtr { gtk_scrolled_window_new()! }
public func makeImage(iconName: String) -> WidgetPtr { gtk_image_new_from_icon_name(iconName)! }

// MARK: - Box (uses _GtkBox which Swift can see)

public func boxAppend(_ box: WidgetPtr, child: WidgetPtr) {
    let b = UnsafeMutableRawPointer(box).assumingMemoryBound(to: _GtkBox.self)
    gtk_box_append(b, child)
}

// MARK: - ScrolledWindow (Swift imports as OpaquePointer)

public func scrolledWindowSetChild(_ sw: WidgetPtr, child: WidgetPtr) {
    gtk_scrolled_window_set_child(OpaquePointer(sw), child)
}
public func scrolledWindowSetPolicy(_ sw: WidgetPtr, h: GtkPolicyType, v: GtkPolicyType) {
    gtk_scrolled_window_set_policy(OpaquePointer(sw), h, v)
}

// MARK: - Button (uses _GtkButton which Swift can see)

public func buttonSetChild(_ btn: WidgetPtr, child: WidgetPtr) {
    let b = UnsafeMutableRawPointer(btn).assumingMemoryBound(to: _GtkButton.self)
    gtk_button_set_child(b, child)
}
public func buttonSetHasFrame(_ btn: WidgetPtr, hasFrame: Bool) {
    let b = UnsafeMutableRawPointer(btn).assumingMemoryBound(to: _GtkButton.self)
    gtk_button_set_has_frame(b, hasFrame ? 1 : 0)
}

// MARK: - Label (Swift imports as OpaquePointer)

public func labelSetWrap(_ lbl: WidgetPtr, wrap: Bool) {
    gtk_label_set_wrap(OpaquePointer(lbl), wrap ? 1 : 0)
}

// MARK: - Window (uses _GtkWindow which Swift can see)

public func windowSetChild(_ win: WidgetPtr, child: WidgetPtr) {
    let w = UnsafeMutableRawPointer(win).assumingMemoryBound(to: _GtkWindow.self)
    gtk_window_set_child(w, child)
}
public func windowSetTitle(_ win: WidgetPtr, title: String) {
    let w = UnsafeMutableRawPointer(win).assumingMemoryBound(to: _GtkWindow.self)
    gtk_window_set_title(w, title)
}
public func windowSetDefaultSize(_ win: WidgetPtr, width: Int32, height: Int32) {
    let w = UnsafeMutableRawPointer(win).assumingMemoryBound(to: _GtkWindow.self)
    gtk_window_set_default_size(w, width, height)
}
public func windowPresent(_ win: WidgetPtr) {
    let w = UnsafeMutableRawPointer(win).assumingMemoryBound(to: _GtkWindow.self)
    gtk_window_present(w)
}

// MARK: - Generic typed cast for any GTK type Swift can see

/// Cast a WidgetPtr to any GTK type that Swift imported (e.g., _GtkTextView).
/// Only use with types that appear in error messages as `UnsafeMutablePointer<_GtkFoo>`.
@inline(__always)
public func typed<T>(_ w: WidgetPtr) -> UnsafeMutablePointer<T> {
    UnsafeMutableRawPointer(w).assumingMemoryBound(to: T.self)
}

// MARK: - Widget properties

public func setHExpand(_ w: WidgetPtr, expand: Bool = true) { gtk_widget_set_hexpand(w, expand ? 1 : 0) }
public func setVExpand(_ w: WidgetPtr, expand: Bool = true) { gtk_widget_set_vexpand(w, expand ? 1 : 0) }
public func setHAlign(_ w: WidgetPtr, align: GtkAlign) { gtk_widget_set_halign(w, align) }
public func setVAlign(_ w: WidgetPtr, align: GtkAlign) { gtk_widget_set_valign(w, align) }
public func addCssClass(_ w: WidgetPtr, _ name: String) { gtk_widget_add_css_class(w, name) }
public func setSizeRequest(_ w: WidgetPtr, width: Int32, height: Int32) { gtk_widget_set_size_request(w, width, height) }

/// Apply inline CSS to a single widget via a per-widget CssProvider.
/// Multiple calls for the same widget are batched into a single provider.
/// Mergeable properties (filter, transform) are automatically combined
/// so `.blur(3).grayscale(0.5)` produces `filter: blur(3px) grayscale(0.5);`
/// instead of the second overwriting the first.
// MARK: Thread Safety: GTK4 is single-threaded. All PineUI code runs on the main thread.
// widgetCssMap and cssCounter are accessed only from the main thread; no locking is needed.
private var widgetCssMap: [UnsafeRawPointer: (provider: UnsafeMutableRawPointer, rules: [String], className: String)] = [:]
private var cssCounter: Int = 0

public func cssProviderCount() -> Int { cssCounter }

public func applyCss(_ w: WidgetPtr, _ css: String) {
    let key = UnsafeRawPointer(w)

    if var entry = widgetCssMap[key] {
        entry.rules.append(css)
        widgetCssMap[key] = entry
        let merged = mergeCssRules(entry.rules)
        let fullCss = ".\(entry.className) { \(merged) }"
        let p = entry.provider.assumingMemoryBound(to: GtkCssProvider.self)
        gtk_css_provider_load_from_string(p, fullCss)
    } else {
        cssCounter += 1
        let className = "pine-inline-\(cssCounter)"
        let fullCss = ".\(className) { \(css) }"
        let provider = gtk_css_provider_new()!
        let p = UnsafeMutableRawPointer(provider).assumingMemoryBound(to: GtkCssProvider.self)
        gtk_css_provider_load_from_string(p, fullCss)
        let display = gdk_display_get_default()!
        gtk_style_context_add_provider_for_display(display, OpaquePointer(provider), UInt32(GTK_STYLE_PROVIDER_PRIORITY_USER))
        addCssClass(w, className)
        widgetCssMap[key] = (provider: UnsafeMutableRawPointer(provider), rules: [css], className: className)
    }
}

/// Merge CSS rules, combining `filter` and `transform` values that would
/// otherwise overwrite each other. E.g.:
///   ["filter: blur(3px);", "filter: grayscale(0.5);"]
/// becomes:
///   "filter: blur(3px) grayscale(0.5);"
private func mergeCssRules(_ rules: [String]) -> String {
    var filterValues: [String] = []
    var transformValues: [String] = []
    var otherRules: [String] = []

    for rule in rules {
        let trimmed = rule.trimmingCharacters(in: .whitespaces)
        if trimmed.hasPrefix("filter:") {
            // Extract the value between "filter:" and ";"
            let value = trimmed
                .replacingOccurrences(of: "filter:", with: "")
                .replacingOccurrences(of: ";", with: "")
                .trimmingCharacters(in: .whitespaces)
            filterValues.append(value)
        } else if trimmed.hasPrefix("transform:") {
            let value = trimmed
                .replacingOccurrences(of: "transform:", with: "")
                .replacingOccurrences(of: ";", with: "")
                .trimmingCharacters(in: .whitespaces)
            transformValues.append(value)
        } else {
            otherRules.append(rule)
        }
    }

    var merged = otherRules.joined(separator: " ")
    if !filterValues.isEmpty {
        merged += " filter: \(filterValues.joined(separator: " "));"
    }
    if !transformValues.isEmpty {
        merged += " transform: \(transformValues.joined(separator: " "));"
    }
    return merged
}
// MARK: - Gesture helpers

/// Attach a click gesture to a widget. Uses capture phase so it fires
/// even when child widgets would otherwise consume the event.
public func attachClickGesture(to w: WidgetPtr, action: @escaping () -> Void) {
    let gesture = gtk_gesture_click_new()!

    // Use capture phase so the gesture fires before children consume the click.
    gtk_event_controller_set_propagation_phase(gesture, GTK_PHASE_CAPTURE)

    let handler = GestureHandler(action: action)
    let ptr = Unmanaged.passRetained(handler).toOpaque()
    let callback: @convention(c) (
        OpaquePointer?, Int32, Double, Double, gpointer?
    ) -> Void = { _, _, _, _, userData in
        guard let userData = userData else { return }
        Unmanaged<GestureHandler>.fromOpaque(userData).takeUnretainedValue().action()
    }

    g_signal_connect_data(
        UnsafeMutableRawPointer(gesture), "pressed",
        unsafeBitCast(callback, to: GCallback.self),
        ptr, { userData, _ in
            guard let userData = userData else { return }
            Unmanaged<GestureHandler>.fromOpaque(userData).release()
        }, GConnectFlags(rawValue: 0)
    )

    gtk_widget_add_controller(w, gesture)
}

public func setMargins(_ w: WidgetPtr, start: Int32 = 0, end: Int32 = 0, top: Int32 = 0, bottom: Int32 = 0) {
    gtk_widget_set_margin_start(w, start); gtk_widget_set_margin_end(w, end)
    gtk_widget_set_margin_top(w, top); gtk_widget_set_margin_bottom(w, bottom)
}
