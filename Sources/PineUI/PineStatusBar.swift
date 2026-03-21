// PineStatusBar.swift — Bottom status bar for windows.

import CGTK4

public struct StatusItem {
    public let text: String
    public let icon: String?

    public init(_ text: String, icon: String? = nil) {
        self.text = text
        self.icon = icon
    }
}

public class PineStatusBar {
    private var leftItems: [StatusItem] = []
    private var centerItems: [StatusItem] = []
    private var rightItems: [StatusItem] = []

    public init() {}

    @discardableResult
    public func left(_ items: StatusItem...) -> PineStatusBar {
        leftItems.append(contentsOf: items)
        return self
    }

    @discardableResult
    public func center(_ items: StatusItem...) -> PineStatusBar {
        centerItems.append(contentsOf: items)
        return self
    }

    @discardableResult
    public func right(_ items: StatusItem...) -> PineStatusBar {
        rightItems.append(contentsOf: items)
        return self
    }

    func build() -> WidgetPtr {
        let bar = makeBox(GTK_ORIENTATION_HORIZONTAL, spacing: 8)
        addCssClass(bar, "pine-status-bar")

        let leftBox = makeBox(GTK_ORIENTATION_HORIZONTAL, spacing: 6)
        setHAlign(leftBox, align: GTK_ALIGN_START)
        setHExpand(leftBox)
        for item in leftItems { appendStatusItem(to: leftBox, item: item) }
        boxAppend(bar, child: leftBox)

        let centerBox = makeBox(GTK_ORIENTATION_HORIZONTAL, spacing: 6)
        setHAlign(centerBox, align: GTK_ALIGN_CENTER)
        for item in centerItems { appendStatusItem(to: centerBox, item: item) }
        boxAppend(bar, child: centerBox)

        let rightBox = makeBox(GTK_ORIENTATION_HORIZONTAL, spacing: 6)
        setHAlign(rightBox, align: GTK_ALIGN_END)
        setHExpand(rightBox)
        for item in rightItems { appendStatusItem(to: rightBox, item: item) }
        boxAppend(bar, child: rightBox)

        return bar
    }

    private func appendStatusItem(to box: WidgetPtr, item: StatusItem) {
        if let icon = item.icon {
            let img = makeImage(iconName: icon)
            boxAppend(box, child: img)
        }
        let label = makeLabel(item.text)
        addCssClass(label, "pine-status-label")
        boxAppend(box, child: label)
    }
}
