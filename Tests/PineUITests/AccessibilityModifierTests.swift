// AccessibilityModifierTests.swift — Type-level tests for accessibility modifiers.
//
// All 8 modifiers are stubs (GTK4's accessible API uses variadic C functions
// that Swift cannot call). These tests verify that each modifier compiles,
// returns the correct type, and can be chained without crashing.
// No GTK display is required since no widget is rendered.

import XCTest
@testable import PineUI

final class AccessibilityModifierTests: XCTestCase {

    // A minimal concrete View for testing modifier return types.
    struct TestView: View {
        var body: Never { fatalError("TestView is a primitive") }
    }

    // MARK: - 1. accessibilityLabel

    func testAccessibilityLabelReturnsModifiedView() {
        let v = TestView()
        let result = v.accessibilityLabel("Submit button")
        let _: ModifiedView<TestView> = result
    }

    func testAccessibilityLabelEmptyString() {
        let v = TestView()
        let result = v.accessibilityLabel("")
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 2. accessibilityHint

    func testAccessibilityHintReturnsModifiedView() {
        let v = TestView()
        let result = v.accessibilityHint("Double tap to activate")
        let _: ModifiedView<TestView> = result
    }

    func testAccessibilityHintEmptyString() {
        let v = TestView()
        let result = v.accessibilityHint("")
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 3. accessibilityValue

    func testAccessibilityValueReturnsModifiedView() {
        let v = TestView()
        let result = v.accessibilityValue("75%")
        let _: ModifiedView<TestView> = result
    }

    func testAccessibilityValueNumericString() {
        let v = TestView()
        let result = v.accessibilityValue("42")
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 4. accessibilityHidden

    func testAccessibilityHiddenTrue() {
        let v = TestView()
        let result = v.accessibilityHidden(true)
        let _: ModifiedView<TestView> = result
    }

    func testAccessibilityHiddenFalse() {
        let v = TestView()
        let result = v.accessibilityHidden(false)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 5. accessibilityAction

    func testAccessibilityActionReturnsModifiedView() {
        let v = TestView()
        let result = v.accessibilityAction("Activate", perform: {})
        let _: ModifiedView<TestView> = result
    }

    func testAccessibilityActionClosureSignature() {
        var performed = false
        let v = TestView()
        let result = v.accessibilityAction("Delete", perform: { performed = true })
        let _: ModifiedView<TestView> = result
        // Closure is not invoked (stub) — verify it compiled and captured correctly.
        XCTAssertFalse(performed)
    }

    // MARK: - 6. accessibilityElement(children:)

    func testAccessibilityElementContain() {
        let v = TestView()
        let result = v.accessibilityElement(children: .contain)
        let _: ModifiedView<TestView> = result
    }

    func testAccessibilityElementCombine() {
        let v = TestView()
        let result = v.accessibilityElement(children: .combine)
        let _: ModifiedView<TestView> = result
    }

    func testAccessibilityElementIgnore() {
        let v = TestView()
        let result = v.accessibilityElement(children: .ignore)
        let _: ModifiedView<TestView> = result
    }

    func testAccessibilityElementDefaultParameter() {
        let v = TestView()
        let result = v.accessibilityElement()
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 7. accessibilityAddTraits

    func testAccessibilityAddTraitsButton() {
        let v = TestView()
        let result = v.accessibilityAddTraits(.isButton)
        let _: ModifiedView<TestView> = result
    }

    func testAccessibilityAddTraitsHeader() {
        let v = TestView()
        let result = v.accessibilityAddTraits(.isHeader)
        let _: ModifiedView<TestView> = result
    }

    func testAccessibilityAddTraitsLink() {
        let v = TestView()
        let result = v.accessibilityAddTraits(.isLink)
        let _: ModifiedView<TestView> = result
    }

    func testAccessibilityAddTraitsImage() {
        let v = TestView()
        let result = v.accessibilityAddTraits(.isImage)
        let _: ModifiedView<TestView> = result
    }

    func testAccessibilityAddTraitsSelected() {
        let v = TestView()
        let result = v.accessibilityAddTraits(.isSelected)
        let _: ModifiedView<TestView> = result
    }

    func testAccessibilityAddTraitsStaticText() {
        let v = TestView()
        let result = v.accessibilityAddTraits(.isStaticText)
        let _: ModifiedView<TestView> = result
    }

    func testAccessibilityAddTraitsPlaysSound() {
        let v = TestView()
        let result = v.accessibilityAddTraits(.playsSound)
        let _: ModifiedView<TestView> = result
    }

    func testAccessibilityAddTraitsSearchField() {
        let v = TestView()
        let result = v.accessibilityAddTraits(.isSearchField)
        let _: ModifiedView<TestView> = result
    }

    func testAccessibilityAddTraitsSummaryElement() {
        let v = TestView()
        let result = v.accessibilityAddTraits(.isSummaryElement)
        let _: ModifiedView<TestView> = result
    }

    func testAccessibilityAddTraitsCombined() {
        let v = TestView()
        let result = v.accessibilityAddTraits([.isButton, .isSelected])
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 8. accessibilitySortPriority

    func testAccessibilitySortPriorityPositive() {
        let v = TestView()
        let result = v.accessibilitySortPriority(10.0)
        let _: ModifiedView<TestView> = result
    }

    func testAccessibilitySortPriorityZero() {
        let v = TestView()
        let result = v.accessibilitySortPriority(0.0)
        let _: ModifiedView<TestView> = result
    }

    func testAccessibilitySortPriorityNegative() {
        let v = TestView()
        let result = v.accessibilitySortPriority(-5.0)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - Supporting Types: AccessibilityChildBehavior

    func testAccessibilityChildBehaviorContainEquality() {
        XCTAssertEqual(AccessibilityChildBehavior.contain, AccessibilityChildBehavior.contain)
    }

    func testAccessibilityChildBehaviorCombineEquality() {
        XCTAssertEqual(AccessibilityChildBehavior.combine, AccessibilityChildBehavior.combine)
    }

    func testAccessibilityChildBehaviorIgnoreEquality() {
        XCTAssertEqual(AccessibilityChildBehavior.ignore, AccessibilityChildBehavior.ignore)
    }

    func testAccessibilityChildBehaviorDistinct() {
        XCTAssertNotEqual(AccessibilityChildBehavior.contain, AccessibilityChildBehavior.combine)
        XCTAssertNotEqual(AccessibilityChildBehavior.contain, AccessibilityChildBehavior.ignore)
        XCTAssertNotEqual(AccessibilityChildBehavior.combine, AccessibilityChildBehavior.ignore)
    }

    // MARK: - Supporting Types: AccessibilityTraits

    func testAccessibilityTraitsOptionSetUnion() {
        let traits: AccessibilityTraits = [.isButton, .isSelected]
        XCTAssertTrue(traits.contains(.isButton))
        XCTAssertTrue(traits.contains(.isSelected))
        XCTAssertFalse(traits.contains(.isHeader))
    }

    func testAccessibilityTraitsDistinctRawValues() {
        // All 9 traits must have unique raw values.
        let allTraits: [AccessibilityTraits] = [
            .isButton, .isHeader, .isLink, .isImage, .isSelected,
            .isStaticText, .playsSound, .isSearchField, .isSummaryElement
        ]
        let rawValues = allTraits.map { $0.rawValue }
        let unique = Set(rawValues)
        XCTAssertEqual(unique.count, allTraits.count, "All trait raw values must be distinct")
    }

    func testAccessibilityTraitsEmptySet() {
        let empty = AccessibilityTraits()
        XCTAssertFalse(empty.contains(.isButton))
        XCTAssertFalse(empty.contains(.isHeader))
    }

    func testAccessibilityTraitsIntersection() {
        let a: AccessibilityTraits = [.isButton, .isHeader]
        let b: AccessibilityTraits = [.isHeader, .isLink]
        let intersection = a.intersection(b)
        XCTAssertTrue(intersection.contains(.isHeader))
        XCTAssertFalse(intersection.contains(.isButton))
        XCTAssertFalse(intersection.contains(.isLink))
    }

    // MARK: - Chaining

    func testModifierChaining() {
        let v = TestView()
        let result = v
            .accessibilityLabel("Profile image")
            .accessibilityHint("Opens profile details")
            .accessibilityAddTraits(.isImage)
            .accessibilityHidden(false)
        XCTAssertNotNil(result)
    }

    func testFullAccessibilityChain() {
        let v = TestView()
        let result = v
            .accessibilityLabel("Submit")
            .accessibilityHint("Submits the form")
            .accessibilityValue("enabled")
            .accessibilityHidden(false)
            .accessibilityAction("Activate", perform: {})
            .accessibilityElement(children: .ignore)
            .accessibilityAddTraits([.isButton, .isSelected])
            .accessibilitySortPriority(1.0)
        XCTAssertNotNil(result)
    }
}
