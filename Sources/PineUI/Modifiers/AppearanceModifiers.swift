// AppearanceModifiers.swift — SwiftUI-compatible appearance modifiers for PineUI.
//
// Implements 19 appearance modifiers:
//   tint, accentColor, preferredColorScheme, blendMode, saturation, brightness,
//   contrast, hueRotation, grayscale, blur, compositingGroup, drawingGroup,
//   glassEffect, backgroundExtensionEffect, rotationEffect, rotation3DEffect,
//   scaleEffect (two overloads), redacted

import CGTK4

// MARK: - Supporting Enums

/// Blend modes matching SwiftUI's BlendMode, mapped to CSS mix-blend-mode values.
public enum BlendMode: String {
    case normal        = "normal"
    case multiply      = "multiply"
    case screen        = "screen"
    case overlay       = "overlay"
    case darken        = "darken"
    case lighten       = "lighten"
    case colorDodge    = "color-dodge"
    case colorBurn     = "color-burn"
    case hardLight     = "hard-light"
    case softLight     = "soft-light"
    case difference    = "difference"
    case exclusion     = "exclusion"
}

/// Color scheme preference matching SwiftUI's ColorScheme.
public enum ColorScheme {
    case light
    case dark
}

/// Glass effect style for glassEffect modifier.
public enum GlassStyle {
    case regular
    case clear
}

/// Reasons for redacting content, matching SwiftUI's RedactionReasons.
public enum RedactionReason {
    case placeholder
    case privacy
}

// MARK: - Appearance Modifiers

extension View {

    // MARK: 1. tint

    /// Sets the tint (foreground accent) color via CSS `color`.
    public func tint(_ color: Color) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "color: \(color.cssValue);")
        }
    }

    // MARK: 2. accentColor

    /// Sets the accent color — alias for tint(_:).
    public func accentColor(_ color: Color) -> ModifiedView<Self> {
        tint(color)
    }

    // MARK: 3. preferredColorScheme

    /// Sets a preferred color scheme for the entire app.
    // STUB: no per-widget GTK4 equivalent — color scheme is a session-level setting
    // managed by the display manager (e.g., via Settings portal or GtkSettings).
    public func preferredColorScheme(_ scheme: ColorScheme?) -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: no GTK4 equivalent — affects whole application, not a single widget.
        }
    }

    // MARK: 4. blendMode

    /// Sets the blend mode for compositing this view via CSS `mix-blend-mode`.
    public func blendMode(_ mode: BlendMode) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "mix-blend-mode: \(mode.rawValue);")
        }
    }

    // MARK: 5. saturation

    /// Adjusts the color saturation via CSS `filter: saturate()`.
    public func saturation(_ amount: Double) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "filter: saturate(\(amount));")
        }
    }

    // MARK: 6. brightness

    /// Adjusts the brightness via CSS `filter: brightness(1 + amount)`.
    public func brightness(_ amount: Double) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            let value = 1.0 + amount
            applyCss(w, "filter: brightness(\(value));")
        }
    }

    // MARK: 7. contrast

    /// Adjusts the contrast via CSS `filter: contrast()`.
    public func contrast(_ amount: Double) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "filter: contrast(\(amount));")
        }
    }

    // MARK: 8. hueRotation

    /// Rotates the hue of the view by the specified degrees via CSS `filter: hue-rotate()`.
    public func hueRotation(_ degrees: Double) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "filter: hue-rotate(\(degrees)deg);")
        }
    }

    // MARK: 9. grayscale

    /// Applies a grayscale effect via CSS `filter: grayscale()`.
    public func grayscale(_ amount: Double) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "filter: grayscale(\(amount));")
        }
    }

    // MARK: 10. blur

    /// Applies a Gaussian blur via CSS `filter: blur()`.
    public func blur(radius: Int32) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "filter: blur(\(radius)px);")
        }
    }

    // MARK: 11. compositingGroup

    /// Groups this view for compositing purposes.
    // STUB: no GTK4 equivalent — compositing groups are a rendering concept not
    // expressible per-widget in GTK4's CSS model.
    public func compositingGroup() -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: no GTK4 equivalent
        }
    }

    // MARK: 12. drawingGroup

    /// Renders this view as a rasterized image before compositing.
    // STUB: no GTK4 equivalent — off-screen rendering groups are not available
    // via GTK4's widget CSS.
    public func drawingGroup() -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: no GTK4 equivalent
        }
    }

    // MARK: 13. glassEffect

    /// Applies a glass (frosted/translucent) material effect.
    ///
    /// Approximated via CSS backdrop-filter and semi-transparent background.
    /// The `in:` shape and `isEnabled:` flag are respected for enable/disable;
    /// true glass compositing requires a compositor supporting CSS backdrop-filter.
    public func glassEffect(
        _ style: GlassStyle = .regular,
        in shape: ClipShape = .rectangle,
        isEnabled: Bool = true
    ) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            guard isEnabled else { return }
            let opacity: String = style == .clear ? "0.5" : "0.75"
            let blur = style == .clear ? "20px" : "12px"
            let shapeCSS: String
            switch shape {
            case .circle:
                shapeCSS = "border-radius: 50%;"
            case .capsule:
                shapeCSS = "border-radius: 9999px;"
            case .roundedRectangle(let radius):
                shapeCSS = "border-radius: \(radius)px;"
            case .rectangle:
                shapeCSS = "border-radius: 0;"
            }
            applyCss(
                w,
                "background: rgba(255, 255, 255, \(opacity)); backdrop-filter: blur(\(blur)); \(shapeCSS)"
            )
        }
    }

    // MARK: 14. backgroundExtensionEffect

    /// Extends the background of the view beyond its bounds.
    // STUB: no GTK4 equivalent — background extension effects are not available
    // in GTK4's CSS model.
    public func backgroundExtensionEffect() -> ModifiedView<Self> {
        ModifiedView(content: self) { _ in
            // STUB: no GTK4 equivalent
        }
    }

    // MARK: 15. rotationEffect

    /// Rotates the view by the specified angle via CSS `transform: rotate()`.
    public func rotationEffect(degrees: Double) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "transform: rotate(\(degrees)deg);")
        }
    }

    // MARK: 16. rotation3DEffect

    /// Applies a 3D rotation via CSS `transform: perspective() rotate*()`.
    ///
    /// The axis tuple (x, y, z) selects which axis to rotate around; the
    /// dominant non-zero component determines the CSS rotate function used.
    public func rotation3DEffect(
        degrees: Double,
        axis: (x: Double, y: Double, z: Double)
    ) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            let absX = abs(axis.x), absY = abs(axis.y), absZ = abs(axis.z)
            let rotateCSS: String
            if absX >= absY && absX >= absZ {
                rotateCSS = "rotateX(\(degrees)deg)"
            } else if absY >= absX && absY >= absZ {
                rotateCSS = "rotateY(\(degrees)deg)"
            } else {
                rotateCSS = "rotateZ(\(degrees)deg)"
            }
            applyCss(w, "transform: perspective(800px) \(rotateCSS);")
        }
    }

    // MARK: 17. scaleEffect (uniform)

    /// Scales the view uniformly via CSS `transform: scale()`.
    public func scaleEffect(_ scale: Double) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "transform: scale(\(scale));")
        }
    }

    // MARK: 18. scaleEffect (x:y:)

    /// Scales the view independently on each axis via CSS `transform: scale(x, y)`.
    public func scaleEffect(x: Double, y: Double) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            applyCss(w, "transform: scale(\(x), \(y));")
        }
    }

    // MARK: 19. redacted

    /// Applies a redaction effect to this view.
    // STUB: no GTK4 equivalent — SwiftUI redaction is a rendering-pass concept;
    // approximated with a heavy blur to obscure content.
    public func redacted(reason: RedactionReason) -> ModifiedView<Self> {
        ModifiedView(content: self) { w in
            switch reason {
            case .placeholder:
                // Placeholder: dim the view to suggest loading content.
                applyCss(w, "opacity: 0.3; filter: blur(4px);")
            case .privacy:
                // Privacy: heavily blur to obscure private data.
                applyCss(w, "filter: blur(8px);")
            }
        }
    }
}
