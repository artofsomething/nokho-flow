# Spike A — Persistence: results log

Raw results per step. The decision goes in ADR 0001 once every step is done.

Setup: `isar_community` 3.4.1, Flutter 3.44.6, Dart 3.12.2. Benchmark code: `spikes/isar_spike/lib/bench.dart`.

## Step 4 — 10,000 records on macOS (2026-11-13)

Machine: Apple silicon Mac, macOS 27.2.1, Xcode 27.2. Project on an APFS disk image on a USB SSD.
Mode: **debug** (JIT). Release and profile builds could not be made, see "Open issue" below, so these timings are pessimistic.
Two consecutive runs gave the same results within a few milliseconds.

| Operation | Time | Result |
|---|---|---|
| Write 10,000 records in one transaction | 66 ms | count = 10,000 |
| Read all 10,000 (with embedded headers) | 37–39 ms | all rows, headers intact |
| Indexed query (one collection, 1,000 rows) | 2–3 ms | 1,000 rows |
| Unique-index lookup × 1,000 | 146–156 ms | 1,000 found (~0.15 ms each) |
| Unindexed filter, count (`method == POST`) | 3–4 ms | 5,000 rows |
| Sorted page (latest 50 by `updatedAt`) | 2 ms | correct first row |
| 100 single-record transactions (autosave pattern) | 490–497 ms | ~5 ms per transaction |
| Duplicate `uuid` insert | 2 ms | rejected with `IsarError`, count unchanged |
| Delete one collection (1,000 rows) | 11 ms | 1,000 deleted, 9,000 remain |
| Watchers | — | collection watcher fired 102 times, query watcher 12 times, final query result empty as expected |
| Database size | — | 2.4 MB |

All checks passed.

Notes:
- A single small write transaction costs about 5 ms. Per-keystroke autosave should be debounced; dragging nodes on the canvas must not write on every frame.
- The collection watcher fires once per transaction (102 = 1 bulk write + 100 single writes + 1 delete), which is the granularity the UI will get.

## Step 5 — Web (Chrome) (2026-11-13): FAIL, does not compile

`flutter build web` fails for the spike app. The test never ran in Chrome.

**JavaScript build (dart2js):**

```
lib/request_record.g.dart:18:8:
Error: The integer literal 460796853305647030 can't be represented exactly in JavaScript.
  id: -460796853305647030,
```

Five such errors: the generated schema, index and embedded-object IDs are 64-bit integers, which JavaScript numbers cannot hold.

**WebAssembly build:** the dry run reports `dart:ffi unsupported` for every file under `package:isar_community/src/native/`, so a wasm build is not an option either.

**Why:** Isar Community 3.4.1 has no working web implementation.
- Its changelog says of the 3.0 line: "This version does not support the web target yet. It will be back in the next version."
- The files under `lib/src/web/` are stubs with the implementation commented out.
- pub.dev lists 3.4.1 (2026-10-13) as the latest version; there is no 4.x release or pre-release of `isar_community` to try.

**Consequence:** Isar Community cannot be the storage backend for Web Lite. Options to weigh in ADR 0001:
1. Isar on native + a different backend on web behind the same repository interfaces (two implementations to keep in step).
2. One backend that runs everywhere, e.g. SQLite via Drift (native + wasm on web).
3. Isar on native, and Web Lite without persistence beyond import/export (weakest).

**Decision (2026-11-13): option 3.** Keep Isar Community for native. Web Lite starts with in-memory repositories and import/export only; saved storage on web is deferred. Recorded in PLAN.md §3.4.1 and §4.1. A Drift comparison was considered and not run.

## Android (2026-11-13): PASS on a physical phone and on an emulator

Same benchmark, debug mode, no code changes. All checks passed on both.

| Operation | TECNO CN7c (physical, Android 16 / API 36, MediaTek MT6878, arm64) | Pixel 9 Pro emulator (API 35, arm64-v8a) | macOS (for reference) |
|---|---|---|---|
| Write 10,000 in one transaction | 388 ms | 2,240 ms | 66 ms |
| Read all 10,000 | 98 ms | 313 ms | 37–39 ms |
| Indexed query (1,000 rows) | 18 ms | 54 ms | 2–3 ms |
| Unique-index lookup × 1,000 | 1,108 ms | 3,430 ms | 146–156 ms |
| Unindexed filter, count | 17 ms | 51 ms | 3–4 ms |
| Sorted page (latest 50) | 10 ms | 15 ms | 2 ms |
| 100 single-record transactions | 683 ms | 1,038 ms | 490–497 ms |
| Duplicate `uuid` rejected | 9 ms | 11 ms | 2 ms |
| Delete one collection (1,000 rows) | 29 ms | 34 ms | 11 ms |
| Watchers (collection / query events) | 102 / 12 | 102 / 12 | 102 / 12 |
| Database size | 2.5 MB | 2.4 MB | 2.4 MB |

Notes:
- One run per device, debug (JIT) builds; treat the numbers as rough upper bounds, not benchmarks.
- On the phone a single lookup by `uuid` costs about 1.1 ms and a single save about 7 ms. Resolving many shared-request references one at a time (e.g. a 200-node flow) should use one batched query, not a loop of lookups.
- The emulator is 3–6× slower than the real phone on bulk work; do not tune against emulator numbers.

## Background isolate and 20 MB blob (2026-11-13)

Test code: `spikes/isar_spike/lib/isolate_blob_test.dart`, run with `--dart-define=SPIKE_TEST=isolate`. Debug mode, one run each. "Max UI gap" is the longest stall of a 4 ms timer on the UI isolate while the operation ran.

| Check | macOS | TECNO CN7c (Android 16) |
|---|---|---|
| Background isolate opens the same database and writes 10,000 records | PASS, 94 ms write, max UI gap 33 ms | PASS, 533 ms write, max UI gap 336 ms |
| UI isolate sees those writes (count and watcher) | PASS, 1 watch event | PASS, 1 watch event |
| 20 MB stored as **one** object | **Silently truncated**: 4,194,304 bytes came back, no error | **Silently truncated**: same |
| 20 MB stored as 20 × 1 MB chunks | PASS, intact; write 68 ms, read 45 ms, max UI gap 6 ms | PASS, intact; write 146 ms, read 97 ms, max UI gap 12 ms |
| UI isolate reads the 20 MB back (async API) | 12 ms, max UI gap 12 ms | 53 ms, max UI gap 51 ms |
| UI isolate writes 10,000 records (async API) | 59 ms, max UI gap 16 ms | 122 ms, max UI gap 47 ms |
| Database size afterwards | 42.8 MB | 42.5 MB |

Findings:

1. **Multi-isolate access works.** A second isolate opens the database by directory and name, and its writes reach the UI isolate's watchers. An open `Isar` instance cannot be sent to another isolate ("object is unsendable"); each isolate must open its own, and closures passed to `Isolate.run` must not capture it.
2. **Objects of 16 MB or more are silently corrupted.** Storing a 20 MB byte list in one object raised no error and returned 4,194,304 bytes, which is 20 MiB modulo 16 MiB, so the length appears to wrap at 16 MiB. This is the most important result of the spike: any single record that can exceed 16 MB (a response body, a big request body, a run step with an embedded response) would lose data without warning.
   - Rule for the storage layer: never put unbounded data in one object. Chunk blobs (1 MB chunks worked) or keep large bodies in files with only a reference in Isar, and enforce a hard per-object size limit in the repository so an oversize write fails loudly.
   - The limit also applies to text fields and embedded lists, not only byte lists; that was not separately tested.
3. **UI stalls.** Reading 20 MB back on the UI isolate stalled it for about 50 ms on the phone (the bytes are copied into Dart on the calling isolate). Large bodies should be read in a background isolate or streamed chunk by chunk.
4. The 336 ms gap on the phone during the first isolate write is unexplained. It was the first operation after launch, in a debug build, so start-up work may be included. Not investigated.
5. The database file grew to about 42 MB for 20 MB of live blob data (the truncated 4 MB object and freed pages are included). Deleting blobs will not shrink the file by itself; compaction behaviour was not tested.

## Schema change with old data (2026-11-13)

Test: `spikes/isar_spike/mig_versions/` holds two versions of a `MigRecord` collection; `sh mig_versions/use.sh <1|2>` switches the active one. Run with `--dart-define=SPIKE_TEST=mig`. Four phases on macOS against one database file: seed 1,000 rows with v1 → open with v2 → open with v1 again (an older app version) → open with v2 again. Isar raised no error in any phase.

### Upgrade (v1 data opened by v2)

| Change made in v2 | What happened to the 1,000 old rows |
|---|---|
| Unique index added to an existing field | Works; old rows are found through the new index |
| Field renamed in Dart, stored name kept with `@Name('title')` | All 1,000 values kept |
| Field renamed **without** `@Name` (`note` → `comment`) | **All 1,000 values lost** (`null`), silently |
| Field type changed (`int size` → `String? size`) | **All 1,000 values lost** (`null`), silently |
| Field removed | No error |
| New nullable field | `null` |
| New non-nullable `String` (`late String status`) | Empty string `""` |
| New `int` with a Dart default (`int priority = 3`) | **`-9223372036854775808`**, not 3: the default initialiser is not applied to old rows |
| New list (`List<String> tags = []`) | Empty list |

Old rows could be updated through the new schema, and new rows written alongside them.

### Downgrade (v2 data opened by v1, then by v2 again)

- The older version opened the newer database **without any error or warning**.
- It read the fields it knows; fields it no longer has (`note`, `legacyCount`, `size` as int) came back as `""` or `-9223372036854775808`.
- **Opening with v1 destroyed the v2-only data.** When v2 opened the file again, `description`, `status`, `priority`, `tags`, `comment` and `size` were empty on every row, including the 10 rows v2 had written and the row v2 had edited. Isar makes the stored schema match whatever schema opens it and drops the rest.

### Android

Seeding with v1 worked on the TECNO phone. Installing the v2 build was refused by the phone twice (`INSTALL_FAILED_VERIFICATION_FAILURE: Install not allowed`), so the upgrade was **not verified on Android**. Earlier installs on the same phone had worked; the cause was not investigated.

### What the storage layer must do

1. **Keep our own schema version** in the database (a small `Meta` collection) and check it before opening the real collections.
2. **Refuse to open a database written by a newer app version.** Otherwise simply launching an old build wipes newer fields. This check has to read the version without opening the collections with the old schema, e.g. from a separate tiny Isar instance or a sidecar file.
3. **Never rename a stored field or change its type in place.** Renames in Dart must keep the stored name with `@Name`. A real rename or type change is: add the new field, copy values in a migration step, remove the old field in a later version.
4. **New non-nullable fields need a migration step** that writes the intended value into old rows; Dart default initialisers do not apply to them. Prefer nullable fields and treat `null` as "not set".
5. **Back up before migrating**: copy the database file before the first open with a new schema version.
6. **Migration tests in CI** from committed fixture databases of every released schema version.

## iOS: NOT TESTED

- No iPhone was reachable (Flutter reported one known device that could not be reached over the network).
- The iOS simulator was skipped by decision. One earlier attempt, `flutter build ios --simulator --debug`, failed at "Failed to copy Flutter framework" before any Isar code ran. That is consistent with the two-architecture `lipo` problem described below, but this was not confirmed.
- Isar on iOS therefore remains unverified.

## Open issue — macOS release/profile builds fail (not caused by Isar)

Diagnosed 2026-11-13: Flutter 3.44.6 runs `lipo <file> -verify_arch arm64 x86_64`; the `lipo` in Xcode 27.2 rejects two architectures in one call ("requires exactly one input file") although each passes alone. Flutter 3.47.9 and 3.50.0 verify one architecture at a time. Fix: upgrade the Flutter SDK (deferred by decision on 2026-11-13).


`flutter build macos --release` and `--profile` fail with:

```
Target release_unpack_macos failed: Exception: Binary …/FlutterMacOS.framework/Versions/A/FlutterMacOS
does not contain architectures "arm64 x86_64".
lipo -info: Architectures in the fat file: … are: x86_64 arm64
```

The same failure happens for `apps/nokho_flow`, which has no Isar dependency, so it comes from the Flutter 3.44.6 + Xcode 27.2 combination on this machine. Debug builds work. Cause not investigated yet; it has to be solved before any macOS release build, and before trusting release-mode timings.
