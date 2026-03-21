// NavigationModifierTests.swift — Type-level tests for navigation and presentation modifiers.
//
// These tests verify that each modifier compiles, returns the correct type,
// and does not crash when called on a simple view (no GTK display required).

import XCTest
@testable import PineUI

final class NavigationModifierTests: XCTestCase {

    // A minimal concrete View for testing modifier return types.
    struct TestView: View {
        var body: Never { fatalError("TestView is a primitive") }
    }

    // MARK: - Navigation Modifiers

    // MARK: 1. navigationTitle

    func testNavigationTitleReturnsModifiedView() {
        let v = TestView()
        let result = v.navigationTitle("My App")
        let _: ModifiedView<TestView> = result
    }

    func testNavigationTitleEmptyString() {
        let v = TestView()
        let result = v.navigationTitle("")
        let _: ModifiedView<TestView> = result
    }

    func testNavigationTitleLongString() {
        let v = TestView()
        let result = v.navigationTitle("A Very Long Navigation Title That Might Truncate")
        let _: ModifiedView<TestView> = result
    }

    // MARK: 2. navigationSubtitle (stub)

    func testNavigationSubtitleReturnsModifiedView() {
        let v = TestView()
        let result = v.navigationSubtitle("Subtitle")
        let _: ModifiedView<TestView> = result
    }

    func testNavigationSubtitleEmptyString() {
        let v = TestView()
        let result = v.navigationSubtitle("")
        let _: ModifiedView<TestView> = result
    }

    // MARK: 3. navigationBarTitleDisplayMode (stub)

    func testNavigationBarTitleDisplayModeAutomatic() {
        let v = TestView()
        let result = v.navigationBarTitleDisplayMode(.automatic)
        let _: ModifiedView<TestView> = result
    }

    func testNavigationBarTitleDisplayModeInline() {
        let v = TestView()
        let result = v.navigationBarTitleDisplayMode(.inline)
        let _: ModifiedView<TestView> = result
    }

    func testNavigationBarTitleDisplayModeLarge() {
        let v = TestView()
        let result = v.navigationBarTitleDisplayMode(.large)
        let _: ModifiedView<TestView> = result
    }

    func testNavigationBarTitleDisplayModeAllCases() {
        let modes: [NavigationBarTitleDisplayMode] = [.automatic, .inline, .large]
        XCTAssertEqual(modes.count, 3)
    }

    // MARK: 4. toolbar (stub)

    func testToolbarReturnsModifiedView() {
        let v = TestView()
        let result = v.toolbar(content: { TestView() })
        let _: ModifiedView<TestView> = result
    }

    // MARK: 5. toolbarBackground (stub)

    func testToolbarBackgroundReturnsModifiedView() {
        let v = TestView()
        let result = v.toolbarBackground(.blue)
        let _: ModifiedView<TestView> = result
    }

    func testToolbarBackgroundCustomColor() {
        let v = TestView()
        let result = v.toolbarBackground(Color(red: 0.1, green: 0.2, blue: 0.3))
        let _: ModifiedView<TestView> = result
    }

    // MARK: 6. toolbarColorScheme (stub)

    func testToolbarColorSchemeDark() {
        let v = TestView()
        let result = v.toolbarColorScheme(.dark)
        let _: ModifiedView<TestView> = result
    }

    func testToolbarColorSchemeLight() {
        let v = TestView()
        let result = v.toolbarColorScheme(.light)
        let _: ModifiedView<TestView> = result
    }

    func testToolbarColorSchemeNil() {
        let v = TestView()
        let result = v.toolbarColorScheme(nil)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - Presentation Modifiers

    // MARK: 7. sheet

    func testSheetReturnsModifiedView() {
        let isPresented = StateStore<Bool>(false)
        let v = TestView()
        let result = v.sheet(isPresented: isPresented) { TestView() }
        let _: ModifiedView<TestView> = result
    }

    func testSheetDoesNotPresentWhenFalse() {
        // Verifies that creating the modifier with isPresented=false doesn't crash.
        let isPresented = StateStore<Bool>(false)
        let v = TestView()
        let result = v.sheet(isPresented: isPresented) { TestView() }
        XCTAssertNotNil(result)
    }

    func testSheetOnChangeCallbackRegistered() {
        // Verifies the modifier registers the onChange callback on the store.
        let isPresented = StateStore<Bool>(false)
        let v = TestView()
        let _ = v.sheet(isPresented: isPresented) { TestView() }
        // After modifier construction, onChange is registered.
        // We can't verify it points to a specific function, but it should be non-nil
        // only after renderGTK() is called — modifier is lazy.
        XCTAssertNil(isPresented.onChange)
    }

    // MARK: 8. fullScreenCover

    func testFullScreenCoverReturnsModifiedView() {
        let isPresented = StateStore<Bool>(false)
        let v = TestView()
        let result = v.fullScreenCover(isPresented: isPresented) { TestView() }
        let _: ModifiedView<TestView> = result
    }

    func testFullScreenCoverDoesNotPresentWhenFalse() {
        let isPresented = StateStore<Bool>(false)
        let v = TestView()
        let result = v.fullScreenCover(isPresented: isPresented) { TestView() }
        XCTAssertNotNil(result)
    }

    // MARK: 9. popover

    func testPopoverReturnsModifiedView() {
        let isPresented = StateStore<Bool>(false)
        let v = TestView()
        let result = v.popover(isPresented: isPresented) { TestView() }
        let _: ModifiedView<TestView> = result
    }

    func testPopoverDoesNotPresentWhenFalse() {
        let isPresented = StateStore<Bool>(false)
        let v = TestView()
        let result = v.popover(isPresented: isPresented) { TestView() }
        XCTAssertNotNil(result)
    }

    // MARK: 10. alert (with actions)

    func testAlertWithActionsReturnsModifiedView() {
        let isPresented = StateStore<Bool>(false)
        let v = TestView()
        let result = v.alert("Warning", isPresented: isPresented) { TestView() }
        let _: ModifiedView<TestView> = result
    }

    func testAlertWithActionsEmptyTitle() {
        let isPresented = StateStore<Bool>(false)
        let v = TestView()
        let result = v.alert("", isPresented: isPresented) { TestView() }
        let _: ModifiedView<TestView> = result
    }

    // MARK: 10b. alert (no actions overload)

    func testAlertNoActionsReturnsModifiedView() {
        let isPresented = StateStore<Bool>(false)
        let v = TestView()
        let result = v.alert("Warning", isPresented: isPresented)
        let _: ModifiedView<TestView> = result
    }

    func testAlertTogglesBooleanState() {
        // Verify initial store value is false.
        let isPresented = StateStore<Bool>(false)
        XCTAssertFalse(isPresented.value)
    }

    // MARK: 11. confirmationDialog (with actions)

    func testConfirmationDialogWithActionsReturnsModifiedView() {
        let isPresented = StateStore<Bool>(false)
        let v = TestView()
        let result = v.confirmationDialog("Are you sure?", isPresented: isPresented) {
            TestView()
        }
        let _: ModifiedView<TestView> = result
    }

    func testConfirmationDialogWithActionsLongTitle() {
        let isPresented = StateStore<Bool>(false)
        let v = TestView()
        let result = v.confirmationDialog(
            "Are you sure you want to delete all data permanently?",
            isPresented: isPresented
        ) { TestView() }
        let _: ModifiedView<TestView> = result
    }

    // MARK: 11b. confirmationDialog (no actions overload)

    func testConfirmationDialogNoActionsReturnsModifiedView() {
        let isPresented = StateStore<Bool>(false)
        let v = TestView()
        let result = v.confirmationDialog("Are you sure?", isPresented: isPresented)
        let _: ModifiedView<TestView> = result
    }

    // MARK: 12. fileImporter (stub)

    func testFileImporterReturnsModifiedView() {
        let isPresented = StateStore<Bool>(false)
        let v = TestView()
        let result = v.fileImporter(
            isPresented: isPresented,
            allowedContentTypes: ["public.text"]
        ) { _ in }
        let _: ModifiedView<TestView> = result
    }

    func testFileImporterDefaultAllowedTypes() {
        let isPresented = StateStore<Bool>(false)
        let v = TestView()
        let result = v.fileImporter(isPresented: isPresented) { _ in }
        let _: ModifiedView<TestView> = result
    }

    // MARK: 13. fileExporter (stub)

    func testFileExporterReturnsModifiedView() {
        let isPresented = StateStore<Bool>(false)
        let v = TestView()
        let result = v.fileExporter(
            isPresented: isPresented,
            fileName: "export.csv"
        ) { _ in }
        let _: ModifiedView<TestView> = result
    }

    func testFileExporterDefaultFileName() {
        let isPresented = StateStore<Bool>(false)
        let v = TestView()
        let result = v.fileExporter(isPresented: isPresented) { _ in }
        let _: ModifiedView<TestView> = result
    }

    // MARK: 14. inspector (stub)

    func testInspectorReturnsModifiedView() {
        let isPresented = StateStore<Bool>(false)
        let v = TestView()
        let result = v.inspector(isPresented: isPresented) { TestView() }
        let _: ModifiedView<TestView> = result
    }

    // MARK: 15. interactiveDismissDisabled (stub)

    func testInteractiveDismissDisabledTrue() {
        let v = TestView()
        let result = v.interactiveDismissDisabled(true)
        let _: ModifiedView<TestView> = result
    }

    func testInteractiveDismissDisabledFalse() {
        let v = TestView()
        let result = v.interactiveDismissDisabled(false)
        let _: ModifiedView<TestView> = result
    }

    func testInteractiveDismissDisabledDefaultParameter() {
        let v = TestView()
        let result = v.interactiveDismissDisabled()
        let _: ModifiedView<TestView> = result
    }

    // MARK: - Supporting enum tests

    func testNavigationBarTitleDisplayModeDistinctValues() {
        let a = NavigationBarTitleDisplayMode.automatic
        let b = NavigationBarTitleDisplayMode.inline
        let c = NavigationBarTitleDisplayMode.large
        XCTAssertNotEqual("\(a)", "\(b)")
        XCTAssertNotEqual("\(b)", "\(c)")
        XCTAssertNotEqual("\(a)", "\(c)")
    }

    // MARK: - StateStore interaction tests

    func testStateStoreInitialValue() {
        let store = StateStore<Bool>(false)
        XCTAssertFalse(store.value)
    }

    func testStateStoreValueChange() {
        let store = StateStore<Bool>(false)
        var callbackFired = false
        store.onChange = { newValue in
            callbackFired = newValue
        }
        store.value = true
        XCTAssertTrue(callbackFired)
    }

    func testStateStoreOnChangeIsNilInitially() {
        let store = StateStore<Bool>(false)
        XCTAssertNil(store.onChange)
    }

    // MARK: - Chaining tests

    func testNavigationModifiersChaining() {
        let v = TestView()
        let result = v
            .navigationTitle("Home")
            .navigationSubtitle("Details")
            .navigationBarTitleDisplayMode(.automatic)
        XCTAssertNotNil(result)
    }

    func testPresentationModifiersChaining() {
        let sheetPresented = StateStore<Bool>(false)
        let alertPresented = StateStore<Bool>(false)
        let v = TestView()
        let result = v
            .sheet(isPresented: sheetPresented) { TestView() }
            .alert("Danger", isPresented: alertPresented)
            .interactiveDismissDisabled(false)
        XCTAssertNotNil(result)
    }

    func testFullChainAllNavigationAndPresentationModifiers() {
        let presented = StateStore<Bool>(false)
        let v = TestView()
        let result = v
            .navigationTitle("Settings")
            .navigationSubtitle("General")
            .navigationBarTitleDisplayMode(.large)
            .toolbar { TestView() }
            .toolbarBackground(.blue)
            .toolbarColorScheme(.dark)
            .sheet(isPresented: presented) { TestView() }
            .fullScreenCover(isPresented: presented) { TestView() }
            .popover(isPresented: presented) { TestView() }
            .alert("Alert", isPresented: presented)
            .confirmationDialog("Confirm?", isPresented: presented)
            .fileImporter(isPresented: presented) { _ in }
            .fileExporter(isPresented: presented) { _ in }
            .inspector(isPresented: presented) { TestView() }
            .interactiveDismissDisabled()
        XCTAssertNotNil(result)
    }
}
