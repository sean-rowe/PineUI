// Animation.swift — Top-level animation context and withAnimation() for PineUI.
//
// Provides a SwiftUI-compatible `withAnimation(_:_:)` free function that
// installs an animation context for the duration of a state-mutating closure.
//
// GTK4 note: Actual CSS transitions are applied per-widget via the
// `.animation(_:)` modifier. `withAnimation` records the current animation
// so future modifier applications (or state-driven rebuilds) can read it.

// MARK: - Animation context

/// Global animation context, readable by modifiers during a `withAnimation` block.
public final class PineAnimationContext {

    /// The animation currently in effect, or `nil` if no animation context is active.
    public static var current: PineAnimation?
}

// MARK: - withAnimation

/// Performs `body` with `animation` set as the active animation context.
///
/// Usage:
/// ```swift
/// withAnimation(.easeInOut) {
///     isExpanded = true   // state mutation; CSS transitions fire on the next render
/// }
/// ```
///
/// - Parameters:
///   - animation: The `PineAnimation` to apply during the body closure.
///   - body: A closure that mutates state or triggers view updates.
public func withAnimation(
    _ animation: PineAnimation = .default,
    _ body: () -> Void
) {
    let previous = PineAnimationContext.current
    PineAnimationContext.current = animation
    body()
    PineAnimationContext.current = previous
}
