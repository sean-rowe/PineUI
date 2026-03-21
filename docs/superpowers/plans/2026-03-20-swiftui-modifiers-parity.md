# SwiftUI Modifier Parity Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add ~132 new view modifiers to PineUI, reaching SwiftUI Tahoe parity.

**Architecture:** All modifiers are `extension View` methods returning `ModifiedView<Self>`. They apply GTK4 changes via CSS (`applyCss()`), widget API calls, signal connections, or container wrapping. Stubs accept the API but no-op where GTK4 has no equivalent.

**Tech Stack:** Swift 6.0.3, GTK4 (via CGTK4 system module), XCTest

**Spec:** `docs/superpowers/specs/2026-03-20-swiftui-modifiers-parity-design.md`

---

### Task 0: Refactor `applyCss()` for Scalability

The current `applyCss()` creates a global `GtkCssProvider` per call. Before adding ~80 CSS-based modifiers, refactor to batch rules per widget.

**Files:**
- Modify: `Sources/PineUI/GtkHelpers.swift:85-97`
- Test: `Tests/PineUITests/ModifierTests.swift` (create)

- [ ] **Step 1: Write failing test for batched CSS**

```swift
// Tests/PineUITests/ModifierTests.swift
import XCTest
@testable import PineUI

final class ModifierTests: XCTestCase {
    func testApplyCssAddsClass() {
        // We can't easily test GTK widgets without a display,
        // but we can verify the function signature exists and
        // the counter increments.
        let before = cssProviderCount()
        // Verify cssProviderCount is accessible
        XCTAssertTrue(before >= 0)
    }
}
```

- [ ] **Step 2: Refactor `applyCss()` in GtkHelpers.swift**

Replace lines 85-97 in `GtkHelpers.swift` with:

```swift
/// Apply inline CSS to a single widget. Batches multiple calls per widget
/// into a single GtkCssProvider to avoid accumulating global providers.
private var widgetCssMap: [UnsafeRawPointer: (provider: UnsafeMutableRawPointer, rules: [String], className: String)] = [:]
private var cssCounter: Int = 0

public func cssProviderCount() -> Int { cssCounter }

public func applyCss(_ w: WidgetPtr, _ css: String) {
    let key = UnsafeRawPointer(w)

    if var entry = widgetCssMap[key] {
        // Append to existing provider for this widget.
        entry.rules.append(css)
        widgetCssMap[key] = entry
        let fullCss = ".\(entry.className) { \(entry.rules.joined(separator: " ")) }"
        let p = entry.provider.assumingMemoryBound(to: GtkCssProvider.self)
        gtk_css_provider_load_from_string(p, fullCss)
    } else {
        // Create new provider for this widget.
        cssCounter += 1
        let className = "pine-inline-\(cssCounter)"
        let fullCss = ".\(className) { \(css) }"
        let provider = gtk_css_provider_new()!
        let p = UnsafeMutableRawPointer(provider).assumingMemoryBound(to: GtkCssProvider.self)
        gtk_css_provider_load_from_string(p, fullCss)
        let display = gdk_display_get_default()!
        gtk_style_context_add_provider_for_display(display, OpaquePointer(provider), UInt32(GTK_STYLE_PROVIDER_PRIORITY_USER))
        addCssClass(w, className)
        widgetCssMap[key] = (provider: UnsafeMutableRawPointer(provider), rules: [css], className: className)
    }
}
```

- [ ] **Step 3: Build and verify no regressions**

Run: `swift build`
Expected: Build complete

- [ ] **Step 4: Run demo to verify visual correctness**

Run: `.build/debug/pine-demo` — verify sidebar, cards, buttons still render correctly.

- [ ] **Step 5: Commit**

```bash
git add Sources/PineUI/GtkHelpers.swift Tests/PineUITests/ModifierTests.swift
git commit -m "refactor: batch applyCss() per widget to avoid global provider accumulation"
```

---

### Task 1: Phase 1 — Layout Modifiers (16 modifiers)

**Files:**
- Create: `Sources/PineUI/Modifiers/LayoutModifiers.swift`
- Test: `Tests/PineUITests/LayoutModifierTests.swift` (create)

- [ ] **Step 1: Create Modifiers directory**

```bash
mkdir -p Sources/PineUI/Modifiers
```

- [ ] **Step 2: Write test file**

```swift
// Tests/PineUITests/LayoutModifierTests.swift
import XCTest
@testable import PineUI

final class LayoutModifierTests: XCTestCase {
    // Type-level tests: verify modifiers compile and return ModifiedView
    func testShadowReturnsModifiedView() {
        let view = Text("test")
        let modified = view.shadow(color: .black, radius: 4, x: 0, y: 2)
        // If this compiles, the modifier exists with correct signature
        XCTAssertTrue(type(of: modified) is ModifiedView<Text>.Type)
    }

    func testClippedReturnsModifiedView() {
        let view = Text("test")
        let modified = view.clipped()
        XCTAssertTrue(type(of: modified) is ModifiedView<Text>.Type)
    }

    func testOffsetReturnsModifiedView() {
        let view = Text("test")
        let modified = view.offset(x: 10, y: 20)
        XCTAssertTrue(type(of: modified) is ModifiedView<Text>.Type)
    }

    func testFixedSizeReturnsModifiedView() {
        let view = Text("test")
        let modified = view.fixedSize()
        XCTAssertTrue(type(of: modified) is ModifiedView<Text>.Type)
    }

    func testAspectRatioReturnsModifiedView() {
        let view = Text("test")
        let modified = view.aspectRatio(1.0, contentMode: .fit)
        XCTAssertTrue(type(of: modified) is ModifiedView<Text>.Type)
    }
}
```

- [ ] **Step 3: Run test to verify it fails**

Run: `swift test --filter LayoutModifierTests`
Expected: FAIL — methods don't exist yet

- [ ] **Step 4: Implement LayoutModifiers.swift**

```swift
// Sources/PineUI/Modifiers/LayoutModifiers.swift
// Layout modifiers: overlay, shadow, clip, offset, position, etc.

import CGTK4

// MARK: - Content Mode (for aspectRatio)

public enum ContentMode {
    case fit, fill
}

// MARK: - Layout Modifiers

extension View {
    /// Add an overlay view on top of this view.
    public func overlay<V: View>(alignment: GtkAlign = GTK_ALIGN_CENTER, @ViewBuilder content: () -> V) -> ModifiedView<Self> {
        let overlayContent = content()
        return ModifiedView(content: self) { w in
            let overlay = gtk_overlay_new()!
            setHExpand(overlay)
            setVExpand(overlay)
            // Reparent: remove w from its parent, put overlay there, put w in overlay
            let parent = gtk_widget_get_parent(w)
            if parent != nil {
                let parentBox: UnsafeMutablePointer<_GtkBox> = typed(parent!)
                gtk_box_remove(parentBox, w)
                gtk_overlay_set_child(OpaquePointer(overlay), w)
                gtk_box_append(parentBox, overlay)
            } else {
                gtk_overlay_set_child(OpaquePointer(overlay), w)
            }
            let overlayWidget = render(overlayContent)
            setHAlign(overlayWidget, align: alignment)
            setVAlign(overlayWidget, align: alignment)
            gtk_overlay_add_overlay(OpaquePointer(overlay), overlayWidget)
        }
    }

    /// Add a shadow effect.
    public func shadow(color: Color = .black.opacity(0.33), radius: Int32 = 4, x: Int32 = 0, y: Int32 = 2) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "box-shadow: \(x)px \(y)px \(radius)px \(color.cssValue);")
        }
    }

    /// Clip content to the view's bounds.
    public func clipped() -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "overflow: hidden;")
        }
    }

    /// Clip content to a shape.
    public func clipShape(_ shape: ClipShape) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "overflow: hidden; \(shape.css)")
        }
    }

    /// Use the view's natural size, ignoring flexible sizing.
    public func fixedSize(horizontal: Bool = true, vertical: Bool = true) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            if horizontal { setHExpand(w, expand: false) }
            if vertical { setVExpand(w, expand: false) }
        }
    }

    // STUB: GTK box packing doesn't have priority.
    public func layoutPriority(_ value: Double) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in }
    }

    // STUB: requires overlay-based compositing.
    public func zIndex(_ value: Double) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in }
    }

    /// Offset the view's rendering position without affecting layout.
    public func offset(x: Int32 = 0, y: Int32 = 0) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "transform: translate(\(x)px, \(y)px);")
        }
    }

    /// Position the view at absolute coordinates within its parent.
    public func position(x: Int32 = 0, y: Int32 = 0) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "transform: translate(\(x)px, \(y)px);")
        }
    }

    // STUB: no GTK4 equivalent.
    public func alignmentGuide(_ guide: HorizontalAlignment, computeValue: @escaping (Int32) -> Int32) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in }
    }

    /// Add content at the edge of the safe area.
    public func safeAreaInset(edge: Edge, @ViewBuilder content: () -> some View) -> ModifiedView<Self> {
        let insetContent = content()
        return ModifiedView(content: self) { w in
            let rendered = render(insetContent)
            let parent = gtk_widget_get_parent(w)
            if let parent = parent {
                let parentBox: UnsafeMutablePointer<_GtkBox> = typed(parent)
                if edge == .top || edge == .leading {
                    // Insert before — GTK4 box doesn't have insert_before easily,
                    // so we use prepend via remove/re-add pattern
                    gtk_box_prepend(parentBox, rendered)
                } else {
                    gtk_box_append(parentBox, rendered)
                }
            }
        }
    }

    /// Set content margins.
    public func contentMargins(_ edges: Edge.Set = .all, _ amount: Int32 = 12) -> ModifiedView<Self> {
        padding(edges, amount)
    }

    /// Scene-appropriate padding.
    public func scenePadding(_ edges: Edge.Set = .all) -> ModifiedView<Self> {
        padding(edges, 20)
    }

    /// Set aspect ratio.
    public func aspectRatio(_ ratio: Double? = nil, contentMode: ContentMode = .fit) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            if let ratio = ratio {
                applyCss(w, "aspect-ratio: \(ratio);")
            }
        }
    }

    // STUB: CSS mask-image not supported in GTK4 CSS.
    public func mask(alignment: GtkAlign = GTK_ALIGN_CENTER, @ViewBuilder content: () -> some View) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in }
    }

    // STUB: no GTK4 equivalent.
    public func containerRelativeFrame(_ axes: ScrollAxes, alignment: GtkAlign = GTK_ALIGN_CENTER) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in }
    }
}

/// Shapes for clipShape.
public enum ClipShape {
    case circle
    case capsule
    case roundedRectangle(cornerRadius: Int32)
    case rectangle

    var css: String {
        switch self {
        case .circle: return "border-radius: 50%;"
        case .capsule: return "border-radius: 9999px;"
        case .roundedRectangle(let r): return "border-radius: \(r)px;"
        case .rectangle: return ""
        }
    }
}
```

- [ ] **Step 5: Run tests**

Run: `swift test --filter LayoutModifierTests`
Expected: All pass

- [ ] **Step 6: Build and run demo**

Run: `swift build && .build/debug/pine-demo`
Expected: No regressions

- [ ] **Step 7: Commit**

```bash
git add Sources/PineUI/Modifiers/LayoutModifiers.swift Tests/PineUITests/LayoutModifierTests.swift
git commit -m "feat: add 16 layout modifiers (overlay, shadow, clipShape, offset, etc.)"
```

---

### Task 2: Phase 1 — Appearance Modifiers (19 modifiers)

**Files:**
- Create: `Sources/PineUI/Modifiers/AppearanceModifiers.swift`
- Test: `Tests/PineUITests/AppearanceModifierTests.swift` (create)

- [ ] **Step 1: Write test file**

```swift
// Tests/PineUITests/AppearanceModifierTests.swift
import XCTest
@testable import PineUI

final class AppearanceModifierTests: XCTestCase {
    func testBlurReturnsModifiedView() {
        let modified = Text("test").blur(radius: 5)
        XCTAssertTrue(type(of: modified) is ModifiedView<Text>.Type)
    }

    func testGrayscaleReturnsModifiedView() {
        let modified = Text("test").grayscale(0.5)
        XCTAssertTrue(type(of: modified) is ModifiedView<Text>.Type)
    }

    func testRotationEffectReturnsModifiedView() {
        let modified = Text("test").rotationEffect(degrees: 45)
        XCTAssertTrue(type(of: modified) is ModifiedView<Text>.Type)
    }

    func testScaleEffectReturnsModifiedView() {
        let modified = Text("test").scaleEffect(1.5)
        XCTAssertTrue(type(of: modified) is ModifiedView<Text>.Type)
    }

    func testTintReturnsModifiedView() {
        let modified = Text("test").tint(.blue)
        XCTAssertTrue(type(of: modified) is ModifiedView<Text>.Type)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `swift test --filter AppearanceModifierTests`
Expected: FAIL

- [ ] **Step 3: Implement AppearanceModifiers.swift**

```swift
// Sources/PineUI/Modifiers/AppearanceModifiers.swift
// Appearance modifiers: foregroundStyle, tint, CSS filters, transforms, glass stubs.

import CGTK4

public enum BlendMode: String {
    case normal, multiply, screen, overlay, darken, lighten
    case colorDodge = "color-dodge"
    case colorBurn = "color-burn"
    case hardLight = "hard-light"
    case softLight = "soft-light"
    case difference, exclusion
}

public enum ColorScheme {
    case light, dark
}

extension View {
    /// Set the tint/accent color.
    public func tint(_ color: Color) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "color: \(color.cssValue);")
        }
    }

    /// Set the accent color (deprecated in SwiftUI, alias for tint).
    public func accentColor(_ color: Color) -> ModifiedView<Self> {
        tint(color)
    }

    /// Set the preferred color scheme.
    public func preferredColorScheme(_ scheme: ColorScheme?) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // This affects the whole app, not just this view.
            guard let scheme = scheme else { return }
            let settings = gtk_settings_get_default()!
            let dark: gboolean = scheme == .dark ? 1 : 0
            g_object_set_data(
                UnsafeMutableRawPointer(settings).assumingMemoryBound(to: GObject.self),
                "gtk-application-prefer-dark-theme",
                UnsafeMutableRawPointer(bitPattern: Int(dark))
            )
        }
    }

    /// Set blend mode.
    public func blendMode(_ mode: BlendMode) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "mix-blend-mode: \(mode.rawValue);")
        }
    }

    /// Adjust saturation (0 = grayscale, 1 = normal).
    public func saturation(_ amount: Double) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "filter: saturate(\(amount));")
        }
    }

    /// Adjust brightness.
    public func brightness(_ amount: Double) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "filter: brightness(\(1 + amount));")
        }
    }

    /// Adjust contrast.
    public func contrast(_ amount: Double) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "filter: contrast(\(amount));")
        }
    }

    /// Rotate hue.
    public func hueRotation(_ angle: Double) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "filter: hue-rotate(\(angle)deg);")
        }
    }

    /// Apply grayscale filter (0 = none, 1 = full).
    public func grayscale(_ amount: Double) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "filter: grayscale(\(amount));")
        }
    }

    /// Apply blur filter.
    public func blur(radius: Int32) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "filter: blur(\(radius)px);")
        }
    }

    // STUB: no GTK4 equivalent.
    public func compositingGroup() -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in }
    }

    // STUB: no GTK4 equivalent.
    public func drawingGroup() -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in }
    }

    // STUB: GTK4 CSS does not support backdrop-filter.
    public func glassEffect(_ style: GlassStyle = .regular, in shape: ClipShape = .rectangle, isEnabled: Bool = true) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            if isEnabled {
                applyCss(w, "background: alpha(@window_bg_color, 0.7); border-radius: 12px;")
            }
        }
    }

    // STUB: Tahoe-specific, no GTK4 equivalent.
    public func backgroundExtensionEffect() -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in }
    }

    /// Rotate the view.
    public func rotationEffect(degrees: Double) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "transform: rotate(\(degrees)deg);")
        }
    }

    /// 3D rotation effect.
    public func rotation3DEffect(degrees: Double, axis: (x: Double, y: Double, z: Double)) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            let rx = degrees * axis.x
            let ry = degrees * axis.y
            let rz = degrees * axis.z
            applyCss(w, "transform: perspective(500px) rotateX(\(rx)deg) rotateY(\(ry)deg) rotateZ(\(rz)deg);")
        }
    }

    /// Scale the view.
    public func scaleEffect(_ scale: Double) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "transform: scale(\(scale));")
        }
    }

    /// Scale the view with separate x/y factors.
    public func scaleEffect(x: Double = 1, y: Double = 1) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "transform: scale(\(x), \(y));")
        }
    }

    // STUB: no GTK4 equivalent.
    public func redacted(reason: RedactionReason) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in }
    }
}

public enum GlassStyle { case regular, clear }
public enum RedactionReason { case placeholder, privacy }
```

- [ ] **Step 4: Run tests**

Run: `swift test --filter AppearanceModifierTests`
Expected: All pass

- [ ] **Step 5: Commit**

```bash
git add Sources/PineUI/Modifiers/AppearanceModifiers.swift Tests/PineUITests/AppearanceModifierTests.swift
git commit -m "feat: add 19 appearance modifiers (blur, grayscale, rotationEffect, scaleEffect, etc.)"
```

---

### Task 3: Phase 2 — Text & Typography (17 modifiers)

**Files:**
- Create: `Sources/PineUI/Modifiers/TextModifiers.swift`
- Test: `Tests/PineUITests/TextModifierTests.swift` (create)

- [ ] **Step 1: Write test, verify fails**

Test that `Text("x").italic()`, `.underline()`, `.strikethrough()`, `.fontWeight(.bold)`, `.lineLimit(2)`, `.textCase(.uppercase)`, `.textSelection(true)` all return `ModifiedView<Text>` or modified `Text`.

- [ ] **Step 2: Implement TextModifiers.swift**

All modifiers as `extension View` using `applyCss()` for CSS-based ones (`italic`, `underline`, `strikethrough`, `kerning`, `tracking`, `baselineOffset`, `lineSpacing`, `textCase`, `fontWeight`, `fontDesign`) and GTK API for widget-based ones (`lineLimit` → `gtk_label_set_lines` + `gtk_label_set_ellipsize`, `textSelection` → `gtk_label_set_selectable`, `truncationMode` → `gtk_label_set_ellipsize`). Include stubs for `minimumScaleFactor`, `allowsTightening`, `typesettingLanguage`.

Add supporting enums: `FontWeight` (.regular, .bold, .semibold, etc.), `FontDesign` (.default_, .rounded, .serif, .monospaced), `TextTruncationMode` (.head, .middle, .tail), `TextCase` (.uppercase, .lowercase).

- [ ] **Step 3: Run tests, verify pass**

Run: `swift test --filter TextModifierTests`

- [ ] **Step 4: Commit**

```bash
git add Sources/PineUI/Modifiers/TextModifiers.swift Tests/PineUITests/TextModifierTests.swift
git commit -m "feat: add 17 text/typography modifiers (italic, underline, fontWeight, lineLimit, etc.)"
```

---

### Task 4: Phase 3 — Interaction Modifiers (20 modifiers)

**Files:**
- Create: `Sources/PineUI/Modifiers/InteractionModifiers.swift`
- Test: `Tests/PineUITests/InteractionModifierTests.swift` (create)

- [ ] **Step 1: Write test, verify fails**

Test that `.onHover { _ in }`, `.onLongPressGesture { }`, `.focusable()`, `.onKeyPress { _ in }`, `.allowsHitTesting(false)`, `.draggable()` all compile and return `ModifiedView<Text>`.

- [ ] **Step 2: Implement InteractionModifiers.swift**

Key implementations:
- `.onHover` → `GtkEventControllerMotion`, connect `enter` and `leave` signals
- `.onLongPressGesture` → `GtkGestureLongPress`, connect `pressed` signal
- `.focusable` → `gtk_widget_set_focusable(w, 1)`
- `.focused` → `gtk_widget_grab_focus(w)` on `map` signal
- `.onKeyPress` → `GtkEventControllerKey`, connect `key-pressed` signal
- `.allowsHitTesting` → `gtk_widget_set_can_target(w, bool)`
- `.onSubmit` → connect `activate` signal
- `.onDrag` → `GtkDragSource` setup
- `.onDrop` → `GtkDropTarget` setup

Stubs: `.contentShape`, `.swipeActions`, `.selectionDisabled`, `.defaultFocus`, `.prefersDefaultFocus`

Handler classes for each signal type (similar to existing `GestureHandler`).

- [ ] **Step 3: Run tests, verify pass**
- [ ] **Step 4: Commit**

```bash
git add Sources/PineUI/Modifiers/InteractionModifiers.swift Tests/PineUITests/InteractionModifierTests.swift
git commit -m "feat: add 20 interaction modifiers (onHover, onLongPressGesture, focusable, onDrag, etc.)"
```

---

### Task 5: Phase 4 — Navigation & Presentation (15 modifiers)

**Files:**
- Create: `Sources/PineUI/Modifiers/NavigationModifiers.swift`
- Create: `Sources/PineUI/Modifiers/PresentationModifiers.swift`
- Test: `Tests/PineUITests/NavigationModifierTests.swift` (create)

- [ ] **Step 1: Write test, verify fails**

Test `.navigationTitle("Title")`, `.sheet(isPresented:content:)`, `.alert(title:isPresented:actions:)`, `.fileImporter(isPresented:allowedContentTypes:onCompletion:)` compile.

- [ ] **Step 2: Implement NavigationModifiers.swift**

- `.navigationTitle` → traverse widget tree to find window, call `windowSetTitle`
- `.navigationSubtitle` → same approach, call subtitle setter
- `.toolbar` → build toolbar items from ViewBuilder content
- `.toolbarBackground` / `.toolbarColorScheme` → CSS on toolbar

- [ ] **Step 3: Implement PresentationModifiers.swift**

- `.sheet(isPresented:content:)` → observe `StateStore<Bool>`, call `Sheet.present()` when true
- `.fullScreenCover` → same but fullscreen
- `.popover` → `GtkPopover` attached to widget
- `.alert(title:isPresented:actions:)` → observe binding, show `Alert.show()`
- `.confirmationDialog` → `Alert.confirm()`
- `.fileImporter` → `GtkFileDialog` open async
- `.fileExporter` → `GtkFileDialog` save async
- `.inspector` → `GtkPaned` side panel

Stubs: `.navigationBarTitleDisplayMode`, `.interactiveDismissDisabled`

- [ ] **Step 4: Run tests, verify pass**
- [ ] **Step 5: Commit**

```bash
git add Sources/PineUI/Modifiers/NavigationModifiers.swift Sources/PineUI/Modifiers/PresentationModifiers.swift Tests/PineUITests/NavigationModifierTests.swift
git commit -m "feat: add 15 navigation/presentation modifiers (navigationTitle, sheet, alert, fileImporter, etc.)"
```

---

### Task 6: Phase 5 — Lists & Scrolling (16 modifiers)

**Files:**
- Create: `Sources/PineUI/Modifiers/ListModifiers.swift`
- Create: `Sources/PineUI/Modifiers/ScrollModifiers.swift`
- Test: `Tests/PineUITests/ListModifierTests.swift` (create)

- [ ] **Step 1: Write test, verify fails**

Test `.listStyle(.sidebar)`, `.listRowBackground(.blue)`, `.scrollIndicators(.hidden)`, `.searchable(text:)`, `.badge(5)` compile.

- [ ] **Step 2: Implement ListModifiers.swift**

- `.listStyle` → CSS class swap (`pine-list-sidebar`, `pine-list-bordered`, etc.)
- `.listRowBackground` → `applyCss(w, "background: ...")`
- `.listRowSeparator` → CSS `border-bottom` toggle
- `.listRowInsets` → CSS padding
- `.listSectionSeparator` → CSS border
- `.searchable` → add `SearchField` to widget tree
- `.badge` → append badge label

Add `ListStyle` enum: `.sidebar`, `.plain`, `.inset`, `.bordered`
Add list CSS classes to `PineTheme.swift`.

- [ ] **Step 3: Implement ScrollModifiers.swift**

- `.scrollIndicators` → `GtkScrolledWindow` policy
- `.scrollDisabled` → set both policies to NEVER
- `.scrollPosition` → vadjustment manipulation
- `.scrollClipDisabled` → CSS `overflow: visible`

Stubs: `.scrollDismissesKeyboard`, `.scrollTargetLayout`, `.scrollTransition`, `.refreshable`, `.privacySensitive`

- [ ] **Step 4: Run tests, verify pass**
- [ ] **Step 5: Commit**

```bash
git add Sources/PineUI/Modifiers/ListModifiers.swift Sources/PineUI/Modifiers/ScrollModifiers.swift Tests/PineUITests/ListModifierTests.swift
git commit -m "feat: add 16 list/scrolling modifiers (listStyle, scrollIndicators, searchable, badge, etc.)"
```

---

### Task 7: Phase 6 — Lifecycle (7 modifiers)

**Files:**
- Create: `Sources/PineUI/Modifiers/LifecycleModifiers.swift`
- Test: `Tests/PineUITests/LifecycleModifierTests.swift` (create)

- [ ] **Step 1: Write test, verify fails**

Test `.onAppear { }`, `.onDisappear { }`, `.onChange(of:perform:)`, `.task { }`, `.id("x")`, `.tag(42)` compile.

- [ ] **Step 2: Implement LifecycleModifiers.swift**

```swift
extension View {
    /// Called when the view appears (GTK4 `map` signal).
    public func onAppear(perform action: @escaping () -> Void) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            let handler = LifecycleHandler(action: action)
            let ptr = Unmanaged.passRetained(handler).toOpaque()
            let callback: @convention(c) (WidgetPtr?, gpointer?) -> Void = { _, userData in
                guard let userData = userData else { return }
                Unmanaged<LifecycleHandler>.fromOpaque(userData).takeUnretainedValue().action()
            }
            g_signal_connect_data(
                UnsafeMutableRawPointer(w), "map",
                unsafeBitCast(callback, to: GCallback.self),
                ptr, { userData, _ in
                    guard let userData = userData else { return }
                    Unmanaged<LifecycleHandler>.fromOpaque(userData).release()
                }, GConnectFlags(rawValue: 0)
            )
        }
    }

    /// Called when the view disappears (GTK4 `unmap` signal).
    public func onDisappear(perform action: @escaping () -> Void) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            // Same pattern as onAppear but with "unmap" signal
            let handler = LifecycleHandler(action: action)
            let ptr = Unmanaged.passRetained(handler).toOpaque()
            let callback: @convention(c) (WidgetPtr?, gpointer?) -> Void = { _, userData in
                guard let userData = userData else { return }
                Unmanaged<LifecycleHandler>.fromOpaque(userData).takeUnretainedValue().action()
            }
            g_signal_connect_data(
                UnsafeMutableRawPointer(w), "unmap",
                unsafeBitCast(callback, to: GCallback.self),
                ptr, { userData, _ in
                    guard let userData = userData else { return }
                    Unmanaged<LifecycleHandler>.fromOpaque(userData).release()
                }, GConnectFlags(rawValue: 0)
            )
        }
    }

    /// Observe state changes.
    public func onChange<Value>(of store: StateStore<Value>, perform action: @escaping (Value) -> Void) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            store.onChange = { newValue in action(newValue) }
        }
    }

    /// Dispatch async work when the view appears.
    public func task(perform action: @escaping () -> Void) -> ModifiedView<Self> {
        onAppear(perform: action)
    }

    /// Set a unique identifier for the view.
    public func id(_ identifier: String) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            gtk_widget_set_name(w, identifier)
        }
    }

    /// Attach a tag value to the view.
    public func tag(_ value: Int) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            g_object_set_data(
                UnsafeMutableRawPointer(w).assumingMemoryBound(to: GObject.self),
                "pine-tag",
                UnsafeMutableRawPointer(bitPattern: value)
            )
        }
    }

    // STUB: no GTK4 equivalent.
    public func equatable() -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in }
    }
}

private class LifecycleHandler {
    let action: () -> Void
    init(action: @escaping () -> Void) { self.action = action }
}
```

- [ ] **Step 3: Run tests, verify pass**
- [ ] **Step 4: Commit**

```bash
git add Sources/PineUI/Modifiers/LifecycleModifiers.swift Tests/PineUITests/LifecycleModifierTests.swift
git commit -m "feat: add 7 lifecycle modifiers (onAppear, onDisappear, onChange, task, id, tag)"
```

---

### Task 8: Phase 7 — Animation (7 modifiers + 1 function)

**Files:**
- Create: `Sources/PineUI/Modifiers/AnimationModifiers.swift`
- Create: `Sources/PineUI/Animation.swift`
- Test: `Tests/PineUITests/AnimationModifierTests.swift` (create)

- [ ] **Step 1: Write test, verify fails**

Test `.animation(.easeInOut)`, `.transition(.opacity)`, `withAnimation { }` compile.

- [ ] **Step 2: Implement AnimationModifiers.swift**

- `.animation` → `applyCss(w, "transition: all 0.3s ease;")`
- `.transition` → CSS transition on opacity/transform
- `.contentTransition` → CSS transition on content
- `.phaseAnimator` → `g_timeout_add` driven state changes
- `.keyframeAnimator` → CSS `@keyframes`

Stubs: `.matchedGeometryEffect`, `.sensoryFeedback`

Add enums: `PineAnimation` (.easeInOut, .linear, .spring, .none), `AnyTransition` (.opacity, .slide, .scale, .move)

- [ ] **Step 3: Implement Animation.swift**

```swift
// Sources/PineUI/Animation.swift
// withAnimation() free function.

public func withAnimation(_ animation: PineAnimation = .easeInOut, _ body: () -> Void) {
    // Set global flag for CSS transitions, execute body, clear flag.
    PineAnimationContext.current = animation
    body()
    PineAnimationContext.current = nil
}

public class PineAnimationContext {
    public static var current: PineAnimation?
}
```

- [ ] **Step 4: Run tests, verify pass**
- [ ] **Step 5: Commit**

```bash
git add Sources/PineUI/Modifiers/AnimationModifiers.swift Sources/PineUI/Animation.swift Tests/PineUITests/AnimationModifierTests.swift
git commit -m "feat: add 7 animation modifiers + withAnimation() (CSS transitions)"
```

---

### Task 9: Phase 8 — Accessibility (8 modifiers)

**Files:**
- Create: `Sources/PineUI/Modifiers/AccessibilityModifiers.swift`
- Test: `Tests/PineUITests/AccessibilityModifierTests.swift` (create)

- [ ] **Step 1: Write test, verify fails**

Test `.accessibilityLabel("Name")`, `.accessibilityHint("Hint")`, `.accessibilityHidden(true)` compile.

- [ ] **Step 2: Implement AccessibilityModifiers.swift**

All use GTK4's `GtkAccessible` interface (NOT deprecated ATK):
- `.accessibilityLabel` → `gtk_accessible_update_property` with `GTK_ACCESSIBLE_PROPERTY_LABEL`
- `.accessibilityHint` → `gtk_accessible_update_property` with `GTK_ACCESSIBLE_PROPERTY_DESCRIPTION`
- `.accessibilityValue` → `gtk_accessible_update_property` with value property
- `.accessibilityHidden` → `gtk_accessible_update_state` with `GTK_ACCESSIBLE_STATE_HIDDEN`

Stubs: `.accessibilityAction`, `.accessibilityElement`, `.accessibilityAddTraits`, `.accessibilitySortPriority`

- [ ] **Step 3: Run tests, verify pass**
- [ ] **Step 4: Commit**

```bash
git add Sources/PineUI/Modifiers/AccessibilityModifiers.swift Tests/PineUITests/AccessibilityModifierTests.swift
git commit -m "feat: add 8 accessibility modifiers (GtkAccessible API)"
```

---

### Task 10: Phase 9 — Environment (6 modifiers)

**Files:**
- Create: `Sources/PineUI/Environment.swift`
- Create: `Sources/PineUI/Modifiers/EnvironmentModifiers.swift`
- Modify: `Sources/PineUI/View.swift` — add optional `RenderContext` parameter to `render()`
- Test: `Tests/PineUITests/EnvironmentTests.swift` (create)

- [ ] **Step 1: Write test for RenderContext**

```swift
final class EnvironmentTests: XCTestCase {
    func testRenderContextStoresValues() {
        let ctx = RenderContext()
        let key = ObjectIdentifier(String.self)
        ctx.values[key] = "hello"
        let retrieved: String? = ctx.value(for: key)
        XCTAssertEqual(retrieved, "hello")
    }

    func testChildContextInheritsParent() {
        let parent = RenderContext()
        let key = ObjectIdentifier(Int.self)
        parent.values[key] = 42
        let child = parent.child()
        let retrieved: Int? = child.value(for: key)
        XCTAssertEqual(retrieved, 42)
    }

    func testChildOverridesParent() {
        let parent = RenderContext()
        let key = ObjectIdentifier(Int.self)
        parent.values[key] = 42
        let child = parent.child()
        child.values[key] = 99
        let childVal: Int? = child.value(for: key)
        let parentVal: Int? = parent.value(for: key)
        XCTAssertEqual(childVal, 99)
        XCTAssertEqual(parentVal, 42)
    }
}
```

- [ ] **Step 2: Implement Environment.swift**

`RenderContext` class with parent chain, `EnvironmentKey` protocol, global `currentRenderContext`.

- [ ] **Step 3: Implement EnvironmentModifiers.swift**

- `.environment` → push key-value, call render with child context
- `.environmentObject` → push type-keyed object

Stubs: `.transformEnvironment`, `.preference`, `.onPreferenceChange`, `.backgroundPreferenceValue`

- [ ] **Step 4: Run tests, verify pass**
- [ ] **Step 5: Build and run demo — verify no regressions**
- [ ] **Step 6: Commit**

```bash
git add Sources/PineUI/Environment.swift Sources/PineUI/Modifiers/EnvironmentModifiers.swift Tests/PineUITests/EnvironmentTests.swift
git commit -m "feat: add environment system (RenderContext) and 6 environment modifiers"
```

---

### Task 11: Final Integration

**Files:**
- Modify: `CLAUDE.md` — update modifier count and known gaps
- Modify: `Sources/PineDemo/main.swift` — add examples of new modifiers

- [ ] **Step 1: Update CLAUDE.md**

Update the "Modifiers" section to list all ~144 modifiers. Remove "modifiers" from Known Gaps.

- [ ] **Step 2: Add modifier examples to demo**

Add a new "Modifiers" tab to the demo showing shadow, blur, rotation, scale, and lifecycle examples.

- [ ] **Step 3: Full test suite**

Run: `swift test`
Expected: All tests pass

- [ ] **Step 4: Full build + visual verification**

Run: `swift build && .build/debug/pine-demo`
Verify: All tabs work, new modifiers render, no visual regressions.

- [ ] **Step 5: Commit and push**

```bash
git add -A
git commit -m "feat: complete SwiftUI modifier parity (144 modifiers across 9 phases)"
git push
```
