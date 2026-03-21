# PineUI — CLAUDE.md

## Overview

PineUI is a **SwiftUI-like declarative UI framework** written in Swift that wraps GTK4. It's the standard UI toolkit for PineOS apps — macOS developers can write familiar Swift code with SwiftUI-style syntax and it renders natively on Linux via GTK4.

## Build & Run

```bash
swift build              # Build library + demo
swift test               # Run tests
.build/debug/pine-demo   # Run the demo Notes app
```

**Dependencies:** `libgtk-4-dev`, `swiftlang` (Swift 6.0.3+)

## Architecture

### Core Concepts

- **`View` protocol** — mirrors SwiftUI's design with `associatedtype Body` and `@ViewBuilder`
- **`GTKRenderable`** — leaf views that produce GTK widgets directly (skip body recursion)
- **`MultiChildView`** — views with multiple children (TupleViews, ForEach) expose children for parent layout
- **`render()`** — recursively resolves any `View` into a `WidgetPtr` (GTK widget)
- **`AxisAwareSpacer`** — spacers that expand only in their parent's axis direction
- **`@PineState`** — property wrapper providing SwiftUI-like `@State` semantics

### File Structure

| File | Purpose |
|------|---------|
| `View.swift` | `View` protocol, `GTKRenderable`, `render()` function |
| `ViewBuilder.swift` | `@resultBuilder`, TupleView2-5, ViewList (6-10), AnyView, conditionals |
| `GtkHelpers.swift` | Swift wrappers for GTK4 C API (constructors, properties, CSS, gestures) |
| `Modifiers.swift` | View modifiers, `Color` type, `GestureHandler` |
| `PineApp.swift` | `PineApp` protocol, GTK Application lifecycle |
| `PineWindow.swift` | Window with toolbar/sidebar/content/statusbar slots |
| `PineSidebar.swift` | macOS-style source list sidebar with selection |
| `PineStatusBar.swift` | Bottom status bar |
| `PineTheme.swift` | CSS theme (typography, sidebar, cards, buttons, toolbar) |
| `Compatibility.swift` | SF Symbol → GTK icon mapping (200+ symbols) |
| `State.swift` | `@PineState`, `StateStore`, `Binding`, reactive views, `SearchField`, `MenuButton` |
| `Components/Text.swift` | `Text` with font/color/alignment modifiers |
| `Components/Controls.swift` | `Button`, `Toggle`, `Label`, `Image`, `TextField` |
| `Components/MoreControls.swift` | `Slider`, `Stepper`, `Picker`, `SecureField`, `TextEditor`, `Link` |
| `Components/ReactiveControls.swift` | `BoundToggle`, `BoundSlider`, `BoundPicker`, `BoundTextField`, `LazyVGrid`, `Avatar`, `LabeledDivider`, `EmptyView` |
| `Components/Stacks.swift` | `VStack`, `HStack`, `Spacer`, `Divider` |
| `Components/Containers.swift` | `TabView`, `Tab`, `DisclosureGroup`, `ScrollView`, `Grid`, `Group` |
| `Components/List.swift` | `List`, `Section`, `ForEach`, `GroupBox`, `Form` |
| `Components/Display.swift` | `ProgressView`, `Gauge`, `Badge` |
| `Components/NavigationSplitView.swift` | `NavigationSplitView` (sidebar + detail) |
| `Components/Navigation.swift` | `NavigationStack`, `NavigationLink`, `BackButton` |
| `Components/Dialogs.swift` | `Alert`, `Sheet`, `PineToolbar` |

### Key Patterns

- **Modifier chain:** `Text("Hi").font(.title).padding().background(.blue)` — each returns `ModifiedView<Self>`
- **ViewBuilder 6-10:** Uses type-erased `AnyView` + `ViewList` instead of more TupleView types
- **SF Symbols:** `Image(systemName: "folder.fill")` → maps to `"folder-symbolic"` for GTK
- **Inline CSS:** `applyCss(widget, "border-radius: 10px;")` creates per-widget CSS providers
- **Reactive state:** `@PineState var count = 0` — `$count` gives `StateStore<Int>`
- **Navigation:** `NavigationStackBuilder` with `.root {}` and `.destination("name") {}`

## Complete Component List

### Layout
`VStack`, `HStack`, `Spacer`, `Divider`, `LabeledDivider`, `ScrollView`, `Grid`, `LazyVGrid`, `Group`, `Form`, `NavigationSplitView`

### Text & Display
`Text`, `Image`, `Label`, `Badge`, `Avatar`, `ProgressView`, `Gauge`, `EmptyView`

### Controls
`Button`, `Toggle`, `TextField`, `SecureField`, `Slider`, `Stepper`, `Picker`, `Link`, `SearchField`, `TextEditor`, `MenuButton`

### Reactive Controls (two-way bound)
`BoundToggle`, `BoundSlider`, `BoundPicker`, `BoundTextField`, `ReactiveButton`, `ReactiveToggle`, `ReactiveText`, `ReactiveView`

### Containers
`List`, `Section`, `ForEach`, `GroupBox`, `TabView`, `Tab`, `DisclosureGroup`

### Navigation
`NavigationStackBuilder`, `NavigationLink`, `BackButton`, `NavigationController`

### App Structure
`PineApp`, `PineWindow`, `PineSidebar`, `PineStatusBar`, `PineToolbar`

### Dialogs
`Alert.show()`, `Alert.confirm()`, `Sheet.present()`, `showPopover()`

### State Management
`@PineState`, `StateStore<T>`, `Binding<T>`, `reactive()`

### Modifiers
`.padding()`, `.frame()`, `.opacity()`, `.background()`, `.cornerRadius()`, `.border()`, `.foregroundColor()`, `.onTapGesture()`, `.hidden()`, `.disabled()`, `.help()`, `.cssClass()`, `.font()`, `.bold()`, `.foregroundStyle()`, `.buttonStyle()`

### Compatibility
`Color` (all SwiftUI standard colors), SF Symbol mapping (200+ symbols), `resolveSFSymbol()`

## Known Gaps

- No view diffing/reconciliation (rebuilds entire subtree on state change)
- No animations beyond GtkStack slide transitions
- No `@Environment` / `@EnvironmentObject`
- No `ZStack` (overlapping views)
- No `GeometryReader`
- No drag-and-drop
- No `DatePicker`, `ColorPicker`
