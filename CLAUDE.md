# PineUI — CLAUDE.md

## Overview

PineUI is a **SwiftUI-like declarative UI framework** written in Swift that wraps GTK4. It's the standard UI toolkit for PineOS apps — macOS developers can write familiar Swift code with SwiftUI-style syntax and it renders natively on Linux via GTK4. Themed with macOS Tahoe's Liquid Glass design language.

## Build & Run

```bash
swift build                    # Build library + apps
swift test                     # Run tests (586 tests)
.build/debug/pine-demo         # Component gallery (9 tabs)
.build/debug/PineTodo          # Todo list proof-of-concept app
```

**Dependencies:** `libgtk-4-dev`, `swiftlang` (Swift 6.0.3+)

## Architecture

### Core Concepts

- **`View` protocol** — mirrors SwiftUI's design with `associatedtype Body` and `@ViewBuilder`
- **`GTKRenderable`** — leaf views that produce GTK widgets directly (skip body recursion)
- **`MultiChildView`** — views with multiple children expose children for parent layout
- **`render()`** — recursively resolves any `View` into a `WidgetPtr` (GTK widget)
- **`@PineState`** — property wrapper providing SwiftUI-like `@State` semantics
- **`StateStore<T>`** — reference-type observable value with `onChange` callback
- **C shim** — `CGTK4/shim.h` wraps variadic GTK functions for Swift accessibility/drag-drop

### File Structure

```
Sources/
  CGTK4/                    # GTK4 system module + C shim wrappers
  PineUI/                   # Framework library
    View.swift              # View protocol, GTKRenderable, render()
    ViewBuilder.swift       # @resultBuilder, TupleView2-5, ViewList, AnyView
    GtkHelpers.swift        # GTK4 C API wrappers, applyCss() with filter/transform merging
    Modifiers.swift          # ModifiedView, Color, Edge, core modifiers
    Modifiers/              # 12 modifier category files (152 total)
    State.swift             # StateStore, Binding, reactive views, SearchField, MenuButton
    PropertyWrappers.swift  # @PineState + 10 SwiftUI-compatible wrappers
    Environment.swift       # RenderContext, EnvironmentKey, EnvironmentValues
    Animation.swift         # withAnimation(), PineAnimationContext
    PineApp.swift           # PineApp protocol, GTK Application lifecycle
    PineWindow.swift        # Window with toolbar/sidebar/content/statusbar
    PineSidebar.swift       # Interactive sidebar with selection
    PineStatusBar.swift     # Bottom status bar
    PineTheme.swift         # Liquid Glass CSS theme
    Compatibility.swift     # SF Symbol → GTK icon mapping (200+ symbols)
    Components/             # All view types (18 files)
  PineDemo/                 # Component gallery app (9 tabs)
  PineTodo/                 # Todo list proof-of-concept app
Tests/PineUITests/          # 586 tests across 12 test files
docs/superpowers/           # Specs and plans
```

## Complete Component Inventory

### Views (~89 types)

**Layout (18):** VStack, HStack, ZStack, LazyVStack, LazyHStack, Spacer, Divider, LabeledDivider, Separator, ScrollView, Grid, GridRow, LazyVGrid, LazyHGrid, Group, Form, NavigationSplitView, ViewThatFits

**Text & Display (11):** Text, Image, Label, Badge, Avatar, Chip, ProgressView, Gauge, EmptyView, ContentUnavailableView, ColorView

**Controls (14):** Button, Toggle, TextField, SecureField, Slider, Stepper, Picker, Link, SearchField, TextEditor, DatePicker, ColorPicker, SegmentedControl, MenuButton

**Reactive Controls (8):** BoundToggle, BoundSlider, BoundPicker, BoundTextField, ReactiveButton, ReactiveToggle, ReactiveText, ReactiveView

**Containers (10):** List, Section, ForEach, GroupBox, Card, TabView, Tab, DisclosureGroup, ControlGroup, OutlineGroup

**Shapes (6):** Rectangle, RoundedRectangle, Circle, Ellipse, Capsule, Path + Shape protocol with .fill()/.stroke()

**Navigation (5):** NavigationStackBuilder, NavigationLink, BackButton, NavigationController, GeometryReader

**App Structure (5):** PineApp, PineWindow, PineSidebar, PineStatusBar, PineToolbar

**Dialogs & Menus (6):** Alert, Sheet, showPopover(), MenuView, InfoButton, ShareLink

**Misc (6):** LabeledContent, TimelineView, AsyncImage, HSplitView, VSplitView, Table

### Modifiers (152 across 12 categories)

**Layout (16):** overlay, shadow, clipped, clipShape, fixedSize, layoutPriority, zIndex, offset, position, alignmentGuide, safeAreaInset, contentMargins, scenePadding, aspectRatio, mask, containerRelativeFrame

**Appearance (19):** tint, accentColor, preferredColorScheme, blendMode, saturation, brightness, contrast, hueRotation, grayscale, blur, compositingGroup, drawingGroup, glassEffect, backgroundExtensionEffect, rotationEffect, rotation3DEffect, scaleEffect, redacted, foregroundStyle(Color)

**Text (17):** fontWeight, fontDesign, italic, strikethrough, underline, kerning, tracking, baselineOffset, lineLimit, lineSpacing, minimumScaleFactor, truncationMode, textCase, textSelection, allowsTightening, labelIconToTitleSpacing, typesettingLanguage

**Interaction (20):** onLongPressGesture, gesture, highPriorityGesture, simultaneousGesture, allowsHitTesting, contentShape, hoverEffect, onHover, focusable, focused, defaultFocus, prefersDefaultFocus, onKeyPress, onSubmit, swipeActions, selectionDisabled, onDrag, onDrop, draggable, dropDestination

**Navigation (6):** navigationTitle, navigationSubtitle, navigationBarTitleDisplayMode, toolbar, toolbarBackground, toolbarColorScheme

**Presentation (9):** sheet, fullScreenCover, popover, alert, confirmationDialog, fileImporter, fileExporter, inspector, interactiveDismissDisabled

**Lists (10):** listStyle, listRowBackground, listRowSeparator, listRowInsets, listSectionSeparator, searchable, refreshable, badge, privacySensitive

**Scrolling (6):** scrollIndicators, scrollDisabled, scrollDismissesKeyboard, scrollPosition, scrollTargetLayout, scrollClipDisabled

**Lifecycle (7):** onAppear, onDisappear, onChange, task, id, tag, equatable

**Animation (7+1):** animation, transition, matchedGeometryEffect, contentTransition, phaseAnimator, keyframeAnimator, sensoryFeedback + withAnimation()

**Accessibility (8):** accessibilityLabel, accessibilityHint, accessibilityValue, accessibilityHidden, accessibilityAction, accessibilityElement, accessibilityAddTraits, accessibilitySortPriority

**Environment (6):** environment, environmentObject, transformEnvironment, preference, onPreferenceChange, backgroundPreferenceValue

**Core (16):** padding, frame, opacity, background, cornerRadius, border, foregroundColor, onTapGesture, contextMenu, hidden, disabled, help, cssClass, font, bold, foregroundStyle, buttonStyle

### Property Wrappers (11)

@PineState, @ObservedObject, @StateObject, @Published, @Environment, @EnvironmentObject, @AppStorage, @SceneStorage, @FocusState, @GestureState, @Namespace

### Environment System

RenderContext, EnvironmentKey, EnvironmentValues, PreferenceKey, currentRenderContext

### Theme

Liquid Glass (macOS Tahoe): translucent surfaces, frosted glass cards, pill buttons (.glass, .glassProminent), thin overlay scrollbars, glass tabs/switches/entries/popovers

## Known Limitations

- Property wrappers are source-compatible but don't trigger automatic view re-renders (use ReactiveView/ReactiveButton/ReactiveText for reactive updates)
- Liquid Glass approximation (no backdrop-filter blur in GTK4 CSS)
- No WebView (would need WebKitGTK dependency)
- No Charts (would need Cairo drawing)
- GTK4 CSS doesn't support `aspect-ratio` or `overflow` — use widget API instead
- Accessibility uses C shim wrappers for variadic GTK functions
- applyCss() merges `filter:` and `transform:` values automatically to prevent override
- All PineUI code runs on the main thread (GTK4 is single-threaded)
