// AppearanceModifierTests.swift — Type-level tests for appearance modifiers.
//
// These tests verify that each modifier compiles, returns the correct type,
// and does not crash when called on a simple view.

import XCTest
@testable import PineUI

final class AppearanceModifierTests: XCTestCase {

    // A minimal concrete View for testing modifier return types.
    struct TestView: View {
        var body: Never { fatalError("TestView is a primitive") }
    }

    // MARK: - 1. tint

    func testTintReturnsModifiedView() {
        let v = TestView()
        let result = v.tint(.blue)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 2. accentColor

    func testAccentColorReturnsModifiedView() {
        let v = TestView()
        let result = v.accentColor(.red)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 3. preferredColorScheme (stub)

    func testPreferredColorSchemeLight() {
        let v = TestView()
        let result = v.preferredColorScheme(.light)
        let _: ModifiedView<TestView> = result
    }

    func testPreferredColorSchemeDark() {
        let v = TestView()
        let result = v.preferredColorScheme(.dark)
        let _: ModifiedView<TestView> = result
    }

    func testPreferredColorSchemeNil() {
        let v = TestView()
        let result = v.preferredColorScheme(nil)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 4. blendMode

    func testBlendModeNormal() {
        let v = TestView()
        let result = v.blendMode(.normal)
        let _: ModifiedView<TestView> = result
    }

    func testBlendModeMultiply() {
        let v = TestView()
        let result = v.blendMode(.multiply)
        let _: ModifiedView<TestView> = result
    }

    func testBlendModeScreen() {
        let v = TestView()
        let result = v.blendMode(.screen)
        let _: ModifiedView<TestView> = result
    }

    func testBlendModeAllCases() {
        let modes: [BlendMode] = [
            .normal, .multiply, .screen, .overlay, .darken, .lighten,
            .colorDodge, .colorBurn, .hardLight, .softLight, .difference, .exclusion,
        ]
        XCTAssertEqual(modes.count, 12)
    }

    // MARK: - 5. saturation

    func testSaturationReturnsModifiedView() {
        let v = TestView()
        let result = v.saturation(0.5)
        let _: ModifiedView<TestView> = result
    }

    func testSaturationZero() {
        let v = TestView()
        let result = v.saturation(0.0)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 6. brightness

    func testBrightnessReturnsModifiedView() {
        let v = TestView()
        let result = v.brightness(0.2)
        let _: ModifiedView<TestView> = result
    }

    func testBrightnessNegative() {
        let v = TestView()
        let result = v.brightness(-0.3)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 7. contrast

    func testContrastReturnsModifiedView() {
        let v = TestView()
        let result = v.contrast(1.5)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 8. hueRotation

    func testHueRotationReturnsModifiedView() {
        let v = TestView()
        let result = v.hueRotation(90.0)
        let _: ModifiedView<TestView> = result
    }

    func testHueRotationFullCircle() {
        let v = TestView()
        let result = v.hueRotation(360.0)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 9. grayscale

    func testGrayscaleReturnsModifiedView() {
        let v = TestView()
        let result = v.grayscale(1.0)
        let _: ModifiedView<TestView> = result
    }

    func testGrayscalePartial() {
        let v = TestView()
        let result = v.grayscale(0.5)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 10. blur

    func testBlurReturnsModifiedView() {
        let v = TestView()
        let result = v.blur(radius: 4)
        let _: ModifiedView<TestView> = result
    }

    func testBlurZeroRadius() {
        let v = TestView()
        let result = v.blur(radius: 0)
        let _: ModifiedView<TestView> = result
    }

    func testBlurLargeRadius() {
        let v = TestView()
        let result = v.blur(radius: 20)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 11. compositingGroup (stub)

    func testCompositingGroupReturnsModifiedView() {
        let v = TestView()
        let result = v.compositingGroup()
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 12. drawingGroup (stub)

    func testDrawingGroupReturnsModifiedView() {
        let v = TestView()
        let result = v.drawingGroup()
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 13. glassEffect

    func testGlassEffectDefaultParameters() {
        let v = TestView()
        let result = v.glassEffect()
        let _: ModifiedView<TestView> = result
    }

    func testGlassEffectRegularStyle() {
        let v = TestView()
        let result = v.glassEffect(.regular, in: .roundedRectangle(cornerRadius: 12), isEnabled: true)
        let _: ModifiedView<TestView> = result
    }

    func testGlassEffectClearStyle() {
        let v = TestView()
        let result = v.glassEffect(.clear, in: .circle, isEnabled: true)
        let _: ModifiedView<TestView> = result
    }

    func testGlassEffectDisabled() {
        let v = TestView()
        let result = v.glassEffect(.regular, in: .rectangle, isEnabled: false)
        let _: ModifiedView<TestView> = result
    }

    func testGlassEffectAllShapes() {
        let v = TestView()
        let _ = v.glassEffect(.regular, in: .circle)
        let _ = v.glassEffect(.regular, in: .capsule)
        let _ = v.glassEffect(.regular, in: .roundedRectangle(cornerRadius: 8))
        let _ = v.glassEffect(.regular, in: .rectangle)
    }

    // MARK: - 14. backgroundExtensionEffect (stub)

    func testBackgroundExtensionEffectReturnsModifiedView() {
        let v = TestView()
        let result = v.backgroundExtensionEffect()
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 15. rotationEffect

    func testRotationEffectReturnsModifiedView() {
        let v = TestView()
        let result = v.rotationEffect(degrees: 45)
        let _: ModifiedView<TestView> = result
    }

    func testRotationEffectNegative() {
        let v = TestView()
        let result = v.rotationEffect(degrees: -90)
        let _: ModifiedView<TestView> = result
    }

    func testRotationEffectFullRotation() {
        let v = TestView()
        let result = v.rotationEffect(degrees: 360)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 16. rotation3DEffect

    func testRotation3DEffectXAxis() {
        let v = TestView()
        let result = v.rotation3DEffect(degrees: 45, axis: (x: 1, y: 0, z: 0))
        let _: ModifiedView<TestView> = result
    }

    func testRotation3DEffectYAxis() {
        let v = TestView()
        let result = v.rotation3DEffect(degrees: 30, axis: (x: 0, y: 1, z: 0))
        let _: ModifiedView<TestView> = result
    }

    func testRotation3DEffectZAxis() {
        let v = TestView()
        let result = v.rotation3DEffect(degrees: 90, axis: (x: 0, y: 0, z: 1))
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 17. scaleEffect (uniform)

    func testScaleEffectUniformReturnsModifiedView() {
        let v = TestView()
        let result = v.scaleEffect(1.5)
        let _: ModifiedView<TestView> = result
    }

    func testScaleEffectHalf() {
        let v = TestView()
        let result = v.scaleEffect(0.5)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 18. scaleEffect (x:y:)

    func testScaleEffectXYReturnsModifiedView() {
        let v = TestView()
        let result = v.scaleEffect(x: 2.0, y: 0.5)
        let _: ModifiedView<TestView> = result
    }

    func testScaleEffectXYUniform() {
        let v = TestView()
        let result = v.scaleEffect(x: 1.5, y: 1.5)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 19. redacted

    func testRedactedPlaceholder() {
        let v = TestView()
        let result = v.redacted(reason: .placeholder)
        let _: ModifiedView<TestView> = result
    }

    func testRedactedPrivacy() {
        let v = TestView()
        let result = v.redacted(reason: .privacy)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - Supporting enum tests

    func testBlendModeRawValues() {
        XCTAssertEqual(BlendMode.normal.rawValue, "normal")
        XCTAssertEqual(BlendMode.multiply.rawValue, "multiply")
        XCTAssertEqual(BlendMode.screen.rawValue, "screen")
        XCTAssertEqual(BlendMode.overlay.rawValue, "overlay")
        XCTAssertEqual(BlendMode.darken.rawValue, "darken")
        XCTAssertEqual(BlendMode.lighten.rawValue, "lighten")
        XCTAssertEqual(BlendMode.colorDodge.rawValue, "color-dodge")
        XCTAssertEqual(BlendMode.colorBurn.rawValue, "color-burn")
        XCTAssertEqual(BlendMode.hardLight.rawValue, "hard-light")
        XCTAssertEqual(BlendMode.softLight.rawValue, "soft-light")
        XCTAssertEqual(BlendMode.difference.rawValue, "difference")
        XCTAssertEqual(BlendMode.exclusion.rawValue, "exclusion")
    }

    func testColorSchemeEnumCases() {
        let light: ColorScheme = .light
        let dark: ColorScheme = .dark
        XCTAssertNotEqual("\(light)", "\(dark)")
    }

    func testGlassStyleEnumCases() {
        let regular: GlassStyle = .regular
        let clear: GlassStyle = .clear
        XCTAssertNotEqual("\(regular)", "\(clear)")
    }

    func testRedactionReasonEnumCases() {
        let placeholder: RedactionReason = .placeholder
        let privacy: RedactionReason = .privacy
        XCTAssertNotEqual("\(placeholder)", "\(privacy)")
    }

    // MARK: - Chaining tests

    func testAppearanceModifierChaining() {
        let v = TestView()
        let result = v
            .blur(radius: 4)
            .grayscale(0.5)
            .rotationEffect(degrees: 15)
        XCTAssertNotNil(result)
    }

    func testFilterModifiersChain() {
        let v = TestView()
        let result = v
            .saturation(0.8)
            .brightness(0.1)
            .contrast(1.2)
            .hueRotation(30)
        XCTAssertNotNil(result)
    }

    func testTransformModifiersChain() {
        let v = TestView()
        let result = v
            .scaleEffect(1.2)
            .rotationEffect(degrees: 45)
            .tint(.blue)
        XCTAssertNotNil(result)
    }
}
