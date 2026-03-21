import XCTest
@testable import PineUI

final class PineUITests: XCTestCase {
    func testSidebarItemCreation() {
        let item = SidebarItem("Notes", icon: "document-edit-symbolic", badge: 5)
        XCTAssertEqual(item.label, "Notes")
        XCTAssertEqual(item.iconName, "document-edit-symbolic")
        XCTAssertEqual(item.badge, 5)
        XCTAssertEqual(item.id, "notes")
    }

    func testSidebarItemDefaultId() {
        let item = SidebarItem("All Notes", icon: "test")
        XCTAssertEqual(item.id, "all-notes")
    }

    func testSidebarSection() {
        let section = SidebarSection("Favorites", items: [
            SidebarItem("A", icon: "a"),
            SidebarItem("B", icon: "b"),
        ])
        XCTAssertEqual(section.title, "Favorites")
        XCTAssertEqual(section.items.count, 2)
    }

    func testStatusItem() {
        let item = StatusItem("12 notes", icon: "folder-symbolic")
        XCTAssertEqual(item.text, "12 notes")
        XCTAssertEqual(item.icon, "folder-symbolic")
    }

    func testPineWindowCreation() {
        let window = PineWindow("Test", subtitle: "Sub", width: 800, height: 600)
        XCTAssertEqual(window.title, "Test")
        XCTAssertEqual(window.subtitle, "Sub")
        XCTAssertEqual(window.defaultWidth, 800)
        XCTAssertEqual(window.defaultHeight, 600)
    }
}
