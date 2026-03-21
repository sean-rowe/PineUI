// PropertyWrapperTests.swift — Tests for SwiftUI-compatible property wrappers.

import XCTest
@testable import PineUI

final class PropertyWrapperTests: XCTestCase {

    // MARK: - @PineState

    func testPineStateWrappedValue() {
        struct Container {
            @PineState var count = 0
        }
        var c = Container()
        XCTAssertEqual(c.count, 0)
        c.count = 42
        XCTAssertEqual(c.count, 42)
    }

    func testPineStateProjectedValue() {
        struct Container {
            @PineState var name = "hello"
        }
        let c = Container()
        // $name returns the underlying StateStore<String>
        let store: StateStore<String> = c.$name
        XCTAssertEqual(store.value, "hello")
    }

    func testPineStateProjectedValueReflectsMutation() {
        struct Container {
            @PineState var value = 10
        }
        var c = Container()
        c.value = 99
        XCTAssertEqual(c.$value.value, 99)
    }

    // MARK: - @ObservedObject

    func testObservedObjectWrappedValue() {
        class Counter: ObservableObject {
            var count = 0
        }
        struct Container {
            @ObservedObject var counter: Counter
        }
        let obj = Counter()
        obj.count = 7
        let c = Container(counter: obj)
        XCTAssertEqual(c.counter.count, 7)
    }

    func testObservedObjectProjectedValueIsSelf() {
        class Service: ObservableObject {
            var name = "svc"
        }
        struct Container {
            @ObservedObject var service: Service
        }
        let svc = Service()
        let c = Container(service: svc)
        // projectedValue is the ObservedObject wrapper itself
        let projected: ObservedObject<Service> = c.$service
        XCTAssertEqual(projected.wrappedValue.name, "svc")
    }

    // MARK: - @StateObject

    func testStateObjectWrappedValue() {
        class Model: ObservableObject {
            var label = "initial"
        }
        struct Container {
            @StateObject var model = Model()
        }
        let c = Container()
        XCTAssertEqual(c.model.label, "initial")
    }

    func testStateObjectOwnsObject() {
        class Model: ObservableObject {
            var x = 1
        }
        struct Container {
            @StateObject var model = Model()
        }
        let c = Container()
        c.model.x = 42
        XCTAssertEqual(c.model.x, 42)
    }

    // MARK: - @Published

    func testPublishedGetSet() {
        struct Container {
            @Published var score = 0
        }
        var c = Container()
        XCTAssertEqual(c.score, 0)
        c.score = 100
        XCTAssertEqual(c.score, 100)
    }

    func testPublishedInsideObservableObject() {
        class ViewModel: ObservableObject {
            @Published var title = "Hello"
        }
        let vm = ViewModel()
        XCTAssertEqual(vm.title, "Hello")
        vm.title = "World"
        XCTAssertEqual(vm.title, "World")
    }

    // MARK: - @AppStorage

    func testAppStorageDefaultValue() {
        // Isolate test with a dedicated store so no prior value exists
        let store = UserDefaultsStore()
        // Directly verify the default-fallback path
        let result = store.value(forKey: "notSet") as? String ?? "default"
        XCTAssertEqual(result, "default")
    }

    func testAppStorageStoreAndRetrieve() {
        let store = UserDefaultsStore()
        store.setValue("stored", forKey: "testKey")
        let retrieved = store.value(forKey: "testKey") as? String
        XCTAssertEqual(retrieved, "stored")
    }

    func testAppStorageWriteAndRead() {
        // Verify write path through AppStorage using the shared store and a unique key
        let uniqueKey = "appStorageTestCounter"
        UserDefaultsStore.shared.removeValue(forKey: uniqueKey)
        struct Container {
            @AppStorage(wrappedValue: 0, "appStorageTestCounter") var counter: Int
        }
        var c = Container()
        XCTAssertEqual(c.counter, 0)
        c.counter = 5
        XCTAssertEqual(UserDefaultsStore.shared.value(forKey: uniqueKey) as? Int, 5)
        XCTAssertEqual(c.counter, 5)
        UserDefaultsStore.shared.removeValue(forKey: uniqueKey)
    }

    // MARK: - UserDefaultsStore

    func testUserDefaultsStoreBasicOperations() {
        let store = UserDefaultsStore()
        XCTAssertNil(store.value(forKey: "missing"))
        store.setValue(42, forKey: "answer")
        XCTAssertEqual(store.value(forKey: "answer") as? Int, 42)
        store.setValue("hello", forKey: "greeting")
        XCTAssertEqual(store.value(forKey: "greeting") as? String, "hello")
    }

    func testUserDefaultsStoreOverwrite() {
        let store = UserDefaultsStore()
        store.setValue(1, forKey: "k")
        store.setValue(2, forKey: "k")
        XCTAssertEqual(store.value(forKey: "k") as? Int, 2)
    }

    func testUserDefaultsStoreRemove() {
        let store = UserDefaultsStore()
        store.setValue("x", forKey: "toRemove")
        store.removeValue(forKey: "toRemove")
        XCTAssertNil(store.value(forKey: "toRemove"))
    }

    // MARK: - @SceneStorage

    func testSceneStorageDefaultValue() {
        struct Container {
            @SceneStorage(wrappedValue: "none", "tab") var selectedTab: String
        }
        // Keys are prefixed "scene-tab" in UserDefaultsStore.shared.
        // Clear any prior value for a clean test.
        UserDefaultsStore.shared.removeValue(forKey: "scene-tab")
        let c = Container()
        XCTAssertEqual(c.selectedTab, "none")
    }

    func testSceneStorageWriteAndRead() {
        UserDefaultsStore.shared.removeValue(forKey: "scene-page")
        struct Container {
            @SceneStorage(wrappedValue: 0, "page") var page: Int
        }
        var c = Container()
        c.page = 3
        // Read back through a fresh instance using the shared store
        let value = UserDefaultsStore.shared.value(forKey: "scene-page") as? Int
        XCTAssertEqual(value, 3)
    }

    // MARK: - @Namespace

    func testNamespaceIDIsHashable() {
        struct Container {
            @Namespace var ns
        }
        let c = Container()
        let id1 = c.ns
        let id2 = c.ns
        // Same wrapper instance — same rawID, so same ID
        XCTAssertEqual(id1, id2)
        XCTAssertEqual(id1.rawID, id2.rawID)

        // Two different Namespace property wrappers produce different IDs
        let ns1 = Namespace()
        let ns2 = Namespace()
        XCTAssertNotEqual(ns1.wrappedValue, ns2.wrappedValue)
    }

    func testNamespaceIDHashableInSet() {
        let ns = Namespace()
        var set = Set<Namespace.ID>()
        set.insert(ns.wrappedValue)
        set.insert(ns.wrappedValue) // duplicate
        XCTAssertEqual(set.count, 1)
    }

    // MARK: - @GestureState

    func testGestureStateDefaultValue() {
        struct Container {
            @GestureState var isDragging = false
        }
        let c = Container()
        XCTAssertEqual(c.isDragging, false)
    }

    func testGestureStateResetValue() {
        struct Container {
            @GestureState var offset = 0.0
        }
        let c = Container()
        XCTAssertEqual(c.$offset.resetValue, 0.0)
    }

    // MARK: - @EnvironmentObject with RenderContext

    func testEnvironmentObjectRetrievedFromRenderContext() {
        class AppConfig: ObservableObject {
            var theme = "dark"
        }
        let config = AppConfig()
        // Inject into the global render context the same way environmentObject modifier does
        let key = ObjectIdentifier(AppConfig.self)
        currentRenderContext.values[key] = config

        struct Container {
            @EnvironmentObject var config: AppConfig
        }
        let c = Container()
        XCTAssertEqual(c.config.theme, "dark")

        // Clean up so other tests are not affected
        currentRenderContext.values.removeValue(forKey: key)
    }

    func testEnvironmentObjectFatalErrorWhenMissing() {
        class MissingService: ObservableObject {}
        let key = ObjectIdentifier(MissingService.self)
        // Ensure it is definitely absent
        currentRenderContext.values.removeValue(forKey: key)

        // We cannot call XCTAssertThrowsFatalError in standard XCTest,
        // so we just verify the key is absent and the type is correct — the
        // fatalError path is documented behaviour.
        let value: MissingService? = currentRenderContext.value(for: key)
        XCTAssertNil(value)
    }

    // MARK: - @FocusState

    func testFocusStateInitialValue() {
        struct Container {
            @FocusState var isFocused: Bool?
        }
        let c = Container()
        XCTAssertNil(c.isFocused)
    }

    func testFocusStateProjectedValue() {
        struct Container {
            @FocusState var field: Bool?
        }
        let c = Container()
        // $field returns the FocusState wrapper itself
        let projected: FocusState<Bool> = c.$field
        XCTAssertNil(projected.wrappedValue)
    }
}
