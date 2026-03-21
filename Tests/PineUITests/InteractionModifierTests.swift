// InteractionModifierTests.swift — Type-level tests for interaction modifiers.
//
// These tests verify that each modifier compiles, returns the correct type,
// and can be called without crashing (no GTK display required for type tests).

import XCTest
@testable import PineUI

final class InteractionModifierTests: XCTestCase {

    // A minimal concrete View for testing modifier return types.
    struct TestView: View {
        var body: Never { fatalError("TestView is a primitive") }
    }

    // MARK: - 1. onLongPressGesture

    func testOnLongPressGestureReturnsModifiedView() {
        let v = TestView()
        let result = v.onLongPressGesture(perform: {})
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 2. gesture

    func testGestureReturnsModifiedView() {
        // We can't create a real OpaquePointer in tests without GTK, so verify type signature only.
        // Type-level: verify the method exists with the correct signature.
        let _: (OpaquePointer) -> ModifiedView<TestView> = TestView().gesture
    }

    // MARK: - 3. highPriorityGesture

    func testHighPriorityGestureReturnsModifiedView() {
        let _: (OpaquePointer) -> ModifiedView<TestView> = TestView().highPriorityGesture
    }

    // MARK: - 4. simultaneousGesture

    func testSimultaneousGestureReturnsModifiedView() {
        let _: (OpaquePointer) -> ModifiedView<TestView> = TestView().simultaneousGesture
    }

    // MARK: - 5. allowsHitTesting

    func testAllowsHitTestingTrue() {
        let v = TestView()
        let result = v.allowsHitTesting(true)
        let _: ModifiedView<TestView> = result
    }

    func testAllowsHitTestingFalse() {
        let v = TestView()
        let result = v.allowsHitTesting(false)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 6. contentShape

    func testContentShapeReturnsModifiedView() {
        let v = TestView()
        let result = v.contentShape(.rectangle)
        let _: ModifiedView<TestView> = result
    }

    func testContentShapeCircle() {
        let v = TestView()
        let result = v.contentShape(.circle)
        let _: ModifiedView<TestView> = result
    }

    func testContentShapeRoundedRectangle() {
        let v = TestView()
        let result = v.contentShape(.roundedRectangle(cornerRadius: 8))
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 7. hoverEffect

    func testHoverEffectAutomatic() {
        let v = TestView()
        let result = v.hoverEffect(.automatic)
        let _: ModifiedView<TestView> = result
    }

    func testHoverEffectLift() {
        let v = TestView()
        let result = v.hoverEffect(.lift)
        let _: ModifiedView<TestView> = result
    }

    func testHoverEffectNone() {
        let v = TestView()
        let result = v.hoverEffect(.none)
        let _: ModifiedView<TestView> = result
    }

    func testHoverEffectDefaultParameter() {
        let v = TestView()
        let result = v.hoverEffect()
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 8. onHover

    func testOnHoverReturnsModifiedView() {
        let v = TestView()
        let result = v.onHover(perform: { _ in })
        let _: ModifiedView<TestView> = result
    }

    func testOnHoverClosureSignature() {
        // Verify the closure receives a Bool (true = entered, false = left).
        var lastValue: Bool? = nil
        let v = TestView()
        let result = v.onHover(perform: { isHovering in lastValue = isHovering })
        let _: ModifiedView<TestView> = result
        // lastValue is nil since GTK is not running — just verify it compiled.
        XCTAssertNil(lastValue)
    }

    // MARK: - 9. focusable

    func testFocusableTrue() {
        let v = TestView()
        let result = v.focusable(true)
        let _: ModifiedView<TestView> = result
    }

    func testFocusableFalse() {
        let v = TestView()
        let result = v.focusable(false)
        let _: ModifiedView<TestView> = result
    }

    func testFocusableDefaultParameter() {
        let v = TestView()
        let result = v.focusable()
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 10. focused

    func testFocusedTrue() {
        let v = TestView()
        let result = v.focused(true)
        let _: ModifiedView<TestView> = result
    }

    func testFocusedFalse() {
        let v = TestView()
        let result = v.focused(false)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 11. defaultFocus (stub)

    func testDefaultFocusReturnsModifiedView() {
        let v = TestView()
        let result = v.defaultFocus()
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 12. prefersDefaultFocus (stub)

    func testPrefersDefaultFocusTrue() {
        let v = TestView()
        let result = v.prefersDefaultFocus(true)
        let _: ModifiedView<TestView> = result
    }

    func testPrefersDefaultFocusFalse() {
        let v = TestView()
        let result = v.prefersDefaultFocus(false)
        let _: ModifiedView<TestView> = result
    }

    func testPrefersDefaultFocusDefaultParameter() {
        let v = TestView()
        let result = v.prefersDefaultFocus()
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 13. onKeyPress

    func testOnKeyPressReturnsModifiedView() {
        let v = TestView()
        let result = v.onKeyPress(perform: { _ in false })
        let _: ModifiedView<TestView> = result
    }

    func testOnKeyPressClosureSignature() {
        // Verify the closure receives a UInt32 keyval and returns Bool.
        let v = TestView()
        let result = v.onKeyPress(perform: { keyval -> Bool in
            return keyval == 65 // 'A' key
        })
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 14. onSubmit

    func testOnSubmitReturnsModifiedView() {
        let v = TestView()
        let result = v.onSubmit(perform: {})
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 15. swipeActions (stub)

    func testSwipeActionsReturnsModifiedView() {
        let v = TestView()
        let result = v.swipeActions(content: { TestView() })
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 16. selectionDisabled (stub)

    func testSelectionDisabledTrue() {
        let v = TestView()
        let result = v.selectionDisabled(true)
        let _: ModifiedView<TestView> = result
    }

    func testSelectionDisabledFalse() {
        let v = TestView()
        let result = v.selectionDisabled(false)
        let _: ModifiedView<TestView> = result
    }

    func testSelectionDisabledDefaultParameter() {
        let v = TestView()
        let result = v.selectionDisabled()
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 17. onDrag (stub)

    func testOnDragReturnsModifiedView() {
        let v = TestView()
        let result = v.onDrag(data: { "data" })
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 18. onDrop (stub)

    func testOnDropReturnsModifiedView() {
        let v = TestView()
        let result = v.onDrop(perform: { _ in false })
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 19. draggable (stub)

    func testDraggableReturnsModifiedView() {
        let v = TestView()
        let result = v.draggable()
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 20. dropDestination (stub)

    func testDropDestinationReturnsModifiedView() {
        let v = TestView()
        let result = v.dropDestination(for: String.self, action: { _, _ in false })
        let _: ModifiedView<TestView> = result
    }

    // MARK: - Supporting types

    func testHoverEffectEnumAllCases() {
        let effects: [HoverEffect] = [.automatic, .lift, .none]
        XCTAssertEqual(effects.count, 3)
    }

    func testCGPointInit() {
        let point = CGPoint(x: 10, y: 20)
        XCTAssertEqual(point.x, 10)
        XCTAssertEqual(point.y, 20)
    }

    func testCGPointDefaultInit() {
        let point = CGPoint()
        XCTAssertEqual(point.x, 0)
        XCTAssertEqual(point.y, 0)
    }

    // MARK: - Chaining

    func testModifierChaining() {
        let v = TestView()
        let result = v
            .allowsHitTesting(true)
            .focusable(true)
            .focused(false)
            .hoverEffect(.automatic)
        XCTAssertNotNil(result)
    }

    func testLongChainWithStubs() {
        let v = TestView()
        let result = v
            .onLongPressGesture(perform: {})
            .allowsHitTesting(true)
            .contentShape(.rectangle)
            .hoverEffect()
            .focusable()
            .defaultFocus()
            .prefersDefaultFocus()
            .onKeyPress(perform: { _ in false })
            .onSubmit(perform: {})
            .selectionDisabled()
            .draggable()
        XCTAssertNotNil(result)
    }
}
