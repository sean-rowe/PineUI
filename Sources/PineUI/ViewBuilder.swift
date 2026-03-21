// ViewBuilder.swift — Result builder for declarative view composition.
//
// This is the magic that makes SwiftUI-like syntax work:
//   VStack {
//       Text("Hello")
//       Text("World")
//   }
//
// Swift's @resultBuilder transforms this block into buildBlock() calls.

import CGTK4

/// A result builder that collects views into a TupleView.
@resultBuilder
public struct ViewBuilder {
    /// Single view passthrough.
    public static func buildBlock<V: View>(_ content: V) -> V {
        content
    }

    /// Two views → TupleView2.
    public static func buildBlock<V0: View, V1: View>(_ v0: V0, _ v1: V1) -> TupleView2<V0, V1> {
        TupleView2(v0, v1)
    }

    /// Three views.
    public static func buildBlock<V0: View, V1: View, V2: View>(_ v0: V0, _ v1: V1, _ v2: V2) -> TupleView3<V0, V1, V2> {
        TupleView3(v0, v1, v2)
    }

    /// Four views.
    public static func buildBlock<V0: View, V1: View, V2: View, V3: View>(
        _ v0: V0, _ v1: V1, _ v2: V2, _ v3: V3
    ) -> TupleView4<V0, V1, V2, V3> {
        TupleView4(v0, v1, v2, v3)
    }

    /// Five views.
    public static func buildBlock<V0: View, V1: View, V2: View, V3: View, V4: View>(
        _ v0: V0, _ v1: V1, _ v2: V2, _ v3: V3, _ v4: V4
    ) -> TupleView5<V0, V1, V2, V3, V4> {
        TupleView5(v0, v1, v2, v3, v4)
    }

    /// Six views.
    public static func buildBlock<V0: View, V1: View, V2: View, V3: View, V4: View, V5: View>(
        _ v0: V0, _ v1: V1, _ v2: V2, _ v3: V3, _ v4: V4, _ v5: V5
    ) -> ViewList {
        ViewList([AnyView(v0), AnyView(v1), AnyView(v2), AnyView(v3), AnyView(v4), AnyView(v5)])
    }

    /// Seven views.
    public static func buildBlock<V0: View, V1: View, V2: View, V3: View, V4: View, V5: View, V6: View>(
        _ v0: V0, _ v1: V1, _ v2: V2, _ v3: V3, _ v4: V4, _ v5: V5, _ v6: V6
    ) -> ViewList {
        ViewList([AnyView(v0), AnyView(v1), AnyView(v2), AnyView(v3), AnyView(v4), AnyView(v5), AnyView(v6)])
    }

    /// Eight views.
    public static func buildBlock<V0: View, V1: View, V2: View, V3: View, V4: View, V5: View, V6: View, V7: View>(
        _ v0: V0, _ v1: V1, _ v2: V2, _ v3: V3, _ v4: V4, _ v5: V5, _ v6: V6, _ v7: V7
    ) -> ViewList {
        ViewList([AnyView(v0), AnyView(v1), AnyView(v2), AnyView(v3), AnyView(v4), AnyView(v5), AnyView(v6), AnyView(v7)])
    }

    /// Nine views.
    public static func buildBlock<V0: View, V1: View, V2: View, V3: View, V4: View, V5: View, V6: View, V7: View, V8: View>(
        _ v0: V0, _ v1: V1, _ v2: V2, _ v3: V3, _ v4: V4, _ v5: V5, _ v6: V6, _ v7: V7, _ v8: V8
    ) -> ViewList {
        ViewList([AnyView(v0), AnyView(v1), AnyView(v2), AnyView(v3), AnyView(v4), AnyView(v5), AnyView(v6), AnyView(v7), AnyView(v8)])
    }

    /// Ten views.
    public static func buildBlock<V0: View, V1: View, V2: View, V3: View, V4: View, V5: View, V6: View, V7: View, V8: View, V9: View>(
        _ v0: V0, _ v1: V1, _ v2: V2, _ v3: V3, _ v4: V4, _ v5: V5, _ v6: V6, _ v7: V7, _ v8: V8, _ v9: V9
    ) -> ViewList {
        ViewList([AnyView(v0), AnyView(v1), AnyView(v2), AnyView(v3), AnyView(v4), AnyView(v5), AnyView(v6), AnyView(v7), AnyView(v8), AnyView(v9)])
    }

    /// Optional support (if statements without else).
    public static func buildOptional<V: View>(_ component: V?) -> OptionalView<V> {
        OptionalView(component)
    }

    /// Conditional first branch.
    public static func buildEither<TrueView: View, FalseView: View>(first: TrueView) -> ConditionalView<TrueView, FalseView> {
        .trueView(first)
    }

    /// Conditional second branch.
    public static func buildEither<TrueView: View, FalseView: View>(second: FalseView) -> ConditionalView<TrueView, FalseView> {
        .falseView(second)
    }
}

// MARK: - Multi-child protocol

/// Views that contain multiple children expose them here.
/// Parent containers (VStack, HStack) use this to arrange children
/// in the correct orientation instead of getting a pre-packed box.
public protocol MultiChildView {
    func renderChildren() -> [WidgetPtr]
}

// MARK: - Tuple views (hold multiple children)

public struct TupleView2<V0: View, V1: View>: View, GTKRenderable, MultiChildView, MultiChildTabView {
    let v0: V0, v1: V1
    init(_ v0: V0, _ v1: V1) { self.v0 = v0; self.v1 = v1 }
    public var body: Never { fatalError() }
    public var viewList: [any View] { [v0, v1] }
    public func renderChildren() -> [WidgetPtr] {
        flatRenderChildren(v0) + flatRenderChildren(v1)
    }
    public func renderChildrenForAxis(_ axis: GtkOrientation) -> [WidgetPtr] {
        flatRenderChildrenForAxis(v0, axis: axis) + flatRenderChildrenForAxis(v1, axis: axis)
    }
    public func collectTabItems() -> [TabItemView] {
        viewList.compactMap { $0 as? TabItemView }
    }
    public func renderGTK() -> WidgetPtr {
        let box = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 0)
        for child in renderChildren() { boxAppend(box, child: child) }
        return box
    }
}

public struct TupleView3<V0: View, V1: View, V2: View>: View, GTKRenderable, MultiChildView, MultiChildTabView {
    let v0: V0, v1: V1, v2: V2
    init(_ v0: V0, _ v1: V1, _ v2: V2) { self.v0 = v0; self.v1 = v1; self.v2 = v2 }
    public var body: Never { fatalError() }
    public var viewList: [any View] { [v0, v1, v2] }
    public func renderChildren() -> [WidgetPtr] {
        flatRenderChildren(v0) + flatRenderChildren(v1) + flatRenderChildren(v2)
    }
    public func renderChildrenForAxis(_ axis: GtkOrientation) -> [WidgetPtr] {
        flatRenderChildrenForAxis(v0, axis: axis) + flatRenderChildrenForAxis(v1, axis: axis) + flatRenderChildrenForAxis(v2, axis: axis)
    }
    public func collectTabItems() -> [TabItemView] {
        viewList.compactMap { $0 as? TabItemView }
    }
    public func renderGTK() -> WidgetPtr {
        let box = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 0)
        for child in renderChildren() { boxAppend(box, child: child) }
        return box
    }
}

public struct TupleView4<V0: View, V1: View, V2: View, V3: View>: View, GTKRenderable, MultiChildView, MultiChildTabView {
    let v0: V0, v1: V1, v2: V2, v3: V3
    init(_ v0: V0, _ v1: V1, _ v2: V2, _ v3: V3) { self.v0 = v0; self.v1 = v1; self.v2 = v2; self.v3 = v3 }
    public var body: Never { fatalError() }
    public var viewList: [any View] { [v0, v1, v2, v3] }
    public func renderChildren() -> [WidgetPtr] {
        flatRenderChildren(v0) + flatRenderChildren(v1) + flatRenderChildren(v2) + flatRenderChildren(v3)
    }
    public func renderChildrenForAxis(_ axis: GtkOrientation) -> [WidgetPtr] {
        flatRenderChildrenForAxis(v0, axis: axis) + flatRenderChildrenForAxis(v1, axis: axis) + flatRenderChildrenForAxis(v2, axis: axis) + flatRenderChildrenForAxis(v3, axis: axis)
    }
    public func collectTabItems() -> [TabItemView] {
        viewList.compactMap { $0 as? TabItemView }
    }
    public func renderGTK() -> WidgetPtr {
        let box = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 0)
        for child in renderChildren() { boxAppend(box, child: child) }
        return box
    }
}

public struct TupleView5<V0: View, V1: View, V2: View, V3: View, V4: View>: View, GTKRenderable, MultiChildView, MultiChildTabView {
    let v0: V0, v1: V1, v2: V2, v3: V3, v4: V4
    init(_ v0: V0, _ v1: V1, _ v2: V2, _ v3: V3, _ v4: V4) { self.v0 = v0; self.v1 = v1; self.v2 = v2; self.v3 = v3; self.v4 = v4 }
    public var body: Never { fatalError() }
    public var viewList: [any View] { [v0, v1, v2, v3, v4] }
    public func renderChildren() -> [WidgetPtr] {
        flatRenderChildren(v0) + flatRenderChildren(v1) + flatRenderChildren(v2) + flatRenderChildren(v3) + flatRenderChildren(v4)
    }
    public func renderChildrenForAxis(_ axis: GtkOrientation) -> [WidgetPtr] {
        flatRenderChildrenForAxis(v0, axis: axis) + flatRenderChildrenForAxis(v1, axis: axis) + flatRenderChildrenForAxis(v2, axis: axis) + flatRenderChildrenForAxis(v3, axis: axis) + flatRenderChildrenForAxis(v4, axis: axis)
    }
    public func collectTabItems() -> [TabItemView] {
        viewList.compactMap { $0 as? TabItemView }
    }
    public func renderGTK() -> WidgetPtr {
        let box = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 0)
        for child in renderChildren() { boxAppend(box, child: child) }
        return box
    }
}

// MARK: - Type-erased view (for 6+ children)

/// Wraps any View into a type-erased container.
public struct AnyView: View, GTKRenderable {
    private let _render: () -> WidgetPtr
    private let _renderForAxis: (GtkOrientation) -> WidgetPtr
    let tabItem: TabItemView?

    public init<V: View>(_ view: V) {
        self._render = { render(view) }
        self.tabItem = view as? TabItemView
        if let spacer = view as? AxisAwareSpacer {
            self._renderForAxis = { axis in spacer.renderForAxis(axis) }
        } else {
            self._renderForAxis = { _ in render(view) }
        }
    }

    public var body: Never { fatalError() }
    public func renderGTK() -> WidgetPtr { _render() }
    func renderForAxis(_ axis: GtkOrientation) -> WidgetPtr { _renderForAxis(axis) }
}

/// A list of type-erased views — used for 6-10 children in ViewBuilder.
public struct ViewList: View, GTKRenderable, MultiChildView, MultiChildTabView {
    let views: [AnyView]

    init(_ views: [AnyView]) {
        self.views = views
    }

    public func collectTabItems() -> [TabItemView] {
        views.compactMap { $0.tabItem }
    }

    public var body: Never { fatalError() }

    public func renderChildren() -> [WidgetPtr] {
        views.map { $0.renderGTK() }
    }

    public func renderChildrenForAxis(_ axis: GtkOrientation) -> [WidgetPtr] {
        views.map { $0.renderForAxis(axis) }
    }

    public func renderGTK() -> WidgetPtr {
        let box = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 0)
        for child in renderChildren() { boxAppend(box, child: child) }
        return box
    }
}

/// Recursively flattens nested MultiChildViews into individual widgets.
/// If a view is itself a MultiChildView (e.g. nested TupleViews),
/// extract its children rather than rendering it as a single box.
public func flatRenderChildren<V: View>(_ view: V) -> [WidgetPtr] {
    if let multi = view as? MultiChildView {
        return multi.renderChildren()
    }
    return [render(view)]
}

/// Render a single child, respecting axis-aware spacers.
public func renderChildForAxis<V: View>(_ view: V, axis: GtkOrientation) -> WidgetPtr {
    if let spacer = view as? AxisAwareSpacer {
        return spacer.renderForAxis(axis)
    }
    return render(view)
}

/// Recursively flattens children with axis awareness for spacers.
public func flatRenderChildrenForAxis<V: View>(_ view: V, axis: GtkOrientation) -> [WidgetPtr] {
    if let multi = view as? MultiChildView {
        return multi.renderChildrenForAxis(axis)
    }
    return [renderChildForAxis(view, axis: axis)]
}

extension MultiChildView {
    /// Default axis-aware rendering delegates to renderChildren().
    public func renderChildrenForAxis(_ axis: GtkOrientation) -> [WidgetPtr] {
        renderChildren()
    }
}

// MARK: - Conditional views

public struct OptionalView<V: View>: View, GTKRenderable {
    let content: V?
    init(_ content: V?) { self.content = content }
    public var body: Never { fatalError() }
    public func renderGTK() -> WidgetPtr {
        if let content = content {
            return render(content)
        }
        // Empty placeholder.
        return makeBox(GTK_ORIENTATION_VERTICAL, spacing: 0)
    }
}

public enum ConditionalView<TrueView: View, FalseView: View>: View, GTKRenderable {
    case trueView(TrueView)
    case falseView(FalseView)
    public var body: Never { fatalError() }
    public func renderGTK() -> WidgetPtr {
        switch self {
        case .trueView(let v): return render(v)
        case .falseView(let v): return render(v)
        }
    }
}
