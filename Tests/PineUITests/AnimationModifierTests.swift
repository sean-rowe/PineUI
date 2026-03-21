// AnimationModifierTests.swift — Type-level tests for animation modifiers.
//
// These tests verify that each modifier compiles, returns the correct type,
// and does not crash when called on a simple view. No GTK display is required.

import XCTest
@testable import PineUI

final class AnimationModifierTests: XCTestCase {

    // A minimal concrete View for testing modifier return types.
    struct TestView: View {
        var body: Never { fatalError("TestView is a primitive") }
    }

    // MARK: - 1. animation

    func testAnimationDefaultReturnsModifiedView() {
        let v = TestView()
        let result = v.animation(.default)
        let _: ModifiedView<TestView> = result
    }

    func testAnimationEaseInReturnsModifiedView() {
        let v = TestView()
        let result = v.animation(.easeIn)
        let _: ModifiedView<TestView> = result
    }

    func testAnimationEaseOutReturnsModifiedView() {
        let v = TestView()
        let result = v.animation(.easeOut)
        let _: ModifiedView<TestView> = result
    }

    func testAnimationEaseInOutReturnsModifiedView() {
        let v = TestView()
        let result = v.animation(.easeInOut)
        let _: ModifiedView<TestView> = result
    }

    func testAnimationLinearReturnsModifiedView() {
        let v = TestView()
        let result = v.animation(.linear)
        let _: ModifiedView<TestView> = result
    }

    func testAnimationSpringReturnsModifiedView() {
        let v = TestView()
        let result = v.animation(.spring)
        let _: ModifiedView<TestView> = result
    }

    func testAnimationNoneReturnsModifiedView() {
        let v = TestView()
        let result = v.animation(.none)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - PineAnimation CSS values

    func testPineAnimationDefaultCss() {
        XCTAssertEqual(PineAnimation.default.css, "all 0.3s ease-in-out")
    }

    func testPineAnimationEaseInCss() {
        XCTAssertEqual(PineAnimation.easeIn.css, "all 0.3s ease-in")
    }

    func testPineAnimationEaseOutCss() {
        XCTAssertEqual(PineAnimation.easeOut.css, "all 0.3s ease-out")
    }

    func testPineAnimationEaseInOutCss() {
        XCTAssertEqual(PineAnimation.easeInOut.css, "all 0.3s ease-in-out")
    }

    func testPineAnimationLinearCss() {
        XCTAssertEqual(PineAnimation.linear.css, "all 0.3s linear")
    }

    func testPineAnimationSpringCss() {
        XCTAssertTrue(PineAnimation.spring.css.contains("cubic-bezier"))
    }

    func testPineAnimationNoneCss() {
        XCTAssertEqual(PineAnimation.none.css, "none")
    }

    // MARK: - 2. transition

    func testTransitionOpacityReturnsModifiedView() {
        let v = TestView()
        let result = v.transition(.opacity)
        let _: ModifiedView<TestView> = result
    }

    func testTransitionSlideReturnsModifiedView() {
        let v = TestView()
        let result = v.transition(.slide)
        let _: ModifiedView<TestView> = result
    }

    func testTransitionScaleReturnsModifiedView() {
        let v = TestView()
        let result = v.transition(.scale)
        let _: ModifiedView<TestView> = result
    }

    func testTransitionMoveLeadingReturnsModifiedView() {
        let v = TestView()
        let result = v.transition(.move(edge: .leading))
        let _: ModifiedView<TestView> = result
    }

    func testTransitionMoveTrailingReturnsModifiedView() {
        let v = TestView()
        let result = v.transition(.move(edge: .trailing))
        let _: ModifiedView<TestView> = result
    }

    func testTransitionMoveTopReturnsModifiedView() {
        let v = TestView()
        let result = v.transition(.move(edge: .top))
        let _: ModifiedView<TestView> = result
    }

    func testTransitionMoveBottomReturnsModifiedView() {
        let v = TestView()
        let result = v.transition(.move(edge: .bottom))
        let _: ModifiedView<TestView> = result
    }

    func testTransitionIdentityReturnsModifiedView() {
        let v = TestView()
        let result = v.transition(.identity)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 3. matchedGeometryEffect (stub)

    func testMatchedGeometryEffectReturnsModifiedView() {
        let v = TestView()
        let ns = Namespace()
        let result = v.matchedGeometryEffect(id: "hero", in: ns.wrappedValue)
        let _: ModifiedView<TestView> = result
    }

    func testMatchedGeometryEffectWithIntIdReturnsModifiedView() {
        let v = TestView()
        let ns = Namespace()
        let result = v.matchedGeometryEffect(id: 42, in: ns.wrappedValue)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 4. contentTransition

    func testContentTransitionOpacityReturnsModifiedView() {
        let v = TestView()
        let result = v.contentTransition(.opacity)
        let _: ModifiedView<TestView> = result
    }

    func testContentTransitionInterpolateReturnsModifiedView() {
        let v = TestView()
        let result = v.contentTransition(.interpolate)
        let _: ModifiedView<TestView> = result
    }

    func testContentTransitionIdentityReturnsModifiedView() {
        let v = TestView()
        let result = v.contentTransition(.identity)
        let _: ModifiedView<TestView> = result
    }

    func testContentTransitionNumericTextReturnsModifiedView() {
        let v = TestView()
        let result = v.contentTransition(.numericText)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 5. phaseAnimator (stub)

    func testPhaseAnimatorReturnsModifiedView() {
        let v = TestView()
        let result = v.phaseAnimator(phases: [1, 2, 3]) { phase in
            TestView()
        }
        let _: ModifiedView<TestView> = result
    }

    func testPhaseAnimatorEmptyPhasesReturnsModifiedView() {
        let v = TestView()
        let result = v.phaseAnimator(phases: [String]()) { _ in
            TestView()
        }
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 6. keyframeAnimator (stub)

    func testKeyframeAnimatorReturnsModifiedView() {
        let v = TestView()
        let result = v.keyframeAnimator(
            initialValue: 0.0,
            content: { _ in TestView() },
            keyframes: { _ in () }
        )
        let _: ModifiedView<TestView> = result
    }

    // MARK: - 7. sensoryFeedback (stub)

    func testSensoryFeedbackSuccessReturnsModifiedView() {
        let v = TestView()
        let result = v.sensoryFeedback(.success, trigger: true)
        let _: ModifiedView<TestView> = result
    }

    func testSensoryFeedbackWarningReturnsModifiedView() {
        let v = TestView()
        let result = v.sensoryFeedback(.warning, trigger: 42)
        let _: ModifiedView<TestView> = result
    }

    func testSensoryFeedbackErrorReturnsModifiedView() {
        let v = TestView()
        let result = v.sensoryFeedback(.error, trigger: "changed")
        let _: ModifiedView<TestView> = result
    }

    func testSensoryFeedbackSelectionReturnsModifiedView() {
        let v = TestView()
        let result = v.sensoryFeedback(.selection, trigger: 0)
        let _: ModifiedView<TestView> = result
    }

    func testSensoryFeedbackImpactReturnsModifiedView() {
        let v = TestView()
        let result = v.sensoryFeedback(.impact, trigger: false)
        let _: ModifiedView<TestView> = result
    }

    func testSensoryFeedbackAlignmentReturnsModifiedView() {
        let v = TestView()
        let result = v.sensoryFeedback(.alignment, trigger: 1.5)
        let _: ModifiedView<TestView> = result
    }

    // MARK: - Supporting enum completeness

    func testSensoryFeedbackTypeAllCases() {
        let types: [SensoryFeedbackType] = [
            .success, .warning, .error, .selection, .impact, .alignment
        ]
        XCTAssertEqual(types.count, 6)
    }

    func testAnyTransitionAllCases() {
        let transitions: [AnyTransition] = [
            .opacity, .slide, .scale, .move(edge: .top), .identity
        ]
        XCTAssertEqual(transitions.count, 5)
    }

    func testContentTransitionAllCases() {
        let transitions: [ContentTransition] = [
            .opacity, .interpolate, .identity, .numericText
        ]
        XCTAssertEqual(transitions.count, 4)
    }

    // MARK: - withAnimation

    func testWithAnimationExecutesBody() {
        var executed = false
        withAnimation(.default) {
            executed = true
        }
        XCTAssertTrue(executed)
    }

    func testWithAnimationSetsContext() {
        withAnimation(.easeIn) {
            XCTAssertEqual(PineAnimationContext.current?.css, PineAnimation.easeIn.css)
        }
    }

    func testWithAnimationRestoresContextAfterBody() {
        XCTAssertNil(PineAnimationContext.current)
        withAnimation(.spring) { }
        XCTAssertNil(PineAnimationContext.current)
    }

    func testWithAnimationNested() {
        withAnimation(.linear) {
            XCTAssertEqual(PineAnimationContext.current?.css, PineAnimation.linear.css)
            withAnimation(.easeOut) {
                XCTAssertEqual(PineAnimationContext.current?.css, PineAnimation.easeOut.css)
            }
            XCTAssertEqual(PineAnimationContext.current?.css, PineAnimation.linear.css)
        }
        XCTAssertNil(PineAnimationContext.current)
    }

    func testWithAnimationDefaultParameter() {
        withAnimation {
            XCTAssertEqual(PineAnimationContext.current?.css, PineAnimation.default.css)
        }
    }

    // MARK: - Chaining

    func testAnimationModifiersChain() {
        let v = TestView()
        let result = v
            .animation(.spring)
            .transition(.opacity)
            .contentTransition(.opacity)
        XCTAssertNotNil(result)
    }

    func testAnimationWithOtherModifiersChain() {
        let v = TestView()
        let result = v
            .animation(.easeInOut)
            .opacity(0.8)
            .scaleEffect(1.1)
        XCTAssertNotNil(result)
    }
}
