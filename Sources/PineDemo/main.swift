// PineDemo — A Notes app using macOS SwiftUI API names.
//
// This uses SF Symbol names (folder.fill, doc.text, star.fill) —
// PineUI automatically maps them to GTK icons.

import PineUI

struct Note {
    let title: String
    let preview: String
    let date: String
}

let notes = [
    Note(title: "Meeting Notes", preview: "Discussed Q2 roadmap priorities...", date: "Today"),
    Note(title: "Architecture Decision", preview: "ADR-001: Use SQLite for local storage.", date: "Yesterday"),
    Note(title: "Sprint Retrospective", preview: "What went well: shipped 3 features.", date: "Mar 18"),
    Note(title: "Sourdough Recipe", preview: "500g flour, 350g water, 100g starter.", date: "Mar 15"),
]

// Reactive state — proves @State-like behavior works.
let noteCount = StateStore<Int>(4)

struct NotesApp: PineApp {
    var appId: String { "com.pinyridgelabs.Notes" }

    func buildWindow() -> PineWindow {
        PineWindow("Notes", width: 1100, height: 750)
            .sidebar(PineSidebar()
                .section("Favorites", items: [
                    // Using SF Symbol names — auto-resolved to GTK icons
                    SidebarItem("All Notes", icon: "doc.text", badge: 4),
                    SidebarItem("Recent", icon: "clock"),
                    SidebarItem("Shared", icon: "person.2"),
                ])
                .section("Folders", items: [
                    SidebarItem("Work", icon: "folder.fill", badge: 3),
                    SidebarItem("Personal", icon: "folder.fill", badge: 1),
                ])
                .section("Smart Folders", items: [
                    SidebarItem("Important", icon: "star.fill", badge: 2),
                    SidebarItem("Attachments", icon: "doc.richtext"),
                ])
            )
            .content {
                let container = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 0)
                setVExpand(container)

                // Header with reactive "+ New Note" button.
                let header = render(
                    HStack(spacing: 12) {
                        Text("All Notes").font(.title)
                        Spacer()
                        ReactiveButton(state: noteCount, label: { "+ New Note (\($0))" }) {
                            noteCount.value += 1
                        }
                        .cssClass("suggested-action")
                    }
                    .padding()
                )
                boxAppend(container, child: header)

                boxAppend(container, child: render(Divider()))

                let scroll = render(
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(notes) { note in
                                GroupBox {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 4) {
                                            Text(note.title).font(.headline)
                                            Spacer()
                                            Text(note.date).font(.caption)
                                        }
                                        Text(note.preview).foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                )
                boxAppend(container, child: scroll)

                return container
            }
            .statusBar(PineStatusBar()
                .left(StatusItem("4 notes"))
                .right(StatusItem("Synced", icon: "checkmark.circle"))
            )
    }
}

NotesApp.main()
