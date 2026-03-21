// Controls.swift — Button, Toggle, Label, Image.
//
// Usage:
//   Button("Click Me") { print("clicked") }
//   Label("Downloads", systemImage: "folder-symbolic")
//   Toggle("Dark Mode", isOn: darkMode)

import CGTK4

/// A clickable button.
public struct Button: View, GTKRenderable {
    let title: String
    let action: () -> Void
    var style: ButtonStyle = .default_

    public init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let btn = gtk_button_new_with_label(title)!
        addCssClass(btn, style.cssClass)

        // Connect click signal.
        let handler = ClickHandler(action: action)
        let ptr = Unmanaged.passRetained(handler).toOpaque()

        let callback: @convention(c) (
            UnsafeMutablePointer<_GtkButton>?, gpointer?
        ) -> Void = { _, userData in
            guard let userData = userData else { return }
            let handler = Unmanaged<ClickHandler>.fromOpaque(userData).takeUnretainedValue()
            handler.action()
        }

        g_signal_connect_data(
            UnsafeMutableRawPointer(btn),
            "clicked",
            unsafeBitCast(callback, to: GCallback.self),
            ptr, { userData, _ in
                guard let userData = userData else { return }
                Unmanaged<ClickHandler>.fromOpaque(userData).release()
            },
            GConnectFlags(rawValue: 0)
        )

        return btn
    }

    public func buttonStyle(_ style: ButtonStyle) -> Button {
        var copy = self
        copy.style = style
        return copy
    }
}

/// Stores the click callback so it can be passed through C function pointers.
private class ClickHandler {
    let action: () -> Void
    init(action: @escaping () -> Void) { self.action = action }
}

public enum ButtonStyle {
    case default_, bordered, borderedProminent, plain

    var cssClass: String {
        switch self {
        case .default_: return "pine-btn"
        case .bordered: return "pine-btn-bordered"
        case .borderedProminent: return "suggested-action"
        case .plain: return "flat"
        }
    }
}

/// A label with icon and text (like SwiftUI's Label).
public struct Label: View, GTKRenderable {
    let title: String
    let iconName: String

    public init(_ title: String, systemImage: String) {
        self.title = title
        self.iconName = resolveSFSymbol(systemImage)
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let row = makeBox(GTK_ORIENTATION_HORIZONTAL, spacing: 6)
        let icon = makeImage(iconName: iconName)
        boxAppend(row, child: icon)
        let label = makeLabel(title)
        boxAppend(row, child: label)
        return row
    }
}

/// An image from the icon theme.
public struct Image: View, GTKRenderable {
    let iconName: String

    /// Create from a system/theme icon name.
    /// Automatically resolves SF Symbol names to GTK icon names.
    public init(systemName: String) {
        self.iconName = resolveSFSymbol(systemName)
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        makeImage(iconName: iconName)
    }
}

/// A toggle switch.
public struct Toggle: View, GTKRenderable {
    let title: String

    public init(_ title: String) {
        self.title = title
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
        boxAppend(row, child: toggle)

        return row
    }
}

/// A text input field.
public struct TextField: View, GTKRenderable {
    let placeholder: String

    public init(_ placeholder: String) {
        self.placeholder = placeholder
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let entry = gtk_entry_new()!
        let e = UnsafeMutableRawPointer(entry).assumingMemoryBound(to: _GtkEntry.self)
        gtk_entry_set_placeholder_text(e, placeholder)
        return entry
    }
}
