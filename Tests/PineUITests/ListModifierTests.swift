// ListModifierTests.swift — Type-level tests for list and scroll modifiers.
//
// These tests verify that each modifier compiles, returns the correct type,
// and does not crash when called on a simple view.

import XCTest
@testable import PineUI

final class ListModifierTests: XCTestCase {

    // A minimal concrete View for testing modifier return types.
    struct TestView: View {
        var body: Never { fatalError("TestView is a primitive") }
    }

    // MARK: - 1. listStyle

    func testListStyleSidebar() {
        let v = TestView()
        let result = v.listStyle(.sidebar)
        let _: ModifiedView<TestView> = result
    }

    func testListStylePlain() {
        let v = TestView()
        let result = v.listStyle(.plain)
        let _: ModifiedView<TestView> = result
    }

    func testListStyleInset() {
        let v = TestView()
        let result = v.listStyle(.inset)
        let _: ModifiedView<TestView> = result
    }

    func testListStyleInsetGrouped() {
        let v = TestView()
        let result = v.listStyle(.insetGrouped)
        let _: ModifiedView<TestView> = result
    }

    func testListStyleBordered() {
        let v = TestView()
        let result = v.listStyle(.bordered)
        let _: ModifiedView<TestView> = result
    }

    func testListStyleAllCases() {
        let styles: [ListStyle] = [.sidebar, .plain, .inset, .insetGrouped, .bordered]
        XCTAssertEqual(styles.count, 5)
    }

    // MARK: - 2. listRowBackground

    func testListRowBackgroundBlue() {
        let v = TestView()
        let result = v.listRowBackground(.blue)
        let _: ModifiedView<TestView> = result
    }

    func testListRowBackgroundClear() {
        let v = TestView()
        let result = v.listRowBackground(.clear)
        let _: ModifiedView<TestView> = result
    }

    func testListRowBackgroundCustomColor() {
        let v = TestView()
        let result = v.listRowBackground(Color(red: 0.5, green: 0.5, blue: 0.5))
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 3. listRowSeparator

    func testListRowSeparatorVisible() {
        let v = TestView()
        let result = v.listRowSeparator(.visible)
        let _: ModifiedView<TestView> = result
    }

    func testListRowSeparatorHidden() {
        let v = TestView()
        let result = v.listRowSeparator(.hidden)
        let _: ModifiedView<TestView> = result
    }

    func testListRowSeparatorAutomatic() {
        let v = TestView()
        let result = v.listRowSeparator(.automatic)
        let _: ModifiedView<TestView> = result
    }

    func testVisibilityEnumCases() {
        let visible: Visibility = .visible
        let hidden: Visibility = .hidden
        let automatic: Visibility = .automatic
        XCTAssertNotEqual("\(visible)", "\(hidden)")
        XCTAssertNotEqual("\(hidden)", "\(automatic)")
        XCTAssertNotEqual("\(visible)", "\(automatic)")
    }

    // MARK: - 4. listRowInsets

    func testListRowInsetsNil() {
        let v = TestView()
        let result = v.listRowInsets(nil)
        let _: ModifiedView<TestView> = result
    }

    func testListRowInsetsUniform() {
        let v = TestView()
        let insets = EdgeInsets(8)
        let result = v.listRowInsets(insets)
        let _: ModifiedView<TestView> = result
    }

    func testListRowInsetsAsymmetric() {
        let v = TestView()
        let insets = EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 8)
        let result = v.listRowInsets(insets)
        let _: ModifiedView<TestView> = result
    }

    func testEdgeInsetsDefaultInit() {
        let insets = EdgeInsets()
        XCTAssertEqual(insets.top, 0)
        XCTAssertEqual(insets.leading, 0)
        XCTAssertEqual(insets.bottom, 0)
        XCTAssertEqual(insets.trailing, 0)
    }

    func testEdgeInsetsUniformInit() {
        let insets = EdgeInsets(12)
        XCTAssertEqual(insets.top, 12)
        XCTAssertEqual(insets.leading, 12)
        XCTAssertEqual(insets.bottom, 12)
        XCTAssertEqual(insets.trailing, 12)
    }

    func testEdgeInsetsPartialInit() {
        let insets = EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
        XCTAssertEqual(insets.top, 8)
        XCTAssertEqual(insets.leading, 0)
        XCTAssertEqual(insets.bottom, 8)
        XCTAssertEqual(insets.trailing, 0)
    }

    // MARK: - 5. listSectionSeparator

    func testListSectionSeparatorVisible() {
        let v = TestView()
        let result = v.listSectionSeparator(.visible)
        let _: ModifiedView<TestView> = result
    }

    func testListSectionSeparatorHidden() {
        let v = TestView()
        let result = v.listSectionSeparator(.hidden)
        let _: ModifiedView<TestView> = result
    }

    func testListSectionSeparatorAutomatic() {
        let v = TestView()
        let result = v.listSectionSeparator(.automatic)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 6. searchable (stub)

    func testSearchableDefaultPrompt() {
        let v = TestView()
        let store = StateStore<String>("")
        let result = v.searchable(text: store)
        let _: ModifiedView<TestView> = result
    }

    func testSearchableCustomPrompt() {
        let v = TestView()
        let store = StateStore<String>("")
        let result = v.searchable(text: store, prompt: "Find items...")
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 7. refreshable (stub)

    func testRefreshableReturnsModifiedView() {
        let v = TestView()
        let result = v.refreshable { }
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 8. badge (Int)

    func testBadgeIntZero() {
        let v = TestView()
        let result = v.badge(0)
        let _: ModifiedView<TestView> = result
    }

    func testBadgeIntPositive() {
        let v = TestView()
        let result = v.badge(42)
        let _: ModifiedView<TestView> = result
    }

    func testBadgeIntLarge() {
        let v = TestView()
        let result = v.badge(999)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 9. badge (String)

    func testBadgeStringNil() {
        let v = TestView()
        let result = v.badge(nil as String?)
        let _: ModifiedView<TestView> = result
    }

    func testBadgeStringValue() {
        let v = TestView()
        let result = v.badge("New")
        let _: ModifiedView<TestView> = result
    }

    func testBadgeStringEmpty() {
        let v = TestView()
        let result = v.badge("")
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 10. privacySensitive (stub)

    func testPrivacySensitiveTrue() {
        let v = TestView()
        let result = v.privacySensitive(true)
        let _: ModifiedView<TestView> = result
    }

    func testPrivacySensitiveFalse() {
        let v = TestView()
        let result = v.privacySensitive(false)
        let _: ModifiedView<TestView> = result
    }

    func testPrivacySensitiveDefaultValue() {
        let v = TestView()
        // Default is true per SwiftUI convention.
        let result = v.privacySensitive()
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 11. scrollIndicators

    func testScrollIndicatorsAutomatic() {
        let v = TestView()
        let result = v.scrollIndicators(.automatic)
        let _: ModifiedView<TestView> = result
    }

    func testScrollIndicatorsVisible() {
        let v = TestView()
        let result = v.scrollIndicators(.visible)
        let _: ModifiedView<TestView> = result
    }

    func testScrollIndicatorsHidden() {
        let v = TestView()
        let result = v.scrollIndicators(.hidden)
        let _: ModifiedView<TestView> = result
    }

    func testScrollIndicatorsNever() {
        let v = TestView()
        let result = v.scrollIndicators(.never)
        let _: ModifiedView<TestView> = result
    }

    func testScrollIndicatorVisibilityAllCases() {
        let cases: [ScrollIndicatorVisibility] = [.automatic, .visible, .hidden, .never]
        XCTAssertEqual(cases.count, 4)
    }

    // MARK: - 12. scrollDisabled

    func testScrollDisabledTrue() {
        let v = TestView()
        let result = v.scrollDisabled(true)
        let _: ModifiedView<TestView> = result
    }

    func testScrollDisabledFalse() {
        let v = TestView()
        let result = v.scrollDisabled(false)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 13. scrollDismissesKeyboard (stub)

    func testScrollDismissesKeyboardAutomatic() {
        let v = TestView()
        let result = v.scrollDismissesKeyboard(.automatic)
        let _: ModifiedView<TestView> = result
    }

    func testScrollDismissesKeyboardImmediately() {
        let v = TestView()
        let result = v.scrollDismissesKeyboard(.immediately)
        let _: ModifiedView<TestView> = result
    }

    func testScrollDismissesKeyboardInteractively() {
        let v = TestView()
        let result = v.scrollDismissesKeyboard(.interactively)
        let _: ModifiedView<TestView> = result
    }

    func testScrollDismissesKeyboardNever() {
        let v = TestView()
        let result = v.scrollDismissesKeyboard(.never)
        let _: ModifiedView<TestView> = result
    }

    func testScrollDismissesKeyboardModeAllCases() {
        let modes: [ScrollDismissesKeyboardMode] = [.automatic, .immediately, .interactively, .never]
        XCTAssertEqual(modes.count, 4)
    }

    // MARK: - 14. scrollPosition (stub)

    func testScrollPositionReturnsModifiedView() {
        let v = TestView()
        let store = StateStore<AnyHashable?>(nil)
        let result = v.scrollPosition(id: store)
        let _: ModifiedView<TestView> = result
    }

    func testScrollPositionWithValue() {
        let v = TestView()
        let store = StateStore<AnyHashable?>(AnyHashable(42))
        let result = v.scrollPosition(id: store)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 15. scrollTargetLayout (stub)

    func testScrollTargetLayoutReturnsModifiedView() {
        let v = TestView()
        let result = v.scrollTargetLayout()
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 16. scrollClipDisabled

    func testScrollClipDisabledTrue() {
        let v = TestView()
        let result = v.scrollClipDisabled(true)
        let _: ModifiedView<TestView> = result
    }

    func testScrollClipDisabledFalse() {
        let v = TestView()
        let result = v.scrollClipDisabled(false)
        let _: ModifiedView<TestView> = result
    }

    func testScrollClipDisabledDefaultValue() {
        let v = TestView()
        // Default parameter is true.
        let result = v.scrollClipDisabled()
        let _: ModifiedView<TestView> = result
    }

    // MARK: - Chaining tests

    func testListModifierChaining() {
        let v = TestView()
        let result = v
            .listStyle(.inset)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        XCTAssertNotNil(result)
    }

    func testScrollModifierChaining() {
        let v = TestView()
        let result = v
            .scrollIndicators(.never)
            .scrollClipDisabled(false)
            .scrollDisabled(false)
        XCTAssertNotNil(result)
    }

    func testMixedListScrollChaining() {
        let v = TestView()
        let result = v
            .listStyle(.plain)
            .listRowBackground(.clear)
            .scrollIndicators(.automatic)
        XCTAssertNotNil(result)
    }
}
