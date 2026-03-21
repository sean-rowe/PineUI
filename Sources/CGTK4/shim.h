// PineUI GTK4 shim — single header that pulls in everything Swift needs.
//
// Swift's ClangImporter uses this to discover all GTK4 types, functions,
// and constants. The order matters: GLib → GObject → GIO → GDK → GTK.

#pragma once

#include <gtk/gtk.h>
#include <gdk/gdk.h>
#include <glib.h>
#include <glib-object.h>
#include <gio/gio.h>
#include <cairo/cairo.h>
#include <pango/pango.h>
#include <pango/pangocairo.h>

// ═══════════════════════════════════════════════════════════════════
// Non-variadic wrappers for GTK functions that Swift can't call
// ═══════════════════════════════════════════════════════════════════

// MARK: - Accessibility (gtk_accessible_update_property is variadic)

/// Set a single string accessibility property on a widget.
static inline void pine_accessible_set_label(GtkWidget *widget, const char *label) {
    gtk_accessible_update_property(
        GTK_ACCESSIBLE(widget),
        GTK_ACCESSIBLE_PROPERTY_LABEL, label,
        -1
    );
}

/// Set the accessibility description (hint) on a widget.
static inline void pine_accessible_set_description(GtkWidget *widget, const char *description) {
    gtk_accessible_update_property(
        GTK_ACCESSIBLE(widget),
        GTK_ACCESSIBLE_PROPERTY_DESCRIPTION, description,
        -1
    );
}

/// Set the accessibility value text on a widget.
static inline void pine_accessible_set_value_text(GtkWidget *widget, const char *value) {
    gtk_accessible_update_property(
        GTK_ACCESSIBLE(widget),
        GTK_ACCESSIBLE_PROPERTY_VALUE_TEXT, value,
        -1
    );
}

/// Set the accessibility role description on a widget.
static inline void pine_accessible_set_role_description(GtkWidget *widget, const char *role_desc) {
    gtk_accessible_update_property(
        GTK_ACCESSIBLE(widget),
        GTK_ACCESSIBLE_PROPERTY_ROLE_DESCRIPTION, role_desc,
        -1
    );
}

// MARK: - Accessibility state (gtk_accessible_update_state is variadic)

/// Set the hidden state for accessibility.
static inline void pine_accessible_set_hidden(GtkWidget *widget, gboolean hidden) {
    gtk_accessible_update_state(
        GTK_ACCESSIBLE(widget),
        GTK_ACCESSIBLE_STATE_HIDDEN, hidden,
        -1
    );
}

// MARK: - GObject property setting (g_object_set is variadic)

/// Set the "button" property on a GtkGestureSingle (for right-click context menus).
/// Accepts void* because Swift can't see GtkGestureSingle as a typed pointer.
static inline void pine_gesture_single_set_button(void *gesture, guint button) {
    g_object_set(G_OBJECT(gesture), "button", button, NULL);
}

/// Set gtk-application-prefer-dark-theme on GtkSettings.
static inline void pine_settings_set_dark_theme(GtkSettings *settings, gboolean dark) {
    g_object_set(G_OBJECT(settings), "gtk-application-prefer-dark-theme", dark, NULL);
}

// MARK: - Drag-and-drop helpers (GValue cannot be constructed from Swift macros)

/// Create a GdkContentProvider that carries a UTF-8 string.
/// Callers must g_object_unref() the returned pointer when done.
static inline GdkContentProvider *pine_content_provider_for_string(const char *str) {
    GValue value = G_VALUE_INIT;
    g_value_init(&value, G_TYPE_STRING);
    g_value_set_string(&value, str);
    GdkContentProvider *provider = gdk_content_provider_new_for_value(&value);
    g_value_unset(&value);
    return provider;
}

/// Extract a UTF-8 string from a GValue retrieved from a GtkDropTarget.
/// Returns NULL if the value does not hold a string.
/// The returned string is owned by the GValue — do not free it.
static inline const char *pine_gvalue_get_string(const GValue *value) {
    if (!G_VALUE_HOLDS_STRING(value)) return NULL;
    return g_value_get_string(value);
}

/// The GType integer for G_TYPE_STRING (= G_TYPE_MAKE_FUNDAMENTAL(16) = 64).
/// Swift cannot evaluate the G_TYPE_MAKE_FUNDAMENTAL macro at compile time.
static inline GType pine_g_type_string(void) {
    return G_TYPE_STRING;
}
