// PineUI Component Gallery — Comprehensive showcase of all view types.
//
// Tabs: Controls, Layout, Text & Display, Containers, Shapes,
//       Modifiers, Navigation, Data Binding, Advanced

import PineUI

// MARK: - Global state stores

struct GalleryState {
    @PineState var counter = 0
    @PineState var toggleA = false
    @PineState var sliderValue = 0.5
    @PineState var pickerIndex = 0
    @PineState var inputText = "Hello PineUI"
}
let gs = GalleryState()

let navController = NavigationController()

// MARK: - App

struct GalleryApp: PineApp {
    var appId: String { "com.pinyridgelabs.Gallery" }

    func buildWindow() -> PineWindow {
        return PineWindow("PineUI Component Gallery", width: 1200, height: 800)
            .toolbar(
                PineToolbar()
                    .leading("Sidebar", icon: "sidebar.left") { }
                    .trailing("Info", icon: "info.circle") { }
            )
            .content {
                render(TabView {
                    Tab("Controls", systemImage: "slider.horizontal.3") {
                        controlsTab()
                    }
                    Tab("Layout", systemImage: "square.grid.2x2") {
                        layoutTab()
                    }
                    Tab("Text & Display", systemImage: "text.alignleft") {
                        textDisplayTab()
                    }
                    Tab("Containers", systemImage: "square.stack") {
                        containersTab()
                    }
                    Tab("Shapes", systemImage: "circle.square") {
                        shapesTab()
                    }
                    Tab("Modifiers", systemImage: "wand.and.stars") {
                        modifiersTab()
                    }
                    Tab("Navigation", systemImage: "arrow.right.circle") {
                        GTKWidget(navigationTabContent())
                    }
                    Tab("Data Binding", systemImage: "arrow.triangle.2.circlepath") {
                        dataBindingTab()
                    }
                    Tab("Advanced", systemImage: "sparkles") {
                        advancedTab()
                    }
                })
            }
            .statusBar(
                PineStatusBar()
                    .left(StatusItem("PineUI Component Gallery"))
                    .right(StatusItem("GTK4 / Swift", icon: "checkmark.circle"))
            )
    }
}

// MARK: - Tab 1: Controls

func controlsTab() -> some View {
    ScrollView {
        VStack(alignment: .leading, spacing: 16) {
            Text("Controls").font(.title).bold()

            GroupBox("Buttons") {
                HStack(spacing: 8) {
                    Button("Default") { }
                    Button("Prominent") { }
                        .buttonStyle(.borderedProminent)
                    Button("Bordered") { }
                        .buttonStyle(.bordered)
                    Button("Plain") { }
                        .buttonStyle(.plain)
                    Button("Glass") { }
                        .buttonStyle(.glass)
                }
            }

            GroupBox("Text Inputs") {
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Enter your name")
                    SecureField("Enter password")
                    SearchField("Search anything...") { _ in }
                }
            }

            GroupBox("Toggles & Sliders") {
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Enable notifications")
                    Toggle("Dark mode")
                    Slider(value: 0.5, in: 0...1, label: "Volume")
                    Slider(value: 0.3, in: 0...1, label: "Brightness")
                }
            }

            GroupBox("Steppers & Pickers") {
                VStack(alignment: .leading, spacing: 8) {
                    Stepper("Font size", in: 8...72)
                    Stepper("Retry count", in: 0...10)
                    Picker("Theme", options: ["System", "Light", "Dark"])
                    Picker("Language", options: ["Swift", "Kotlin", "Rust"])
                }
            }

            GroupBox("Date & Color") {
                VStack(alignment: .leading, spacing: 8) {
                    ColorPicker("Accent color")
                    DatePicker("Pick a date")
                }
            }

            GroupBox("Segmented Control") {
                VStack(alignment: .leading, spacing: 8) {
                    SegmentedControl(["Day", "Week", "Month", "Year"])
                    SegmentedControl(["Left", "Center", "Right"])
                }
            }

            GroupBox("Menu Button") {
                MenuButton("File", icon: nil, items: [
                    MenuItem("New", icon: "plus"),
                    MenuItem("Open", icon: "folder"),
                    MenuItem("Save", icon: "square.and.arrow.down"),
                ])
            }

            GroupBox("Link") {
                Link("Visit pinyridgelabs.com", destination: "https://pinyridgelabs.com")
            }
        }
        .padding()
    }
}

// MARK: - Tab 2: Layout

func layoutTab() -> some View {
    ScrollView {
        VStack(alignment: .leading, spacing: 16) {
            Text("Layout").font(.title).bold()

            GroupBox("VStack & HStack") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("VStack (leading aligned)").font(.headline)
                    HStack(spacing: 8) {
                        Text("Item A")
                        Text("Item B")
                        Text("Item C")
                        Spacer()
                        Text("Right")
                    }
                    HStack(spacing: 8) {
                        Text("Left").font(.caption)
                        Spacer()
                        Text("Center").font(.body)
                        Spacer()
                        Text("Right").font(.caption)
                    }
                }
            }

            GroupBox("Dividers") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Above divider")
                    Divider()
                    Text("Below divider")
                    LabeledDivider("OR")
                    Text("Below labeled divider")
                }
            }

            GroupBox("LazyVGrid — 3 columns") {
                LazyVGrid(columns: 3, spacing: 8, data: [
                    "Swift", "Kotlin", "Rust",
                    "Python", "Go", "C++",
                    "Java", "TypeScript", "Ruby",
                ]) { item in
                    Text(item)
                        .padding(8)
                        .background(Color.blue.opacity(0.12))
                        .cornerRadius(6)
                }
            }

            GroupBox("LazyVGrid — 4 columns") {
                LazyVGrid(columns: 4, spacing: 8, data: [
                    "Red", "Green", "Blue", "Yellow",
                    "Purple", "Orange", "Pink", "Cyan",
                ]) { item in
                    Text(item)
                        .padding(6)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(4)
                }
            }

            GroupBox("ScrollView (horizontal)") {
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(["Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta"]) { item in
                            Text(item)
                                .padding(8)
                                .background(Color.accentColor.opacity(0.15))
                                .cornerRadius(8)
                        }
                    }
                    .padding(4)
                }
            }

            GroupBox("GeometryReader") {
                GeometryReader { proxy in
                    VStack(alignment: .leading, spacing: 6) {
                        Text("GeometryReader")
                            .font(.headline)
                        Text(String(format: "Allocated width:  %.0f pt", proxy.size.width))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(String(format: "Allocated height: %.0f pt", proxy.size.height))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        // Fill 50% of the available width with a colored bar.
                        ColorView(.accentColor)
                            .frame(width: Int32(proxy.size.width / 2), height: 8)
                            .cornerRadius(4)
                    }
                    .padding(8)
                }
                .frame(height: 100)
                .background(Color.blue.opacity(0.05))
                .cornerRadius(8)
            }
        }
        .padding()
    }
}

// MARK: - Tab 3: Text & Display

func textDisplayTab() -> some View {
    ScrollView {
        VStack(alignment: .leading, spacing: 16) {
            Text("Text & Display").font(.title).bold()

            GroupBox("Font Scale") {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Large Title").font(.largeTitle)
                    Text("Title").font(.title)
                    Text("Title 2").font(.title2)
                    Text("Title 3").font(.title3)
                    Text("Headline").font(.headline)
                    Text("Subheadline").font(.subheadline)
                    Text("Body text").font(.body)
                    Text("Callout").font(.callout)
                    Group {
                        Text("Footnote").font(.footnote)
                        Text("Caption").font(.caption)
                    }
                }
            }

            GroupBox("Foreground Styles") {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Primary foreground").foregroundStyle(.primary)
                    Text("Secondary foreground").foregroundStyle(.secondary)
                    Text("Tertiary foreground").foregroundStyle(.tertiary)
                    Text("Accent foreground").foregroundStyle(.accent)
                }
            }

            GroupBox("Image & Label") {
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: "star.fill")
                    Label("Downloads", systemImage: "folder")
                    Label("Shared", systemImage: "person.2")
                    Label("Favourite", systemImage: "heart.fill")
                }
            }

            GroupBox("Avatar & Chip") {
                HStack(spacing: 12) {
                    Avatar("JD", size: 48)
                    Avatar("SR", size: 40)
                    Avatar("AB", size: 32)
                    Chip("Swift", color: .orange)
                    Chip("GTK4", color: .blue)
                    Chip("Linux", color: .green)
                }
            }

            GroupBox("Badge") {
                HStack(spacing: 12) {
                    Badge(3)
                    Badge(12)
                    Badge(99)
                }
            }

            GroupBox("ProgressView") {
                VStack(alignment: .leading, spacing: 8) {
                    ProgressView("Loading…", value: 0.25)
                    ProgressView("Uploading…", value: 0.65)
                    ProgressView("Complete", value: 1.0)
                    ProgressView("Indeterminate spinner")
                }
            }

            GroupBox("Gauge") {
                VStack(alignment: .leading, spacing: 8) {
                    Gauge("CPU", value: 0.72, in: 0...1)
                    Gauge("Memory", value: 0.45, in: 0...1)
                    Gauge("Disk", value: 0.88, in: 0...1)
                }
            }

            GroupBox("ContentUnavailableView") {
                ContentUnavailableView(
                    "No Results",
                    systemImage: "magnifyingglass",
                    description: "Try a different search term"
                )
            }

            GroupBox("ColorView") {
                HStack(spacing: 8) {
                    ColorView(.red).frame(width: 40, height: 40).cornerRadius(6)
                    ColorView(.green).frame(width: 40, height: 40).cornerRadius(6)
                    ColorView(.blue).frame(width: 40, height: 40).cornerRadius(6)
                    ColorView(.purple).frame(width: 40, height: 40).cornerRadius(6)
                    ColorView(.orange).frame(width: 40, height: 40).cornerRadius(6)
                }
            }
        }
        .padding()
    }
}

// MARK: - Tab 4: Containers

func containersTab() -> some View {
    ScrollView {
        VStack(alignment: .leading, spacing: 16) {
            Text("Containers").font(.title).bold()

            GroupBox("List with Sections") {
                List {
                    Section("Favourites") {
                        Label("All Notes", systemImage: "doc.text")
                        Label("Recent", systemImage: "clock")
                        Label("Starred", systemImage: "star.fill")
                    }
                    Section("Folders") {
                        Label("Work", systemImage: "briefcase")
                        Label("Personal", systemImage: "house")
                        Label("Archive", systemImage: "archivebox")
                    }
                }
                .frame(height: 200)
            }

            GroupBox("Card") {
                HStack(spacing: 12) {
                    Card("Feature Card", subtitle: "A subtitle here") {
                        Text("Card body content goes here.")
                    }
                    Card("Simple Card") {
                        Text("Another card without a subtitle.")
                    }
                }
            }

            GroupBox("DisclosureGroup") {
                VStack(alignment: .leading, spacing: 8) {
                    DisclosureGroup("Advanced Options") {
                        VStack(alignment: .leading, spacing: 4) {
                            Toggle("Enable debug logging")
                            Toggle("Use hardware acceleration")
                            Slider(value: 0.7, in: 0...1, label: "Cache limit")
                        }
                    }
                    DisclosureGroup("Network Settings") {
                        VStack(alignment: .leading, spacing: 4) {
                            TextField("Proxy host")
                            Stepper("Timeout (sec)", in: 1...120)
                        }
                    }
                }
            }

            GroupBox("ControlGroup") {
                HStack(spacing: 12) {
                    ControlGroup {
                        Button("Bold") { }
                        Button("Italic") { }
                        Button("Underline") { }
                    }
                    ControlGroup {
                        Button("Left") { }
                        Button("Center") { }
                        Button("Right") { }
                    }
                }
            }

            GroupBox("Form") {
                Form {
                    Picker("Color scheme", options: ["System", "Light", "Dark"])
                    Toggle("Show toolbar")
                    Slider(value: 0.5, in: 0...1, label: "Opacity")
                    TextField("Window title")
                }
            }

            GroupBox("OutlineGroup") {
                OutlineGroup(["Root item", "Child A", "Child B", "Grandchild"]) { item in
                    Label(item, systemImage: "chevron.right")
                }
            }

            GroupBox("ForEach") {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(["Apple", "Banana", "Cherry", "Date", "Elderberry"]) { fruit in
                        HStack(spacing: 8) {
                            Image(systemName: "circle.fill")
                            Text(fruit)
                        }
                    }
                }
            }

            GroupBox("HSplitView") {
                HSplitView(position: 200) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Leading pane").font(.headline)
                        Text("Drag the divider").font(.caption)
                    }
                    .padding()
                } trailing: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Trailing pane").font(.headline)
                        Text("Resize freely").font(.caption)
                    }
                    .padding()
                }
                .frame(height: 120)
            }
        }
        .padding()
    }
}

// MARK: - Tab 5: Shapes

func shapesTab() -> some View {
    ScrollView {
        VStack(alignment: .leading, spacing: 16) {
            Text("Shapes").font(.title).bold()

            GroupBox("Filled Shapes") {
                HStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Rectangle()
                            .fill(.blue)
                            .frame(width: 80, height: 60)
                        Text("Rectangle").font(.caption)
                    }
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.green)
                            .frame(width: 80, height: 60)
                        Text("RoundedRect").font(.caption)
                    }
                    VStack(spacing: 4) {
                        Circle()
                            .fill(.red)
                            .frame(width: 60, height: 60)
                        Text("Circle").font(.caption)
                    }
                    VStack(spacing: 4) {
                        Ellipse()
                            .fill(.purple)
                            .frame(width: 80, height: 50)
                        Text("Ellipse").font(.caption)
                    }
                    VStack(spacing: 4) {
                        Capsule()
                            .fill(.orange)
                            .frame(width: 80, height: 40)
                        Text("Capsule").font(.caption)
                    }
                }
            }

            GroupBox("Stroked Shapes") {
                HStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Rectangle()
                            .stroke(.blue, lineWidth: 2)
                            .frame(width: 80, height: 60)
                        Text("Rectangle").font(.caption)
                    }
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.green, lineWidth: 2)
                            .frame(width: 80, height: 60)
                        Text("RoundedRect").font(.caption)
                    }
                    VStack(spacing: 4) {
                        Circle()
                            .stroke(.red, lineWidth: 3)
                            .frame(width: 60, height: 60)
                        Text("Circle").font(.caption)
                    }
                    VStack(spacing: 4) {
                        Ellipse()
                            .stroke(.purple, lineWidth: 2)
                            .frame(width: 80, height: 50)
                        Text("Ellipse").font(.caption)
                    }
                    VStack(spacing: 4) {
                        Capsule()
                            .stroke(.orange, lineWidth: 2)
                            .frame(width: 80, height: 40)
                        Text("Capsule").font(.caption)
                    }
                }
            }

            GroupBox("Color Palette via Shapes") {
                LazyVGrid(columns: 6, spacing: 8, data: [
                    Color.red, Color.orange, Color.yellow,
                    Color.green, Color.teal, Color.cyan,
                    Color.blue, Color.indigo, Color.purple,
                    Color.pink, Color.brown, Color.gray,
                ]) { color in
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color)
                        .frame(width: 40, height: 40)
                }
            }
        }
        .padding()
    }
}

// MARK: - Tab 6: Modifiers

func modifiersTab() -> some View {
    ScrollView {
        VStack(alignment: .leading, spacing: 16) {
            Text("Modifiers").font(.title).bold()

            Group {
                GroupBox("Shadow") {
                    HStack(spacing: 16) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.white)
                            .frame(width: 80, height: 60)
                            .shadow(color: Color(css: "rgba(0,0,0,0.3)"), radius: 4, x: 0, y: 2)
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.white)
                            .frame(width: 80, height: 60)
                            .shadow(color: Color.blue.opacity(0.4), radius: 8, x: 2, y: 4)
                        Text("Shadow text")
                            .padding()
                            .shadow(color: Color(css: "rgba(0,0,0,0.25)"), radius: 3, x: 1, y: 1)
                    }
                }

                GroupBox("Blur") {
                    HStack(spacing: 16) {
                        Text("Blur r=2")
                            .padding()
                            .background(Color.orange.opacity(0.3))
                            .blur(radius: 2)
                        Text("Blur r=4")
                            .padding()
                            .background(Color.blue.opacity(0.3))
                            .blur(radius: 4)
                        Text("No blur")
                            .padding()
                            .background(Color.green.opacity(0.3))
                    }
                }

                GroupBox("Rotation") {
                    HStack(spacing: 24) {
                        Text("15deg")
                            .padding()
                            .background(Color.red.opacity(0.2))
                            .rotationEffect(degrees: 15)
                        Text("-15deg")
                            .padding()
                            .background(Color.blue.opacity(0.2))
                            .rotationEffect(degrees: -15)
                        Text("45deg")
                            .padding()
                            .background(Color.green.opacity(0.2))
                            .rotationEffect(degrees: 45)
                    }
                }

                GroupBox("Scale") {
                    HStack(spacing: 24) {
                        Text("0.8x")
                            .padding()
                            .background(Color.purple.opacity(0.2))
                            .scaleEffect(0.8)
                        Text("1.0x")
                            .padding()
                            .background(Color.teal.opacity(0.2))
                        Text("1.3x")
                            .padding()
                            .background(Color.orange.opacity(0.2))
                            .scaleEffect(1.3)
                    }
                }

                GroupBox("Opacity") {
                    HStack(spacing: 12) {
                        Text("100%").padding().background(Color.blue.opacity(0.8))
                        Text("70%").padding().background(Color.blue.opacity(0.8)).opacity(0.7)
                        Text("40%").padding().background(Color.blue.opacity(0.8)).opacity(0.4)
                        Text("20%").padding().background(Color.blue.opacity(0.8)).opacity(0.2)
                    }
                }
            }

            Group {
                GroupBox("Offset") {
                    HStack(spacing: 24) {
                        Text("y+10")
                            .padding()
                            .background(Color.red.opacity(0.2))
                            .offset(x: 0, y: 10)
                        Text("x+10")
                            .padding()
                            .background(Color.green.opacity(0.2))
                            .offset(x: 10, y: 0)
                        Text("x-10,y-10")
                            .padding()
                            .background(Color.blue.opacity(0.2))
                            .offset(x: -10, y: -10)
                    }
                }

                GroupBox("ClipShape") {
                    HStack(spacing: 16) {
                        ColorView(.blue)
                            .frame(width: 60, height: 60)
                            .clipShape(.circle)
                        ColorView(.green)
                            .frame(width: 80, height: 60)
                            .clipShape(.capsule)
                        ColorView(.red)
                            .frame(width: 80, height: 60)
                            .clipShape(.roundedRectangle(cornerRadius: 16))
                    }
                }

                GroupBox("Border & CornerRadius") {
                    HStack(spacing: 12) {
                        Text("border 1px").padding(8).border(.blue, width: 1)
                        Text("border 2px").padding(8).border(.red, width: 2)
                        Text("radius 8").padding(8).border(.green, width: 1).cornerRadius(8)
                        Text("radius 16").padding(8).border(.purple, width: 1).cornerRadius(16)
                    }
                }

                GroupBox("Background Color") {
                    HStack(spacing: 8) {
                        Text("Red bg").padding(8).background(Color.red.opacity(0.2)).cornerRadius(6)
                        Text("Blue bg").padding(8).background(Color.blue.opacity(0.2)).cornerRadius(6)
                        Text("Green bg").padding(8).background(Color.green.opacity(0.2)).cornerRadius(6)
                    }
                }

                GroupBox("Animation (CSS transition)") {
                    HStack(spacing: 12) {
                        Button("Ease In Out") { }
                            .animation(.easeInOut)
                        Button("Spring") { }
                            .animation(.spring)
                        Button("Linear") { }
                            .animation(.linear)
                    }
                }
            }
        }
        .padding()
    }
}

// MARK: - Tab 7: Navigation

func navigationTabContent() -> WidgetPtr {
    NavigationStackBuilder(controller: navController)
        .root {
            VStack(alignment: .leading, spacing: 16) {
                Text("Navigation").font(.title).bold()

                GroupBox("NavigationLink") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tap a link below to navigate:").font(.caption)
                        NavigationLink("Go to Detail A", destination: "detail-a", controller: navController)
                        NavigationLink("Go to Detail B", destination: "detail-b", controller: navController)
                        NavigationLink("Go to Settings", destination: "nav-settings", controller: navController)
                    }
                }

                GroupBox("Manual Navigation") {
                    HStack(spacing: 8) {
                        Button("Push Detail A") { navController.push("detail-a") }
                            .buttonStyle(.borderedProminent)
                        Button("Push Detail B") { navController.push("detail-b") }
                        Button("Pop to Root") { navController.popToRoot() }
                    }
                }

                GroupBox("BackButton") {
                    HStack(spacing: 8) {
                        BackButton(controller: navController)
                        Text("(pop the stack)").font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
        .destination("detail-a") {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    BackButton(controller: navController)
                    Text("Detail A").font(.title)
                    Spacer()
                }
                Divider()
                Text("This is Detail A — a destination pushed onto the NavigationStack.")
                NavigationLink("Go deeper → Detail B", destination: "detail-b", controller: navController)
                Button("Pop to Root") { navController.popToRoot() }
            }
            .padding()
        }
        .destination("detail-b") {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    BackButton(controller: navController)
                    Text("Detail B").font(.title)
                    Spacer()
                }
                Divider()
                Text("This is Detail B — nested deeper in the stack.")
                Button("Pop to Root") { navController.popToRoot() }
            }
            .padding()
        }
        .destination("nav-settings") {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    BackButton(controller: navController)
                    Text("Nav Settings").font(.title)
                    Spacer()
                }
                Divider()
                Form {
                    Toggle("Enable animations")
                    Picker("Transition style", options: ["Slide", "Fade", "None"])
                }
            }
            .padding()
        }
        .build()
}

// MARK: - Tab 8: Data Binding

func dataBindingTab() -> some View {
    ScrollView {
        VStack(alignment: .leading, spacing: 16) {
            Text("Data Binding").font(.title).bold()

            GroupBox("ReactiveButton & ReactiveText") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Counter increments on each click:").font(.caption)
                    HStack(spacing: 12) {
                        ReactiveButton(state: gs.$counter, label: { "Count: \($0)" }) {
                            gs.counter += 1
                        }
                        Button("Reset") { gs.counter = 0 }
                    }
                    ReactiveText(state: gs.$counter) { "Current value: \($0)" }
                        .font(.headline)
                }
            }

            GroupBox("BoundToggle") {
                VStack(alignment: .leading, spacing: 8) {
                    BoundToggle("Enable feature A", isOn: gs.$toggleA)
                    ReactiveText(state: gs.$toggleA) { enabled in
                        enabled ? "Feature A is ON" : "Feature A is OFF"
                    }
                    .font(.caption)
                }
            }

            GroupBox("BoundSlider") {
                VStack(alignment: .leading, spacing: 8) {
                    BoundSlider("Volume", value: gs.$sliderValue, in: 0...1)
                    ReactiveText(state: gs.$sliderValue) { v in
                        String(format: "Value: %.2f", v)
                    }
                    .font(.caption)
                }
            }

            GroupBox("BoundPicker") {
                VStack(alignment: .leading, spacing: 8) {
                    BoundPicker("Theme", selection: gs.$pickerIndex, options: ["Light", "Dark", "System"])
                    ReactiveText(state: gs.$pickerIndex) { idx in
                        "Selected index: \(idx)"
                    }
                    .font(.caption)
                }
            }

            GroupBox("BoundTextField") {
                VStack(alignment: .leading, spacing: 8) {
                    BoundTextField("Type something…", text: gs.$inputText)
                    ReactiveText(state: gs.$inputText) { text in
                        "You typed: \"\(text)\" (\(text.count) chars)"
                    }
                    .font(.caption)
                }
            }

            GroupBox("ReactiveView") {
                ReactiveView(state: gs.$counter) { count in
                    HStack(spacing: 8) {
                        ForEach(Array(0..<min(count, 8))) { _ in
                            Circle()
                                .fill(.accentColor)
                                .frame(width: 16, height: 16)
                        }
                    }
                }
            }
        }
        .padding()
    }
}

// MARK: - Tab 9: Advanced

func advancedTab() -> some View {
    ScrollView {
        VStack(alignment: .leading, spacing: 16) {
            Text("Advanced").font(.title).bold()

            GroupBox("Table") {
                Table(
                    columns: [
                        TableColumn("Name"),
                        TableColumn("Type"),
                        TableColumn("Size"),
                        TableColumn("Modified"),
                    ],
                    rows: [
                        ["main.swift", "Swift", "12 KB", "Today"],
                        ["Package.swift", "Swift", "2 KB", "Yesterday"],
                        ["README.md", "Markdown", "5 KB", "Mar 15"],
                        ["Sources/", "Directory", "—", "Today"],
                        ["Tests/", "Directory", "—", "Mar 10"],
                    ]
                )
                .frame(height: 200)
            }

            GroupBox("LabeledContent") {
                VStack(alignment: .leading, spacing: 4) {
                    LabeledContent(label: { Text("App version") }, content: { Text("1.0.0") })
                    LabeledContent(label: { Text("Build number") }, content: { Text("42") })
                    LabeledContent(label: { Text("Platform") }, content: { Text("Linux / GTK4") })
                    LabeledContent(label: { Text("Framework") }, content: { Text("PineUI") })
                }
            }

            GroupBox("InfoButton") {
                HStack(spacing: 8) {
                    Text("What is PineUI?")
                    InfoButton {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("PineUI").font(.headline)
                            Text("A SwiftUI-like framework wrapping GTK4.")
                                .font(.caption)
                        }
                    }
                }
            }

            GroupBox("ShareLink & AsyncImage") {
                HStack(spacing: 12) {
                    ShareLink("Share this demo")
                    AsyncImage(url: nil)
                        .frame(width: 64, height: 64)
                }
            }

            GroupBox("TimelineView") {
                TimelineView(.everyMinute) {
                    HStack(spacing: 8) {
                        Image(systemName: "clock")
                        Text("TimelineView — refreshes every minute")
                    }
                }
            }

            GroupBox("ViewThatFits") {
                ViewThatFits {
                    Text("Full-length label text that might overflow")
                    Text("Short label")
                }
            }

            Group {
                GroupBox("VSplitView") {
                    VSplitView(position: 100) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Top pane").font(.headline)
                            Text("Drag to resize").font(.caption)
                        }
                        .padding()
                    } bottom: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Bottom pane").font(.headline)
                            Text("Independent scroll area").font(.caption)
                        }
                        .padding()
                    }
                    .frame(height: 200)
                }

                GroupBox("ContentUnavailableView") {
                    ContentUnavailableView(
                        "No Data Available",
                        systemImage: "externaldrive.badge.xmark",
                        description: "Connect a data source to view results here."
                    )
                }

                GroupBox("EmptyView & Group") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Group with EmptyView:")
                        Group {
                            Text("Grouped item A")
                            Text("Grouped item B")
                            EmptyView()
                            Text("Grouped item C (EmptyView skipped)")
                        }
                    }
                }

                GroupBox("Drag and Drop (string payload)") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Drag any colored tile onto the drop zone below.")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 12) {
                            ForEach(["Swift", "GTK4", "Linux"]) { label in
                                Text(label)
                                    .padding(8)
                                    .background(Color.accentColor.opacity(0.2))
                                    .cornerRadius(8)
                                    .draggable(label)
                            }
                        }

                        Text("Drop zone")
                            .frame(width: 300, height: 60)
                            .background(Color.gray.opacity(0.12))
                            .cornerRadius(8)
                            .border(.gray, width: 1)
                            .dropDestination(for: String.self) { items, _ in
                                // In a real app: update state with items.first
                                return true
                            }
                    }
                }
            }
        }
        .padding()
    }
}

GalleryApp.main()
