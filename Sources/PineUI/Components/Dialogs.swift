// Dialogs.swift — Alert, Sheet, ConfirmationDialog.
//
// Usage:
//   Alert.show(on: window, title: "Error", message: "Something went wrong")
//   Sheet.present(on: window, width: 400, height: 300) { Text("Sheet content") }

import CGTK4

// MARK: - Alert

/// A modal alert dialog — like SwiftUI's .alert() modifier.
public struct Alert {
    /// Show an alert with a title, message, and dismiss button.
    public static func show(
        on window: WidgetPtr,
        title: String,
        message: String,
        buttonText: String = "OK",
        onDismiss: (() -> Void)? = nil
    ) {
        let dialog = gtk_window_new()!
        let win: UnsafeMutablePointer<_GtkWindow> = typed(dialog)
        gtk_window_set_title(win, title)
        gtk_window_set_default_size(win, 360, -1)
        gtk_window_set_modal(win, 1)
        gtk_window_set_resizable(win, 0)

        // Set parent.
        let parentWin = gtk_widget_get_root(window)
        if let parentWin = parentWin {
            let p: UnsafeMutablePointer<_GtkWindow> = typed(UnsafeMutableRawPointer(parentWin).assumingMemoryBound(to: GtkWidget.self))
            gtk_window_set_transient_for(win, p)
        }

        let box = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 16)
        setMargins(box, start: 24, end: 24, top: 24, bottom: 24)

        // Title.
        let titleLabel = makeLabel(title)
        addCssClass(titleLabel, "pine-title3")
        setHAlign(titleLabel, align: GTK_ALIGN_CENTER)
        boxAppend(box, child: titleLabel)

        // Message.
        let msgLabel = makeLabel(message)
        labelSetWrap(msgLabel, wrap: true)
        setHAlign(msgLabel, align: GTK_ALIGN_CENTER)
        addCssClass(msgLabel, "pine-body")
        boxAppend(box, child: msgLabel)

        // Button.
        let btn = gtk_button_new_with_label(buttonText)!
        addCssClass(btn, "suggested-action")
        setHAlign(btn, align: GTK_ALIGN_CENTER)
        setSizeRequest(btn, width: 120, height: -1)

        let handler = AlertDismissHandler(window: dialog, onDismiss: onDismiss)
        let ptr = Unmanaged.passRetained(handler).toOpaque()
        let callback: @convention(c) (UnsafeMutablePointer<_GtkButton>?, gpointer?) -> Void = { _, userData in
            guard let userData = userData else { return }
            let h = Unmanaged<AlertDismissHandler>.fromOpaque(userData).takeRetainedValue()
            let w: UnsafeMutablePointer<_GtkWindow> = typed(h.window)
            gtk_window_destroy(w)
            h.onDismiss?()
        }
        g_signal_connect_data(
            UnsafeMutableRawPointer(btn), "clicked",
            unsafeBitCast(callback, to: GCallback.self),
            ptr, nil, GConnectFlags(rawValue: 0)
        )
        boxAppend(box, child: btn)

        windowSetChild(dialog, child: box)
        windowPresent(dialog)
    }

    /// Show an alert with two buttons (confirm/cancel).
    public static func confirm(
        on window: WidgetPtr,
        title: String,
        message: String,
        confirmText: String = "Confirm",
        cancelText: String = "Cancel",
        onConfirm: @escaping () -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        let dialog = gtk_window_new()!
        let win: UnsafeMutablePointer<_GtkWindow> = typed(dialog)
        gtk_window_set_title(win, title)
        gtk_window_set_default_size(win, 360, -1)
        gtk_window_set_modal(win, 1)
        gtk_window_set_resizable(win, 0)

        let parentWin = gtk_widget_get_root(window)
        if let parentWin = parentWin {
            let p: UnsafeMutablePointer<_GtkWindow> = typed(UnsafeMutableRawPointer(parentWin).assumingMemoryBound(to: GtkWidget.self))
            gtk_window_set_transient_for(win, p)
        }

        let box = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 16)
        setMargins(box, start: 24, end: 24, top: 24, bottom: 24)

        let titleLabel = makeLabel(title)
        addCssClass(titleLabel, "pine-title3")
        setHAlign(titleLabel, align: GTK_ALIGN_CENTER)
        boxAppend(box, child: titleLabel)

        let msgLabel = makeLabel(message)
        labelSetWrap(msgLabel, wrap: true)
        setHAlign(msgLabel, align: GTK_ALIGN_CENTER)
        boxAppend(box, child: msgLabel)

        // Button row.
        let btnRow = makeBox(GTK_ORIENTATION_HORIZONTAL, spacing: 12)
        setHAlign(btnRow, align: GTK_ALIGN_CENTER)

        // Cancel button.
        let cancelBtn = gtk_button_new_with_label(cancelText)!
        setSizeRequest(cancelBtn, width: 100, height: -1)
        let cancelHandler = AlertDismissHandler(window: dialog, onDismiss: onCancel)
        let cancelPtr = Unmanaged.passRetained(cancelHandler).toOpaque()
        let cancelCb: @convention(c) (UnsafeMutablePointer<_GtkButton>?, gpointer?) -> Void = { _, userData in
            guard let userData = userData else { return }
            let h = Unmanaged<AlertDismissHandler>.fromOpaque(userData).takeRetainedValue()
            let w: UnsafeMutablePointer<_GtkWindow> = typed(h.window)
            gtk_window_destroy(w)
            h.onDismiss?()
        }
        g_signal_connect_data(
            UnsafeMutableRawPointer(cancelBtn), "clicked",
            unsafeBitCast(cancelCb, to: GCallback.self),
            cancelPtr, nil, GConnectFlags(rawValue: 0)
        )
        boxAppend(btnRow, child: cancelBtn)

        // Confirm button.
        let confirmBtn = gtk_button_new_with_label(confirmText)!
        addCssClass(confirmBtn, "destructive-action")
        setSizeRequest(confirmBtn, width: 100, height: -1)
        let confirmHandler = AlertDismissHandler(window: dialog, onDismiss: onConfirm)
        let confirmPtr = Unmanaged.passRetained(confirmHandler).toOpaque()
        g_signal_connect_data(
            UnsafeMutableRawPointer(confirmBtn), "clicked",
            unsafeBitCast(cancelCb, to: GCallback.self),
            confirmPtr, nil, GConnectFlags(rawValue: 0)
        )
        boxAppend(btnRow, child: confirmBtn)

        boxAppend(box, child: btnRow)
        windowSetChild(dialog, child: box)
        windowPresent(dialog)
    }
}

private class AlertDismissHandler {
    let window: WidgetPtr
    let onDismiss: (() -> Void)?
    init(window: WidgetPtr, onDismiss: (() -> Void)?) {
        self.window = window
        self.onDismiss = onDismiss
    }
}

// MARK: - Sheet

/// A modal sheet window — like SwiftUI's .sheet() modifier.
public struct Sheet {
    /// Present a modal sheet with custom content.
    public static func present<V: View>(
        on window: WidgetPtr,
        title: String = "",
        width: Int32 = 500,
        height: Int32 = 400,
        @ViewBuilder content: () -> V
    ) {
        let dialog = gtk_window_new()!
        let win: UnsafeMutablePointer<_GtkWindow> = typed(dialog)
        gtk_window_set_title(win, title)
        gtk_window_set_default_size(win, width, height)
        gtk_window_set_modal(win, 1)

        let parentWin = gtk_widget_get_root(window)
        if let parentWin = parentWin {
            let p: UnsafeMutablePointer<_GtkWindow> = typed(UnsafeMutableRawPointer(parentWin).assumingMemoryBound(to: GtkWidget.self))
            gtk_window_set_transient_for(win, p)
        }

        let contentWidget = render(content())
        setHExpand(contentWidget)
        setVExpand(contentWidget)
        windowSetChild(dialog, child: contentWidget)
        windowPresent(dialog)
    }
}

// MARK: - Toolbar

/// A toolbar at the top of a window — like macOS window toolbars.
public class PineToolbar {
    private var leftItems: [WidgetPtr] = []
    private var centerItems: [WidgetPtr] = []
    private var rightItems: [WidgetPtr] = []

    public init() {}

    @discardableResult
    public func leading(_ title: String, icon: String? = nil, action: @escaping () -> Void) -> PineToolbar {
        leftItems.append(makeToolbarButton(title, icon: icon, action: action))
        return self
    }

    @discardableResult
    public func trailing(_ title: String, icon: String? = nil, action: @escaping () -> Void) -> PineToolbar {
        rightItems.append(makeToolbarButton(title, icon: icon, action: action))
        return self
    }

    func build() -> WidgetPtr {
        let bar = makeBox(GTK_ORIENTATION_HORIZONTAL, spacing: 4)
        addCssClass(bar, "pine-toolbar")
        setMargins(bar, start: 8, end: 8, top: 4, bottom: 4)

        for item in leftItems { boxAppend(bar, child: item) }

        let spacer = makeBox(GTK_ORIENTATION_HORIZONTAL, spacing: 0)
        setHExpand(spacer)
        boxAppend(bar, child: spacer)

        for item in rightItems { boxAppend(bar, child: item) }

        return bar
    }
}

private func makeToolbarButton(_ title: String, icon: String?, action: @escaping () -> Void) -> WidgetPtr {
    let btn: WidgetPtr
    if let icon = icon {
        let resolved = resolveSFSymbol(icon)
        btn = gtk_button_new_from_icon_name(resolved)!
        gtk_widget_set_tooltip_text(btn, title)
    } else {
        btn = gtk_button_new_with_label(title)!
    }
    buttonSetHasFrame(btn, hasFrame: false)
    addCssClass(btn, "flat")

    let handler = ToolbarClickHandler(action: action)
    let ptr = Unmanaged.passRetained(handler).toOpaque()
    let callback: @convention(c) (UnsafeMutablePointer<_GtkButton>?, gpointer?) -> Void = { _, userData in
        guard let userData = userData else { return }
        Unmanaged<ToolbarClickHandler>.fromOpaque(userData).takeUnretainedValue().action()
    }
    g_signal_connect_data(
        UnsafeMutableRawPointer(btn), "clicked",
        unsafeBitCast(callback, to: GCallback.self),
        ptr, { userData, _ in
            guard let userData = userData else { return }
            Unmanaged<ToolbarClickHandler>.fromOpaque(userData).release()
        }, GConnectFlags(rawValue: 0)
    )
    return btn
}

private class ToolbarClickHandler {
    let action: () -> Void
    init(action: @escaping () -> Void) { self.action = action }
}
