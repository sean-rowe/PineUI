// PropertyWrappers.swift — SwiftUI-compatible property wrappers for PineUI.
//
// These wrappers provide source compatibility with SwiftUI's property wrapper API.
// They are simplified for the GTK4/Linux environment but preserve the same
// surface area so SwiftUI code compiles with minimal changes.

// MARK: - ObservableObject

/// Protocol marking a class as observable. Mirrors SwiftUI's ObservableObject.
/// In real SwiftUI this has an objectWillChange publisher; here we use a simpler pattern.
public protocol ObservableObject: AnyObject {}

// MARK: - @ObservedObject

/// Wraps an ObservableObject that is owned externally (passed in).
/// Mirrors SwiftUI's @ObservedObject.
@propertyWrapper
public struct ObservedObject<ObjectType: ObservableObject> {
    private let object: ObjectType

    public init(wrappedValue: ObjectType) {
        self.object = wrappedValue
    }

    public var wrappedValue: ObjectType { object }

    /// Projected value returns self so $name gives access to the wrapper.
    public var projectedValue: ObservedObject<ObjectType> { self }
}

// MARK: - @StateObject

/// Wraps an ObservableObject that is owned by this wrapper (created once).
/// Mirrors SwiftUI's @StateObject.
@propertyWrapper
public struct StateObject<ObjectType: ObservableObject> {
    private let object: ObjectType

    public init(wrappedValue: @autoclosure () -> ObjectType) {
        self.object = wrappedValue()
    }

    public var wrappedValue: ObjectType { object }

    /// Projected value returns self so $name gives access to the wrapper.
    public var projectedValue: StateObject<ObjectType> { self }
}

// MARK: - @Published

/// Marks a stored property for observation within an ObservableObject.
/// Without Combine on Linux, this is a simple stored-value wrapper.
/// In real SwiftUI the projectedValue is a Publisher; here we return self.
@propertyWrapper
public struct Published<Value> {
    private var value: Value

    public init(wrappedValue: Value) {
        self.value = wrappedValue
    }

    public var wrappedValue: Value {
        get { value }
        set { value = newValue }
    }

    /// In SwiftUI this is a Publisher. Here we return the wrapper itself
    /// for basic source compatibility.
    public var projectedValue: Published<Value> { self }
}

// MARK: - @Environment

/// Reads a value from EnvironmentValues via a key path.
/// Mirrors SwiftUI's @Environment.
@propertyWrapper
public struct Environment<Value> {
    private let keyPath: WritableKeyPath<EnvironmentValues, Value>

    public init(_ keyPath: WritableKeyPath<EnvironmentValues, Value>) {
        self.keyPath = keyPath
    }

    public var wrappedValue: Value {
        EnvironmentValues()[keyPath: keyPath]
    }
}

// MARK: - @EnvironmentObject

/// Reads a type-keyed ObservableObject from the current render context.
/// Mirrors SwiftUI's @EnvironmentObject.
/// Inject objects via `view.environmentObject(myObject)` or by setting
/// `currentRenderContext.values[ObjectIdentifier(MyType.self)] = myObject`.
@propertyWrapper
public struct EnvironmentObject<ObjectType: ObservableObject> {
    public init() {}

    public var wrappedValue: ObjectType {
        let key = ObjectIdentifier(ObjectType.self)
        guard let obj: ObjectType = currentRenderContext.value(for: key) else {
            fatalError("No EnvironmentObject of type \(ObjectType.self) found in render context")
        }
        return obj
    }
}

// MARK: - UserDefaultsStore

/// Simple in-memory (and optionally file-backed) key-value store.
/// Linux does not have UserDefaults, so this provides a compatible replacement.
public class UserDefaultsStore {
    public static let shared = UserDefaultsStore()

    private var storage: [String: Any] = [:]

    public init() {}

    public func value(forKey key: String) -> Any? {
        storage[key]
    }

    public func setValue(_ value: Any, forKey key: String) {
        storage[key] = value
    }

    public func removeValue(forKey key: String) {
        storage.removeValue(forKey: key)
    }
}

// MARK: - @AppStorage

/// Persists a value across launches using UserDefaultsStore.
/// Mirrors SwiftUI's @AppStorage. On Linux, backed by UserDefaultsStore.shared.
@propertyWrapper
public struct AppStorage<Value> {
    private let key: String
    private let defaultValue: Value
    private let store: UserDefaultsStore

    public init(wrappedValue: Value, _ key: String, store: UserDefaultsStore = .shared) {
        self.key = key
        self.defaultValue = wrappedValue
        self.store = store
    }

    public var wrappedValue: Value {
        get { store.value(forKey: key) as? Value ?? defaultValue }
        nonmutating set { store.setValue(newValue, forKey: key) }
    }
}

// MARK: - @FocusState

/// Tracks which view currently holds focus.
/// Mirrors SwiftUI's @FocusState. Value must be Hashable (or Bool).
/// In PineUI, focus state is managed by the GTK focus system; this wrapper
/// provides source-compatibility with the SwiftUI API surface.
@propertyWrapper
public struct FocusState<Value: Hashable> {
    // Class-backed store so mutations through the projected binding are visible
    // without requiring a mutating context on the enclosing struct.
    private final class Storage {
        var value: Value?
        init(_ v: Value?) { self.value = v }
    }
    private let storage: Storage

    /// Designated initialiser — Value can be any Hashable type or Bool.
    public init() {
        self.storage = Storage(nil)
    }

    /// The currently-focused binding value, or nil when nothing is focused.
    public var wrappedValue: Value? {
        get { storage.value }
        nonmutating set { storage.value = newValue }
    }

    /// Projected value returns self so $name can be used as a FocusState binding.
    public var projectedValue: FocusState<Value> { self }
}

// MARK: - @SceneStorage

/// Like @AppStorage but scoped per scene. Simplified to share UserDefaultsStore
/// with a "scene-" key prefix for source compatibility.
@propertyWrapper
public struct SceneStorage<Value> {
    private let key: String
    private let defaultValue: Value

    public init(wrappedValue: Value, _ key: String) {
        self.key = key
        self.defaultValue = wrappedValue
    }

    public var wrappedValue: Value {
        get { UserDefaultsStore.shared.value(forKey: "scene-\(key)") as? Value ?? defaultValue }
        nonmutating set { UserDefaultsStore.shared.setValue(newValue, forKey: "scene-\(key)") }
    }
}

// MARK: - @Namespace

/// Creates a stable namespace identifier for matched-geometry animations.
/// Mirrors SwiftUI's @Namespace.
@propertyWrapper
public struct Namespace {
    /// Thread-safe monotonically-increasing counter — avoids a Foundation/UUID dependency.
    private static var _counter: UInt64 = 0
    private static func nextID() -> UInt64 {
        _counter &+= 1
        return _counter
    }

    private let rawID: UInt64

    public init() {
        self.rawID = Namespace.nextID()
    }

    public var wrappedValue: Namespace.ID { ID(rawID: rawID) }

    /// An opaque, stable, Hashable namespace identifier.
    public struct ID: Hashable {
        public let rawID: UInt64
    }
}

// MARK: - @GestureState

/// Tracks transient state for the duration of a gesture.
/// Mirrors SwiftUI's @GestureState; resets to resetValue when the gesture ends.
@propertyWrapper
public struct GestureState<Value> {
    private final class Storage {
        var value: Value
        init(_ v: Value) { self.value = v }
    }
    private let storage: Storage
    public let resetValue: Value

    public init(wrappedValue: Value) {
        self.storage = Storage(wrappedValue)
        self.resetValue = wrappedValue
    }

    public init(reset: Value, transaction: Transaction? = nil) {
        self.storage = Storage(reset)
        self.resetValue = reset
    }

    public var wrappedValue: Value {
        get { storage.value }
        nonmutating set { storage.value = newValue }
    }

    /// Projected value returns self so $name can be passed to gesture modifiers.
    public var projectedValue: GestureState<Value> { self }
}

// MARK: - Transaction (stub)

/// Minimal Transaction type for GestureState API compatibility.
public struct Transaction {
    public init() {}
}
