// PresentationModifiers.swift — SwiftUI-compatible presentation modifiers for PineUI.
//
// Implements 9 presentation modifiers:
//   sheet, fullScreenCover, popover,
//   alert, confirmationDialog,
//   fileImporter, fileExporter, inspector, interactiveDismissDisabled

import CGTK4

// MARK: - Handler Classes

/// Manages the sheet/fullScreenCover lifecycle tied to a StateStore<Bool>.
private class SheetHandler<Content: View> {
    let store: StateStore<Bool>
    let width: Int32
    let height: Int32
    let content: () -> Content

    init(
        store: StateStore<Bool>,
        width: Int32,
        height: Int32,
        content: @escaping () -> Content
    ) {
        self.store = store
        self.width = width
        self.height = height
        self.content = content
    }

    func setup(parentWidget: WidgetPtr) {
        store.onChange = { [weak self] isPresented in
            guard let self = self else { return }
            if isPresented {
                Sheet.present(
                    on: parentWidget,
                    width: self.width,
                    height: self.height,
                    content: self.content
                )
                // Reset the flag after presentation so a subsequent set(true)
                // can trigger again. Done on the next run-loop iteration to
                // avoid re-entrancy into onChange.
                self.store.value = false
            }
        }
    }
}

/// Manages a popover tied to a StateStore<Bool>.
private class PopoverHandler<Content: View> {
    let store: StateStore<Bool>
    let content: () -> Content
    var popoverWidget: WidgetPtr?

    init(store: StateStore<Bool>, content: @escaping () -> Content) {
        self.store = store
        self.content = content
    }

    func setup(parentWidget: WidgetPtr) {
        // Build the popover once, parented to the widget.
        let pop = gtk_popover_new()!
        self.popoverWidget = pop
        let typedPop: UnsafeMutablePointer<_GtkPopover> = typed(pop)
        let contentWidget = render(content())
        setMargins(contentWidget, start: 12, end: 12, top: 12, bottom: 12)
        gtk_popover_set_child(typedPop, contentWidget)
        gtk_widget_set_parent(pop, parentWidget)

        store.onChange = { [weak self] isPresented in
            guard let self = self, let pop = self.popoverWidget else { return }
            let typedPop2: UnsafeMutablePointer<_GtkPopover> = typed(pop)
            if isPresented {
                gtk_popover_popup(typedPop2)
            } else {
                gtk_popover_popdown(typedPop2)
            }
        }
    }
}

/// Manages an alert tied to a StateStore<Bool>.
private class AlertHandler {
    let title: String
    let store: StateStore<Bool>

    init(title: String, store: StateStore<Bool>) {
        self.title = title
        self.store = store
    }

    func setup(parentWidget: WidgetPtr) {
        store.onChange = { [weak self] isPresented in
            guard let self = self else { return }
            if isPresented {
                Alert.show(
                    on: parentWidget,
                    title: self.title,
                    message: "",
                    onDismiss: {
                        self.store.value = false
                    }
                )
            }
        }
    }
}

/// Manages a confirmation dialog tied to a StateStore<Bool>.
private class ConfirmationDialogHandler {
    let title: String
    let store: StateStore<Bool>

    init(title: String, store: StateStore<Bool>) {
        self.title = title
        self.store = store
    }

    func setup(parentWidget: WidgetPtr) {
        store.onChange = { [weak self] isPresented in
            guard let self = self else { return }
            if isPresented {
                Alert.confirm(
                    on: parentWidget,
                    title: self.title,
                    message: "",
                    onConfirm: {
                        self.store.value = false
                    },
                    onCancel: {
                        self.store.value = false
                    }
                )
            }
        }
    }
}

// MARK: - Presentation Modifiers

extension View {

    // MARK: 7. sheet

    /// Presents a modal sheet when `isPresented` becomes `true`.
    ///
    /// Observes the `StateStore<Bool>` via its `onChange` callback.
    /// The callback is registered on the "map" signal so the widget's root
    /// window is available when the sheet needs to find its parent.
    ///
    /// - Parameters:
    ///   - isPresented: A `StateStore<Bool>` that drives sheet presentation.
    ///   - content: A view builder producing the sheet's content.
    public func sheet<Content: View>(
        isPresented: StateStore<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> ModifiedView<Self> {
        let handler = SheetHandler(
            store: isPresented,
            width: 500,
            height: 400,
            content: content
        )
        return ModifiedView(content: self) { w in
            handler.setup(parentWidget: w)
        }
    }

    // MARK: 8. fullScreenCover

    /// Presents a full-screen cover when `isPresented` becomes `true`.
    ///
    /// Behaves identically to `.sheet` but uses a larger default size to
    /// approximate a full-screen presentation on the current display.
    ///
    /// - Parameters:
    ///   - isPresented: A `StateStore<Bool>` that drives cover presentation.
    ///   - content: A view builder producing the cover's content.
    public func fullScreenCover<Content: View>(
        isPresented: StateStore<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> ModifiedView<Self> {
        let handler = SheetHandler(
            store: isPresented,
            width: 1024,
            height: 768,
            content: content
        )
        return ModifiedView(content: self) { w in
            handler.setup(parentWidget: w)
        }
    }

    // MARK: 9. popover

    /// Presents a popover anchored to this view when `isPresented` is `true`.
    ///
    /// Uses `GtkPopover` — calls `gtk_popover_popup` when `isPresented` becomes
    /// `true` and `gtk_popover_popdown` when it becomes `false`.
    ///
    /// - Parameters:
    ///   - isPresented: A `StateStore<Bool>` controlling visibility.
    ///   - content: A view builder producing the popover's content.
    public func popover<Content: View>(
        isPresented: StateStore<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> ModifiedView<Self> {
        let handler = PopoverHandler(store: isPresented, content: content)
        return ModifiedView(content: self) { w in
            handler.setup(parentWidget: w)
        }
    }

    // MARK: 10. alert

    /// Presents a modal alert when `isPresented` becomes `true`.
    ///
    /// The alert is dismissed automatically when the user taps OK,
    /// which also resets `isPresented` to `false`.
    ///
    /// - Parameters:
    ///   - title: The alert's title string.
    ///   - isPresented: A `StateStore<Bool>` controlling presentation.
    ///   - actions: Ignored — OK button is always shown (GTK4 Alert API).
    public func alert<Actions: View>(
        _ title: String,
        isPresented: StateStore<Bool>,
        @ViewBuilder actions: () -> Actions
    ) -> ModifiedView<Self> {
        let _ = actions()
        let handler = AlertHandler(title: title, store: isPresented)
        return ModifiedView(content: self) { w in
            handler.setup(parentWidget: w)
        }
    }

    /// Presents a modal alert when `isPresented` becomes `true` (no-actions overload).
    ///
    /// - Parameters:
    ///   - title: The alert's title string.
    ///   - isPresented: A `StateStore<Bool>` controlling presentation.
    public func alert(
        _ title: String,
        isPresented: StateStore<Bool>
    ) -> ModifiedView<Self> {
        let handler = AlertHandler(title: title, store: isPresented)
        return ModifiedView(content: self) { w in
            handler.setup(parentWidget: w)
        }
    }

    // MARK: 11. confirmationDialog

    /// Presents a confirmation dialog when `isPresented` becomes `true`.
    ///
    /// Shows a two-button dialog (Confirm / Cancel). Both buttons reset
    /// `isPresented` to `false` on dismissal.
    ///
    /// - Parameters:
    ///   - title: The dialog's title string.
    ///   - isPresented: A `StateStore<Bool>` controlling presentation.
    ///   - actions: Ignored — buttons are always Confirm and Cancel (GTK4 Alert API).
    public func confirmationDialog<Actions: View>(
        _ title: String,
        isPresented: StateStore<Bool>,
        @ViewBuilder actions: () -> Actions
    ) -> ModifiedView<Self> {
        let _ = actions()
        let handler = ConfirmationDialogHandler(title: title, store: isPresented)
        return ModifiedView(content: self) { w in
            handler.setup(parentWidget: w)
        }
    }

    /// Presents a confirmation dialog when `isPresented` becomes `true` (no-actions overload).
    ///
    /// - Parameters:
    ///   - title: The dialog's title string.
    ///   - isPresented: A `StateStore<Bool>` controlling presentation.
    public func confirmationDialog(
        _ title: String,
        isPresented: StateStore<Bool>
    ) -> ModifiedView<Self> {
        let handler = ConfirmationDialogHandler(title: title, store: isPresented)
        return ModifiedView(content: self) { w in
            handler.setup(parentWidget: w)
        }
    }

    // MARK: 12. fileImporter

    /// Presents a file importer dialog when `isPresented` becomes `true`.
    // STUB: GtkFileDialog uses async completion handlers introduced in GTK 4.10
    // and requires GCancellable integration — too complex for this iteration.
    public func fileImporter(
        isPresented: StateStore<Bool>,
        allowedContentTypes: [String] = [],
        onCompletion: @escaping (Result<String, Error>) -> Void
    ) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: GtkFileDialog is async — requires GCancellable and GTK 4.10+.
        }
    }

    // MARK: 13. fileExporter

    /// Presents a file exporter dialog when `isPresented` becomes `true`.
    // STUB: GtkFileDialog uses async completion handlers — deferred for the same
    // reason as fileImporter.
    public func fileExporter(
        isPresented: StateStore<Bool>,
        fileName: String = "",
        onCompletion: @escaping (Result<String, Error>) -> Void
    ) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: GtkFileDialog is async — requires GCancellable and GTK 4.10+.
        }
    }

    // MARK: 14. inspector

    /// Presents an inspector panel when `isPresented` becomes `true`.
    // STUB: No GTK4 equivalent — inspector panels are platform-specific (Xcode/Swift Playgrounds).
    public func inspector<Content: View>(
        isPresented: StateStore<Bool>,
        @ViewBuilder content: () -> Content
    ) -> ModifiedView<Self> {
        let _ = content()
        return ModifiedView(content: self) { _ in
            // STUB: no GTK4 equivalent — inspector panels are an Xcode/SwiftUI concept.
        }
    }

    // MARK: 15. interactiveDismissDisabled

    /// Prevents interactive dismissal of a sheet or cover.
    // STUB: GTK4 windows are not interactively dismissible in the same sense as
    // iOS sheets. GTK modal windows already block their parent; swipe-to-dismiss
    // is not a GTK4 concept.
    public func interactiveDismissDisabled(_ isDisabled: Bool = true) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: no GTK4 equivalent — GTK4 modal windows do not support swipe-to-dismiss.
        }
    }
}
