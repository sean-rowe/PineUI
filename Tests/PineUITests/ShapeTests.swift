// ShapeTests.swift — Type-level tests for Shape protocol and shape views.
//
// Verifies that each shape compiles, conforms to the Shape protocol, and
// that modifiers (.fill, .stroke) return the correct types.

import XCTest
@testable import PineUI

final class ShapeTests: XCTestCase {

    // MARK: - CGRect (Foundation type used by path(in:))

    func testCGRectZeroIsZero() {
        // Foundation's CGRect.zero — verify it is usable in path(in:) calls.
        let r = CGRect.zero
        XCTAssertEqual(r.width, 0)
        XCTAssertEqual(r.height, 0)
    }

    func testCGRectInitWithDoubles() {
        let r = CGRect(x: 10, y: 20, width: 100, height: 200)
        XCTAssertEqual(r.width, 100)
        XCTAssertEqual(r.height, 200)
    }

    // MARK: - CGSize (Foundation type)

    func testCGSizeZeroIsZero() {
        let s = CGSize.zero
        XCTAssertEqual(s.width, 0)
        XCTAssertEqual(s.height, 0)
    }

    func testCGSizeInitWithDoubles() {
        let s = CGSize(width: 320, height: 480)
        XCTAssertEqual(s.width, 320)
        XCTAssertEqual(s.height, 480)
    }

    // MARK: - Rectangle

    func testRectangleConformsToShape() {
        let shape: any Shape = Rectangle()
        XCTAssertNotNil(shape)
    }

    func testRectangleConformsToView() {
        let view: any View = Rectangle()
        XCTAssertNotNil(view)
    }

    func testRectangleConformsToGTKRenderable() {
        let renderable: any GTKRenderable = Rectangle()
        XCTAssertNotNil(renderable)
    }

    func testRectanglePath() {
        // path(in:) is a no-op stub — just verify it doesn't crash.
        Rectangle().path(in: .zero)
    }

    // MARK: - RoundedRectangle

    func testRoundedRectangleConformsToShape() {
        let shape: any Shape = RoundedRectangle(cornerRadius: 12)
        XCTAssertNotNil(shape)
    }

    func testRoundedRectangleConformsToView() {
        let view: any View = RoundedRectangle(cornerRadius: 8)
        XCTAssertNotNil(view)
    }

    func testRoundedRectangleStoressCornerRadius() {
        let rr = RoundedRectangle(cornerRadius: 16)
        XCTAssertEqual(rr.cornerRadius, 16)
    }

    func testRoundedRectanglePath() {
        RoundedRectangle(cornerRadius: 8).path(in: .zero)
    }

    // MARK: - Circle

    func testCircleConformsToShape() {
        let shape: any Shape = Circle()
        XCTAssertNotNil(shape)
    }

    func testCircleConformsToView() {
        let view: any View = Circle()
        XCTAssertNotNil(view)
    }

    func testCirclePath() {
        Circle().path(in: .zero)
    }

    // MARK: - Ellipse

    func testEllipseConformsToShape() {
        let shape: any Shape = Ellipse()
        XCTAssertNotNil(shape)
    }

    func testEllipseConformsToView() {
        let view: any View = Ellipse()
        XCTAssertNotNil(view)
    }

    func testEllipsePath() {
        Ellipse().path(in: .zero)
    }

    // MARK: - Capsule

    func testCapsuleConformsToShape() {
        let shape: any Shape = Capsule()
        XCTAssertNotNil(shape)
    }

    func testCapsuleConformsToView() {
        let view: any View = Capsule()
        XCTAssertNotNil(view)
    }

    func testCapsulePath() {
        Capsule().path(in: .zero)
    }

    // MARK: - Path

    func testPathConformsToShape() {
        let shape: any Shape = Path()
        XCTAssertNotNil(shape)
    }

    func testPathConformsToView() {
        let view: any View = Path()
        XCTAssertNotNil(view)
    }

    func testPathBuilderInit() {
        // Builder-style init should not crash.
        let p = Path { _ in }
        XCTAssertNotNil(p)
    }

    func testPathPathMethod() {
        Path().path(in: .zero)
    }

    // MARK: - fill modifier

    func testRectangleFillReturnsModifiedView() {
        let result = Rectangle().fill(.blue)
        let _: ModifiedView<Rectangle> = result
    }

    func testCircleFillReturnsModifiedView() {
        let result = Circle().fill(.red)
        let _: ModifiedView<Circle> = result
    }

    func testCapsuleFillReturnsModifiedView() {
        let result = Capsule().fill(.green)
        let _: ModifiedView<Capsule> = result
    }

    func testEllipseFillReturnsModifiedView() {
        let result = Ellipse().fill(.yellow)
        let _: ModifiedView<Ellipse> = result
    }

    func testRoundedRectangleFillReturnsModifiedView() {
        let result = RoundedRectangle(cornerRadius: 10).fill(.orange)
        let _: ModifiedView<RoundedRectangle> = result
    }

    // MARK: - stroke modifier

    func testRectangleStrokeReturnsModifiedView() {
        let result = Rectangle().stroke(.black, lineWidth: 2)
        let _: ModifiedView<Rectangle> = result
    }

    func testCircleStrokeDefaultLineWidth() {
        let result = Circle().stroke(.gray)
        let _: ModifiedView<Circle> = result
    }

    func testCapsuleStrokeReturnsModifiedView() {
        let result = Capsule().stroke(.blue, lineWidth: 3)
        let _: ModifiedView<Capsule> = result
    }

    func testEllipseStrokeReturnsModifiedView() {
        let result = Ellipse().stroke(.red, lineWidth: 1)
        let _: ModifiedView<Ellipse> = result
    }

    func testRoundedRectangleStrokeReturnsModifiedView() {
        let result = RoundedRectangle(cornerRadius: 8).stroke(.purple, lineWidth: 2)
        let _: ModifiedView<RoundedRectangle> = result
    }

    // MARK: - Modifier chaining

    func testShapeModifierChaining() {
        // Shapes should compose with standard View modifiers after fill/stroke.
        let result = Circle()
            .fill(.blue)
            .padding(16)
            .opacity(0.8)
        XCTAssertNotNil(result)
    }

    func testShapeWithFrameModifier() {
        let result = Rectangle()
            .frame(width: 100, height: 100)
        XCTAssertNotNil(result)
    }

    // MARK: - All shapes compile as any Shape

    func testAllShapesAsExistential() {
        let shapes: [any Shape] = [
            Rectangle(),
            RoundedRectangle(cornerRadius: 12),
            Circle(),
            Ellipse(),
            Capsule(),
            Path(),
        ]
        XCTAssertEqual(shapes.count, 6)
    }
}
