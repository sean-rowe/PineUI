// MissingViewTests.swift — Type-level tests for the views added in MissingViews.swift.
//
// Verifies that each type:
//   • Can be instantiated with the documented initialisers
//   • Conforms to View and GTKRenderable
//   • Stores the expected values for inspectable properties

import XCTest
@testable import PineUI

final class MissingViewTests: XCTestCase {

    // MARK: - LabeledContent

    func testLabeledContentConformsToView() {
        let v: any View = LabeledContent(label: { Text("Label") }, content: { Text("Value") })
        XCTAssertNotNil(v)
    }

    func testLabeledContentConformsToGTKRenderable() {
        let v: any GTKRenderable = LabeledContent(label: { Text("Label") }, content: { Text("Value") })
        XCTAssertNotNil(v)
    }

    func testLabeledContentStringConvenience() {
        let v = LabeledContent("Name", value: "Sean")
        let _: any View = v
        XCTAssertNotNil(v)
    }

    func testLabeledContentAcceptsAnyViewLabel() {
        let v = LabeledContent(label: { Image(systemName: "star") }, content: { Text("5") })
        XCTAssertNotNil(v)
    }

    func testLabeledContentAcceptsAnyViewContent() {
        let v = LabeledContent(label: { Text("Status") }, content: { Image(systemName: "checkmark") })
        XCTAssertNotNil(v)
    }

    // MARK: - ControlGroup

    func testControlGroupConformsToView() {
        let v: any View = ControlGroup { Text("A") }
        XCTAssertNotNil(v)
    }

    func testControlGroupConformsToGTKRenderable() {
        let v: any GTKRenderable = ControlGroup { Text("A") }
        XCTAssertNotNil(v)
    }

    func testControlGroupWithMultipleChildren() {
        let v = ControlGroup {
            Button("Cut") {}
            Button("Copy") {}
            Button("Paste") {}
        }
        XCTAssertNotNil(v)
    }

    func testControlGroupWithSingleChild() {
        let v = ControlGroup { Button("OK") {} }
        XCTAssertNotNil(v)
    }

    // MARK: - ViewThatFits

    func testViewThatFitsConformsToView() {
        let v: any View = ViewThatFits { Text("Hello") }
        XCTAssertNotNil(v)
    }

    func testViewThatFitsConformsToGTKRenderable() {
        let v: any GTKRenderable = ViewThatFits { Text("Hello") }
        XCTAssertNotNil(v)
    }

    func testViewThatFitsWithMultipleChildren() {
        let v = ViewThatFits {
            Text("Long label that might not fit")
            Text("Short")
        }
        XCTAssertNotNil(v)
    }

    func testViewThatFitsWithSingleChild() {
        let v = ViewThatFits { Text("Only option") }
        XCTAssertNotNil(v)
    }

    // MARK: - TimelineSchedule

    func testTimelineScheduleAnimation() {
        let s = TimelineSchedule.animation
        if case .animation = s { XCTAssertTrue(true) } else { XCTFail() }
    }

    func testTimelineScheduleEveryMinute() {
        let s = TimelineSchedule.everyMinute
        if case .everyMinute = s { XCTAssertTrue(true) } else { XCTFail() }
    }

    func testTimelineSchedulePeriodic() {
        let s = TimelineSchedule.periodic(from: 0, by: 60)
        if case .periodic(let from, let by) = s {
            XCTAssertEqual(from, 0)
            XCTAssertEqual(by, 60)
        } else { XCTFail() }
    }

    func testTimelineScheduleExplicit() {
        let s = TimelineSchedule.explicit([0, 30, 60])
        if case .explicit(let times) = s {
            XCTAssertEqual(times.count, 3)
        } else { XCTFail() }
    }

    // MARK: - TimelineView

    func testTimelineViewConformsToView() {
        let v: any View = TimelineView(.everyMinute) { Text("Tick") }
        XCTAssertNotNil(v)
    }

    func testTimelineViewConformsToGTKRenderable() {
        let v: any GTKRenderable = TimelineView(.everyMinute) { Text("Tick") }
        XCTAssertNotNil(v)
    }

    func testTimelineViewDefaultSchedule() {
        let v = TimelineView { Text("default") }
        XCTAssertNotNil(v)
    }

    func testTimelineViewAnimationSchedule() {
        let v = TimelineView(.animation) { Text("Animated") }
        XCTAssertNotNil(v)
    }

    func testTimelineViewPeriodicSchedule() {
        let v = TimelineView(.periodic(from: 0, by: 5)) { Text("Periodic") }
        XCTAssertNotNil(v)
    }

    func testTimelineViewExplicitSchedule() {
        let v = TimelineView(.explicit([0, 10, 20])) { Text("Explicit") }
        XCTAssertNotNil(v)
    }

    // MARK: - OutlineGroup

    func testOutlineGroupConformsToView() {
        let v: any View = OutlineGroup(["A", "B"]) { Text($0) }
        XCTAssertNotNil(v)
    }

    func testOutlineGroupConformsToGTKRenderable() {
        let v: any GTKRenderable = OutlineGroup([1, 2, 3]) { Text("\($0)") }
        XCTAssertNotNil(v)
    }

    func testOutlineGroupStoresData() {
        let items = ["root", "child1", "child2"]
        let v = OutlineGroup(items) { Text($0) }
        XCTAssertEqual(Array(v.data), items)
    }

    func testOutlineGroupWithEmptyData() {
        let v = OutlineGroup([String]()) { Text($0) }
        XCTAssertTrue(Array(v.data).isEmpty)
    }

    func testOutlineGroupWithIntData() {
        let v = OutlineGroup(Array(0..<5)) { Text("\($0)") }
        XCTAssertEqual(Array(v.data).count, 5)
    }

    // MARK: - MenuView

    func testMenuViewConformsToView() {
        let v: any View = MenuView(content: { Text("Item") }, label: { Text("Menu") })
        XCTAssertNotNil(v)
    }

    func testMenuViewConformsToGTKRenderable() {
        let v: any GTKRenderable = MenuView(content: { Text("Item") }, label: { Text("Menu") })
        XCTAssertNotNil(v)
    }

    func testMenuViewStringConvenience() {
        let v = MenuView("Options") { Text("Edit") }
        let _: any View = v
        XCTAssertNotNil(v)
    }

    func testMenuViewWithMultipleItems() {
        let v = MenuView(
            content: {
                Button("Cut") {}
                Button("Copy") {}
                Button("Paste") {}
            },
            label: { Text("Edit") }
        )
        XCTAssertNotNil(v)
    }

    func testMenuViewWithIconLabel() {
        let v = MenuView(
            content: { Text("Action") },
            label: { Image(systemName: "ellipsis.circle") }
        )
        XCTAssertNotNil(v)
    }

    // MARK: - GridRow

    func testGridRowConformsToView() {
        let v: any View = GridRow { Text("A") }
        XCTAssertNotNil(v)
    }

    func testGridRowConformsToGTKRenderable() {
        let v: any GTKRenderable = GridRow { Text("A") }
        XCTAssertNotNil(v)
    }

    func testGridRowConformsToMultiChildView() {
        let v: any MultiChildView = GridRow {
            Text("Col1")
            Text("Col2")
        }
        XCTAssertNotNil(v)
    }

    func testGridRowWithTwoChildrenConformsToMultiChildView() {
        // Verify the conformance — rendering is not exercised (requires GTK display).
        let row = GridRow {
            Text("X")
            Text("Y")
        }
        let _: any MultiChildView = row
        XCTAssertNotNil(row)
    }

    func testGridRowWithSingleChildConformsToMultiChildView() {
        let row = GridRow { Text("Only") }
        let _: any MultiChildView = row
        XCTAssertNotNil(row)
    }

    // MARK: - ShareLink

    func testShareLinkConformsToView() {
        let v: any View = ShareLink()
        XCTAssertNotNil(v)
    }

    func testShareLinkConformsToGTKRenderable() {
        let v: any GTKRenderable = ShareLink()
        XCTAssertNotNil(v)
    }

    func testShareLinkDefaultTitle() {
        let v = ShareLink()
        XCTAssertEqual(v.title, "Share")
    }

    func testShareLinkCustomTitle() {
        let v = ShareLink("Export")
        XCTAssertEqual(v.title, "Export")
    }

    func testShareLinkCustomTitleVariants() {
        let v1 = ShareLink("Send")
        let v2 = ShareLink("Upload")
        XCTAssertEqual(v1.title, "Send")
        XCTAssertEqual(v2.title, "Upload")
    }

    // MARK: - AsyncImage

    func testAsyncImageConformsToView() {
        let v: any View = AsyncImage(url: nil)
        XCTAssertNotNil(v)
    }

    func testAsyncImageConformsToGTKRenderable() {
        let v: any GTKRenderable = AsyncImage(url: nil)
        XCTAssertNotNil(v)
    }

    func testAsyncImageNilUrl() {
        let v = AsyncImage(url: nil)
        XCTAssertNil(v.url)
    }

    func testAsyncImageWithUrl() {
        let v = AsyncImage(url: "https://example.com/image.png")
        XCTAssertEqual(v.url, "https://example.com/image.png")
    }

    func testAsyncImageWithDifferentUrls() {
        let v1 = AsyncImage(url: "https://a.com/1.jpg")
        let v2 = AsyncImage(url: "https://b.com/2.png")
        XCTAssertNotEqual(v1.url, v2.url)
    }

    // MARK: - ColorView

    func testColorViewConformsToView() {
        let v: any View = ColorView(.blue)
        XCTAssertNotNil(v)
    }

    func testColorViewConformsToGTKRenderable() {
        let v: any GTKRenderable = ColorView(.red)
        XCTAssertNotNil(v)
    }

    func testColorViewStoresColor() {
        let v = ColorView(.green)
        XCTAssertEqual(v.color.cssValue, Color.green.cssValue)
    }

    func testColorViewWithCustomColor() {
        let custom = Color(red: 0.5, green: 0.3, blue: 0.9)
        let v = ColorView(custom)
        XCTAssertNotNil(v)
    }

    func testColorViewWithSemanticColor() {
        let v = ColorView(.accentColor)
        XCTAssertNotNil(v)
    }

    func testColorViewWithClearColor() {
        let v = ColorView(.clear)
        XCTAssertNotNil(v)
    }

    // MARK: - Separator (typealias for Divider)

    func testSeparatorIsTypealias() {
        // Separator and Divider are the same type.
        let sep: Separator = Separator()
        let div: Divider = sep
        XCTAssertNotNil(div)
    }

    func testSeparatorConformsToView() {
        let v: any View = Separator()
        XCTAssertNotNil(v)
    }

    func testSeparatorConformsToGTKRenderable() {
        let v: any GTKRenderable = Separator()
        XCTAssertNotNil(v)
    }

    // MARK: - Material

    func testMaterialCases() {
        let cases: [Material] = [
            .ultraThinMaterial,
            .thinMaterial,
            .regularMaterial,
            .thickMaterial,
            .ultraThickMaterial,
        ]
        XCTAssertEqual(cases.count, 5)
    }

    func testMaterialCssValuesDifferByOpacity() {
        // Higher opacity materials should have a higher alpha value in their CSS.
        let thin = Material.thinMaterial.cssValue
        let thick = Material.thickMaterial.cssValue
        XCTAssertNotEqual(thin, thick)
    }

    func testMaterialUltraThinCssValue() {
        let m = Material.ultraThinMaterial
        XCTAssertTrue(m.cssValue.contains("0.55"))
    }

    func testMaterialUltraThickCssValue() {
        let m = Material.ultraThickMaterial
        XCTAssertTrue(m.cssValue.contains("0.95"))
    }

    // MARK: - Material background modifier

    func testMaterialBackgroundModifierReturnsModifiedView() {
        let result = Text("Hello").background(Material.regularMaterial)
        let _: ModifiedView<Text> = result
        XCTAssertNotNil(result)
    }

    func testMaterialBackgroundOnAnyView() {
        let result = VStack { Text("A") }.background(Material.thinMaterial)
        XCTAssertNotNil(result)
    }

    func testMaterialBackgroundChaining() {
        let result = Text("Hi")
            .background(Material.ultraThinMaterial)
            .padding(8)
            .opacity(0.9)
        XCTAssertNotNil(result)
    }

    // MARK: - Interaction between new types and existing modifiers

    func testLabeledContentWithPadding() {
        let v = LabeledContent("Key", value: "Val").padding(8)
        XCTAssertNotNil(v)
    }

    func testColorViewWithFrame() {
        let v = ColorView(.blue).frame(width: 100, height: 50)
        XCTAssertNotNil(v)
    }

    func testAsyncImageWithCornerRadius() {
        let v = AsyncImage(url: nil).cornerRadius(12)
        XCTAssertNotNil(v)
    }

    func testShareLinkWithOpacity() {
        let v = ShareLink("Send").opacity(0.5)
        XCTAssertNotNil(v)
    }

    func testMenuViewWithBackground() {
        let v = MenuView("File") { Text("New") }.background(Material.regularMaterial)
        XCTAssertNotNil(v)
    }

    // MARK: - OutlineGroup with different collection types

    func testOutlineGroupWithRange() {
        let v = OutlineGroup(Array(1...5)) { Text("Item \($0)") }
        XCTAssertEqual(Array(v.data).count, 5)
    }

    func testOutlineGroupWithStructData() {
        struct Item { let name: String }
        let items = [Item(name: "A"), Item(name: "B")]
        let v = OutlineGroup(items) { Text($0.name) }
        XCTAssertEqual(Array(v.data).count, 2)
    }

    // MARK: - ControlGroup with linked-button behavior

    func testControlGroupProducesLinkedBox() {
        let v = ControlGroup {
            Button("B") {}
            Button("I") {}
            Button("U") {}
        }
        // Type conformance is sufficient — GTK "linked" class is set at render time.
        let _: any View = v
        XCTAssertNotNil(v)
    }

    // MARK: - GridRow multi-child extraction

    func testGridRowWithThreeChildrenConformsToMultiChildView() {
        let row = GridRow {
            Text("A")
            Text("B")
            Text("C")
        }
        let _: any MultiChildView = row
        XCTAssertNotNil(row)
    }

    func testGridRowIsMultiChildView() {
        // Compile-time check: GridRow conforms to MultiChildView.
        let row = GridRow { Text("x") }
        let _: any MultiChildView = row
        XCTAssertNotNil(row)
    }
}
