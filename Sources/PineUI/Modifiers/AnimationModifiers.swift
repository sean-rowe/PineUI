// AnimationModifiers.swift — SwiftUI-compatible animation modifiers for PineUI.
//
// Implements 7 animation modifiers:
//   animation, transition, matchedGeometryEffect, contentTransition,
//   phaseAnimator, keyframeAnimator, sensoryFeedback
//
// GTK4 note: Animations are implemented via CSS `transition` property.
// GTK4 does NOT have GtkPropertyTransition — CSS transitions are the
// correct approach for declarative per-widget animation.

import CGTK4

// MARK: - Supporting Types

/// Animation curve and duration, mapping to CSS transition values.
public enum PineAnimation {
    case `default`
    case easeIn
    case easeOut
    case easeInOut
    case linear
    case spring
    case none

    /// CSS `transition` shorthand for this animation.
    var css: String {
        switch self {
        case .default, .easeInOut: return "all 0.3s ease-in-out"
        case .easeIn:              return "all 0.3s ease-in"
        case .easeOut:             return "all 0.3s ease-out"
        case .linear:              return "all 0.3s linear"
        case .spring:              return "all 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55)"
        case .none:                return "none"
        }
    }
}

/// Transition types matching SwiftUI's AnyTransition.
public enum AnyTransition {
    case opacity
    case slide
    case scale
    case move(edge: Edge)
    case identity
}

/// Content transition modes matching SwiftUI's ContentTransition.
public enum ContentTransition {
    case opacity
    case interpolate
    case identity
    case numericText
}

/// Sensory feedback types matching SwiftUI's SensoryFeedback.
public enum SensoryFeedbackType {
    case success, warning, error, selection, impact, alignment
}

// MARK: - Namespace for matchedGeometryEffect

/// A namespace for matched geometry effects (type identity only on Linux/GTK4).
public class Namespace {
    public init() {}
}

// MARK: - Animation Modifiers

extension View {

    // MARK: 1. animation

    /// Applies a CSS transition to animate property changes on this widget.
    ///
    /// Sets `transition: <css>` on the widget, which GTK4's CSS engine will
    /// honour when animated properties (opacity, transform, etc.) change.
    public func animation(_ animation: PineAnimation) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "transition: \(animation.css);")
        }
    }

    // MARK: 2. transition

    /// Applies a CSS transition targeting specific properties based on the
    /// transition type.
    ///
    /// Opacity/identity transitions target `opacity`; slide and move transitions
    /// target `margin` properties; scale targets `transform`.
    public func transition(_ transition: AnyTransition) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            let css: String
            switch transition {
            case .opacity:
                css = "transition: opacity 0.3s ease-in-out;"
            case .slide:
                css = "transition: margin 0.3s ease-in-out, opacity 0.3s ease-in-out;"
            case .scale:
                css = "transition: transform 0.3s ease-in-out, opacity 0.3s ease-in-out;"
            case .move(let edge):
                switch edge {
                case .leading:
                    css = "transition: margin-left 0.3s ease-in-out, opacity 0.3s ease-in-out;"
                case .trailing:
                    css = "transition: margin-right 0.3s ease-in-out, opacity 0.3s ease-in-out;"
                case .top:
                    css = "transition: margin-top 0.3s ease-in-out, opacity 0.3s ease-in-out;"
                case .bottom:
                    css = "transition: margin-bottom 0.3s ease-in-out, opacity 0.3s ease-in-out;"
                }
            case .identity:
                css = "transition: none;"
            }
            applyCss(w, css)
        }
    }

    // MARK: 3. matchedGeometryEffect

    /// Synchronises geometry between views sharing the same `id` in a `namespace`.
    ///
    /// STUB: geometry matching requires a layout-pass coordinator that does not
    /// exist in GTK4's CSS model. No visual effect is applied.
    public func matchedGeometryEffect(
        id: AnyHashable,
        in namespace: Namespace
    ) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: matched geometry requires a two-pass layout coordinator —
            // not available in GTK4's CSS model.
        }
    }

    // MARK: 4. contentTransition

    /// Applies a CSS transition to animate content changes within this widget.
    ///
    /// For `.opacity` and `.numericText`, a cross-fade via `opacity` transition
    /// is applied. `.interpolate` and `.identity` are no-ops on GTK4.
    public func contentTransition(_ transition: ContentTransition) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            switch transition {
            case .opacity, .numericText:
                applyCss(w, "transition: opacity 0.25s ease-in-out;")
            case .interpolate:
                // Interpolated content transitions are rendering-engine specific;
                // approximate with a short opacity cross-fade.
                applyCss(w, "transition: opacity 0.15s linear;")
            case .identity:
                // No animation — instant content swap.
                break
            }
        }
    }

    // MARK: 5. phaseAnimator

    /// Cycles through `phases` and calls `content` for each phase, animating
    /// between them.
    ///
    /// STUB: phase animation requires a `g_timeout_add` timer loop driving
    /// state updates — not expressible as a pure CSS modifier. A real
    /// implementation would require PineUI's state/update infrastructure.
    public func phaseAnimator<Phase>(
        phases: [Phase],
        @ViewBuilder content: (Phase) -> some View
    ) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: phase animation requires g_timeout_add + state invalidation.
        }
    }

    // MARK: 6. keyframeAnimator

    /// Drives animation using keyframe tracks defined by `keyframes`.
    ///
    /// STUB: keyframe animation requires a timeline engine driving property
    /// updates on a timer — not available via GTK4 CSS alone. Would need
    /// g_timeout_add with interpolated CSS value injection.
    public func keyframeAnimator<Value>(
        initialValue: Value,
        @ViewBuilder content: (Value) -> some View,
        keyframes: (Value) -> some Any
    ) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: keyframe animation requires a timer-driven interpolation engine.
        }
    }

    // MARK: 7. sensoryFeedback

    /// Triggers sensory (haptic) feedback when `trigger` changes.
    ///
    /// STUB: desktop Linux has no haptic feedback API. This modifier is a no-op
    /// provided for SwiftUI API compatibility.
    public func sensoryFeedback<T: Equatable>(
        _ feedback: SensoryFeedbackType,
        trigger: T
    ) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: no haptic/sensory feedback API on desktop Linux/GTK4.
        }
    }
}
