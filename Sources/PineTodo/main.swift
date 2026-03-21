// PineTodo — A complete todo list app built with PineUI.
//
// Demonstrates: StateStore, ReactiveView, ReactiveText, BoundTextField,
// SegmentedControl, PineSidebar, PineToolbar, PineStatusBar, ForEach,
// ScrollView, GroupBox, VStack, HStack, Button, Text, Spacer, Divider.

import PineUI

// MARK: - Data Model

struct Todo {
    let id: Int
    var title: String
    var completed: Bool
    var category: String
}

// MARK: - TodoStore

class TodoStore {
    let todos = StateStore<[Todo]>([
        Todo(id: 1, title: "Build PineUI framework", completed: true, category: "Work"),
        Todo(id: 2, title: "Add SwiftUI modifier parity", completed: true, category: "Work"),
        Todo(id: 3, title: "Create todo app", completed: false, category: "Work"),
        Todo(id: 4, title: "Buy groceries", completed: false, category: "Shopping"),
        Todo(id: 5, title: "Read Swift docs", completed: false, category: "Personal"),
    ])
    private var nextId = 6

    func add(title: String, category: String) {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        var list = todos.value
        list.append(Todo(id: nextId, title: title, completed: false, category: category))
        nextId += 1
        todos.value = list
    }

    func toggle(id: Int) {
        var list = todos.value
        if let idx = list.firstIndex(where: { $0.id == id }) {
            list[idx].completed.toggle()
        }
        todos.value = list
    }

    func delete(id: Int) {
        var list = todos.value
        list.removeAll { $0.id == id }
        todos.value = list
    }

    var activeCount: Int { todos.value.filter { !$0.completed }.count }
}

// MARK: - Global state

let store = TodoStore()

// Filter: 0=All, 1=Active, 2=Completed
let filterStore = StateStore<Int>(0)

// Selected sidebar category: "all", "work", "personal", "shopping"
let categoryStore = StateStore<String>("all")

// Text being entered in the new-todo field
let newTodoText = StateStore<String>("")

// Whether the add-row is visible
let addRowVisible = StateStore<Bool>(false)

// MARK: - Content area builder

func buildContent() -> WidgetPtr {
    let outer = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 0)
    setHExpand(outer)
    setVExpand(outer)

    // Filter segmented control header
    let header = makeBox(GTK_ORIENTATION_HORIZONTAL, spacing: 8)
    setMargins(header, start: 12, end: 12, top: 8, bottom: 8)
    addCssClass(header, "pine-toolbar")

    let sc = render(SegmentedControl(["All", "Active", "Completed"], selection: filterStore))
    boxAppend(header, child: sc)

    let spacer = makeBox(GTK_ORIENTATION_HORIZONTAL, spacing: 0)
    setHExpand(spacer)
    boxAppend(header, child: spacer)

    // Item count label
    let countLabel = render(
        ReactiveText(state: store.todos) { todos in
            let active = todos.filter { !$0.completed }.count
            return "\(active) item\(active == 1 ? "" : "s") remaining"
        }.font(.caption).foregroundStyle(.secondary)
    )
    boxAppend(header, child: countLabel)

    boxAppend(outer, child: header)

    // Add-todo inline row (conditionally visible)
    let addRow = makeBox(GTK_ORIENTATION_HORIZONTAL, spacing: 8)
    setMargins(addRow, start: 12, end: 12, top: 6, bottom: 6)

    let entry = gtk_entry_new()!
    let e = UnsafeMutableRawPointer(entry).assumingMemoryBound(to: _GtkEntry.self)
    gtk_entry_set_placeholder_text(e, "New todo title…")
    setHExpand(entry)

    // Keep entry text in sync with newTodoText store
    let textRef = Unmanaged.passRetained(newTodoText).toOpaque()
    let textChangedCb: @convention(c) (OpaquePointer?, gpointer?) -> Void = { editable, userData in
        guard let editable = editable, let userData = userData else { return }
        let text = String(cString: gtk_editable_get_text(editable))
        Unmanaged<StateStore<String>>.fromOpaque(userData).takeUnretainedValue().value = text
    }
    g_signal_connect_data(
        UnsafeMutableRawPointer(entry), "changed",
        unsafeBitCast(textChangedCb, to: GCallback.self),
        textRef, { ud, _ in ud.map { Unmanaged<StateStore<String>>.fromOpaque($0).release() } },
        GConnectFlags(rawValue: 0)
    )
    boxAppend(addRow, child: entry)

    // Add button in the row
    let addBtn = gtk_button_new_with_label("Add")!
    addCssClass(addBtn, "suggested-action")

    class AddHandler {
        let store: TodoStore
        let textStore: StateStore<String>
        let categoryStore: StateStore<String>
        let visibleStore: StateStore<Bool>
        let entry: WidgetPtr
        init(store: TodoStore, textStore: StateStore<String>, categoryStore: StateStore<String>, visibleStore: StateStore<Bool>, entry: WidgetPtr) {
            self.store = store
            self.textStore = textStore
            self.categoryStore = categoryStore
            self.visibleStore = visibleStore
            self.entry = entry
        }
        func run() {
            let text = textStore.value
            let cat: String
            switch categoryStore.value {
            case "work": cat = "Work"
            case "personal": cat = "Personal"
            case "shopping": cat = "Shopping"
            default: cat = "Work"
            }
            store.add(title: text, category: cat)
            textStore.value = ""
            gtk_editable_set_text(OpaquePointer(entry), "")
            visibleStore.value = false
        }
    }
    let addHandler = AddHandler(store: store, textStore: newTodoText, categoryStore: categoryStore, visibleStore: addRowVisible, entry: entry)
    let addPtr = Unmanaged.passRetained(addHandler).toOpaque()
    let addBtnCb: @convention(c) (UnsafeMutablePointer<_GtkButton>?, gpointer?) -> Void = { _, ud in
        guard let ud = ud else { return }
        Unmanaged<AddHandler>.fromOpaque(ud).takeUnretainedValue().run()
    }
    g_signal_connect_data(
        UnsafeMutableRawPointer(addBtn), "clicked",
        unsafeBitCast(addBtnCb, to: GCallback.self),
        addPtr, { ud, _ in ud.map { Unmanaged<AddHandler>.fromOpaque($0).release() } },
        GConnectFlags(rawValue: 0)
    )
    boxAppend(addRow, child: addBtn)

    // Cancel button
    let cancelBtn = gtk_button_new_with_label("Cancel")!
    addCssClass(cancelBtn, "flat")
    class CancelHandler {
        let visibleStore: StateStore<Bool>
        let textStore: StateStore<String>
        let entry: WidgetPtr
        init(visibleStore: StateStore<Bool>, textStore: StateStore<String>, entry: WidgetPtr) {
            self.visibleStore = visibleStore
            self.textStore = textStore
            self.entry = entry
        }
        func run() {
            textStore.value = ""
            gtk_editable_set_text(OpaquePointer(entry), "")
            visibleStore.value = false
        }
    }
    let cancelHandler = CancelHandler(visibleStore: addRowVisible, textStore: newTodoText, entry: entry)
    let cancelPtr = Unmanaged.passRetained(cancelHandler).toOpaque()
    let cancelBtnCb: @convention(c) (UnsafeMutablePointer<_GtkButton>?, gpointer?) -> Void = { _, ud in
        guard let ud = ud else { return }
        Unmanaged<CancelHandler>.fromOpaque(ud).takeUnretainedValue().run()
    }
    g_signal_connect_data(
        UnsafeMutableRawPointer(cancelBtn), "clicked",
        unsafeBitCast(cancelBtnCb, to: GCallback.self),
        cancelPtr, { ud, _ in ud.map { Unmanaged<CancelHandler>.fromOpaque($0).release() } },
        GConnectFlags(rawValue: 0)
    )
    boxAppend(addRow, child: cancelBtn)

    // Show/hide add row based on addRowVisible
    gtk_widget_set_visible(addRow, 0)
    addRowVisible.onChange = { visible in
        gtk_widget_set_visible(addRow, visible ? 1 : 0)
    }
    boxAppend(outer, child: addRow)

    // Divider
    let div = render(Divider())
    boxAppend(outer, child: div)

    // Scrollable reactive todo list
    let scroll = makeScrolledWindow()
    scrolledWindowSetPolicy(scroll, h: GTK_POLICY_NEVER, v: GTK_POLICY_AUTOMATIC)
    setVExpand(scroll)
    setHExpand(scroll)

    // We need a combined state to react to both todos and filter changes.
    // Use a wrapper store that fires when either changes.
    let listContainer = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 0)
    setHExpand(listContainer)
    setVExpand(listContainer)

    func buildTodoList() -> WidgetPtr {
        let todos = store.todos.value
        let filter = filterStore.value
        let category = categoryStore.value

        // Apply category filter
        let byCat: [Todo]
        switch category {
        case "work":     byCat = todos.filter { $0.category == "Work" }
        case "personal": byCat = todos.filter { $0.category == "Personal" }
        case "shopping": byCat = todos.filter { $0.category == "Shopping" }
        default:         byCat = todos
        }

        // Apply completion filter
        let filtered: [Todo]
        switch filter {
        case 1: filtered = byCat.filter { !$0.completed }
        case 2: filtered = byCat.filter { $0.completed }
        default: filtered = byCat
        }

        let box = makeBox(GTK_ORIENTATION_VERTICAL, spacing: 0)
        setHExpand(box)

        if filtered.isEmpty {
            let empty = render(
                VStack(alignment: .center, spacing: 12) {
                    Image(systemName: "checkmark.circle")
                    Text("No todos here").font(.headline).foregroundStyle(.secondary)
                    Text("Add a new todo using the + button above").font(.caption).foregroundStyle(.secondary)
                }
                .padding(32)
            )
            setHExpand(empty)
            setVExpand(empty)
            setHAlign(empty, align: GTK_ALIGN_CENTER)
            setVAlign(empty, align: GTK_ALIGN_CENTER)
            boxAppend(box, child: empty)
            return box
        }

        for todo in filtered {
            let row = buildTodoRow(todo)
            boxAppend(box, child: row)
            let sep = gtk_separator_new(GTK_ORIENTATION_HORIZONTAL)!
            boxAppend(box, child: sep)
        }

        return box
    }

    // Initial render
    var currentListChild = buildTodoList()
    boxAppend(listContainer, child: currentListChild)

    // Rebuild on todo changes
    func rebuildList() {
        let parent = UnsafeMutableRawPointer(listContainer).assumingMemoryBound(to: _GtkBox.self)
        gtk_box_remove(parent, currentListChild)
        currentListChild = buildTodoList()
        gtk_box_append(parent, currentListChild)
    }

    store.todos.onChange = { _ in rebuildList() }
    filterStore.onChange = { _ in rebuildList() }
    categoryStore.onChange = { _ in rebuildList() }

    scrolledWindowSetChild(scroll, child: listContainer)
    boxAppend(outer, child: scroll)

    return outer
}

// MARK: - Todo Row Builder

func buildTodoRow(_ todo: Todo) -> WidgetPtr {
    let row = makeBox(GTK_ORIENTATION_HORIZONTAL, spacing: 12)
    setHExpand(row)
    setMargins(row, start: 16, end: 12, top: 10, bottom: 10)
    addCssClass(row, "pine-list-item")

    // Checkbox button (toggle completion)
    let checkIcon = todo.completed ? "checkmark.circle.fill" : "circle"
    let checkBtn = gtk_button_new_from_icon_name(resolveSFSymbol(checkIcon))!
    buttonSetHasFrame(checkBtn, hasFrame: false)
    addCssClass(checkBtn, "flat")
    if todo.completed {
        applyCss(checkBtn, "color: @accent_color;")
    }

    let todoId = todo.id
    class ToggleHandler {
        let id: Int
        let store: TodoStore
        init(id: Int, store: TodoStore) { self.id = id; self.store = store }
        func run() { store.toggle(id: id) }
    }
    let toggleHandler = ToggleHandler(id: todoId, store: store)
    let togglePtr = Unmanaged.passRetained(toggleHandler).toOpaque()
    let toggleCb: @convention(c) (UnsafeMutablePointer<_GtkButton>?, gpointer?) -> Void = { _, ud in
        guard let ud = ud else { return }
        Unmanaged<ToggleHandler>.fromOpaque(ud).takeUnretainedValue().run()
    }
    g_signal_connect_data(
        UnsafeMutableRawPointer(checkBtn), "clicked",
        unsafeBitCast(toggleCb, to: GCallback.self),
        togglePtr, { ud, _ in ud.map { Unmanaged<ToggleHandler>.fromOpaque($0).release() } },
        GConnectFlags(rawValue: 0)
    )
    boxAppend(row, child: checkBtn)

    // Title label
    let titleLabel = makeLabel(todo.title)
    setHExpand(titleLabel)
    setHAlign(titleLabel, align: GTK_ALIGN_START)
    if todo.completed {
        applyCss(titleLabel, "text-decoration: line-through; opacity: 0.6;")
    }
    boxAppend(row, child: titleLabel)

    // Category chip
    let catLabel = makeLabel(todo.category)
    addCssClass(catLabel, "pine-caption")
    applyCss(catLabel, "padding: 2px 8px; border-radius: 10px; background: alpha(currentColor, 0.12);")
    boxAppend(row, child: catLabel)

    // Delete button
    let delBtn = gtk_button_new_from_icon_name(resolveSFSymbol("trash"))!
    buttonSetHasFrame(delBtn, hasFrame: false)
    addCssClass(delBtn, "flat")
    applyCss(delBtn, "color: @error_color;")
    gtk_widget_set_tooltip_text(delBtn, "Delete")

    class DeleteHandler {
        let id: Int
        let store: TodoStore
        init(id: Int, store: TodoStore) { self.id = id; self.store = store }
        func run() { store.delete(id: id) }
    }
    let deleteHandler = DeleteHandler(id: todoId, store: store)
    let deletePtr = Unmanaged.passRetained(deleteHandler).toOpaque()
    let deleteCb: @convention(c) (UnsafeMutablePointer<_GtkButton>?, gpointer?) -> Void = { _, ud in
        guard let ud = ud else { return }
        Unmanaged<DeleteHandler>.fromOpaque(ud).takeUnretainedValue().run()
    }
    g_signal_connect_data(
        UnsafeMutableRawPointer(delBtn), "clicked",
        unsafeBitCast(deleteCb, to: GCallback.self),
        deletePtr, { ud, _ in ud.map { Unmanaged<DeleteHandler>.fromOpaque($0).release() } },
        GConnectFlags(rawValue: 0)
    )
    boxAppend(row, child: delBtn)

    return row
}

// MARK: - Sidebar builder

func buildSidebar() -> PineSidebar {
    let todos = store.todos.value
    let allCount = todos.count
    let workCount = todos.filter { $0.category == "Work" }.count
    let personalCount = todos.filter { $0.category == "Personal" }.count
    let shoppingCount = todos.filter { $0.category == "Shopping" }.count

    let sidebar = PineSidebar()
        .section("TASKS", items: [
            SidebarItem("All", icon: "tray.full", badge: allCount, id: "all"),
            SidebarItem("Work", icon: "briefcase", badge: workCount, id: "work"),
            SidebarItem("Personal", icon: "person", badge: personalCount, id: "personal"),
            SidebarItem("Shopping", icon: "cart", badge: shoppingCount, id: "shopping"),
        ])
        .onSelection { id in
            categoryStore.value = id
        }

    return sidebar
}

// MARK: - App

struct TodoApp: PineApp {
    var appId: String { "com.pinyridgelabs.PineTodo" }

    func buildWindow() -> PineWindow {
        let sidebar = buildSidebar()

        return PineWindow("PineTodo", width: 900, height: 650)
            .toolbar(
                PineToolbar()
                    .leading("Toggle Sidebar", icon: "sidebar.left") { }
                    .trailing("New Todo", icon: "plus") {
                        addRowVisible.value = true
                    }
            )
            .sidebar(sidebar)
            .content {
                buildContent()
            }
            .statusBar(
                PineStatusBar()
                    .left(StatusItem("PineTodo"))
                    .right(StatusItem("GTK4 / Swift"))
            )
    }
}

TodoApp.main()
