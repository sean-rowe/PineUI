// GlibFlagEnumCompat.swift — compatibility constants for glib flag enums whose
// C global names Swift no longer imports.
//
// glib marks bitfield enums with `G_GNUC_FLAG_ENUM` (`__attribute__((flag_enum))`).
// Under glib 2.88, Swift's ClangImporter imports such enums as OptionSet structs
// and stops surfacing the C enumerator *global* names (e.g. G_APPLICATION_DEFAULT_FLAGS,
// G_FILE_TEST_EXISTS). Older glib headers lacked the attribute, so these names
// imported directly and the PineOS components reference them unqualified.
//
// This file re-declares the handful of flag-enum constants the components use as
// typed OptionSet constants. Every PineOS component imports PineUI, so these
// become visible at all call sites without editing any of them. Each value
// mirrors the corresponding glib header exactly.
//
// Add a constant here when a new build surfaces "cannot find 'G_*' in scope" for
// a glib flag enum. Remove the file only if the importer regains the global names.

import CGTK4

// MARK: - GApplicationFlags (gio/gioenums.h)

/// No application flags — the default. Replaces the Swift-invisible
/// `G_APPLICATION_DEFAULT_FLAGS` (value `0`). Pass to `gtk_application_new` when
/// the app needs no special GApplication behavior.
public let G_APPLICATION_DEFAULT_FLAGS = GApplicationFlags(rawValue: 0)

/// Legacy spelling of the no-flags default (value `0`), deprecated in glib 2.74
/// in favor of `G_APPLICATION_DEFAULT_FLAGS`. Kept for the one call site using it.
public let G_APPLICATION_FLAGS_NONE = GApplicationFlags(rawValue: 0)

/// Do not contend for the single primary instance over D-Bus (`1 << 5`). Used by
/// bars/daemons that must allow re-launch after pkill without waiting for the bus
/// name to release.
public let G_APPLICATION_NON_UNIQUE = GApplicationFlags(rawValue: 1 << 5)

/// The application handles opening files (`1 << 2`). Set when the app registers an
/// `open` handler for file arguments passed on the command line.
public let G_APPLICATION_HANDLES_OPEN = GApplicationFlags(rawValue: 1 << 2)

// MARK: - GBusNameOwnerFlags (gio/gioenums.h)

/// No special bus-name-owning behavior (`0`). Pass to `g_bus_own_name` when the
/// service does not allow replacement and should queue for the name normally.
public let G_BUS_NAME_OWNER_FLAGS_NONE = GBusNameOwnerFlags(rawValue: 0)

// MARK: - GFileTest (glib/gfileutils.h)

/// Test whether a path exists (`1 << 4`). Pass to `g_file_test` to check presence
/// of a file or directory regardless of type.
public let G_FILE_TEST_EXISTS = GFileTest(rawValue: 1 << 4)
