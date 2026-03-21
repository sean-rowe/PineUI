// PineApp.swift — Application entry point, wraps GtkApplication.

import CGTK4

/// Protocol for PineOS applications.
public protocol PineApp {
    var appId: String { get }
    func buildWindow() -> PineWindow
    init()
}

extension PineApp {
    public static func main() {
        let instance = Self.init()
        runGtkApp(appId: instance.appId) { app in
            instance.buildWindow().realize(app: app)
        }
    }
}

// ---------------------------------------------------------------------------
// GTK Application runner
// ---------------------------------------------------------------------------

private var activationHandler: ((UnsafeMutablePointer<GtkApplication>) -> Void)?

func runGtkApp(appId: String, onActivate handler: @escaping (UnsafeMutablePointer<GtkApplication>) -> Void) {
    activationHandler = handler

    let app = gtk_application_new(appId, G_APPLICATION_DEFAULT_FLAGS)!

    // Connect "activate" signal using g_signal_connect_data.
    let callback: @convention(c) (
        UnsafeMutablePointer<GtkApplication>?,
        gpointer?
    ) -> Void = { app, _ in
        guard let app = app else { return }
        activationHandler?(app)
    }

    g_signal_connect_data(
        UnsafeMutableRawPointer(app),
        "activate",
        unsafeBitCast(callback, to: GCallback.self),
        nil, nil, GConnectFlags(rawValue: 0)
    )

    let gApp = UnsafeMutableRawPointer(app).assumingMemoryBound(to: GApplication.self)
    let status = g_application_run(gApp, CommandLine.argc, CommandLine.unsafeArgv)
    g_object_unref(gpointer(app))

    if status != 0 {
        exit(status)
    }
}
