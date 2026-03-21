// Environment.swift — Environment value propagation for PineUI.

import CGTK4

/// A context that holds environment values, propagated down the view tree.
public class RenderContext {
    public var values: [ObjectIdentifier: Any] = [:]
    public var parent: RenderContext?

    public init() {}

    /// Create a child context that inherits from this one.
    public func child() -> RenderContext {
        let c = RenderContext()
        c.parent = self
        return c
    }

    /// Look up a value, walking up the parent chain.
    public func value<T>(for key: ObjectIdentifier) -> T? {
        if let v = values[key] as? T { return v }
        return parent?.value(for: key)
    }
}

/// Global render context — used by environment modifiers.
public var currentRenderContext = RenderContext()

/// Protocol for defining environment keys (mirrors SwiftUI's EnvironmentKey).
public protocol EnvironmentKey {
    associatedtype Value
    static var defaultValue: Value { get }
}

/// A collection of environment values (mirrors SwiftUI's EnvironmentValues).
public struct EnvironmentValues {
    private var storage: [ObjectIdentifier: Any] = [:]

    public init() {}

    public subscript<K: EnvironmentKey>(key: K.Type) -> K.Value {
        get { storage[ObjectIdentifier(key)] as? K.Value ?? K.defaultValue }
        set { storage[ObjectIdentifier(key)] = newValue }
    }
}
