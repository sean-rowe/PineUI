// GeometryReaderTests.swift — Type-level tests for GeometryReader and GeometryProxy.
//
// These tests do not require a running GTK display — they verify compilation,
// correct return types, and the pure-Swift logic of GeometryProxy.

import XCTest
import Foundation
@testable import PineUI

final class GeometryReaderTests: XCTestCase {

    // A minimal concrete View for testing modifier return types.
    struct TestView: View {
        var body: Never { fatalError("TestView is a primitive") }
    }

    // MARK: - GeometryProxy

    func testGeometryProxyStoresSize() {
        let size = CGSize(width: 320, height: 240)
        let proxy = GeometryProxy(size: size)
        XCTAssertEqual(proxy.size.width, 320)
        XCTAssertEqual(proxy.size.height, 240)
    }

    func testGeometryProxyZeroSize() {
        let proxy = GeometryProxy(size: .zero)
        XCTAssertEqual(proxy.size.width, 0)
        XCTAssertEqual(proxy.size.height, 0)
    }

    func testGeometryProxyNonIntegerSize() {
        let proxy = GeometryProxy(size: CGSize(width: 123.5, height: 456.75))
        XCTAssertEqual(proxy.size.width, 123.5, accuracy: 0.001)
        XCTAssertEqual(proxy.size.height, 456.75, accuracy: 0.001)
    }

    // MARK: - GeometryReader init and View conformance

    func testGeometryReaderConformsToView() {
        // GeometryReader must be a View — verify the type is accepted where View is expected.
        let _: any View = GeometryReader { _ in TestView() }
    }

    func testGeometryReaderReceivesProxy() {
        // The closure must be called with a GeometryProxy.
        var receivedProxy: GeometryProxy? = nil
        let reader = GeometryReader { proxy in
            receivedProxy = proxy
            return TestView()
        }
        // The closure is captured, not called at init time.
        // Call it manually to verify the proxy is passed through.
        let proxy = GeometryProxy(size: CGSize(width: 100, height: 50))
        let _ = reader.content(proxy)
        XCTAssertNotNil(receivedProxy)
        XCTAssertEqual(receivedProxy?.size.width, 100)
        XCTAssertEqual(receivedProxy?.size.height, 50)
    }

    // MARK: - draggable(_:) string overload

    func testDraggableWithStringReturnsModifiedView() {
        let v = TestView()
        let result = v.draggable("hello")
        let _: ModifiedView<TestView> = result
    }

    func testDraggableDefaultStringReturnsModifiedView() {
        let v = TestView()
        let result = v.draggable()
        let _: ModifiedView<TestView> = result
    }
}
