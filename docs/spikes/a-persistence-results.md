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

## Open issue — macOS release/profile builds fail (not caused by Isar)

`flutter build macos --release` and `--profile` fail with:

```
Target release_unpack_macos failed: Exception: Binary …/FlutterMacOS.framework/Versions/A/FlutterMacOS
does not contain architectures "arm64 x86_64".
lipo -info: Architectures in the fat file: … are: x86_64 arm64
```

The same failure happens for `apps/nokho_flow`, which has no Isar dependency, so it comes from the Flutter 3.44.6 + Xcode 27.2 combination on this machine. Debug builds work. Cause not investigated yet; it has to be solved before any macOS release build, and before trusting release-mode timings.
