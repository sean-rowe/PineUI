// PineDemo — A Notes app using macOS SwiftUI API names.
//
// Demonstrates: sidebar selection, toolbar, tabs, navigation,
// reactive state, SF Symbol mapping, and the full SwiftUI-like API.

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

// Reactive state.
let noteCount = StateStore<Int>(4)
let nav = NavigationController()

struct NotesApp: PineApp {
    var appId: String { "com.pinyridgelabs.Notes" }

    func buildWindow() -> PineWindow {
        let sidebar = PineSidebar()
            .section("Favorites", items: [
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
            .onSelection { itemId in
                nav.popToRoot()
            }

        return PineWindow("Notes", width: 1100, height: 750)
            .toolbar(PineToolbar()
                .leading("Sidebar", icon: "sidebar.left") { }
                .trailing("Search", icon: "magnifyingglass") { }
                .trailing("New Note", icon: "plus") {
                    noteCount.value += 1
                }
            )
            .sidebar(sidebar)
            .content {
                NavigationStackBuilder(controller: nav)
                    .root {
                        TabView {
                            Tab("Notes", systemImage: "doc.text") {
                                notesTab()
                            }
                            Tab("Settings", systemImage: "gear") {
                                settingsTab()
                            }
                        }
                    }
                    .destination("note-detail") {
                        noteDetailView()
                    }
                    .build()
            }
            .statusBar(PineStatusBar()
                .left(StatusItem("4 notes"))
                .right(StatusItem("Synced", icon: "checkmark.circle"))
            )
    }
}

// MARK: - Notes tab

func notesTab() -> some View {
    VStack(alignment: .leading, spacing: 0) {
        HStack(spacing: 12) {
            Text("All Notes").font(.title)
            Spacer()
            ReactiveButton(state: noteCount, label: { "\($0) notes" }) {
                noteCount.value += 1
            }
            .cssClass("suggested-action")
        }
        .padding()

        Divider()

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
                    .onTapGesture {
                        nav.push("note-detail")
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Note detail view (pushed via NavigationStack)

func noteDetailView() -> some View {
    VStack(alignment: .leading, spacing: 0) {
        HStack(spacing: 8) {
            BackButton(controller: nav)
            Text("Note Detail").font(.title)
            Spacer()
        }
        .padding()

        Divider()

        VStack(alignment: .leading, spacing: 12) {
            Text("Meeting Notes").font(.title2)
            Text("March 20, 2026").font(.caption)

            Divider()

            TextEditor(text: "Discussed Q2 roadmap priorities.\n\n- Feature A: target April release\n- Feature B: needs design review\n- Feature C: blocked on API team\n\nAction items:\n1. Schedule design review for Feature B\n2. Follow up with API team on blockers\n3. Update sprint board with new priorities")
        }
        .padding()
    }
}

// MARK: - Settings tab

func settingsTab() -> some View {
    ScrollView {
        Form {
            GroupBox("Appearance") {
                Picker("Theme", options: ["System", "Light", "Dark"])
                Picker("Font Size", options: ["Small", "Medium", "Large"])
            }

            GroupBox("Editor") {
                Toggle("Spell Check")
                Toggle("Smart Quotes")
                Slider(value: 0.7, in: 0...1, label: "Line Spacing")
            }

            GroupBox("Sync") {
                Toggle("iCloud Sync")
                Toggle("Auto-save")
                Stepper("Backup Interval (hours)", in: 1...24)
            }

            GroupBox("About") {
                HStack(spacing: 8) {
                    Image(systemName: "doc.text")
                    VStack(alignment: .leading, spacing: 2) {
                        Text("PineUI Notes").font(.headline)
                        Text("Version 1.0 — Built with PineUI").font(.caption)
                    }
                }
            }
        }
    }
}

NotesApp.main()
