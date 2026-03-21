// TextModifierTests.swift — Type-level tests for text/typography modifiers.
//
// These tests verify that each modifier compiles, returns the correct type,
// and does not crash when called on a simple view.

import XCTest
@testable import PineUI

final class TextModifierTests: XCTestCase {

    // A minimal concrete View for testing modifier return types.
    struct TestView: View {
        var body: Never { fatalError("TestView is a primitive") }
    }

    // MARK: - 1. fontWeight

    func testFontWeightReturnsModifiedView() {
        let v = TestView()
        let result = v.fontWeight(.bold)
        let _: ModifiedView<TestView> = result
    }

    func testFontWeightAllCases() {
        let v = TestView()
        let _ = v.fontWeight(.ultraLight)
        let _ = v.fontWeight(.thin)
        let _ = v.fontWeight(.light)
        let _ = v.fontWeight(.regular)
        let _ = v.fontWeight(.medium)
        let _ = v.fontWeight(.semibold)
        let _ = v.fontWeight(.bold)
        let _ = v.fontWeight(.heavy)
        let _ = v.fontWeight(.black)
    }

    func testFontWeightRawValues() {
        XCTAssertEqual(FontWeight.ultraLight.rawValue, 100)
        XCTAssertEqual(FontWeight.thin.rawValue,       200)
        XCTAssertEqual(FontWeight.light.rawValue,      300)
        XCTAssertEqual(FontWeight.regular.rawValue,    400)
        XCTAssertEqual(FontWeight.medium.rawValue,     500)
        XCTAssertEqual(FontWeight.semibold.rawValue,   600)
        XCTAssertEqual(FontWeight.bold.rawValue,       700)
        XCTAssertEqual(FontWeight.heavy.rawValue,      800)
        XCTAssertEqual(FontWeight.black.rawValue,      900)
    }

    // MARK: - 2. fontDesign

    func testFontDesignReturnsModifiedView() {
        let v = TestView()
        let result = v.fontDesign(.monospaced)
        let _: ModifiedView<TestView> = result
    }

    func testFontDesignAllCases() {
        let v = TestView()
        let _ = v.fontDesign(.default)
        let _ = v.fontDesign(.rounded)
        let _ = v.fontDesign(.serif)
        let _ = v.fontDesign(.monospaced)
    }

    func testFontDesignRawValues() {
        XCTAssertEqual(FontDesign.default.rawValue,   "inherit")
        XCTAssertEqual(FontDesign.rounded.rawValue,   "system-ui")
        XCTAssertEqual(FontDesign.serif.rawValue,     "serif")
        XCTAssertEqual(FontDesign.monospaced.rawValue, "monospace")
    }

    // MARK: - 3. italic

    func testItalicReturnsModifiedView() {
        let v = TestView()
        let result = v.italic()
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 4. strikethrough

    func testStrikethroughDefaultReturnsModifiedView() {
        let v = TestView()
        let result = v.strikethrough()
        let _: ModifiedView<TestView> = result
    }

    func testStrikethroughActive() {
        let v = TestView()
        let result = v.strikethrough(true)
        let _: ModifiedView<TestView> = result
    }

    func testStrikethroughInactive() {
        let v = TestView()
        let result = v.strikethrough(false)
        let _: ModifiedView<TestView> = result
    }

    func testStrikethroughWithColor() {
        let v = TestView()
        let result = v.strikethrough(true, color: .red)
        let _: ModifiedView<TestView> = result
    }

    func testStrikethroughWithNilColor() {
        let v = TestView()
        let result = v.strikethrough(true, color: nil)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 5. underline

    func testUnderlineDefaultReturnsModifiedView() {
        let v = TestView()
        let result = v.underline()
        let _: ModifiedView<TestView> = result
    }

    func testUnderlineActive() {
        let v = TestView()
        let result = v.underline(true)
        let _: ModifiedView<TestView> = result
    }

    func testUnderlineInactive() {
        let v = TestView()
        let result = v.underline(false)
        let _: ModifiedView<TestView> = result
    }

    func testUnderlineWithColor() {
        let v = TestView()
        let result = v.underline(true, color: .blue)
        let _: ModifiedView<TestView> = result
    }

    func testUnderlineWithNilColor() {
        let v = TestView()
        let result = v.underline(true, color: nil)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 6. kerning

    func testKerningReturnsModifiedView() {
        let v = TestView()
        let result = v.kerning(2.0)
        let _: ModifiedView<TestView> = result
    }

    func testKerningZero() {
        let v = TestView()
        let result = v.kerning(0.0)
        let _: ModifiedView<TestView> = result
    }

    func testKerningNegative() {
        let v = TestView()
        let result = v.kerning(-1.5)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 7. tracking

    func testTrackingReturnsModifiedView() {
        let v = TestView()
        let result = v.tracking(3.0)
        let _: ModifiedView<TestView> = result
    }

    func testTrackingZero() {
        let v = TestView()
        let result = v.tracking(0.0)
        let _: ModifiedView<TestView> = result
    }

    func testTrackingNegative() {
        let v = TestView()
        let result = v.tracking(-2.0)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 8. baselineOffset

    func testBaselineOffsetReturnsModifiedView() {
        let v = TestView()
        let result = v.baselineOffset(4.0)
        let _: ModifiedView<TestView> = result
    }

    func testBaselineOffsetNegative() {
        let v = TestView()
        let result = v.baselineOffset(-4.0)
        let _: ModifiedView<TestView> = result
    }

    func testBaselineOffsetZero() {
        let v = TestView()
        let result = v.baselineOffset(0.0)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 9. lineLimit

    func testLineLimitReturnsModifiedView() {
        let v = TestView()
        let result = v.lineLimit(3)
        let _: ModifiedView<TestView> = result
    }

    func testLineLimitOne() {
        let v = TestView()
        let result = v.lineLimit(1)
        let _: ModifiedView<TestView> = result
    }

    func testLineLimitNil() {
        let v = TestView()
        let result = v.lineLimit(nil)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 10. lineSpacing

    func testLineSpacingReturnsModifiedView() {
        let v = TestView()
        let result = v.lineSpacing(1.5)
        let _: ModifiedView<TestView> = result
    }

    func testLineSpacingTight() {
        let v = TestView()
        let result = v.lineSpacing(1.0)
        let _: ModifiedView<TestView> = result
    }

    func testLineSpacingLoose() {
        let v = TestView()
        let result = v.lineSpacing(2.0)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 11. minimumScaleFactor (stub)

    func testMinimumScaleFactorReturnsModifiedView() {
        let v = TestView()
        let result = v.minimumScaleFactor(0.5)
        let _: ModifiedView<TestView> = result
    }

    func testMinimumScaleFactorOne() {
        let v = TestView()
        let result = v.minimumScaleFactor(1.0)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 12. truncationMode

    func testTruncationModeHead() {
        let v = TestView()
        let result = v.truncationMode(.head)
        let _: ModifiedView<TestView> = result
    }

    func testTruncationModeMiddle() {
        let v = TestView()
        let result = v.truncationMode(.middle)
        let _: ModifiedView<TestView> = result
    }

    func testTruncationModeTail() {
        let v = TestView()
        let result = v.truncationMode(.tail)
        let _: ModifiedView<TestView> = result
    }

    func testTruncationModeAllCases() {
        let modes: [TruncationMode] = [.head, .middle, .tail]
        XCTAssertEqual(modes.count, 3)
    }

    // MARK: - 13. textCase

    func testTextCaseUppercase() {
        let v = TestView()
        let result = v.textCase(.uppercase)
        let _: ModifiedView<TestView> = result
    }

    func testTextCaseLowercase() {
        let v = TestView()
        let result = v.textCase(.lowercase)
        let _: ModifiedView<TestView> = result
    }

    func testTextCaseNil() {
        let v = TestView()
        let result = v.textCase(nil)
        let _: ModifiedView<TestView> = result
    }

    func testTextCaseRawValues() {
        XCTAssertEqual(TextCase.uppercase.rawValue, "uppercase")
        XCTAssertEqual(TextCase.lowercase.rawValue, "lowercase")
    }

    // MARK: - 14. textSelection

    func testTextSelectionEnabled() {
        let v = TestView()
        let result = v.textSelection(true)
        let _: ModifiedView<TestView> = result
    }

    func testTextSelectionDisabled() {
        let v = TestView()
        let result = v.textSelection(false)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 15. allowsTightening (stub)

    func testAllowsTighteningTrue() {
        let v = TestView()
        let result = v.allowsTightening(true)
        let _: ModifiedView<TestView> = result
    }

    func testAllowsTighteningFalse() {
        let v = TestView()
        let result = v.allowsTightening(false)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 16. labelIconToTitleSpacing (stub)

    func testLabelIconToTitleSpacingReturnsModifiedView() {
        let v = TestView()
        let result = v.labelIconToTitleSpacing(8)
        let _: ModifiedView<TestView> = result
    }

    func testLabelIconToTitleSpacingZero() {
        let v = TestView()
        let result = v.labelIconToTitleSpacing(0)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 17. typesettingLanguage (stub)

    func testTypesettingLanguageReturnsModifiedView() {
        let v = TestView()
        let result = v.typesettingLanguage("en")
        let _: ModifiedView<TestView> = result
    }

    func testTypesettingLanguageEmpty() {
        let v = TestView()
        let result = v.typesettingLanguage("")
        let _: ModifiedView<TestView> = result
    }

    func testTypesettingLanguageLocale() {
        let v = TestView()
        let result = v.typesettingLanguage("fr-FR")
        let _: ModifiedView<TestView> = result
    }

    // MARK: - Chaining tests

    func testTypographyModifiersChain() {
        let v = TestView()
        let result = v
            .fontWeight(.bold)
            .italic()
            .underline()
            .kerning(1.5)
        XCTAssertNotNil(result)
    }

    func testDecorationModifiersChain() {
        let v = TestView()
        let result = v
            .strikethrough(true, color: .red)
            .underline(true, color: .blue)
            .textCase(.uppercase)
        XCTAssertNotNil(result)
    }

    func testLabelBehaviorModifiersChain() {
        let v = TestView()
        let result = v
            .lineLimit(2)
            .lineSpacing(1.4)
            .truncationMode(.tail)
            .textSelection(true)
        XCTAssertNotNil(result)
    }

    func testFullTypographyChain() {
        let v = TestView()
        let result = v
            .fontWeight(.semibold)
            .fontDesign(.rounded)
            .italic()
            .underline()
            .tracking(0.5)
            .lineLimit(3)
            .truncationMode(.tail)
            .textCase(.uppercase)
        XCTAssertNotNil(result)
    }
}
