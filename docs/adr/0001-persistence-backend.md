# 0001 — Persistence backend

- Status: Accepted, with open verification items (see "Not verified")
- Date: 2026-11-13
- Evidence: [Spike A results](../spikes/a-persistence-results.md), code in `spikes/isar_spike`

## Context

Nokho-Flow stores collections, requests, environments, flows, run history and response bodies locally, on macOS, Windows, Linux, iOS, Android and web. The planned stack named Isar Community. Before building on it we tested `isar_community` 3.4.1 with Flutter 3.44.6.

What Spike A found:

| Area | Result |
|---|---|
| macOS, 10,000 records | All checks pass. Bulk write 66 ms, read all 37–39 ms, one small write transaction about 5 ms (debug build) |
| Android, physical phone (TECNO CN7c, Android 16) and emulator (API 35) | All checks pass. On the phone: bulk write 388 ms, one `uuid` lookup about 1.1 ms, one small write about 7 ms |
| Web | **Does not compile.** Generated 64-bit schema IDs break `dart2js`; the native bindings need `dart:ffi`. The package has no web implementation and no newer release line |
| Second isolate | Works. Each isolate opens its own instance; writes reach the other isolate's watchers |
| One object ≥ 16 MB | **Silently truncated.** 20 MiB in, 4 MiB out, no error |
| 20 MB as 1 MB chunks | Intact |
| Schema upgrade | Adding fields and indexes works. A rename without `@Name`, or a type change, **silently loses** the old values. Dart default initialisers are not applied to old rows |
| Schema downgrade | An older schema opens a newer database without error and **erases the fields it does not know** |

## Decision

1. **Native platforms use Isar Community** as the storage backend.
2. **Web keeps data in memory** and moves it in and out through import/export. Saved storage on web is deferred (PLAN.md §3.4.1, §4.1).
3. **The app depends only on repository interfaces** in `nokho_storage`. No Isar type appears in their signatures. The Isar implementation is reached through a conditional import so web builds never compile it. An in-memory implementation serves web and tests, and both pass one shared contract test suite.
4. **The Isar implementation must enforce these rules**, each of which comes from a spike finding:

   | Rule | Why |
   |---|---|
   | No unbounded data in a single object. Large bodies are chunked (≤ 1 MB per chunk) or kept in files with a reference in Isar | Objects ≥ 16 MB are silently truncated |
   | A hard per-object size limit checked before every write, failing with an error | So oversize data fails loudly instead of corrupting |
   | Our own schema version stored outside the main collections, read before they are opened; refuse to open a database from a newer app version | An older schema erases newer fields on open |
   | Copy the database file before the first open with a new schema version | Migrations are destructive when wrong |
   | Never rename a stored field or change its type in place. Dart renames keep the stored name with `@Name`; real changes are add-copy-remove across versions | Both lose data silently |
   | New fields are nullable, or a migration step writes their value into old rows | Dart defaults are not applied to old rows |
   | Each isolate opens its own instance; closures sent to isolates must not capture one | An open instance is unsendable |
   | Autosave is debounced; no write per keystroke or per drag frame | A small write transaction costs 5–7 ms |
   | Many records are fetched in one query, not one lookup each | A lookup costs about 1 ms on a mid-range phone |
   | Large bodies are read in a background isolate or chunk by chunk | Reading 20 MB stalled the phone's UI for about 50 ms |

## Not verified

These limit how far "Accepted" reaches. Each must be closed before the release it affects.

- **iOS.** No reachable iPhone; the simulator was skipped. Isar on iOS is untested.
- **Windows and Linux.** Cannot be tested from the development Mac.
- **Schema upgrade on Android.** Seeding worked; the phone refused to install the second build (`INSTALL_FAILED_VERIFICATION_FAILURE`), cause not investigated.
- **Release-mode behaviour and timings.** All runs were debug builds, because macOS release builds fail with Flutter 3.44.6 + Xcode 27.2 (a `lipo` check; fixed in Flutter ≥ 3.47.9, upgrade deferred).
- **The 16 MB limit for text fields and embedded lists.** Only a byte list was tested.
- **File growth and compaction** after deleting large blobs.
- **A 336 ms UI stall** on the phone during the first isolate write after launch.

## Alternatives considered

- **Drift (SQLite) on every platform, including web via WebAssembly.** One backend instead of two, and a maintained library with explicit migrations. Not tested in the spike. Rejected for now to keep the chosen stack; it is the named fallback if Isar fails on iOS, Windows or Linux, or if the fork stops being maintained.
- **Isar on native plus a real database on web.** Two full implementations to keep in step. Rejected as too much work for the first release.
- **Isar on web via an old 2.x release.** The 3.x changelog points web users at 2.5.0; that would mean two incompatible Isar versions in one app. Not pursued.

## Consequences

- Web users lose their workspace on reload unless they export. The UI must say so plainly and warn before leaving with unexported changes.
- The storage layer carries more code than "just use Isar": versioning, backup, size limits, chunking, a downgrade guard. These are requirements, not polish.
- Because no Isar type leaks out of `nokho_storage`, replacing Isar later means rewriting one package and re-running the contract suite, plus a one-time data migration for existing users.
- Migration tests need fixture databases committed for every released schema version.

## Revisit when

- iOS, Windows or Linux testing fails.
- `isar_community` goes more than about a year without a release, or a Flutter/Dart upgrade breaks it.
- Web needs saved storage (planned for post-1.0): re-evaluate one backend for all platforms at that point.
