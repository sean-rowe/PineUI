// Navigation.swift — NavigationStack with push/pop.
//
// Usage:
//   let nav = NavigationController()
//
//   NavigationStack(controller: nav) {
//       VStack {
//           Text("Home")
//           Button("Go to Detail") { nav.push("detail") }
//       }
//   }
//   .destination("detail") {
//       VStack {
//           Text("Detail View")
//           Button("Back") { nav.pop() }
//       }
//   }

import CGTK4

// MARK: - NavigationController

/// Manages a stack of navigation destinations.
/// Owns the GtkStack and handles push/pop transitions.
public class NavigationController {
    var stack: UnsafeMutablePointer<GtkWidget>?
    var history: [String] = ["root"]
    private var onNavigate: ((String) -> Void)?

    public init() {}

    /// Push a named destination onto the navigation stack.
    public func push(_ name: String) {
        history.append(name)
        showCurrent()
    }

    /// Pop the top destination, returning to the previous one.
    public func pop() {
        guard history.count > 1 else { return }
        history.removeLast()
        showCurrent()
    }

    /// Pop to the root destination.
    public func popToRoot() {
        history = ["root"]
        showCurrent()
    }

    /// Current visible destination name.
    public var current: String {
        history.last ?? "root"
    }

    func setStack(_ gtkStack: WidgetPtr) {
        self.stack = gtkStack
    }

    private func showCurrent() {
        guard let stack = stack else { return }
        let s = OpaquePointer(stack)
        let name = current
        gtk_stack_set_visible_child_name(s, name)
        onNavigate?(name)
    }

    func setOnNavigate(_ handler: @escaping (String) -> Void) {
        self.onNavigate = handler
    }
}

// MARK: - NavigationStack

/// A container that manages push/pop navigation between named destinations.
public class NavigationStackBuilder {
    let controller: NavigationController
    private var rootBuilder: (() -> WidgetPtr)?
    private var destinations: [(String, () -> WidgetPtr)] = []

    public init(controller: NavigationController) {
        self.controller = controller
    }

    /// Set the root (home) content.
    @discardableResult
    public func root(@ViewBuilder _ content: @escaping () -> some View) -> NavigationStackBuilder {
        self.rootBuilder = { render(content()) }
        return self
    }

    /// Register a named destination.
    @discardableResult
    public func destination(_ name: String, @ViewBuilder content: @escaping () -> some View) -> NavigationStackBuilder {
        destinations.append((name, { render(content()) }))
        return self
    }

    /// Build the navigation stack widget.
    public func build() -> WidgetPtr {
        let gtkStack = gtk_stack_new()!
        let s = OpaquePointer(gtkStack)
        gtk_stack_set_transition_type(s, GTK_STACK_TRANSITION_TYPE_SLIDE_LEFT_RIGHT)
        gtk_stack_set_transition_duration(s, 200)
        setHExpand(gtkStack)
        setVExpand(gtkStack)

        // Add root page.
        if let rootBuilder = rootBuilder {
            let rootWidget = rootBuilder()
            gtk_stack_add_named(s, rootWidget, "root")
        }

        // Add destination pages.
        for (name, builder) in destinations {
            let widget = builder()
            gtk_stack_add_named(s, widget, name)
        }

        controller.setStack(gtkStack)
        return gtkStack
    }
}

// MARK: - NavigationLink

/// A button that pushes a destination onto the navigation stack.
public struct NavigationLink: View, GTKRenderable {
    let title: String
    let destination: String
    let controller: NavigationController

    public init(_ title: String, destination: String, controller: NavigationController) {
        self.title = title
        self.destination = destination
        self.controller = controller
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let btn = gtk_button_new()!
        buttonSetHasFrame(btn, hasFrame: false)

        let row = makeBox(GTK_ORIENTATION_HORIZONTAL, spacing: 8)
        setHExpand(row)

        let label = makeLabel(title)
        setHExpand(label)
        setHAlign(label, align: GTK_ALIGN_START)
        boxAppend(row, child: label)

        // Chevron indicator.
        let chevron = makeImage(iconName: resolveSFSymbol("chevron.right"))
        addCssClass(chevron, "pine-fg-tertiary")
        boxAppend(row, child: chevron)

        buttonSetChild(btn, child: row)

        // Connect click to push navigation.
        let handler = NavLinkHandler(destination: destination, controller: controller)
        let ptr = Unmanaged.passRetained(handler).toOpaque()
        let callback: @convention(c) (UnsafeMutablePointer<_GtkButton>?, gpointer?) -> Void = { _, userData in
            guard let userData = userData else { return }
            let h = Unmanaged<NavLinkHandler>.fromOpaque(userData).takeUnretainedValue()
            h.controller.push(h.destination)
        }
        g_signal_connect_data(
            UnsafeMutableRawPointer(btn), "clicked",
            unsafeBitCast(callback, to: GCallback.self),
            ptr, { userData, _ in
                guard let userData = userData else { return }
                Unmanaged<NavLinkHandler>.fromOpaque(userData).release()
            }, GConnectFlags(rawValue: 0)
        )

        return btn
    }
}

private class NavLinkHandler {
    let destination: String
    let controller: NavigationController
    init(destination: String, controller: NavigationController) {
        self.destination = destination
        self.controller = controller
    }
}

// MARK: - Back Button

/// A button that pops the navigation stack.
public struct BackButton: View, GTKRenderable {
    let title: String
    let controller: NavigationController

    public init(_ title: String = "Back", controller: NavigationController) {
        self.title = title
        self.controller = controller
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let btn = gtk_button_new()!
        buttonSetHasFrame(btn, hasFrame: false)

        let row = makeBox(GTK_ORIENTATION_HORIZONTAL, spacing: 4)
        let chevron = makeImage(iconName: resolveSFSymbol("chevron.left"))
        addCssClass(chevron, "pine-fg-accent")
        boxAppend(row, child: chevron)

        let label = makeLabel(title)
        addCssClass(label, "pine-fg-accent")
        boxAppend(row, child: label)

        buttonSetChild(btn, child: row)

        // Connect click.
        let controllerRef = Unmanaged.passRetained(controller).toOpaque()
        let callback: @convention(c) (UnsafeMutablePointer<_GtkButton>?, gpointer?) -> Void = { _, userData in
            guard let userData = userData else { return }
            Unmanaged<NavigationController>.fromOpaque(userData).takeUnretainedValue().pop()
        }
        g_signal_connect_data(
            UnsafeMutableRawPointer(btn), "clicked",
            unsafeBitCast(callback, to: GCallback.self),
            controllerRef, { userData, _ in
                guard let userData = userData else { return }
                Unmanaged<NavigationController>.fromOpaque(userData).release()
            }, GConnectFlags(rawValue: 0)
        )

        return btn
    }
}
