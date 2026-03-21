// NavigationModifiers.swift — SwiftUI-compatible navigation modifiers for PineUI.
//
// Implements 6 navigation modifiers:
//   navigationTitle, navigationSubtitle, navigationBarTitleDisplayMode,
//   toolbar, toolbarBackground, toolbarColorScheme

import CGTK4

// MARK: - Supporting Enums

/// Display modes for the navigation bar title, matching SwiftUI's NavigationBarItem.TitleDisplayMode.
public enum NavigationBarTitleDisplayMode {
    /// Automatically selects a display mode based on context.
    case automatic
    /// Displays the title inline (smaller, in the centre of the bar).
    case inline
    /// Displays the title in a large, prominent style.
    case large
}

// MARK: - Handler Classes

/// Retains the title string so the C callback can use it safely.
private class NavigationTitleHandler {
    let title: String
    init(title: String) { self.title = title }
}

// MARK: - Navigation Modifiers

extension View {

    // MARK: 1. navigationTitle

    /// Sets the window title when this view appears on screen.
    ///
    /// Connects to the "map" signal so the title is applied once the widget
    /// is realised and its root GtkWindow is reachable via `gtk_widget_get_root`.
    public func navigationTitle(_ title: String) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            let handler = NavigationTitleHandler(title: title)
            let ptr = Unmanaged.passRetained(handler).toOpaque()

            let mapCallback: @convention(c) (WidgetPtr?, gpointer?) -> Void = { widget, userData in
                guard let widget = widget, let userData = userData else { return }
                let h = Unmanaged<NavigationTitleHandler>.fromOpaque(userData).takeUnretainedValue()
                if let root = gtk_widget_get_root(widget) {
                    // gtk_widget_get_root returns OpaquePointer? — cast via raw pointer.
                    let win: UnsafeMutablePointer<_GtkWindow> = typed(
                        UnsafeMutableRawPointer(root).assumingMemoryBound(to: GtkWidget.self)
                    )
                    gtk_window_set_title(win, h.title)
                }
            }

            g_signal_connect_data(
                UnsafeMutableRawPointer(w), "map",
                unsafeBitCast(mapCallback, to: GCallback.self),
                ptr,
                { userData, _ in
                    guard let userData = userData else { return }
                    Unmanaged<NavigationTitleHandler>.fromOpaque(userData).release()
                },
                GConnectFlags(rawValue: 0)
            )
        }
    }

    // MARK: 2. navigationSubtitle

    /// Sets a navigation subtitle for this view.
    // STUB: GTK4 windows do not have native subtitle support without a headerbar
    // (AdwHeaderBar from libadwaita). Subtitles would require injecting an
    // AdwHeaderBar into the window, which is outside PineUI's current scope.
    public func navigationSubtitle(_ subtitle: String) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: no GTK4 equivalent — subtitle requires AdwHeaderBar from libadwaita.
        }
    }

    // MARK: 3. navigationBarTitleDisplayMode

    /// Sets the display mode of the navigation bar title.
    // STUB: iOS-specific concept. GTK4 has no equivalent large/inline title distinction.
    public func navigationBarTitleDisplayMode(
        _ mode: NavigationBarTitleDisplayMode
    ) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: iOS-specific — GTK4 does not distinguish title display modes.
        }
    }

    // MARK: 4. toolbar

    /// Populates the window toolbar with the provided content.
    // STUB: Injecting toolbar items into PineWindow's existing toolbar is complex —
    // it would require a shared toolbar context passed through the view hierarchy.
    // Use PineWindow's built-in toolbar API directly for now.
    public func toolbar<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> ModifiedView<Self> {
        let _ = content()
        return ModifiedView(content: self) { _ in
            // STUB: toolbar injection requires a shared toolbar context — use PineWindow's
            // toolbar API directly.
        }
    }

    // MARK: 5. toolbarBackground

    /// Sets the background color of the navigation/toolbar.
    // STUB: PineWindow's toolbar is a standard GtkBox. Per-modifier background changes
    // would need access to the toolbar widget reference, which is not available here.
    public func toolbarBackground(_ color: Color) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: no direct GTK4 equivalent — set toolbar background via PineWindow's
            // toolbar widget reference or CSS.
        }
    }

    // MARK: 6. toolbarColorScheme

    /// Sets the color scheme of the toolbar.
    // STUB: iOS-specific concept. GTK4 uses a single color scheme per GtkSettings,
    // not per-widget. Use GtkSettings.gtk-application-prefer-dark-theme at the app level.
    public func toolbarColorScheme(_ scheme: ColorScheme?) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: iOS-specific — GTK4 color scheme is application-level, not toolbar-level.
        }
    }
}
