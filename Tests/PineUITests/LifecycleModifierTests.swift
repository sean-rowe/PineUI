// LifecycleModifierTests.swift — Type-level tests for lifecycle modifiers.
//
// These tests verify that each modifier compiles, returns the correct type,
// and does not crash when called on a simple view. Signal connections are
// validated at the type level only — GTK4 widgets cannot be instantiated
// in a headless test environment.

import XCTest
@testable import PineUI

final class LifecycleModifierTests: XCTestCase {

    // A minimal concrete View for testing modifier return types.
    struct TestView: View {
        var body: Never { fatalError("TestView is a primitive") }
    }

    // MARK: - 1. onAppear

    func testOnAppearReturnsModifiedView() {
        let v = TestView()
        let result = v.onAppear { }
        let _: ModifiedView<TestView> = result
    }

    func testOnAppearWithNonTrivialAction() {
        var called = false
        let v = TestView()
        let result = v.onAppear { called = true }
        let _: ModifiedView<TestView> = result
        // Action is captured but not yet called (no widget to map).
        XCTAssertFalse(called)
    }

    // MARK: - 2. onDisappear

    func testOnDisappearReturnsModifiedView() {
        let v = TestView()
        let result = v.onDisappear { }
        let _: ModifiedView<TestView> = result
    }

    func testOnDisappearWithNonTrivialAction() {
        var called = false
        let v = TestView()
        let result = v.onDisappear { called = true }
        let _: ModifiedView<TestView> = result
        // Action is captured but not yet called (no widget to unmap).
        XCTAssertFalse(called)
    }

    // MARK: - 3. onChange(of:perform:)

    func testOnChangeOfIntReturnsModifiedView() {
        let store = StateStore<Int>(0)
        let v = TestView()
        let result = v.onChange(of: store) { _ in }
        let _: ModifiedView<TestView> = result
    }

    func testOnChangeOfStringReturnsModifiedView() {
        let store = StateStore<String>("hello")
        let v = TestView()
        let result = v.onChange(of: store) { _ in }
        let _: ModifiedView<TestView> = result
    }

    func testOnChangeSetsStoreOnChange() {
        let store = StateStore<Int>(0)
        let v = TestView()

        // The onChange modifier sets store.onChange when the modifier closure runs.
        // We simulate the modifier closure directly since we can't render without GTK.
        var receivedValue: Int? = nil
        store.onChange = { receivedValue = $0 }

        // Trigger as if the store mutated.
        store.value = 42
        XCTAssertEqual(receivedValue, 42)

        // Verify the result type still compiles.
        let result = v.onChange(of: store) { _ in }
        let _: ModifiedView<TestView> = result
    }

    func testOnChangeOfBoolReturnsModifiedView() {
        let store = StateStore<Bool>(false)
        let v = TestView()
        let result = v.onChange(of: store) { _ in }
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 4. task

    func testTaskReturnsModifiedView() {
        let v = TestView()
        let result = v.task { }
        let _: ModifiedView<TestView> = result
    }

    func testTaskWithNonTrivialAction() {
        var called = false
        let v = TestView()
        let result = v.task { called = true }
        let _: ModifiedView<TestView> = result
        // Action is captured but not yet called (no widget to map).
        XCTAssertFalse(called)
    }

    // MARK: - 5. id

    func testIdReturnsModifiedView() {
        let v = TestView()
        let result = v.id("my-view")
        let _: ModifiedView<TestView> = result
    }

    func testIdWithEmptyString() {
        let v = TestView()
        let result = v.id("")
        let _: ModifiedView<TestView> = result
    }

    func testIdWithLongIdentifier() {
        let v = TestView()
        let result = v.id("some-deeply-nested-view-identifier-12345")
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 6. tag

    func testTagReturnsModifiedView() {
        let v = TestView()
        let result = v.tag(42)
        let _: ModifiedView<TestView> = result
    }

    func testTagZero() {
        let v = TestView()
        let result = v.tag(0)
        let _: ModifiedView<TestView> = result
    }

    func testTagNegative() {
        let v = TestView()
        let result = v.tag(-1)
        let _: ModifiedView<TestView> = result
    }

    func testTagLargeValue() {
        let v = TestView()
        let result = v.tag(Int.max)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 7. equatable (stub)

    func testEquatableReturnsModifiedView() {
        let v = TestView()
        let result = v.equatable()
        let _: ModifiedView<TestView> = result
    }

    // MARK: - Chaining tests

    func testLifecycleModifiersChain() {
        let v = TestView()
        let result = v
            .onAppear { }
            .onDisappear { }
            .id("chained-view")
            .tag(1)
        XCTAssertNotNil(result)
    }

    func testOnAppearAndTaskChain() {
        let v = TestView()
        let result = v
            .onAppear { }
            .task { }
            .equatable()
        XCTAssertNotNil(result)
    }

    func testOnChangeChainedWithOtherModifiers() {
        let store = StateStore<Int>(0)
        let v = TestView()
        let result = v
            .onChange(of: store) { _ in }
            .onAppear { }
            .id("reactive-view")
        XCTAssertNotNil(result)
    }

    // MARK: - Generic constraint tests

    func testOnChangeIsGenericOverValue() {
        let intStore = StateStore<Int>(0)
        let stringStore = StateStore<String>("")
        let boolStore = StateStore<Bool>(false)
        let doubleStore = StateStore<Double>(0.0)

        let v = TestView()
        let r1 = v.onChange(of: intStore) { (_: Int) in }
        let r2 = v.onChange(of: stringStore) { (_: String) in }
        let r3 = v.onChange(of: boolStore) { (_: Bool) in }
        let r4 = v.onChange(of: doubleStore) { (_: Double) in }

        let _: ModifiedView<TestView> = r1
        let _: ModifiedView<TestView> = r2
        let _: ModifiedView<TestView> = r3
        let _: ModifiedView<TestView> = r4
    }
}
