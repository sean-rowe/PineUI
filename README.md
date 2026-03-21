# PineUI

A **SwiftUI-like declarative UI framework** for Linux, wrapping GTK4. Write familiar Swift code with SwiftUI syntax — it renders natively via GTK4 with a macOS Tahoe Liquid Glass theme.

## Quick Start

```bash
# Dependencies (Ubuntu/Debian)
sudo apt install libgtk-4-dev swiftlang

# Build
swift build

# Run the component gallery
.build/debug/pine-demo

# Run the todo app
.build/debug/PineTodo
```

## What It Looks Like

PineUI apps look like native macOS apps on Linux:

- Translucent sidebar with section headers and badges
- Liquid Glass buttons, cards, and popovers
- SF Symbol icon mapping (200+ symbols auto-resolved to GTK icons)
- Toolbar, status bar, tab views, navigation stacks

## Example

```swift
import PineUI

struct MyApp: PineApp {
    var appId: String { "com.example.MyApp" }

    func buildWindow() -> PineWindow {
        PineWindow("My App", width: 800, height: 600)
            .toolbar(PineToolbar()
                .trailing("Add", icon: "plus") { }
            )
            .content {
                render(
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Hello, PineUI!").font(.title)

                        HStack(spacing: 8) {
                            Button("Click Me") { }
                                .buttonStyle(.borderedProminent)
                            Toggle("Dark Mode")
                        }

                        ForEach(["Swift", "GTK4", "Linux"]) { item in
                            Label(item, systemImage: "checkmark.circle")
                        }
                    }
                    .padding()
                )
            }
            .statusBar(PineStatusBar()
                .left(StatusItem("Ready"))
            )
    }
}

MyApp.main()
```

## Features

### 89 View Types

| Category | Components |
|----------|-----------|
| **Layout** | VStack, HStack, ZStack, LazyVStack, LazyHStack, ScrollView, Grid, LazyVGrid, Spacer, Divider, GeometryReader |
| **Controls** | Button, Toggle, TextField, SecureField, Slider, Stepper, Picker, DatePicker, ColorPicker, SearchField, SegmentedControl |
| **Display** | Text, Image, Label, Avatar, Chip, Badge, ProgressView, Gauge, ContentUnavailableView |
| **Containers** | List, ForEach, GroupBox, Card, TabView, DisclosureGroup, ControlGroup, Form |
| **Shapes** | Rectangle, RoundedRectangle, Circle, Ellipse, Capsule, Path |
| **Navigation** | NavigationStack, NavigationLink, BackButton, HSplitView, VSplitView |

### 152 Modifiers

`.padding()`, `.frame()`, `.background()`, `.cornerRadius()`, `.shadow()`, `.blur()`, `.rotationEffect()`, `.scaleEffect()`, `.opacity()`, `.onTapGesture()`, `.onHover()`, `.onAppear()`, `.animation()`, `.navigationTitle()`, `.sheet()`, `.alert()`, `.accessibilityLabel()`, and 135 more.

### 11 Property Wrappers

`@PineState`, `@ObservedObject`, `@StateObject`, `@Published`, `@Environment`, `@EnvironmentObject`, `@AppStorage`, `@SceneStorage`, `@FocusState`, `@GestureState`, `@Namespace`

### Reactive State

```swift
let counter = StateStore<Int>(0)

ReactiveButton(state: counter, label: { "Count: \($0)" }) {
    counter.value += 1
}

ReactiveText(state: counter) { "Value is \($0)" }

BoundToggle("Enable", isOn: toggleStore)
BoundSlider("Volume", value: sliderStore, in: 0...1)
```

### SF Symbol Compatibility

Use Apple SF Symbol names — PineUI maps them to GTK icons automatically:

```swift
Image(systemName: "folder.fill")    // → folder-symbolic
Label("Star", systemImage: "star")  // → starred-symbolic
SidebarItem("Mail", icon: "envelope") // → mail-unread-symbolic
```

200+ symbols mapped covering files, navigation, media, people, system, and more.

### Liquid Glass Theme

macOS Tahoe-inspired design with translucent surfaces, frosted glass cards, pill-shaped buttons, thin overlay scrollbars, and smooth transitions.

Button styles: `.default_`, `.bordered`, `.borderedProminent`, `.plain`, `.glass`, `.glassProminent`

## Architecture

```
SwiftUI Code (your app)
    ↓ import PineUI
View Protocol + @ViewBuilder
    ↓ render()
GTKRenderable → WidgetPtr (GtkWidget*)
    ↓ applyCss()
GTK4 + Liquid Glass Theme
```

PineUI views are Swift structs conforming to `View`. The `@ViewBuilder` result builder enables declarative syntax. `render()` recursively resolves views into GTK4 widgets. CSS theming provides the visual styling.

## Requirements

- Swift 6.0.3+
- GTK4 (`libgtk-4-dev`)
- Linux (tested on Ubuntu 25.10+)

## License

Pine Ridge Labs
