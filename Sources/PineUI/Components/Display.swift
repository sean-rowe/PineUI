// Display.swift — ProgressView, Gauge, Badge.

import CGTK4

/// A progress indicator — determinate or indeterminate.
public struct ProgressView: View, GTKRenderable {
    let title: String?
    let value: Double?

    /// Indeterminate spinner.
    public init(_ title: String? = nil) {
        self.title = title
        self.value = nil
    }

    /// Determinate progress bar (0.0 to 1.0).
    public init(_ title: String? = nil, value: Double) {
        self.title = title
        self.value = value
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let box = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 4)

        if let title = title {
            let lbl = makeLabel(title)
            addCssClass(lbl, "pine-caption")
            setHAlign(lbl, align: GTK_ALIGN_START)
            boxAppend(box, child: lbl)
        }

        if let value = value {
            // Determinate progress bar.
            let bar = gtk_progress_bar_new()!
            gtk_progress_bar_set_fraction(OpaquePointer(bar), value)
            setHExpand(bar)
            boxAppend(box, child: bar)
        } else {
            // Indeterminate spinner.
            let spinner = gtk_spinner_new()!
            gtk_spinner_start(OpaquePointer(spinner))
            boxAppend(box, child: spinner)
        }

        return box
    }
}

/// A gauge showing a value within a range (like macOS Gauge).
public struct Gauge: View, GTKRenderable {
    let label: String
    let value: Double
    let min: Double
    let max: Double

    public init(_ label: String, value: Double, in range: ClosedRange<Double> = 0...1) {
        self.label = label
        self.value = value
        self.min = range.lowerBound
        self.max = range.upperBound
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let box = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 4)

        let row = makeBox(GTK_ORIENTATION_HORIZONTAL, spacing: 8)
        setHExpand(row)
        let lbl = makeLabel(label)
        setHExpand(lbl)
        setHAlign(lbl, align: GTK_ALIGN_START)
        boxAppend(row, child: lbl)

        let fraction = (value - min) / (max - min)
        let pctLabel = makeLabel("\(Int(fraction * 100))%")
        addCssClass(pctLabel, "pine-caption")
        boxAppend(row, child: pctLabel)
        boxAppend(box, child: row)

        let bar = gtk_level_bar_new_for_interval(min, max)!
        gtk_level_bar_set_value(OpaquePointer(bar), value)
        setHExpand(bar)
        boxAppend(box, child: bar)

        return box
    }
}

/// A small badge count (like notification badges).
public struct Badge: View, GTKRenderable {
    let count: Int

    public init(_ count: Int) {
        self.count = count
    }

    public var body: Never { fatalError() }

    public func renderGTK() -> WidgetPtr {
        let lbl = makeLabel("\(count)")
        addCssClass(lbl, "pine-sidebar-badge")
        return lbl
    }
}
