// LazyStackTests.swift — Type-level tests for LazyVStack, LazyHStack, LazyHGrid,
// and the PinnedScrollableViews option set.
//
// These are compile-time / structural tests — they verify that each type:
//   • Can be instantiated with the documented initialisers
//   • Conforms to View and GTKRenderable
//   • Stores the expected values for inspectable properties

import XCTest
@testable import PineUI

final class LazyStackTests: XCTestCase {

    // MARK: - PinnedScrollableViews

    func testPinnedScrollableViewsRawValues() {
        XCTAssertEqual(PinnedScrollableViews.sectionHeaders.rawValue, 1)
        XCTAssertEqual(PinnedScrollableViews.sectionFooters.rawValue, 2)
    }

    func testPinnedScrollableViewsEmptySet() {
        let empty: PinnedScrollableViews = []
        XCTAssertTrue(empty.isEmpty)
    }

    func testPinnedScrollableViewsUnion() {
        let both: PinnedScrollableViews = [.sectionHeaders, .sectionFooters]
        XCTAssertTrue(both.contains(.sectionHeaders))
        XCTAssertTrue(both.contains(.sectionFooters))
    }

    func testPinnedScrollableViewsContains() {
        let headers: PinnedScrollableViews = .sectionHeaders
        XCTAssertTrue(headers.contains(.sectionHeaders))
        XCTAssertFalse(headers.contains(.sectionFooters))
    }

    func testPinnedScrollableViewsInit() {
        let custom = PinnedScrollableViews(rawValue: 3)
        XCTAssertEqual(custom.rawValue, 3)
    }

    // MARK: - LazyVStack conformances

    func testLazyVStackConformsToView() {
        let stack: any View = LazyVStack { Text("hi") }
        XCTAssertNotNil(stack)
    }

    func testLazyVStackConformsToGTKRenderable() {
        let stack: any GTKRenderable = LazyVStack { Text("hi") }
        XCTAssertNotNil(stack)
    }

    // MARK: - LazyVStack initialisers

    func testLazyVStackDefaultInit() {
        let stack = LazyVStack { Text("hello") }
        XCTAssertEqual(stack.spacing, 8)
        XCTAssertTrue(stack.pinnedViews.isEmpty)
    }

    func testLazyVStackCustomSpacing() {
        let stack = LazyVStack(spacing: 16) { Text("hello") }
        XCTAssertEqual(stack.spacing, 16)
    }

    func testLazyVStackZeroSpacing() {
        let stack = LazyVStack(spacing: 0) { Text("hello") }
        XCTAssertEqual(stack.spacing, 0)
    }

    func testLazyVStackAlignmentLeading() {
        let stack = LazyVStack(alignment: .leading) { Text("hello") }
        XCTAssertNotNil(stack)
    }

    func testLazyVStackAlignmentTrailing() {
        let stack = LazyVStack(alignment: .trailing) { Text("hello") }
        XCTAssertNotNil(stack)
    }

    func testLazyVStackWithPinnedHeaders() {
        let stack = LazyVStack(pinnedViews: .sectionHeaders) { Text("hello") }
        XCTAssertTrue(stack.pinnedViews.contains(.sectionHeaders))
        XCTAssertFalse(stack.pinnedViews.contains(.sectionFooters))
    }

    func testLazyVStackWithPinnedFooters() {
        let stack = LazyVStack(pinnedViews: .sectionFooters) { Text("hello") }
        XCTAssertTrue(stack.pinnedViews.contains(.sectionFooters))
    }

    func testLazyVStackWithBothPinnedViews() {
        let stack = LazyVStack(pinnedViews: [.sectionHeaders, .sectionFooters]) {
            Text("hello")
        }
        XCTAssertTrue(stack.pinnedViews.contains(.sectionHeaders))
        XCTAssertTrue(stack.pinnedViews.contains(.sectionFooters))
    }

    func testLazyVStackNilSpacingDefaultsToEight() {
        let stack = LazyVStack(spacing: nil) { Text("hello") }
        XCTAssertEqual(stack.spacing, 8)
    }

    func testLazyVStackAllParameters() {
        let stack = LazyVStack(
            alignment: .leading,
            spacing: 20,
            pinnedViews: .sectionHeaders
        ) {
            Text("A")
            Text("B")
        }
        XCTAssertEqual(stack.spacing, 20)
        XCTAssertTrue(stack.pinnedViews.contains(.sectionHeaders))
    }

    // MARK: - LazyHStack conformances

    func testLazyHStackConformsToView() {
        let stack: any View = LazyHStack { Text("hi") }
        XCTAssertNotNil(stack)
    }

    func testLazyHStackConformsToGTKRenderable() {
        let stack: any GTKRenderable = LazyHStack { Text("hi") }
        XCTAssertNotNil(stack)
    }

    // MARK: - LazyHStack initialisers

    func testLazyHStackDefaultInit() {
        let stack = LazyHStack { Text("hello") }
        XCTAssertEqual(stack.spacing, 8)
        XCTAssertTrue(stack.pinnedViews.isEmpty)
    }

    func testLazyHStackCustomSpacing() {
        let stack = LazyHStack(spacing: 24) { Text("hello") }
        XCTAssertEqual(stack.spacing, 24)
    }

    func testLazyHStackZeroSpacing() {
        let stack = LazyHStack(spacing: 0) { Text("hello") }
        XCTAssertEqual(stack.spacing, 0)
    }

    func testLazyHStackAlignmentTop() {
        let stack = LazyHStack(alignment: .top) { Text("hello") }
        XCTAssertNotNil(stack)
    }

    func testLazyHStackAlignmentBottom() {
        let stack = LazyHStack(alignment: .bottom) { Text("hello") }
        XCTAssertNotNil(stack)
    }

    func testLazyHStackWithPinnedHeaders() {
        let stack = LazyHStack(pinnedViews: .sectionHeaders) { Text("hello") }
        XCTAssertTrue(stack.pinnedViews.contains(.sectionHeaders))
    }

    func testLazyHStackNilSpacingDefaultsToEight() {
        let stack = LazyHStack(spacing: nil) { Text("hello") }
        XCTAssertEqual(stack.spacing, 8)
    }

    func testLazyHStackAllParameters() {
        let stack = LazyHStack(
            alignment: .top,
            spacing: 4,
            pinnedViews: [.sectionHeaders, .sectionFooters]
        ) {
            Text("X")
            Text("Y")
        }
        XCTAssertEqual(stack.spacing, 4)
        XCTAssertTrue(stack.pinnedViews.contains(.sectionHeaders))
        XCTAssertTrue(stack.pinnedViews.contains(.sectionFooters))
    }

    // MARK: - LazyHGrid conformances

    func testLazyHGridConformsToView() {
        let grid: any View = LazyHGrid(rows: 2, data: [1, 2, 3]) { _ in Text("x") }
        XCTAssertNotNil(grid)
    }

    func testLazyHGridConformsToGTKRenderable() {
        let grid: any GTKRenderable = LazyHGrid(rows: 2, data: [1, 2, 3]) { _ in Text("x") }
        XCTAssertNotNil(grid)
    }

    // MARK: - LazyHGrid initialisers

    func testLazyHGridDefaultSpacing() {
        let grid = LazyHGrid(rows: 3, data: ["a", "b"]) { _ in Text("item") }
        XCTAssertEqual(grid.spacing, 8)
        XCTAssertEqual(grid.rows, 3)
    }

    func testLazyHGridCustomSpacing() {
        let grid = LazyHGrid(rows: 2, spacing: 16, data: [1]) { _ in Text("item") }
        XCTAssertEqual(grid.spacing, 16)
    }

    func testLazyHGridRowCount() {
        let grid = LazyHGrid(rows: 5, data: (0..<10).map { $0 }) { _ in Text("cell") }
        XCTAssertEqual(grid.rows, 5)
    }

    func testLazyHGridDataCount() {
        let items = Array(0..<7)
        let grid = LazyHGrid(rows: 2, data: items) { i in Text("\(i)") }
        XCTAssertEqual(grid.data.count, 7)
    }

    func testLazyHGridWithStringData() {
        let names = ["Alice", "Bob", "Carol"]
        let grid = LazyHGrid(rows: 1, data: names) { name in Text(name) }
        XCTAssertEqual(grid.data.count, 3)
    }

    func testLazyHGridWithEmptyData() {
        let grid = LazyHGrid(rows: 3, data: [String]()) { _ in Text("none") }
        XCTAssertEqual(grid.data.count, 0)
    }

    func testLazyHGridSingleRow() {
        let grid = LazyHGrid(rows: 1, spacing: 4, data: [10, 20, 30]) { n in
            Text("\(n)")
        }
        XCTAssertEqual(grid.rows, 1)
        XCTAssertEqual(grid.spacing, 4)
    }

    // MARK: - Type compatibility with VStack / HStack siblings

    func testLazyVStackAndVStackShareAlignmentEnum() {
        // Both use HorizontalAlignment — confirm they accept the same values.
        let vstack = VStack(alignment: .leading) { Text("v") }
        let lazyVstack = LazyVStack(alignment: .leading) { Text("v") }
        XCTAssertNotNil(vstack)
        XCTAssertNotNil(lazyVstack)
    }

    func testLazyHStackAndHStackShareAlignmentEnum() {
        let hstack = HStack(alignment: .top) { Text("h") }
        let lazyHstack = LazyHStack(alignment: .top) { Text("h") }
        XCTAssertNotNil(hstack)
        XCTAssertNotNil(lazyHstack)
    }

    func testLazyVGridAndLazyHGridAreDifferentTypes() {
        let vgrid = LazyVGrid(columns: 2, data: [1, 2]) { _ in Text("v") }
        let hgrid = LazyHGrid(rows: 2, data: [1, 2]) { _ in Text("h") }
        XCTAssertNotNil(vgrid)
        XCTAssertNotNil(hgrid)
    }
}
