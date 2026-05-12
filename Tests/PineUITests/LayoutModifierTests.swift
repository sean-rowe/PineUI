// LayoutModifierTests.swift — Type-level tests for layout modifiers.
//
// These tests verify that each modifier compiles, returns the correct type,
// and does not crash when called on a simple view.

import XCTest
@testable import PineUI

final class LayoutModifierTests: XCTestCase {

    // A minimal concrete View for testing modifier return types.
    struct TestView: View {
        var body: Never { fatalError("TestView is a primitive") }
    }

    // MARK: - 1. overlay

    func testOverlayReturnsOverlayView() {
        let v = TestView()
        let result = v.overlay(alignment: .center) { TestView() }
        // overlay() now returns OverlayView<Base, Overlay> instead of
        // ModifiedView<Base>. The old stub returned ModifiedView because
        // it threw the overlay content away; the real implementation
        // needs a dedicated view type so renderGTK can construct a
        // GtkOverlay container at the right point in the render pipeline.
        let _: OverlayView<TestView, TestView> = result
    }

    // MARK: - 2. shadow

    func testShadowReturnsModifiedView() {
        let v = TestView()
        let result = v.shadow(color: .black, radius: 4, x: 0, y: 2)
        let _: ModifiedView<TestView> = result
    }

    func testShadowDefaultParameters() {
        let v = TestView()
        let result = v.shadow()
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 3. clipped

    func testClippedReturnsModifiedView() {
        let v = TestView()
        let result = v.clipped()
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 4. clipShape

    func testClipShapeCircle() {
        let v = TestView()
        let result = v.clipShape(.circle)
        let _: ModifiedView<TestView> = result
    }

    func testClipShapeCapsule() {
        let v = TestView()
        let result = v.clipShape(.capsule)
        let _: ModifiedView<TestView> = result
    }

    func testClipShapeRoundedRectangle() {
        let v = TestView()
        let result = v.clipShape(.roundedRectangle(cornerRadius: 12))
        let _: ModifiedView<TestView> = result
    }

    func testClipShapeRectangle() {
        let v = TestView()
        let result = v.clipShape(.rectangle)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 5. fixedSize

    func testFixedSizeDefaultParameters() {
        let v = TestView()
        let result = v.fixedSize()
        let _: ModifiedView<TestView> = result
    }

    func testFixedSizeHorizontalOnly() {
        let v = TestView()
        let result = v.fixedSize(horizontal: true, vertical: false)
        let _: ModifiedView<TestView> = result
    }

    func testFixedSizeVerticalOnly() {
        let v = TestView()
        let result = v.fixedSize(horizontal: false, vertical: true)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 6. layoutPriority (stub)

    func testLayoutPriorityReturnsModifiedView() {
        let v = TestView()
        let result = v.layoutPriority(1.0)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 7. zIndex (stub)

    func testZIndexReturnsModifiedView() {
        let v = TestView()
        let result = v.zIndex(2.0)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 8. offset

    func testOffsetReturnsModifiedView() {
        let v = TestView()
        let result = v.offset(x: 10, y: -5)
        let _: ModifiedView<TestView> = result
    }

    func testOffsetDefaultParameters() {
        let v = TestView()
        let result = v.offset()
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 9. position

    func testPositionReturnsModifiedView() {
        let v = TestView()
        let result = v.position(x: 100, y: 200)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 10. alignmentGuide (stub)

    func testAlignmentGuideHorizontalReturnsModifiedView() {
        let v = TestView()
        let result = v.alignmentGuide(HorizontalAlignment.center) { _ in 0 }
        let _: ModifiedView<TestView> = result
    }

    func testAlignmentGuideVerticalReturnsModifiedView() {
        let v = TestView()
        let result = v.alignmentGuide(VerticalAlignment.center) { _ in 0 }
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 11. safeAreaInset (stub)

    func testSafeAreaInsetReturnsModifiedView() {
        let v = TestView()
        let result = v.safeAreaInset(edge: .top) { TestView() }
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 12. contentMargins

    func testContentMarginsAllEdges() {
        let v = TestView()
        let result = v.contentMargins(16)
        let _: ModifiedView<TestView> = result
    }

    func testContentMarginsSpecificEdges() {
        let v = TestView()
        let result = v.contentMargins(.horizontal, 8)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 13. scenePadding

    func testScenePaddingDefaultEdges() {
        let v = TestView()
        let result = v.scenePadding()
        let _: ModifiedView<TestView> = result
    }

    func testScenePaddingSpecificEdges() {
        let v = TestView()
        let result = v.scenePadding(.vertical)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 14. aspectRatio

    func testAspectRatioFit() {
        let v = TestView()
        let result = v.aspectRatio(16.0 / 9.0, contentMode: .fit)
        let _: ModifiedView<TestView> = result
    }

    func testAspectRatioFill() {
        let v = TestView()
        let result = v.aspectRatio(1.0, contentMode: .fill)
        let _: ModifiedView<TestView> = result
    }

    func testAspectRatioNilRatio() {
        let v = TestView()
        let result = v.aspectRatio(contentMode: .fit)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 15. mask (stub)

    func testMaskReturnsModifiedView() {
        let v = TestView()
        let result = v.mask { TestView() }
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 16. containerRelativeFrame (stub)

    func testContainerRelativeFrameHorizontal() {
        let v = TestView()
        let result = v.containerRelativeFrame(.horizontal)
        let _: ModifiedView<TestView> = result
    }

    func testContainerRelativeFrameAll() {
        let v = TestView()
        let result = v.containerRelativeFrame(.all)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - Supporting type tests

    func testClipShapeEnumAllCases() {
        // Verify all cases exist and pattern-match correctly.
        let shapes: [ClipShape] = [
            .circle,
            .capsule,
            .roundedRectangle(cornerRadius: 8),
            .rectangle,
        ]
        XCTAssertEqual(shapes.count, 4)
    }

    func testContentModeEnumAllCases() {
        let fitMode: ContentMode = .fit
        let fillMode: ContentMode = .fill
        XCTAssertNotEqual("\(fitMode)", "\(fillMode)")
    }

    func testViewDimensionsInit() {
        let dims = ViewDimensions(width: 100, height: 200)
        XCTAssertEqual(dims.width, 100)
        XCTAssertEqual(dims.height, 200)
    }

    func testAxisSetContainment() {
        let axes = Axis.Set.all
        XCTAssertTrue(axes.contains(.horizontal))
        XCTAssertTrue(axes.contains(.vertical))
        XCTAssertFalse(Axis.Set.horizontal.contains(.vertical))
    }

    // MARK: - Chaining test

    func testModifierChaining() {
        // Verify multiple layout modifiers can be chained together.
        let v = TestView()
        let result = v
            .shadow(radius: 4)
            .clipped()
            .fixedSize()
            .offset(x: 5, y: 0)
        // The chain should still compile as a ModifiedView of some kind.
        XCTAssertNotNil(result)
    }
}
