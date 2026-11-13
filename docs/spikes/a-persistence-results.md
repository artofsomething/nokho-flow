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

## Open issue — macOS release/profile builds fail (not caused by Isar)

Diagnosed 2026-11-13: Flutter 3.44.6 runs `lipo <file> -verify_arch arm64 x86_64`; the `lipo` in Xcode 27.2 rejects two architectures in one call ("requires exactly one input file") although each passes alone. Flutter 3.47.9 and 3.50.0 verify one architecture at a time. Fix: upgrade the Flutter SDK (deferred by decision on 2026-11-13).


`flutter build macos --release` and `--profile` fail with:

```
Target release_unpack_macos failed: Exception: Binary …/FlutterMacOS.framework/Versions/A/FlutterMacOS
does not contain architectures "arm64 x86_64".
lipo -info: Architectures in the fat file: … are: x86_64 arm64
```

The same failure happens for `apps/nokho_flow`, which has no Isar dependency, so it comes from the Flutter 3.44.6 + Xcode 27.2 combination on this machine. Debug builds work. Cause not investigated yet; it has to be solved before any macOS release build, and before trusting release-mode timings.
