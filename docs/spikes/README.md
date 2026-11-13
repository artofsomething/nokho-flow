# Phase 0 Spikes

Each spike is throwaway code on its own branch (`spike/a-persistence`, ...). The output is an ADR in [../adr](../adr), not production code.

## A — Persistence on all six platforms
- **Question:** Does Isar Community work on macOS, Windows, Linux, iOS, Android and web, including from a background isolate?
- **Do:** Store and watch 10k request records plus a 20 MB blob; run one schema change; open the DB from two isolates.
- **Done when:** Go/no-go per platform, with a fallback named if any platform fails. → ADR 0001

## B — Flow canvas
- **Question:** Custom canvas or a package?
- **Do:** 200 nodes with pan, zoom, drag and connect on a desktop and a mid-range phone; measure frame times; try tap-to-connect on touch.
- **Done when:** 60 fps at 200 nodes on desktop, usable on the phone, approach chosen. → ADR 0002

## C — HTTP adapters
- **Question:** What can each platform's HTTP stack control, and how do we detect CORS and mixed-content failures on web?
- **Do:** Native adapter with duplicate headers, redirects off, a custom method, cancel; web adapter with `fetch`; fill in the capability matrix.
- **Done when:** `HttpCapabilities` values confirmed per platform and the web error messages defined. → ADR 0003

## D — Large JSON
- **Question:** Can the editor and tree viewer handle 10–50 MB responses without freezing?
- **Do:** Parse off the UI thread, virtualised tree, candidate editor packages with a 5 MB body.
- **Done when:** Editor package chosen and size caps set.

## E — JS runtime
- **Question:** Which JS runtime works on all six platforms, in the pure-Dart CLI and inside an isolate?
- **Do:** One script with a host callback, a timeout kill and a memory limit on every target; compare `flutter_js` with QuickJS over FFI, and QuickJS with JavaScriptCore on Apple platforms.
- **Done when:** Runtime chosen per platform and the fallback for web decided. → ADR 0005
