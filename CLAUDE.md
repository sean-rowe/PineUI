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

### File Structure

| File | Purpose |
|------|---------|
| `View.swift` | `View` protocol, `GTKRenderable`, `render()` function |
| `ViewBuilder.swift` | `@resultBuilder`, TupleView2-5, ViewList (6-10), AnyView, conditionals |
| `GtkHelpers.swift` | Swift wrappers for GTK4 C API (constructors, properties, CSS) |
| `Modifiers.swift` | `.padding()`, `.frame()`, `.opacity()`, `.background()`, `.cornerRadius()`, `.border()`, `Color` type |
| `PineApp.swift` | `PineApp` protocol, GTK Application lifecycle |
| `PineWindow.swift` | Window with sidebar/content/statusbar slots |
| `PineSidebar.swift` | macOS-style source list sidebar |
| `PineStatusBar.swift` | Bottom status bar |
| `PineTheme.swift` | CSS theme (typography, sidebar, cards, buttons) |
| `Compatibility.swift` | SF Symbol → GTK icon mapping (200+ symbols) |
| `State.swift` | `StateStore`, `Binding`, `ReactiveButton`, `ReactiveToggle` |
| `Components/` | Text, Controls, Stacks, Containers, List, Display, NavigationSplitView, MoreControls, Navigation, Dialogs |

### Key Patterns

- **Modifier chain:** `Text("Hi").font(.title).padding().background(.blue)` — each returns `ModifiedView<Self>`
- **ViewBuilder 6-10:** Uses type-erased `AnyView` + `ViewList` instead of more TupleView types
- **SF Symbols:** `Image(systemName: "folder.fill")` → maps to `"folder-symbolic"` for GTK
- **Inline CSS:** `applyCss(widget, "border-radius: 10px;")` creates per-widget CSS providers
- **Reactive state:** `StateStore<T>` with `onChange` callback, `ReactiveButton` updates label on state change

## What's Working

- Full declarative syntax: VStack, HStack, Text, Button, ForEach, GroupBox, etc.
- Proper child flattening (HStack children actually lay out horizontally)
- SF Symbol → GTK icon resolution (200+ symbols)
- macOS-like theme with sidebar, cards, status bar, toolbar
- Basic reactive state (StateStore, ReactiveButton, ReactiveToggle)
- Modifiers: padding, frame, opacity, background, cornerRadius, border, foregroundColor
- TabView with multiple tabs, icons, and proper page switching
- Alert and confirm dialogs (Alert.show, Alert.confirm)
- Sheet modal windows (Sheet.present)
- Toolbar with leading/trailing icon buttons
- ViewBuilder up to 10 children, Group for unlimited nesting
- Color type with all standard SwiftUI colors

## Known Gaps

- No full `@State` property wrapper (using `StateStore` class instead)
- No `@Binding` propagation through view hierarchy
- No view diffing/reconciliation (rebuilds entire subtree on state change)
- No animations or transitions (GtkStack has slide transitions for NavigationStack)
