# PineUI Stream 1: SwiftUI Modifier Parity

**Date:** 2026-03-20
**Goal:** Bring PineUI from ~12 generic View modifiers to full SwiftUI Tahoe parity (~144 modifiers)
**Scope:** View modifiers only — no new view types, property wrappers, or theming

## Current State

PineUI has ~12 generic `View` extension modifiers returning `ModifiedView<Self>` in `Modifiers.swift`:

`.padding` (2 overloads), `.frame` (2 overloads), `.opacity`, `.background`, `.cornerRadius`, `.border`, `.foregroundColor`, `.onTapGesture`, `.hidden`, `.disabled`, `.help`, `.cssClass`

Additionally, `.contextMenu` is in `Pickers.swift`, and `.font`/`.buttonStyle`/`.foregroundStyle`/`.bold` are per-type modifiers on `Text`/`Button` (not generic `View` extensions).

## Target State

Full SwiftUI Tahoe modifier API surface (~150 modifiers). Where GTK4 has no equivalent, provide source-compatible stubs that accept the API but no-op, so SwiftUI code compiles without modification.

## Architecture

All modifiers follow the existing pattern:

```swift
extension View {
    public func shadow(...) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "box-shadow: ...")
        }
    }
}
```

Implementation strategies by modifier type:

| Strategy | GTK4 Mechanism | Example Modifiers |
|----------|---------------|-------------------|
| **CSS** | `applyCss()` per-widget provider | shadow, blur, saturation, cornerRadius |
| **Widget API** | Direct GTK function call | opacity, visible, sensitive, size-request |
| **Signal** | `g_signal_connect_data` | onAppear, onHover, onKeyPress, onChange |
| **Container** | Wrap in GtkOverlay/GtkFrame | overlay, clipShape, safeAreaInset |
| **Stub** | Accept params, no-op | accessibility*, matchedGeometryEffect |

### `applyCss()` Scalability

**Known issue:** The current `applyCss()` creates a new `GtkCssProvider` per call and adds it globally via `gtk_style_context_add_provider_for_display`. With ~80+ CSS-based modifiers chained on hundreds of widgets, this accumulates thousands of global providers.

**Mitigation (Phase 1 prerequisite):** Before implementing CSS-based modifiers at scale, refactor `applyCss()` to batch multiple CSS rules into a single provider per widget. Each widget gets one `GtkCssProvider` that accumulates rules, stored via `g_object_set_data`. Subsequent `applyCss()` calls on the same widget append to the existing provider rather than creating a new one.

## Phase 1 — Layout & Appearance (~35 modifiers)

### Layout Modifiers

| Modifier | SwiftUI Signature | GTK4 Implementation |
|----------|------------------|---------------------|
| `.overlay` | `overlay(alignment:content:)` | Wrap in `GtkOverlay`, add content as overlay child |
| `.shadow` | `shadow(color:radius:x:y:)` | CSS `box-shadow` |
| `.clipShape` | `clipShape(_:)` | CSS `overflow: hidden` + shape-specific `border-radius` or `clip-path` |
| `.clipped` | `clipped()` | CSS `overflow: hidden` |
| `.fixedSize` | `fixedSize(horizontal:vertical:)` | Remove hexpand/vexpand, use natural size |
| `.layoutPriority` | `layoutPriority(_:)` | Stub — GTK box packing doesn't have priority |
| `.zIndex` | `zIndex(_:)` | Stub — requires overlay-based compositing |
| `.offset` | `offset(x:y:)` | CSS `transform: translate(x, y)` — does NOT affect layout flow, matching SwiftUI semantics |
| `.position` | `position(x:y:)` | CSS `transform: translate()` relative to parent origin |
| `.alignmentGuide` | `alignmentGuide(_:computeValue:)` | Stub |
| `.safeAreaInset` | `safeAreaInset(edge:content:)` | Add content box at specified edge |
| `.contentMargins` | `contentMargins(_:_:for:)` | CSS margins on content area |
| `.scenePadding` | `scenePadding(_:)` | Maps to standard padding value |
| `.aspectRatio` | `aspectRatio(_:contentMode:)` | CSS `aspect-ratio` property |
| `.mask` | `mask(alignment:_:)` | Stub — CSS `mask-image` not supported in GTK4 CSS |
| `.containerRelativeFrame` | `containerRelativeFrame(_:alignment:)` | Stub |

**Note on `.offset` vs CSS margins:** SwiftUI's `.offset` changes rendering position without affecting layout flow. CSS `margin` affects layout. We use `transform: translate()` instead, which matches SwiftUI's semantics — siblings are unaffected.

### Appearance Modifiers

| Modifier | SwiftUI Signature | GTK4 Implementation |
|----------|------------------|---------------------|
| `.foregroundStyle` | `foregroundStyle(_:)` | CSS `color` — extend to accept `Color`, gradient, or `.secondary`/`.tertiary` |
| `.tint` | `tint(_:)` | CSS custom property or accent color override |
| `.accentColor` | `accentColor(_:)` | CSS `--accent-color` variable |
| `.preferredColorScheme` | `preferredColorScheme(_:)` | `gtk_settings_set` dark/light preference |
| `.blendMode` | `blendMode(_:)` | CSS `mix-blend-mode` |
| `.saturation` | `saturation(_:)` | CSS `filter: saturate()` |
| `.brightness` | `brightness(_:)` | CSS `filter: brightness()` |
| `.contrast` | `contrast(_:)` | CSS `filter: contrast()` |
| `.hueRotation` | `hueRotation(_:)` | CSS `filter: hue-rotate()` |
| `.grayscale` | `grayscale(_:)` | CSS `filter: grayscale()` |
| `.blur` | `blur(radius:)` | CSS `filter: blur()` — note: GTK4 CSS filter support varies |
| `.compositingGroup` | `compositingGroup()` | Stub |
| `.drawingGroup` | `drawingGroup()` | Stub |
| `.glassEffect` | `glassEffect(_:in:isEnabled:)` | Stub — GTK4 CSS does not support `backdrop-filter: blur()` |
| `.backgroundExtensionEffect` | `backgroundExtensionEffect()` | Stub — Tahoe-specific, no GTK4 equivalent |
| `.rotationEffect` | `rotationEffect(_:)` | CSS `transform: rotate()` |
| `.rotation3DEffect` | `rotation3DEffect(_:axis:)` | CSS `transform: perspective() rotateX/Y/Z()` |
| `.scaleEffect` | `scaleEffect(_:)` | CSS `transform: scale()` |
| `.redacted` | `redacted(reason:)` | Stub |

### Files

- `Sources/PineUI/Modifiers/LayoutModifiers.swift` — overlay, shadow, clip, offset, position, safeAreaInset, aspectRatio
- `Sources/PineUI/Modifiers/AppearanceModifiers.swift` — foregroundStyle, tint, filters, transforms, glass stubs

## Phase 2 — Text & Typography (~17 modifiers)

| Modifier | Implementation |
|----------|---------------|
| `.fontWeight` | CSS `font-weight` via `applyCss` |
| `.fontDesign` | CSS `font-family` (rounded, serif, monospaced) |
| `.italic` | CSS `font-style: italic` |
| `.strikethrough` | CSS `text-decoration: line-through` |
| `.underline` | CSS `text-decoration: underline` |
| `.kerning` | CSS `letter-spacing` |
| `.tracking` | CSS `letter-spacing` (same as kerning for our purposes) |
| `.baselineOffset` | CSS `vertical-align` |
| `.lineLimit` | `gtk_label_set_lines` + `gtk_label_set_ellipsize` |
| `.lineSpacing` | CSS `line-height` |
| `.minimumScaleFactor` | Stub — no GTK equivalent |
| `.truncationMode` | `gtk_label_set_ellipsize` (start/middle/end) |
| `.textCase` | CSS `text-transform: uppercase/lowercase` |
| `.textSelection` | `gtk_label_set_selectable` |
| `.allowsTightening` | Stub |
| `.labelIconToTitleSpacing` | Adjust Label's box spacing |
| `.typesettingLanguage` | Stub |

### Files

- `Sources/PineUI/Modifiers/TextModifiers.swift`

## Phase 3 — Interaction (~20 modifiers)

| Modifier | Implementation |
|----------|---------------|
| `.onLongPressGesture` | `GtkGestureLongPress` |
| `.gesture` | Generic gesture attachment |
| `.highPriorityGesture` | Gesture with `GTK_PHASE_CAPTURE` |
| `.simultaneousGesture` | Multiple gestures on same widget |
| `.allowsHitTesting` | `gtk_widget_set_can_target` |
| `.contentShape` | Stub (affects hit testing shape) |
| `.hoverEffect` | CSS `:hover` pseudo-class |
| `.onHover` | `GtkEventControllerMotion` — `enter` and `leave` signals |
| `.focusable` | `gtk_widget_set_focusable` |
| `.focused` | `gtk_widget_grab_focus` |
| `.defaultFocus` | Stub |
| `.prefersDefaultFocus` | Stub |
| `.onKeyPress` | `GtkEventControllerKey` — `key-pressed` signal |
| `.onSubmit` | Connect to `activate` signal on entry widgets |
| `.swipeActions` | Stub (no native GTK equivalent) |
| `.selectionDisabled` | Stub |
| `.onDrag` | `GtkDragSource` |
| `.onDrop` | `GtkDropTarget` |
| `.draggable` | Simplified `GtkDragSource` wrapper |
| `.dropDestination` | Simplified `GtkDropTarget` wrapper |

### Files

- `Sources/PineUI/Modifiers/InteractionModifiers.swift`

## Phase 4 — Navigation & Presentation (~15 modifiers)

| Modifier | Implementation |
|----------|---------------|
| `.navigationTitle` | Set window/headerbar title via widget tree traversal |
| `.navigationSubtitle` | Set subtitle on headerbar |
| `.navigationBarTitleDisplayMode` | Stub (iOS-specific) |
| `.toolbar` | Build toolbar items, attach to nearest PineWindow |
| `.toolbarBackground` | CSS on toolbar widget |
| `.toolbarColorScheme` | CSS color scheme on toolbar |
| `.sheet` | `Sheet.present()` triggered by binding |
| `.fullScreenCover` | Sheet with fullscreen size |
| `.popover` | `GtkPopover` attached to widget |
| `.alert` | `Alert.show()` triggered by binding |
| `.confirmationDialog` | `Alert.confirm()` triggered by binding |
| `.fileImporter` | `GtkFileDialog` open |
| `.fileExporter` | `GtkFileDialog` save |
| `.inspector` | Side panel (GtkPaned-based) |
| `.interactiveDismissDisabled` | Stub |

### Files

- `Sources/PineUI/Modifiers/NavigationModifiers.swift`
- `Sources/PineUI/Modifiers/PresentationModifiers.swift`

## Phase 5 — Lists & Scrolling (~16 modifiers)

| Modifier | Implementation |
|----------|---------------|
| `.listStyle` | CSS class swap (sidebar, bordered, plain, inset) |
| `.listRowBackground` | CSS background on row widget |
| `.listRowSeparator` | CSS border-bottom toggle |
| `.listRowInsets` | CSS padding on row |
| `.listSectionSeparator` | CSS border on section |
| `.scrollIndicators` | `GtkScrolledWindow` scrollbar policy |
| `.scrollDisabled` | Disable scroll policy |
| `.scrollDismissesKeyboard` | Stub (iOS-specific) |
| `.scrollPosition` | `gtk_scrolled_window_set_vadjustment` |
| `.scrollTargetLayout` | Stub |
| `.scrollClipDisabled` | CSS `overflow: visible` |
| `.scrollTransition` | Stub (Tahoe-specific scroll effect) |
| `.searchable` | Add SearchField to navigation hierarchy |
| `.refreshable` | Stub (desktop doesn't use pull-to-refresh) |
| `.badge` | Add badge label to list row |
| `.privacySensitive` | Stub |

### Files

- `Sources/PineUI/Modifiers/ListModifiers.swift`
- `Sources/PineUI/Modifiers/ScrollModifiers.swift`

## Phase 6 — Lifecycle (~7 modifiers)

| Modifier | Implementation |
|----------|---------------|
| `.onAppear` | Connect to GTK4 `map` signal (widget becomes visible) |
| `.onDisappear` | Connect to GTK4 `unmap` signal |
| `.onChange` | Observe StateStore changes |
| `.task` | Dispatch async work when widget maps |
| `.id` | Set widget name for identification |
| `.tag` | Store tag value as widget data via `g_object_set_data` |
| `.equatable` | Stub |

### Files

- `Sources/PineUI/Modifiers/LifecycleModifiers.swift`

## Phase 7 — Animation (~8 modifiers + 1 function)

| API | Type | Implementation |
|-----|------|---------------|
| `.animation` | Modifier | CSS `transition` property on widget; for complex animations, use `AdwAnimation` from libadwaita if available |
| `.transition` | Modifier | CSS transitions on opacity/transform for insert/remove |
| `.matchedGeometryEffect` | Modifier | Stub |
| `withAnimation()` | **Free function** (not a modifier) | Global function that sets a flag causing subsequent state changes to apply CSS transitions. Lives in `Animation.swift`, not as a View extension. |
| `.contentTransition` | Modifier | CSS transition on content swap |
| `.phaseAnimator` | Modifier | Timer-driven state changes via `g_timeout_add` |
| `.keyframeAnimator` | Modifier | CSS `@keyframes` animation |
| `.sensoryFeedback` | Modifier | Stub (no haptics on desktop) |

**Note:** GTK4 does NOT have `GtkPropertyTransition`. Animation options are: CSS `transition` properties, `GdkFrameClock` for frame-by-frame animation, or `AdwAnimation` / `AdwTimedAnimation` from libadwaita. For Phase 1, CSS transitions cover most cases.

### Files

- `Sources/PineUI/Modifiers/AnimationModifiers.swift`
- `Sources/PineUI/Animation.swift` — `withAnimation()` free function

## Phase 8 — Accessibility (~8 modifiers)

All accessibility modifiers use GTK4's `GtkAccessible` interface (NOT the deprecated ATK API which was removed in GTK4).

| Modifier | Implementation |
|----------|---------------|
| `.accessibilityLabel` | `gtk_accessible_update_property` with `GTK_ACCESSIBLE_PROPERTY_LABEL` |
| `.accessibilityHint` | `gtk_accessible_update_property` with `GTK_ACCESSIBLE_PROPERTY_DESCRIPTION` |
| `.accessibilityValue` | `gtk_accessible_update_property` with `GTK_ACCESSIBLE_PROPERTY_VALUE_TEXT` |
| `.accessibilityHidden` | `gtk_accessible_update_state` with `GTK_ACCESSIBLE_STATE_HIDDEN` |
| `.accessibilityAction` | Stub — GTK4 accessible actions are limited |
| `.accessibilityElement` | Stub |
| `.accessibilityAddTraits` | `gtk_accessible_update_property` with `GTK_ACCESSIBLE_PROPERTY_ROLE_DESCRIPTION` |
| `.accessibilitySortPriority` | Stub |

### Files

- `Sources/PineUI/Modifiers/AccessibilityModifiers.swift`

## Phase 9 — Environment (~6 modifiers)

**Architectural note:** These modifiers require a propagation mechanism through the render tree. The current `render()` function is a simple recursive call with no context passing.

**Design:** Introduce a `RenderContext` class that holds environment values and is passed through `render()`. This is the most invasive change in the spec — it requires modifying `render()` to accept an optional context parameter (defaulting to a global context for backward compatibility).

```swift
public class RenderContext {
    var values: [ObjectIdentifier: Any] = [:]
    var parent: RenderContext?

    func child() -> RenderContext {
        let c = RenderContext()
        c.parent = self
        return c
    }

    func value<T>(for key: ObjectIdentifier) -> T? {
        values[key] as? T ?? parent?.value(for: key)
    }
}
```

| Modifier | Implementation |
|----------|---------------|
| `.environment` | Push key-value into `RenderContext` for child tree |
| `.environmentObject` | Push type-keyed object into `RenderContext` |
| `.transformEnvironment` | Modify environment value via closure before passing to children |
| `.preference` | Stub — child-to-parent propagation requires post-render pass |
| `.onPreferenceChange` | Stub |
| `.backgroundPreferenceValue` | Stub |

### Files

- `Sources/PineUI/Environment.swift` — `RenderContext`, `EnvironmentKey` protocol
- `Sources/PineUI/Modifiers/EnvironmentModifiers.swift`

## File Organization & Migration

Current: all modifiers in `Modifiers.swift` (single file).

**Migration strategy:** Existing modifiers stay in `Modifiers.swift` for now. New modifiers go into category files under `Modifiers/`. No existing code moves — this avoids merge conflicts and keeps the diff clean. If a future refactor wants to consolidate, that's a separate task.

```
Sources/PineUI/
  Modifiers.swift              ← keep as-is: ModifiedView, Edge, MaxDimension, Color, existing 12 modifiers
  Modifiers/
    LayoutModifiers.swift      ← Phase 1 (new)
    AppearanceModifiers.swift  ← Phase 1 (new)
    TextModifiers.swift        ← Phase 2 (new)
    InteractionModifiers.swift ← Phase 3 (new)
    NavigationModifiers.swift  ← Phase 4 (new)
    PresentationModifiers.swift← Phase 4 (new)
    ListModifiers.swift        ← Phase 5 (new)
    ScrollModifiers.swift      ← Phase 5 (new)
    LifecycleModifiers.swift   ← Phase 6 (new)
    AnimationModifiers.swift   ← Phase 7 (new)
    AccessibilityModifiers.swift ← Phase 8 (new)
    EnvironmentModifiers.swift ← Phase 9 (new)
  Environment.swift            ← Phase 9 (new)
  Animation.swift              ← Phase 7 (new, withAnimation free function)
```

## Phase Count Summary

| Phase | Category | Count |
|-------|----------|-------|
| 1 | Layout & Appearance | 35 |
| 2 | Text & Typography | 17 |
| 3 | Interaction | 20 |
| 4 | Navigation & Presentation | 15 |
| 5 | Lists & Scrolling | 16 |
| 6 | Lifecycle | 7 |
| 7 | Animation | 7 + 1 function |
| 8 | Accessibility | 8 |
| 9 | Environment | 6 |
| | **Total new** | **~132** |
| | + existing 12 | **~144** |

## Testing Strategy

Each phase gets a test file in `Tests/PineUITests/` verifying:
1. Modifier compiles with expected signature
2. Returns `ModifiedView<Self>` (type check)
3. For CSS-based modifiers: verify the CSS string generated
4. For signal-based modifiers: verify signal connection (where testable)

## Success Criteria

- All ~144 SwiftUI Tahoe modifiers have corresponding PineUI implementations
- SwiftUI code using these modifiers compiles against PineUI with only `import PineUI` change
- Stubs are clearly documented with `// STUB: no GTK4 equivalent` comments
- No regressions — existing demo app continues to build and run

## Streams 2-4 (Future Specs)

This spec covers Stream 1 only. Future specs will cover:
- **Stream 2: Property Wrappers** — `@State` (full), `@Binding`, `@ObservedObject`, `@Environment`, etc.
- **Stream 3: Missing Views** — LazyVStack/HStack, AsyncImage, Shapes, WebView, OutlineGroup, etc.
- **Stream 4: Liquid Glass Theming** — CSS overhaul to match Tahoe visual design
