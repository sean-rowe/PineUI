// PineWindow.swift — macOS-style application window.

import CGTK4

public class PineWindow {
    public let title: String
    public let subtitle: String?
    public let defaultWidth: Int32
    public let defaultHeight: Int32

    private var sidebar: PineSidebar?
    private var contentBuilder: (() -> WidgetPtr)?
    private var statusBar: PineStatusBar?

    public init(_ title: String, subtitle: String? = nil, width: Int32 = 1200, height: Int32 = 800) {
        self.title = title
        self.subtitle = subtitle
        self.defaultWidth = width
        self.defaultHeight = height
    }

    @discardableResult
    public func sidebar(_ sidebar: PineSidebar) -> PineWindow { self.sidebar = sidebar; return self }

    @discardableResult
    public func content(_ builder: @escaping () -> WidgetPtr) -> PineWindow { self.contentBuilder = builder; return self }

    @discardableResult
    public func statusBar(_ bar: PineStatusBar) -> PineWindow { self.statusBar = bar; return self }

    func realize(app: UnsafeMutablePointer<GtkApplication>) {
        let window = gtk_application_window_new(app)!
        windowSetTitle(window, title: title)
        windowSetDefaultSize(window, width: defaultWidth, height: defaultHeight)

        let outerBox = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 0)
        setVExpand(outerBox)

        let mainBox = makeBox(GTK_ORIENTATION_HORIZONTAL, spacing: 0)
        setVExpand(mainBox)

        if let sidebar = self.sidebar { boxAppend(mainBox, child: sidebar.build()) }

        if let builder = self.contentBuilder {
            let content = builder()
            setHExpand(content)
            boxAppend(mainBox, child: content)
        } else {
            let placeholder = makeLabel("No content")
            setHExpand(placeholder); setVExpand(placeholder)
            boxAppend(mainBox, child: placeholder)
        }

        boxAppend(outerBox, child: mainBox)
        if let bar = self.statusBar { boxAppend(outerBox, child: bar.build()) }

        PineTheme.apply()
        windowSetChild(window, child: outerBox)
        windowPresent(window)
    }
}
