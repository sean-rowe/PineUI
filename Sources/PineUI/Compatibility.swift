// Compatibility.swift — macOS SwiftUI API aliases.
//
// Makes Apple's API names work transparently in PineUI.
// A developer can use either the Apple name or the PineUI name.

import CGTK4

// MARK: - SF Symbols → Adwaita/Theme icon mapping

/// Maps Apple's SF Symbol names to GTK/Adwaita icon names.
/// When a developer writes Image(systemName: "folder.fill"), PineUI
/// translates it to "folder-symbolic" for GTK's icon theme.
private let sfSymbolMap: [String: String] = [
    // Folders & Documents
    "folder": "folder-symbolic",
    "folder.fill": "folder-symbolic",
    "doc": "document-new-symbolic",
    "doc.text": "document-edit-symbolic",
    "doc.text.fill": "document-edit-symbolic",
    "doc.richtext": "document-edit-symbolic",
    "doc.plaintext": "document-properties-symbolic",
    "note.text": "document-edit-symbolic",
    "square.and.pencil": "document-edit-symbolic",
    "pencil": "document-edit-symbolic",

    // Navigation & Layout
    "sidebar.left": "view-dual-symbolic",
    "sidebar.right": "view-dual-symbolic",
    "rectangle.split.3x1": "view-grid-symbolic",
    "square.grid.2x2": "view-grid-symbolic",
    "square.grid.3x2": "view-grid-symbolic",
    "list.bullet": "view-list-symbolic",
    "list.dash": "view-list-symbolic",
    "line.3.horizontal": "view-list-symbolic",

    // Actions
    "plus": "list-add-symbolic",
    "plus.circle": "list-add-symbolic",
    "plus.circle.fill": "list-add-symbolic",
    "minus": "list-remove-symbolic",
    "minus.circle": "list-remove-symbolic",
    "xmark": "window-close-symbolic",
    "xmark.circle": "window-close-symbolic",
    "checkmark": "emblem-ok-symbolic",
    "checkmark.circle": "emblem-ok-symbolic",
    "checkmark.circle.fill": "object-select-symbolic",

    // Communication
    "envelope": "mail-unread-symbolic",
    "envelope.fill": "mail-unread-symbolic",
    "paperplane": "mail-send-symbolic",
    "paperplane.fill": "mail-send-symbolic",
    "bubble.left": "user-available-symbolic",
    "bubble.left.fill": "user-available-symbolic",
    "phone": "call-start-symbolic",
    "video": "camera-video-symbolic",
    "video.fill": "camera-video-symbolic",

    // Media & Playback
    "play": "media-playback-start-symbolic",
    "play.fill": "media-playback-start-symbolic",
    "pause": "media-playback-pause-symbolic",
    "pause.fill": "media-playback-pause-symbolic",
    "stop": "media-playback-stop-symbolic",
    "stop.fill": "media-playback-stop-symbolic",
    "forward": "media-seek-forward-symbolic",
    "backward": "media-seek-backward-symbolic",
    "speaker.wave.2": "audio-volume-medium-symbolic",
    "speaker.wave.2.fill": "audio-volume-medium-symbolic",
    "speaker.slash": "audio-volume-muted-symbolic",
    "music.note": "audio-x-generic-symbolic",

    // People
    "person": "avatar-default-symbolic",
    "person.fill": "avatar-default-symbolic",
    "person.circle": "avatar-default-symbolic",
    "person.2": "system-users-symbolic",
    "person.2.fill": "system-users-symbolic",

    // System & Settings
    "gear": "emblem-system-symbolic",
    "gearshape": "emblem-system-symbolic",
    "gearshape.fill": "emblem-system-symbolic",
    "slider.horizontal.3": "emblem-system-symbolic",
    "wrench": "preferences-system-symbolic",
    "wrench.fill": "preferences-system-symbolic",
    "hammer": "applications-utilities-symbolic",
    "terminal": "utilities-terminal-symbolic",

    // Status & Alerts
    "exclamationmark.triangle": "dialog-warning-symbolic",
    "exclamationmark.triangle.fill": "dialog-warning-symbolic",
    "info.circle": "dialog-information-symbolic",
    "info.circle.fill": "dialog-information-symbolic",
    "questionmark.circle": "dialog-question-symbolic",
    "bell": "preferences-system-notifications-symbolic",
    "bell.fill": "preferences-system-notifications-symbolic",

    // Favorites & Rating
    "star": "starred-symbolic",
    "star.fill": "starred-symbolic",
    "heart": "emblem-favorite-symbolic",
    "heart.fill": "emblem-favorite-symbolic",
    "bookmark": "user-bookmarks-symbolic",
    "bookmark.fill": "user-bookmarks-symbolic",
    "flag": "emblem-important-symbolic",
    "flag.fill": "emblem-important-symbolic",

    // Search & Find
    "magnifyingglass": "system-search-symbolic",

    // Calendar & Time
    "calendar": "x-office-calendar-symbolic",
    "clock": "preferences-system-time-symbolic",
    "clock.fill": "preferences-system-time-symbolic",
    "timer": "preferences-system-time-symbolic",

    // Network & Cloud
    "wifi": "network-wireless-symbolic",
    "cloud": "weather-overcast-symbolic",
    "cloud.fill": "weather-overcast-symbolic",
    "globe": "applications-internet-symbolic",
    "link": "insert-link-symbolic",

    // Files & Storage
    "trash": "user-trash-symbolic",
    "trash.fill": "user-trash-symbolic",
    "archivebox": "package-x-generic-symbolic",
    "archivebox.fill": "package-x-generic-symbolic",
    "tray": "mail-inbox-symbolic",
    "tray.fill": "mail-inbox-symbolic",
    "externaldrive": "drive-harddisk-symbolic",

    // Editing
    "scissors": "edit-cut-symbolic",
    "doc.on.clipboard": "edit-paste-symbolic",
    "arrow.uturn.backward": "edit-undo-symbolic",
    "arrow.uturn.forward": "edit-redo-symbolic",
    "bold": "format-text-bold-symbolic",
    "italic": "format-text-italic-symbolic",
    "underline": "format-text-underline-symbolic",

    // Arrows & Navigation
    "chevron.right": "go-next-symbolic",
    "chevron.left": "go-previous-symbolic",
    "chevron.up": "go-up-symbolic",
    "chevron.down": "go-down-symbolic",
    "arrow.right": "go-next-symbolic",
    "arrow.left": "go-previous-symbolic",
    "arrow.up": "go-up-symbolic",
    "arrow.down": "go-down-symbolic",
    "house": "go-home-symbolic",
    "house.fill": "go-home-symbolic",

    // Sharing
    "square.and.arrow.up": "send-to-symbolic",
    "square.and.arrow.down": "document-save-symbolic",

    // Photos & Images
    "photo": "image-x-generic-symbolic",
    "photo.fill": "image-x-generic-symbolic",
    "camera": "camera-photo-symbolic",
    "camera.fill": "camera-photo-symbolic",

    // Security
    "lock": "changes-prevent-symbolic",
    "lock.fill": "changes-prevent-symbolic",
    "lock.open": "changes-allow-symbolic",
    "key": "dialog-password-symbolic",
    "key.fill": "dialog-password-symbolic",
    "shield": "security-high-symbolic",
    "shield.fill": "security-high-symbolic",

    // Power
    "power": "system-shutdown-symbolic",
    "bolt": "battery-full-charging-symbolic",
    "bolt.fill": "battery-full-charging-symbolic",
    "battery.100": "battery-full-symbolic",
    "battery.25": "battery-low-symbolic",

    // Display
    "display": "video-display-symbolic",
    "desktopcomputer": "computer-symbolic",
    "laptopcomputer": "computer-symbolic",
    "keyboard": "input-keyboard-symbolic",
    "printer": "printer-symbolic",
    "printer.fill": "printer-symbolic",

    // Misc
    //
    // Where Adwaita lacks a 1:1 icon (no gavel, no heart-square, no tag,
    // no person.crop.rectangle), pick the closest semantic neighbour
    // rather than leave the mapping pointing at a name that GTK4 will
    // fall back to image-missing for.
    "tag": "bookmark-new-symbolic",
    "tag.fill": "bookmark-new-symbolic",
    "pin": "view-pin-symbolic",
    "pin.fill": "view-pin-symbolic",
    "paintbrush": "applications-graphics-symbolic",
    "paintbrush.fill": "applications-graphics-symbolic",
    "eye": "view-reveal-symbolic",
    "eye.fill": "view-reveal-symbolic",
    "eye.slash": "view-conceal-symbolic",
    "chart.bar": "org.gnome.PowerStats-symbolic",
    "chart.bar.fill": "org.gnome.PowerStats-symbolic",
    "map": "find-location-symbolic",
    "map.fill": "find-location-symbolic",

    // Time / scheduling — FluidTime, calendar-recurring, "in progress".
    // (clock / clock.fill / timer / alarm already mapped earlier;
    //  only adding the arrow-circlepath variants here.)
    "clock.arrow.circlepath": "preferences-system-time-symbolic",
    "appointment.soon": "appointment-soon-symbolic",

    // Code / development — Code Review, source files.
    // (terminal / terminal.fill already mapped earlier.)
    "chevron.left.forwardslash.chevron.right": "utilities-terminal-symbolic",
    "curlybraces": "utilities-terminal-symbolic",
    "ladybug": "application-x-executable-symbolic",
    "ladybug.fill": "application-x-executable-symbolic",

    // Warnings / blockers / stop indicators.
    // (exclamationmark.triangle variants already mapped earlier.)
    "exclamationmark.octagon": "process-stop-symbolic",
    "exclamationmark.octagon.fill": "process-stop-symbolic",
    "stop.circle": "process-stop-symbolic",
    "stop.circle.fill": "process-stop-symbolic",

    // Decisions / records / ADR / log.
    //
    // Adwaita has no gavel. Decisions get written down, so the
    // text-editor icon is the closest semantic match.
    "gavel": "accessories-text-editor-symbolic",
    "doc.append": "x-office-document-symbolic",
    "books.vertical": "folder-documents-symbolic",
    "books.vertical.fill": "folder-documents-symbolic",

    // Wellness / health / mood.
    //
    // No heart-square in Adwaita; dialog-information matches the
    // "health info" intent. (heart / heart.fill already mapped earlier
    // to emblem-favorite-symbolic.)
    "heart.text.square": "dialog-information-symbolic",
    "waveform.path.ecg": "dialog-information-symbolic",

    // Invoicing / accounting — "doc.text.below.ecg" is Apple's SF Symbol
    // for billing/invoice. Closest GNOME concept is the calculator.
    "doc.text.below.ecg": "accessories-calculator-symbolic",
    "creditcard": "accessories-calculator-symbolic",
    "creditcard.fill": "accessories-calculator-symbolic",
    "dollarsign.circle": "accessories-calculator-symbolic",

    // People / contacts / career profiles.
    "person.crop.rectangle": "system-users-symbolic",
    "person.crop.rectangle.fill": "system-users-symbolic",
    "person.crop.square": "system-users-symbolic",
    "person.text.rectangle": "user-info-symbolic",
    "person.crop.circle.badge": "user-info-symbolic",
    "rectangle.stack.person.crop": "system-users-symbolic",
    "graduationcap": "system-users-symbolic",
    "graduationcap.fill": "system-users-symbolic",
]

/// Resolve an SF Symbol name to a GTK icon name.
/// Falls through to the original name if no mapping exists (allows
/// using GTK icon names directly too).
public func resolveSFSymbol(_ name: String) -> String {
    sfSymbolMap[name] ?? name
}

// MARK: - SF Symbol resolution is built into Image and Label initializers.
// See Controls.swift — Image(systemName:) and Label(_:systemImage:)
// both call resolveSFSymbol() automatically. A macOS developer can write
// Image(systemName: "folder.fill") and it maps to "folder-symbolic".
