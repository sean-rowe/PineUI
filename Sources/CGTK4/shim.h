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
