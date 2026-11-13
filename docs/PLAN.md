# Nokho-Flow — Project Plan

> API testing client (Postman-like) with a **visual flow builder**: chain requests on a graph, extract values from responses, and drive the next request automatically.

- **Status:** Phase 0 (scaffolded; spikes in progress)
- **Platforms:** macOS, Windows, Linux, iOS, Android, Web
- **Stack:** Flutter, Riverpod, Isar Community (native only; web keeps data in memory, see §4.1)
- **Last updated:** 2026-11-13

---

## 1. Vision & Positioning

**One-liner:** Postman for single requests + n8n/Zapier-style graph for chaining them, local-first.

**Differentiator:** Most API clients treat "collections" as flat lists run in order. Nokho-Flow treats a *flow* as a first-class, visual, branching graph where each edge carries *extracted data* from one response into the next request.

**Target users**
1. Backend/mobile devs testing and debugging APIs.
2. QA engineers building end-to-end API scenarios (login → create → verify → delete).
3. Solo devs / small teams who want a lightweight, local-first, offline-capable alternative.

**Principles**
- Local-first, works offline, no account required.
- Visual first, but everything is representable as plain JSON (diff-able, importable, exportable).
- One engine: the same execution engine powers single sends, flows, the CLI runner and (later) scheduled runs.
- Secure by default (secrets never leak into exports/logs unless asked).

**Non-goals (v1)**
- Not a load-testing tool (basic repeat/parallel only; no k6/JMeter replacement).
- Not an API gateway/mock hosting platform (local mock server is a later phase).
- No cloud accounts / team collaboration in v1 (designed for, not built).

---

## 2. Feature Catalogue

Priority tags: **P0** = MVP, **P1** = v1.0, **P2** = post-1.0, **P3** = exploratory.

### 2.1 Request Builder

| Feature | Pri |
|---|---|
| Methods: GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS | P0 |
| Custom/other methods (TRACE, CONNECT, PROPFIND, any string) | P1 |
| URL bar with query-param table synced both ways (edit URL ↔ edit table) | P0 |
| Path variables (`/users/:id`) | P1 |
| Headers table (enable/disable per row, bulk-edit mode, autocomplete of common headers/values) | P0 |
| Auto-generated headers shown (Host, Content-Length, User-Agent, Accept) and overridable | P1 |
| Body types: none, raw (JSON/Text/XML/HTML/JS), form-data (text + file), x-www-form-urlencoded, binary file, GraphQL (query + variables) | P0 (JSON/raw/form), P1 (rest) |
| Body editor: syntax highlight, JSON prettify/minify, bracket matching, JSON lint, find/replace | P0 |
| Auth helpers: None, Basic, Bearer, API Key (header/query), Digest, OAuth 2.0 (auth code + PKCE, client credentials, password, refresh), AWS SigV4, JWT builder | P0 (Basic/Bearer/API key), P1 (OAuth2, Digest), P2 (SigV4, others) |
| Inherit auth/headers from folder/collection | P1 |
| Variables `{{name}}` with autocomplete + resolved-value hover preview | P0 |
| Dynamic variables (`{{$uuid}}`, `{{$timestamp}}`, `{{$randomEmail}}`, `{{$randomInt(1,10)}}`, `{{$isoDate}}`, base64/hash helpers) | P1 |
| Cookies: per-workspace cookie jar, view/edit/delete, per-domain, toggle jar per request | P1 |
| Request settings: timeout, follow redirects (max count), verify TLS, send cookies, proxy override, HTTP version | P1 |
| Client certificates (mTLS), custom CA bundle | P2 |
| Proxy: system, manual (HTTP/SOCKS5), per-workspace, no-proxy list | P1 |
| Request description / docs (markdown) | P1 |
| Pre-request & post-response *steps* (declarative, see §2.5) | P0 |
| JS scripting sandbox: pre-request and post-response scripts (see §2.5.1) | P1 |
| WebSocket client | P2 |
| Server-Sent Events viewer | P2 |
| gRPC (unary + streaming, proto import/reflection) | P3 |
| Cancel in-flight request | P0 |

### 2.2 Response Viewer

| Feature | Pri |
|---|---|
| Status code, text, time, size | P0 |
| Body: pretty / raw / preview (HTML render, image, PDF) | P0 (pretty/raw), P1 (preview) |
| JSON tree view (collapsible, click node → "copy JSONPath" / "use as variable" / "monitor this") | **P0 (core)** |
| Headers + cookies tabs | P0 |
| Timing breakdown (DNS, connect, TLS, TTFB, download) — native only | P2 |
| Redirect chain viewer | P1 |
| Raw request actually sent (post-variable-resolution, with auth headers) | P1 |
| Search in body, filter JSON by JSONPath live | P1 |
| Copy / save body to file | P1 |
| Large-response handling (virtualized viewer, lazy parse, size caps, "open as file") | P1 |
| Binary/stream responses (download progress, save) | P1 |
| Diff two responses (this run vs previous run vs saved example) | P2 |
| Saved response examples | P2 |
| Charset detection (UTF-8, ISO-8859-1, BOM), gzip/br/deflate decoding | P0 |

### 2.3 Collections, Environments & Workspace

| Feature | Pri |
|---|---|
| Workspaces (separate DBs/contexts) | P1 |
| Collections → Folders → Requests (nested, drag-reorder, duplicate, move) | P0 |
| Environments (key/value, enable/disable, secret type, initial vs current value) | P0 |
| Variable scopes + precedence: **Flow run > Flow > Environment > Collection > Global** | P0 |
| Quick environment switcher, environment-less mode | P0 |
| Tabs (multiple open requests), pinned tabs, restore session | P0 (tabs), P1 (restore) |
| Request history (auto-saved sends, searchable, restore to editor) | P0 |
| Search/command palette (Ctrl/Cmd+K) across requests, flows, envs | P1 |
| Tags/labels, favorites | P2 |
| Trash/undo-delete (soft delete 30 days) | P1 |

### 2.4 Flow Builder (Core Differentiator)

#### Canvas
| Feature | Pri |
|---|---|
| Infinite canvas: pan, zoom, minimap, fit-to-screen | P0 |
| Drag requests from sidebar onto canvas, or create inline node | P0 |
| Connect nodes via ports with bezier/orthogonal edges; snap, auto-route, edge labels | P0 |
| Multi-select, box-select, copy/paste, duplicate, align/distribute, grouping/frames | P1 |
| Undo/redo (command stack, ≥100 steps) | P0 |
| Auto-layout (layered/Sugiyama) | P1 |
| Node status overlay while running (idle / queued / running / success / failed / skipped) with timing | P0 |
| Edge animation showing data flow during run | P2 |
| Notes/sticky comments, colored groups | P1 |
| Keyboard shortcuts, accessibility (focus order, screen-reader labels) | P1 |
| Touch gestures on mobile (pinch zoom, long-press connect, tap-to-connect mode) | P0 |

#### Node types
| Node | Purpose | Pri |
|---|---|---|
| **Start** | Entry; defines flow inputs (variables/parameters) | P0 |
| **Request** | Executes a saved request. Dragging one from the sidebar creates a **shared reference** by default (decided 2026-11-13); "Make local copy" detaches it into a flow-local inline request. Nodes created directly on the canvas are inline. See "Shared request nodes" below | P0 |
| **End / Output** | Marks terminal; collects flow outputs | P0 |
| **Condition (If/Else)** | Branch on expression over extracted values | P0 |
| **Switch** | Multi-branch on value / pattern | P1 |
| **Delay / Wait** | Fixed or randomized sleep | P0 |
| **Poll Until** | Repeat a request until condition true (interval, max attempts, timeout, backoff) | P1 |
| **Loop / For-Each** | Iterate over array from a response or dataset | P1 |
| **Parallel (Fork) + Join** | Run branches concurrently; join policy: all / any / first-success / quorum | P1 |
| **Set Variable / Transform** | Compute new values (JSONata-like expressions, string/number/date ops) | P1 |
| **Assert** | Validate (status, schema, value, header, time); fail or warn | P0 |
| **Sub-flow** | Call another flow with params, returns outputs | P2 |
| **Error Handler / Catch** | Route failures to recovery path | P1 |
| **Manual Input / Pause** | Prompt user for value (OTP, captcha token) mid-run | P1 |
| **Webhook Wait** | Local listener waits for incoming callback (desktop only) | P3 |
| **Log / Note** | Emit message to run log | P1 |
| **Script** | Custom JS code node (reads/writes flow variables, can set outputs and fail the node) | P1 |

#### Shared request nodes
- A shared node stores the request's UUID plus **per-node overrides** (URL params, headers, body fields, auth, settings). Overrides are layered on top of the saved request at run time and shown as "overridden" badges, each resettable.
- **Extractors, assertions, edge conditions and failure policy belong to the node**, not the saved request, so two flows can use the same request differently.
- Scripts and declarative steps saved on the request run for every flow that references it; a node can add its own on top or disable the inherited ones.
- Editing the saved request updates every flow that references it. The request editor shows "Used in N flows", and saving a change that removes something a flow overrides or binds to lists the affected flows first.
- A shared node shows a link badge; double-click opens the saved request, with a "Make local copy" action. The reverse, "Save to collection", turns an inline node into a shared one.
- The same request can appear several times in one flow; each node has its own name, overrides and results.
- A run uses a snapshot of the referenced requests taken at run start.
- Export of a single flow embeds the referenced requests; import relinks by UUID if the request already exists, otherwise recreates it (or inlines it, user's choice).

#### Data wiring (the "monitor which response element continues the flow")
- **Extractors** attached to a Request node (output side): each defines `name`, `source`, `query`, `type`, `default`, `required`.
  - Sources: body JSON (JSONPath), body XML (XPath), body text (regex w/ capture group), body HTML (CSS selector, P2), header, cookie, status code, response time, response size, redirect URL.
  - Type coercion: string / number / bool / json / list.
  - Pick from the response viewer by clicking a JSON node (auto-writes JSONPath).
- **Edge conditions (gates):** an edge can be *always*, *on success (2xx)*, *on failure*, or a *custom expression* (e.g. `{{login.token}} != null && {{login.role}} == "admin"`). This is the "monitor this element to continue" feature.
- **Wait-for conditions:** "continue only when `$.status == 'READY'`" (poll), with timeout and fallback edge.
- **Bindings:** drag from an extractor port to a request field (URL/header/query/body/auth) → inserts `{{nodeName.extractorName}}`; visual indicator on bound fields.
- **Data inspector:** click an edge/node to view the exact values passed during the last run.
- **Mapping view** for array → loop item, and for object → body composition.
- **Schema hints:** after a run, remember response shape to give autocomplete for downstream bindings.

#### Flow-level features
| Feature | Pri |
|---|---|
| Run whole flow / run from node / run only selected node(s) with cached upstream values | P0 (whole), P1 (from node, partial) |
| Step-through / debug mode (breakpoints on nodes, step over, inspect context, edit value & continue) | P1 |
| Stop / pause / resume / cancel | P0 (stop), P1 (pause/resume) |
| Flow inputs (parameters) and outputs | P1 |
| Run with dataset (CSV/JSON rows → one run per row, data-driven testing) | P1 |
| Repeat N times / schedule (while app open; later headless) | P1 / P2 |
| Run report: per-node request/response, timing, assertion results, extracted values | P0 |
| Export report: JSON, JUnit XML, HTML, Markdown | P1 |
| Flow versioning (snapshots, restore, diff) | P2 |
| Flow templates (login+CRUD, polling job, OAuth refresh) | P2 |
| Flow validation panel (unconnected nodes, unreachable branches, missing variables, cycles) before run | P0 |

### 2.5 Pre/Post Request Steps (Declarative-first)
Declarative "steps" cover ~90% of needs without a scripting runtime (safer on iOS/web):
- Set variable (env/flow/global) from extractor or literal
- Assert (status, header, JSONPath equals/contains/exists/type/regex/schema/response-time/size)
- Extract (as above)
- Sleep
- Conditional skip
- JSON Schema validation (draft-07/2020-12)

Declarative steps stay the default and ship first (Phases 1–2); the UI offers them before scripting.

#### 2.5.1 JS Scripting (P1 — decided 2026-11-13, ships in 1.0)

**Where scripts run**
- Pre-request script and post-response script on a request (also inheritable from folder/collection).
- Script node in a flow.
- Order per request: collection pre → folder pre → request pre → declarative pre-steps → **send** → declarative post-steps → request post → folder post → collection post.

**API surface (`nk.*`, with a `pm.*` alias for the supported subset)**
- `nk.variables.get/set/unset` (resolves across scopes), plus `nk.environment`, `nk.collectionVariables`, `nk.globals`, `nk.flow` (flow-run scope).
- `nk.request` — read and mutate method, URL, headers, body in pre-request scripts.
- `nk.response` — `code`, `status`, `headers`, `responseTime`, `size`, `text()`, `json()`.
- `nk.test(name, fn)` and `nk.expect(...)` (Chai-style subset) → results appear with declarative assertions in the run report.
- `nk.node("Login").extracted.token` / `.response` — read other nodes' results inside a flow.
- `nk.setOutput(name, value)`, `nk.fail(message)`, `nk.skip()` for Script nodes.
- `console.log/warn/error` → run log.
- `nk.sendRequest(spec)` — goes through the engine's HTTP adapter (same proxy/TLS/cancel rules); P2 if it threatens the 1.0 date.
- Built-ins: `JSON`, `Math`, `Date`, `RegExp`, `atob/btoa`, a small bundled helper set (uuid, hashing/HMAC, base64). No `require`/npm, no filesystem, no raw network, no timers beyond a bounded `await nk.sleep(ms)`.

**Postman compatibility**
- Target the commonly used subset: `pm.environment/globals/collectionVariables/variables`, `pm.request`, `pm.response`, `pm.test`, `pm.expect`, `pm.sendRequest`.
- Not supported: `pm.visualizer`, `pm.execution.setNextRequest`/`postman.setNextRequest` (flow edges replace it — importer adds a warning), `require()` of sandbox libraries beyond the bundled helpers, legacy `tests[...]` syntax (P2).
- Importer runs a static check on each script and lists unsupported calls per request.

**Runtime**
- `ScriptRuntime` interface in the engine; implementations per platform (§3.5.1).
- Fresh context per script execution; limits on wall time (default 5 s), memory, output size and log lines.
- Editor: JS syntax highlight, autocomplete for `nk.*`, snippets ("set variable from response", "status is 200"), inline error with line number.

### 2.6 Import / Export / Interop

| Feature | Pri |
|---|---|
| Import cURL (paste), export as cURL | P0 |
| Import/Export Postman Collection v2.1 + environments | P1 |
| Import OpenAPI 3.x / Swagger 2 → collection (+ generate sample flows from operations) | P1 |
| Import Insomnia, Bruno, HAR | P2 |
| Native Nokho format: `.nokho.json` (versioned schema, human-diffable), per collection/flow/workspace | P0 |
| Code snippet generation (cURL, Dart/http, JS fetch, Python requests, Kotlin, Swift, Go…) | P1 |
| Git-friendly folder export (one file per request/flow) for version control | P2 |
| Import flows from Postman Collection Runner order (convert linear run into linear flow) | P2 |

### 2.7 Sync, Sharing & Collaboration (post-1.0)
- P2: Manual file-based sync (export/import, iCloud/Drive/Dropbox folder watch).
- P2: Optional cloud sync with E2E encryption (secrets never plaintext server-side).
- P3: Real-time team workspaces, comments, roles, shared environments.
- P2: Share a single flow via link/file (secrets stripped).

### 2.8 Automation & Headless
- P1: **`nokho` CLI** (pure Dart, reuses the engine package): `nokho run flow.json --env staging --report junit.xml`; exit codes for CI.
- P2: Scheduled runs (desktop app in tray / background agent), notifications on failure (email/webhook/Slack).
- P2: GitHub Action / Docker image wrapping the CLI.
- P3: Local mock server from saved examples; request/response interception proxy (MITM-style capture → import).

### 2.9 UX, Settings & Polish
- Light/dark/system theme, accent color, font size, editor font, density (compact/comfortable).
- Responsive layout: 3-pane desktop, 2-pane tablet, single-pane mobile with bottom navigation.
- Multi-window (desktop): detach tab or flow into new window.
- Localization-ready (ARB), at least EN at launch; add ID / others later.
- Onboarding sample workspace (public echo API like httpbin) + guided first-flow tutorial.
- Keyboard-first: shortcuts map, customizable (desktop).
- Crash/error reporting: opt-in, local logs, "copy diagnostics" button.
- Auto-update (desktop: Sparkle/Squirrel-style or store), PWA update prompt (web).
- Privacy: no telemetry by default; opt-in anonymous analytics.

### 2.10 Security
- Secrets stored via `flutter_secure_storage` (Keychain/Keystore/libsecret/DPAPI); Isar holds only secret *references*.
- Optional workspace-level encryption at rest + app lock (biometric/PIN, auto-lock timeout).
- Secret variables masked in UI, logs, history, run reports, exports, code snippets (opt-in "include secrets").
- "Initial" vs "Current" value: shared value vs local-only value (never exported).
- TLS verification on by default; per-request opt-out with warning banner.
- Redact `Authorization`, `Cookie`, `Set-Cookie`, tokens in saved history by default (configurable).
- Imported collections/scripts treated as untrusted (no auto-run, scripts sandboxed with no FS/network except via the engine).
- Clipboard hygiene for secrets (auto-clear optional).

---

## 3. Architecture

### 3.1 High-level layers

```
┌────────────────────────────────────────────────────────────────┐
│ Presentation (Flutter widgets, adaptive layouts, canvas)       │
├────────────────────────────────────────────────────────────────┤
│ State (Riverpod: Notifiers/AsyncNotifiers, providers, codegen) │
├────────────────────────────────────────────────────────────────┤
│ Domain (entities, use-cases, pure Dart, no Flutter imports)    │
├───────────────┬───────────────────────┬────────────────────────┤
│ Flow Engine   │ HTTP Client Adapter   │ Persistence (Isar repo)│
│ (pure Dart)   │ (dio / platform impl) │ + SecureStorage        │
└───────────────┴───────────────────────┴────────────────────────┘
```

### 3.2 Monorepo / package layout (Dart pub workspace — scaffolded 2026-11-13)

```
nokho-flow/
├── apps/
│   └── nokho_flow/                # Flutter app (all platforms), app ID com.nokho.nokho_flow
├── packages/
│   ├── nokho_core/                # entities, value objects, expression/variable resolver (pure Dart)
│   ├── nokho_engine/              # flow graph model, scheduler, executor, extractors, assertions (pure Dart)
│   ├── nokho_script/              # ScriptRuntime impls (QuickJS FFI, JavaScriptCore, web Worker) + nk.* bridge + JS prelude
│   ├── nokho_http/                # HttpAdapter interface + dio/native/web impls
│   ├── nokho_storage/             # repository interfaces + Isar impl (native) + in-memory impl (web, tests) + migrations + secure storage
│   ├── nokho_importers/           # curl, postman, openapi, har
│   ├── nokho_codegen_snippets/    # request → code snippet generators
│   ├── nokho_flow_canvas/         # node-graph canvas widget (CustomPainter, no app deps)
│   └── nokho_ui/                  # design system, shared widgets, editor widgets
├── tools/
│   └── nokho_cli/                 # headless runner (pure Dart)
└── docs/
```

Rule: `nokho_engine` and `nokho_core` must stay **pure Dart** so the CLI, isolates, and tests need no Flutter.

### 3.3 Suggested libraries (verify versions at start)

| Concern | Candidate | Notes |
|---|---|---|
| State | `flutter_riverpod`, `riverpod_annotation` + `riverpod_generator` | Use `AsyncNotifier` for DB-backed state |
| Immutability | `freezed`, `json_serializable` | |
| DB | `isar_community` (+ `isar_community_flutter_libs`) on native; in-memory repositories on web | Original `isar` is unmaintained. `isar_community` 3.4.1 does **not** compile for web (Spike A, step 5), so it must never be imported in web builds — see §3.4.1 |
| Secrets | `flutter_secure_storage` | Web: session-only (in memory) |
| HTTP | `dio` (+ native adapters) | Need per-platform adapters, cookie jar, cancel tokens |
| Routing | `go_router` | Deep links to flow/request |
| JSONPath | `json_path` / `petitparser`-based | Must support filters & recursive descent |
| XPath/HTML | `xml`, `xpath_selector`, `html` | |
| Expressions | custom small evaluator, or `expressions` / JSONata port | Needs sandbox, no `eval` |
| Schema validation | `json_schema` | |
| JS runtime | `flutter_js` (QuickJS / JavaScriptCore), or QuickJS directly via `dart:ffi`; web → sandboxed Web Worker | Must also work in the pure-Dart CLI and inside the engine isolate — decide in Spike E |
| Code editor | `re_editor` / `flutter_code_editor` / `code_text_field` | Evaluate perf with 5 MB JSON |
| Graph canvas | **Build custom** (InteractiveViewer + CustomPainter + widget nodes) or evaluate `vyuh_node_flow` / `flutter_flow_chart` / `graphview` | Prototype in Phase 0 and decide |
| Desktop | `window_manager`, `tray_manager`, `desktop_multi_window` | |
| Files | `file_picker`, `share_plus`, `path_provider` | |
| Isolates | `dart:isolate`, `Isolate.run`; web → `Worker` fallback | |
| Testing | `flutter_test`, `mocktail`, `golden_toolkit`/`alchemist`, `patrol` or `integration_test`, local test server (`shelf`) | |
| Lint/CI | `very_good_analysis`, GitHub Actions, `melos` | |

### 3.4 Data model (Isar collections — sketch)

```
Workspace      id, name, createdAt, settings(embedded), schemaVersion
Collection     id, workspaceId, name, description, auth(embedded), headers, variables, order
Folder         id, collectionId, parentId, name, auth, headers, order
RequestDef     id, collectionId, folderId?, name, method, url, params[], headers[],
               body(embedded), auth(embedded), settings(embedded), steps[], order, updatedAt
Environment    id, workspaceId, name, isActive, vars[] (key, initial, currentRef, secret, enabled)
FlowDef        id, workspaceId, name, description, inputs[], outputs[], viewport, version, updatedAt
FlowNode       id, flowId, type, position(x,y), size, config(json), requestRef?(uuid)+overrides(embedded)|inlineRequest?, extractors[], asserts[]
FlowEdge       id, flowId, fromNode, fromPort, toNode, toPort, condition(expr)?, label, kind
RunRecord      id, flowId?|requestId?, startedAt, endedAt, status, envSnapshot(redacted), trigger, summary
RunStep        id, runId, nodeId, attempt, request(redacted), response(ref), extracted{}, asserts[], durationMs, error?
BlobStore      id, bytes/ref  (large response bodies stored out-of-row, file-backed on native)
CookieEntry    id, workspaceId, domain, path, name, value(ref), expires, secure, httpOnly, sameSite
HistoryEntry   id, requestSnapshot, responseMeta, createdAt
Secret         (not in Isar) secure storage key = "ws:{id}:env:{id}:{var}"
```

Design notes:
- **Soft refs by UUID**, not Isar IDs, for portable export/import and future sync.
- Every entity: `uuid`, `createdAt`, `updatedAt`, `deletedAt?`, `rev` (for future sync/conflict resolution).
- Graph stored **normalized** (nodes + edges) for efficient partial updates; exportable as a single JSON document.
- Large bodies out of main collections; cap & auto-prune history (count + total size + age).
- Schema versioning + migration runner from day 1 (Isar has no automatic migrations beyond field add; plan explicit migration steps).

### 3.4.1 Storage per platform (decided 2026-11-13)

| Platform | Repository implementation | Data survives restart |
|---|---|---|
| macOS, Windows, Linux, iOS, Android | Isar Community | Yes |
| Web Lite | In-memory | No — import/export only |

- The app depends only on repository interfaces (`RequestRepository`, `FlowRepository`, …) defined in `nokho_storage` with **no Isar types in their signatures**: plain entities from `nokho_core`, `Stream`s for watching.
- The Isar implementation and its generated schemas live behind a **conditional import** (`dart.library.io`), so web builds never compile Isar code. The generated 64-bit schema IDs break `dart2js`, and Isar's native bindings use `dart:ffi`.
- The in-memory implementation is the web backend and also the fake used in unit and widget tests, so it is exercised constantly. Both implementations run the same repository contract test suite.
- Web workflow: start empty (or from the sample workspace) → import a `.nokho.json` → work → export. Details in §4.1.
- Possible later step, without touching the rest of the app: persist the web workspace as one JSON document in browser storage, reusing the export format.

### 3.5 Flow engine design

**Model:** directed graph; nodes have typed input/output ports. Execution semantics:
1. **Validate** (reachability from Start, port type compat, required bindings present, cycle detection — cycles only allowed through Loop/Poll nodes with explicit bounds).
2. **Plan:** topological ordering with *ready-set* scheduler: a node is ready when all *required* inbound edges are resolved (fired or skipped).
3. **Execute:** ready nodes dispatched (sequential by default; concurrent where graph forks, bounded by `maxConcurrency`).
4. **Context:** immutable-per-step `RunContext` with scoped variables: `flow.*`, `env.*`, `node["Login"].extracted.token`, `node["Login"].response.status`, `loop.item`, `loop.index`.
5. **Edge evaluation:** after a node finishes, evaluate outgoing edge conditions → *fired* or *skipped*; skipped propagates "dead path" downstream (so Joins don't deadlock).
6. **Failure policy** per node: `stop-flow` | `continue` | `route-to-error-edge` | `retry(n, backoff)`.
7. **Events:** engine emits a `Stream<RunEvent>` (NodeQueued/Started/Finished/Failed/Skipped, LogLine, RunDone). UI and CLI are just subscribers.
8. **Isolation:** run in a background isolate on native so UI stays at 60fps with large payloads; on web use main thread w/ chunking or Web Worker later.
9. **Determinism & replay:** persist each step's resolved inputs/outputs so a node can be re-run from cached upstream data ("run from here").
10. **Cancellation:** cooperative token passed to the HTTP adapter and sleeps.

**Expression language** (for conditions, bindings, transforms): small, safe, no side effects:
- Literals, `==, !=, <, >, &&, ||, !, ??`, `in`, ternary
- Path access `node.Login.extracted.token`, array index, `length`, `contains`, `startsWith`, `matches(regex)`, `exists`, `isEmpty`, type checks, date/number/string helpers.
- Templating `{{ ... }}` inside strings, with type-preserving whole-value substitution (§3.5.2).

### 3.5.2 Variable typing rule (decided 2026-11-13: keep the type)

**Rule.** In a JSON context, a string value that consists of exactly one template and nothing else is replaced by the variable's value **with its type**. Anything else is string interpolation.

| Template in a JSON body | x | Sent |
|---|---|---|
| `{"age": "{{x}}"}` | `30` (number) | `{"age": 30}` |
| `{"ok": "{{x}}"}` | `true` | `{"ok": true}` |
| `{"user": "{{x}}"}` | `{"id": 1}` | `{"user": {"id": 1}}` |
| `{"v": "{{x}}"}` | `null` | `{"v": null}` |
| `{"v": "{{x}}"}` | `"30"` (string) | `{"v": "30"}` |
| `{"msg": "Age: {{x}}"}` | `30` | `{"msg": "Age: 30"}` |
| `{"id": "{{string(x)}}"}` | `30` | `{"id": "30"}` |

- **JSON contexts:** JSON request bodies, GraphQL variables, and Set Variable/Transform node values. `"{{ x }}"` (inner whitespace) counts as whole-value; `" {{x}} "` does not.
- **Everywhere else is always a string:** URL, path and query params, headers, form fields, raw text/XML bodies, and JSON object *keys*. Objects and arrays are JSON-encoded; `null` renders as an empty string and is flagged in the resolved-value preview.
- **Explicit casts:** `{{string(x)}}`, `{{number(x)}}`, `{{bool(x)}}`, `{{json(x)}}` (parse a JSON string). A failed cast fails the node with the offending value.
- **Where types come from:** extracted values keep their JSON type; script-set values keep their JS type; environment/collection variables are strings unless given a type in the variable table (string / number / boolean / JSON); dataset CSV cells are strings, JSON dataset values keep their type.
- **Unquoted `{{x}}` in a JSON body** (Postman style, not valid JSON before resolution) is still accepted and substituted as raw text, so `{"age": {{x}}}` works as it does in Postman.
- **Postman import:** Postman sends `"{{x}}"` as a string. The importer rewrites whole-value quoted templates to `"{{string(x)}}"` (option, on by default) so imported requests behave as before.
- The request editor's resolved preview shows the final type of each substituted value, and the "raw request sent" view shows the exact bytes.

### 3.5.1 Script runtime

```dart
abstract class ScriptRuntime {
  Future<ScriptResult> run(ScriptSpec script, ScriptBindings bindings, {ScriptLimits limits, CancelToken? cancel});
}
```
- The interface lives in `nokho_engine` (pure Dart); the engine only knows `ScriptRuntime`, so it has no Flutter or FFI dependency itself. With no runtime injected, script steps fail with a clear "scripting unavailable" error.
- Implementations in `nokho_script`:
  - **Native app + CLI:** QuickJS through `dart:ffi` (one implementation for desktop, Android, CLI; usable inside the engine isolate). iOS/macOS may use JavaScriptCore instead to avoid shipping an interpreter — check App Store rules and behaviour differences in Spike E.
  - **Web Lite:** dedicated Web Worker with no DOM access, terminated on timeout; the `nk.*` bridge is message-passing.
- `nk.*` is a JS prelude over a small set of host functions (`host.getVar`, `host.setVar`, `host.sendRequest`, `host.log`, …). Values cross the boundary as JSON, so the same prelude runs on every runtime.
- Scripts are synchronous by default; `await` is supported only for host calls (`nk.sendRequest`, `nk.sleep`), which the host resolves and then resumes the job queue.
- Mutations are collected and applied by the engine after the script ends successfully (a failed script leaves variables untouched), then recorded in the `RunStep`.
- Scripts are stored as plain text on the request/node; flow snapshots at run start include them.

### 3.6 HTTP adapter abstraction

```dart
abstract class HttpAdapter {
  Future<HttpResult> send(HttpRequestSpec spec, {CancelToken? cancel});
  Stream<HttpEvent> sendStreaming(...);   // progress, SSE
  Capabilities get capabilities;          // supportsCustomMethods, supportsRawHeaders, supportsTimings, supportsProxy, supportsMtls, ...
}
```
- `NativeHttpAdapter` (dart:io HttpClient / dio IOHttpClientAdapter): full control, timings, proxy, mTLS, cookies, redirects.
- `WebHttpAdapter` (fetch/XHR): **browser-restricted** (see CORS edge cases). The UI must read `capabilities` and disable/explain unsupported options instead of failing silently.
- `ProxyHttpAdapter` (web, **post-1.0**): route via **Nokho Agent** (local companion, desktop app or small CLI exposing `localhost:PORT`) or a user-hosted relay, to bypass CORS and forbidden headers. Not built for the lite web version; the adapter interface just leaves room for it.

### 3.7 Riverpod conventions
- Feature-first folders: `features/requests`, `features/flows`, `features/environments`, `features/history`, `features/settings`.
- Repositories exposed via providers (overridable in tests); UI never touches Isar directly.
- Repository `watch…()` streams → `StreamProvider` for reactive lists (Isar `watch()` on native, a broadcast stream in the in-memory implementation).
- Editor state (draft) separate from persisted state; explicit Save, with "unsaved changes" indicator and autosave option.
- Canvas state: separate `FlowEditorController` (selection, viewport, drag, undo stack) from `FlowDef` persistence; debounce persistence of position changes.
- Run state: `flowRunProvider.family(flowId)` consuming engine event stream.
- Use `ref.keepAlive` consciously; dispose engine isolates on provider disposal.

---

## 4. Platform Strategy

| Platform | Notes |
|---|---|
| **macOS / Windows / Linux** | First-class target; full HTTP capability; multi-window; tray; keyboard shortcuts; sandbox entitlements (macOS: `network.client`, file access; localhost server entitlement for agent/webhook). |
| **iOS / Android** | Touch-first UX; single-pane navigation; flow editor w/ tap-to-connect mode; limited background execution (run while foreground; optional foreground service on Android for long flows); share-sheet import of cURL/files; ATS on iOS requires exception config for plain `http://` & local network permission prompt for LAN APIs; Android `usesCleartextTraffic` / network security config for dev. |
| **Web (Lite — decided 2026-11-13)** | Hosted PWA shipping as a **lite version first**; no Nokho Agent/relay until post-1.0. See §4.1 for exact scope. **No saved storage at first**: data lives in memory and moves in and out by import/export (§3.4.1); large payload memory limits. |

### 4.1 Web Lite scope

The browser sends requests directly with `fetch`, so only **CORS-enabled APIs** (and same-origin/localhost APIs that allow the app's origin) are reachable.

**Included**
- Request builder, response viewer, collections, environments, history, tabs.
- Flow builder and flow runs, using the same engine (main thread, no isolate).
- Import/export (`.nokho.json`, cURL, Postman, OpenAPI), code snippets.
- Opening and inspecting flows/run reports exported from desktop or mobile.

**Not available on web (hidden or disabled with an explanation, driven by `HttpAdapter.capabilities`)**
- APIs without CORS headers; https page → `http://` API (mixed content).
- Browser-forbidden headers (`Host`, `Cookie`, `Origin`, `User-Agent`, `Content-Length`, …) and reading `Set-Cookie`; no managed cookie jar (the browser owns cookies).
- Proxy settings, mTLS/client certs, custom CA, disabling TLS verification.
- Manual redirect control and redirect-chain viewer; timing breakdown.
- Non-standard methods rejected by `fetch` (CONNECT, TRACE).
- Webhook Wait node, scheduled/background runs, CLI.
- **Saved storage.** Collections, environments, flows, history and run reports are kept in memory and are gone after a reload or tab close. The user imports a `.nokho.json` to start and exports to keep changes.
- Secrets are session-only (in memory) and are never written to the export unless the user opts in.

**Required UX**
- A persistent "Web Lite" badge with a link to what is limited and a prompt to get the desktop app.
- Failed requests that look like CORS/mixed-content blocks show a specific message, not a generic network error.
- Flow validation flags nodes that use web-unsupported options before a run.

- An "unsaved changes" indicator with a one-click **Export workspace**, and a browser leave-page warning when there are unexported changes.
- Start screen offers: import a file, open the sample workspace, or start empty. Drag-and-drop of a `.nokho.json` onto the page imports it.
- History and run reports are capped more tightly than on native (memory only).

**Later (Phase 5):** saved storage on web (workspace JSON in browser storage, or a web-capable database), and the optional Nokho Agent/relay to lift the network limits.

**Adaptive UI breakpoints:** <600 compact (mobile), 600–1100 medium (tablet), >1100 expanded (desktop). Canvas and request editor are the two screens needing bespoke mobile layouts.

---

## 5. Edge Cases & Failure Modes

### 5.1 Networking
- DNS failure, connection refused, reset, TLS handshake failure, expired/self-signed/hostname-mismatch certs → distinct, human-readable errors with "fix" hints (e.g. "Disable TLS verification for this request").
- Timeouts: connect vs send vs receive; total deadline; timeouts inside loops/polls.
- Redirects: 301/302/303 method rewrite rules, 307/308 preserve, loops, max redirects, cross-origin auth-header stripping, `Location` relative URLs.
- Chunked, streaming, `Content-Length` mismatch, truncated body, gzip/brotli corruption, huge bodies (100MB+), HEAD with body, 204/304 without body, `Expect: 100-continue`.
- HTTP/1.1 vs HTTP/2 vs HTTP/3 capability differences per platform; keep-alive reuse; connection pool limits when running parallel nodes.
- IPv6 literals, `localhost` vs `127.0.0.1` vs `10.0.2.2` (Android emulator) vs `host.docker.internal`; suggest helper rewrites.
- Non-ASCII URLs (IDN/punycode), spaces and unescaped chars, double encoding, `+` vs `%20` in query, repeated query keys, empty vs missing values, fragments (never sent).
- Duplicate headers (`Set-Cookie` multiples), case-insensitivity, header order preservation, invalid header chars, forbidden headers on web.
- Cookies: `SameSite`, `Secure` on http localhost, domain/path matching, expiry, `Max-Age` precedence, cookies set on redirects, cookie isolation between workspaces/environments.
- Proxy auth failures, PAC files (unsupported → warn), proxy with HTTPS CONNECT, no-proxy patterns.
- Offline/airplane mode, network switch mid-request, app suspended mid-request on mobile.
- Captive portals returning HTML instead of JSON.
- Rate limiting (429 + `Retry-After`): optional auto-respect in flows.
- Web: CORS preflight failures indistinguishable from network errors → detect and show "likely CORS" message with relay option; mixed-content (https page → http API) blocked.

### 5.2 Request building
- Unresolved variable `{{foo}}`: warn in UI (red highlight), block/continue by setting; never send literal `{{foo}}` silently by default.
- Variable resolving to empty/null/object/array in a string context; recursive variables (`a → {{b}} → {{a}}`) → detect cycle & max depth.
- Escaping literal `{{` in bodies (e.g. Mustache payloads); JSON body with variable inside quotes vs unquoted (§3.5.2).
- Type-preserving surprises: an ID extracted as a number but the API expects a string (needs `string()`); numeric-looking strings such as `"007"` or phone numbers must stay strings (never auto-coerce strings); integers > 2^53 lose precision on web; whole-value template resolving to `undefined` follows the unresolved-variable policy rather than sending `null`; a string variable containing JSON text is sent as a string unless wrapped in `json()`.
- Invalid-JSON body containing templates (unquoted style or deliberately broken payloads) → fall back to plain text substitution for the whole body and say so in the preview.
- Secrets in URL query → warn; in history → redact.
- Body type switch loses/keeps data (confirm; preserve per-type drafts); `Content-Type` auto-sync with body type and manual override conflicts.
- Form-data with large files: stream from disk, don't load into RAM; file moved/deleted after being attached → stale reference error; sandboxed file access on iOS/macOS (security-scoped bookmarks), Android scoped storage.
- GET with body, DELETE with body: allow but warn on platforms that drop it.
- Invalid JSON body: allow send (testing bad payloads is a core use-case) but flag.
- Binary body from variable (base64 → bytes).
- Extremely long URLs/headers; 10k-row headers tables performance.
- Auth edge cases: token expiry mid-flow → auto-refresh strategy; OAuth redirect on desktop (loopback server) / mobile (custom scheme/universal link) / web (popup); PKCE verifier persistence; clock skew for JWT/SigV4.

### 5.3 Response handling
- Non-UTF8 / mislabeled charset, BOM, null bytes, invalid JSON despite `application/json`, JSON with big integers (>2^53, lossless parse needed — Dart `int` is 64-bit native but 53-bit on web), duplicate keys, NaN/Infinity, deeply nested (stack overflow protection), huge arrays, JSON Lines/NDJSON, JSON5/comments.
- HTML error pages for API errors; empty body with `Content-Type: application/json`.
- Multipart responses; SSE/streaming never ending → memory cap & stop button.
- Rendering massive text → virtualization, line-length caps (single 50MB line).
- Binary detection; image/PDF preview safety.
- Response size cap setting (e.g. 50MB default, keep first N MB, "download full").

### 5.4 Extractors & conditions
- JSONPath returns **0 matches** vs **1** vs **many** → define semantics: scalar mode (first/error if none), list mode; `required` flag → fail node or use default.
- Path matches `null` vs missing vs empty string vs `false`/`0` → condition must distinguish (`exists`, `isNull`, `isEmpty`).
- Response shape changes between runs (field renamed) → clear error "extractor `token` found nothing at `$.data.token`; response keys: …" + quick-fix to re-pick.
- Type mismatch (string "123" vs number 123 in equality) → explicit coercion rules + strict mode.
- Extracting from non-JSON body with JSONPath → error message, not crash.
- Regex: catastrophic backtracking (ReDoS) → timeout/size limit; named groups; multiline flags.
- Array index out of range, negative indices, wildcard flattening, filter expressions with missing keys.
- Extracted value huge (MBs) → store reference/truncate in context display, not in variable table.
- Extractor name collisions, renamed nodes breaking `{{Login.token}}` references → **reference by stable node ID internally, display by name** and auto-rewrite on rename.
- Secrets extracted (tokens) → mark as secret automatically if name matches heuristics (`token`, `password`, `secret`, `key`) and mask in logs.
- Expression errors (division by zero, undefined function) → node failure with location, not engine crash.

### 5.5 Flow graph & execution
- **Cycles:** accidental loops → blocked at validation unless going through Loop/Poll with max iterations (hard cap, default 1000) and wall-clock timeout.
- **Disconnected nodes / orphans / multiple Start nodes / no End** → validation warnings; define policy (orphans ignored with warning).
- **Fan-out then Join with skipped branch** → dead-path elimination so Join doesn't hang; join policies explicit.
- **Diamond dependencies:** node reachable by two paths runs once; which upstream's data wins? → Bindings are by explicit node reference, not by "previous node".
- **Referenced node never executed** (skipped branch) → binding resolves to `undefined` → follow node's `onMissing` policy (fail / default / skip).
- **Request node deleted from collection** while referenced by flow → broken-ref badge; offer relink/remove, or restore from trash; deleting a request that flows reference warns first and offers to convert those nodes to local copies. **Shared is the default**: editing a shared request changes all flows; show "used in N flows" and impact warning.
- **Override drift:** saved request changes body type or removes a header/param that a node overrides → override becomes orphaned; flag it on the node rather than silently dropping or sending it.
- **Moved/duplicated requests:** moving between collections keeps the UUID (and changes inherited auth/scripts → warn); duplicating a collection creates new UUIDs, flows keep pointing at the originals.
- **Unsaved request draft** while a flow runs → run uses the saved version; indicate this in the run report.
- **Loop over empty array** → zero iterations, downstream gets empty result; loop over non-array → error or wrap as single.
- **Nested loops / parallel inside loop** → context scoping for `loop.index` (use named loops `outer.index`).
- **Concurrent writes to the same variable** in parallel branches → last-write-wins is dangerous; make flow variables branch-scoped, merge at Join with explicit strategy.
- **Large iterations** (10k) → UI shows aggregated progress instead of 10k step rows; persist summary + sample + failures only.
- **Partial failure in parallel:** one branch fails → policy cancels siblings or lets them finish.
- **Retries:** idempotency warnings for POST/PATCH/DELETE; retry only on specified conditions (network error, 5xx, 429), jittered backoff; retry counts in report.
- **Cancel while request mid-flight / mid-sleep / mid-poll** → immediate; ensure no zombie isolates; final state "cancelled", not "failed".
- **Pause with in-flight requests** → let in-flight finish, hold next.
- **Run from node X** when upstream cache missing/stale/expired token → prompt "run upstream first?" with TTL-based staleness warning.
- **Editing flow during a run** → lock graph (read-only) or snapshot version at run start; run uses immutable snapshot.
- **Same flow run twice concurrently** → allow with separate contexts; guard shared cookie jar (isolated jar per run option).
- **Environment switched mid-run** → run pinned to env snapshot at start.
- **Flow timeout** (global) and per-node timeouts; max total runtime; max response bytes retained per run.
- **App killed / crashes mid-run** → on restart mark orphan runs "interrupted" and offer resume-from-last-successful-node (P2).
- **Side-effect safety:** "dry run" mode (resolve & show requests without sending), confirmation banner when env is tagged `production`, destructive-method guard (DELETE on prod env requires confirm).
- **Idempotent cleanup:** optional "finally" path that always runs (delete created test data) even after failure.
- **Time-based:** DST/timezone for scheduled runs, clock changes, token expiring `exp` claims (helper to read JWT exp).
- **Manual Input node** on headless/CLI → must be supplied via flags or fail fast.
- **Large graphs** (500+ nodes): canvas virtualization (only paint/build visible nodes), edge culling, hit-testing via spatial index, 60fps pan/zoom target.
- **Edge cases in canvas UX:** overlapping nodes, dragging edge onto incompatible port, duplicate edges, self-loops, deleting node with edges (reconnect-through option), multi-touch conflicts (pinch vs drag node), zoom limits, RTL layouts, text scale up to 200%.

### 5.5.1 Scripting
- Infinite loop / runaway recursion / huge allocation → interrupt handler + memory limit; node fails with "script timed out", engine and UI stay responsive. On web, terminate the Worker.
- Syntax error vs runtime exception vs failed `nk.test` → three distinct outcomes; map line/column back to the user's script (offset by the prelude).
- Unhandled promise rejection, script finishing with pending async work, `await` on a host call after cancel.
- Flow cancelled mid-script; script calling `nk.sendRequest` in a loop (cap requests per script).
- Value marshalling: `undefined`, functions, circular objects, `BigInt`, `Date`, `NaN`, binary data, very large objects set as variables; numbers > 2^53 coming from responses.
- Script sets a variable that a declarative step or a parallel branch also sets → same branch-scoped rules as §5.5; order of execution documented.
- Pre-request script mutates URL/headers/body after variables were resolved → define: scripts run **before** final variable resolution, and anything they set is resolved again once.
- Script-written secrets (token stored via `nk.environment.set`) → inherit the secret flag of the target variable; redact in logs; `console.log` of a secret value is masked by value-matching.
- Inherited collection/folder scripts: failure in a parent script, disabling inheritance per request, same script running for every loop iteration (performance: reuse compiled bytecode, fresh context).
- Engine differences: QuickJS vs JavaScriptCore vs browser engine (Intl, regex lookbehind, date parsing, error messages) → a shared conformance test suite runs on every runtime; document the supported ES level.
- Imported Postman scripts using unsupported APIs → imported as-is but flagged; run fails at the unsupported call with a pointer to the docs, never silently skipped.
- Untrusted scripts from imported/shared workspaces → not run until the user trusts the workspace; scripts cannot reach filesystem, environment variables of the OS, or network outside the HTTP adapter.
- Web: strict CSP must still allow the Worker; no `eval` in the main page.
- Mobile: JIT is unavailable on iOS (interpreter only) → slower scripts; keep limits realistic.
- CLI/headless: same runtime and limits; scripts must not depend on UI prompts.

### 5.6 Persistence & data integrity
- Isar schema migrations: adding/removing/renaming fields, index changes, downgrade (open DB from newer app version → refuse with message, don't corrupt).
- Corrupt DB / crash during write → transactional writes; auto-backup snapshots (daily, keep N); "recover from backup" UI.
- Disk full; DB growth from history/blobs → size meter, auto-prune, "clear history" with confirmation.
- Concurrent access from multiple desktop windows/isolates → single-writer discipline; Isar handles multi-isolate but design repository to avoid races; CLI reading the same DB while app is open.
- Large imports (50MB Postman export) → streaming parse, progress, cancel, partial-import report, duplicate detection (merge/replace/skip).
- Import with unsupported features (Postman scripts using APIs outside the supported subset) → import the script unchanged with per-call warnings (§2.5.1).
- Unicode normalization in names; name collisions in folders; very long names; empty names; illegal filename chars on export.
- Export safety: secrets stripped by default; confirm dialog when including; check output doesn't include history/cookies unless chosen.
- Secure storage unavailable (Linux without keyring, web) → fallback with explicit user passphrase or in-memory-only, never silent plaintext.
- Backup restore across platforms (path separators, file refs) → file attachments stored as relative/embedded.
- Web (in-memory): accidental reload, tab crash, browser update or the OS discarding a background tab loses everything since the last export → leave-page warning, visible unsaved indicator, export reminders after N changes. The leave-page warning cannot fire on a crash, so say plainly on the start screen that web does not save.
- Web: importing a second file while unexported changes exist → ask to merge, replace or cancel; exporting a large workspace (many MB of history) → exclude history/run reports by default.
- Web → native hand-off: a workspace exported from web must import cleanly into the Isar-backed app and back (round-trip test in CI).
- If web later gains browser storage: eviction by the browser (Safari ITP 7-day, private mode) → warn, request persistent storage, keep export reminders.

### 5.7 Security & abuse
- Imported content containing malicious scripts/URLs → never auto-execute; show a trust prompt when opening shared workspaces.
- SSRF-style: app intentionally can call anything (including `localhost`, metadata IPs) — that's a feature; but web relay/agent must **not** be an open proxy: bind to loopback, require token, restrict origins.
- Nokho Agent local server: CSRF/DNS rebinding protection (Origin/Host validation, per-session token).
- OAuth tokens in logs/crash reports; clipboard exposure; screenshots of secrets in app switcher (blur on background for mobile).
- Cert pinning for the app's own update channel; signed builds; notarization.
- Zip-bomb/decompression bomb in responses → decompressed size cap.
- ReDoS via user regex; expression evaluator CPU/time/recursion limits.
- Local webhook listener exposure to LAN → default loopback only.

### 5.8 UX / Product edge cases
- First launch with no network; empty states for every list; sample content.
- Unsaved changes on close/tab switch/OS kill → draft recovery.
- Undo after delete (toast with Undo); accidental drag-and-drop in tree.
- Very long JSON keys/values in table cells; RTL text; emoji; large font scaling; high-contrast mode; colorblind-safe status colors (don't rely on red/green only).
- Mobile keyboards: `{`, `"` access, smart-quotes/auto-correct must be disabled in editors; hardware keyboard support on iPad.
- Copy/paste of multi-line headers (`Key: Value` lines) → auto-parse into table.
- Localized number/date formatting vs raw API values (never localize payloads).
- Background → foreground on mobile while flow running: continue vs pause policy, notifications on completion.
- Battery/thermal on long loops on mobile → warn.
- Accessibility: screen reader for canvas (list view alternative for flows), keyboard-only graph editing (arrow-key navigation, "connect to…" command palette).

---

## 6. Non-Functional Requirements

| Area | Target |
|---|---|
| Cold start | < 2 s desktop, < 3 s mobile on mid-tier device |
| UI frame rate | 60 fps canvas pan/zoom with 200 nodes; 30+ fps with 500 |
| Memory | Handle 50 MB JSON response without UI freeze (parse in isolate, lazy tree) |
| Flow throughput | ≥ 100 sequential simple requests/sec local engine overhead < 2 ms/node |
| Offline | 100% of non-network features work offline |
| Data safety | No data loss on crash (≤ last 1s of edits); daily auto-backup |
| Accessibility | WCAG 2.1 AA for non-canvas screens; keyboard alternatives for canvas |
| Test coverage | ≥ 85% engine/core, ≥ 70% overall; golden tests for key screens |
| Binary size | Desktop < 60 MB, mobile < 40 MB, web initial < 3 MB gzip (deferred loading for canvas/editor) |
| Privacy | Zero network calls except user requests (and opt-in update check) |

---

## 7. Roadmap

### Phase 0 — Foundations & Spikes (2–3 weeks)
Goal: kill the biggest risks before building features.
- [ ] Repo, melos workspace, CI (analyze, test, build matrix), flavors (dev/prod), lints.
- [ ] **Spike A — Isar Community on native platforms.** macOS passed; web failed to compile, which led to the §3.4.1 decision. Remaining: Android, iOS, isolates + large blob, schema change, ADR 0001. Results in `docs/spikes/a-persistence-results.md`.
- [ ] **Spike B — Canvas:** prototype node graph with 200 nodes (pan/zoom/drag/connect) on desktop + phone; choose custom vs package.
- [ ] **Spike C — HTTP adapters:** native full-control vs web `fetch` restrictions; define the `capabilities` matrix and CORS/mixed-content error detection for Web Lite.
- [ ] **Spike D — JSON editor/viewer perf** with 10–50 MB payloads.
- [ ] **Spike E — JS runtime:** run one script with a host callback, a timeout kill and a memory limit on all 6 platforms plus the pure-Dart CLI and inside an isolate; choose `flutter_js` vs direct QuickJS FFI, and QuickJS vs JavaScriptCore on Apple platforms.
- [ ] Design system tokens, theming, adaptive scaffold; write ADRs for each decision.
- [ ] Define `.nokho.json` schema v1 and expression-language grammar.

### Phase 1 — Single-Request MVP (4–5 weeks) → "Mini Postman"
- Request builder (methods, URL/params, headers, JSON/raw/form body, Basic/Bearer/API key).
- Response viewer (pretty/raw/headers/cookies, JSON tree, timing basics).
- Collections/folders, environments + variables, history, tabs.
- cURL import/export, native JSON export/import.
- Engine v0: single send via the same engine API.
- Desktop + Android + iOS builds; Web Lite build (direct `fetch`, capability-gated UI, in-memory repositories with import/export, §4.1).
- Repository interfaces with Isar and in-memory implementations passing one shared contract test suite.
- **Exit criteria:** daily-usable for basic API testing; 0 data-loss bugs.

### Phase 2 — Flow Builder Alpha (6–8 weeks)
- Canvas, Start/Request/End/Delay/Condition/Assert nodes.
- Extractors (JSONPath, header, status, regex), bindings, edge conditions.
- Engine v1: validation, ready-set scheduler, run events, failure policies, cancel.
- Run visualization, per-node inspector, run history & report.
- Undo/redo, auto-save, flow validation panel.
- **Exit criteria:** build & run "login → create → get → delete" flow in < 5 min using only the UI.

### Phase 3 — Power Features / Beta (9–12 weeks)
- Loop, Parallel/Join, Poll Until, Switch, Set Variable/Transform, Error handler, Manual input, Log.
- Debug mode (breakpoints, step, edit-and-continue), run-from-node with cache.
- Datasets (CSV/JSON), retries/backoff, JSON Schema validation.
- JS scripting: `ScriptRuntime` + `nk.*`/`pm.*` bridge, pre/post scripts, Script node, script editor, conformance suite, Postman script import check (adds roughly 3–4 weeks to this phase).
- OAuth 2.0, cookie jar UI, proxy, mTLS, redirects control.
- Postman + OpenAPI import; code snippet generation.
- CLI runner + JUnit/HTML reports.
- Performance pass (large graphs, large payloads), accessibility pass.

### Phase 4 — Release 1.0 (4 weeks)
- Onboarding & templates, polishing, localization infra, docs site.
- Crash handling, backups, migrations hardening, security review.
- Packaging: macOS notarized DMG / App Store, Windows MSIX/installer, Linux (AppImage/deb/Flatpak), TestFlight → App Store, Play Store, PWA hosting.
- Beta program, feedback loop, bug bash.

### Phase 5 — Post-1.0 (rolling)
Sub-flows, flow versioning, scheduler & headless agent, saved storage on web, Nokho Agent/relay for full-featured web, WebSocket/SSE/gRPC, wider Postman script compatibility (legacy syntax, more bundled libraries), mock server, cloud sync (E2E), team workspaces, Git-friendly folder format, plugin API.

---

## 8. Testing Strategy

- **Unit:** extractors, expression evaluator (property-based/fuzz), variable resolver, scheduler (ready-set, dead-path), importers (golden corpora from real Postman/OpenAPI files).
- **Engine integration:** local `shelf` test server exposing scripted endpoints (delays, redirects, 5xx, flaky, huge bodies, malformed JSON, cookie setting, auth flows) — the same server doubles as the in-app demo API.
- **Repository tests:** one contract suite run against both the Isar implementation (temp dir) and the in-memory implementation; migration tests (N-1 → N fixtures committed); web ↔ native export/import round-trip.
- **Widget/golden:** request editor, response viewer, canvas nodes in light/dark, text-scale 1.0/2.0, RTL.
- **Canvas interaction tests:** gesture simulation (drag/connect/zoom), perf benchmarks via `integration_test` + timeline summaries.
- **E2E:** desktop (integration_test / `patrol`), mobile device farm smoke tests, web Playwright against the PWA + agent.
- **Chaos tests:** network drop, kill app mid-run, slow disk, low memory.
- **Security tests:** secret redaction snapshot tests across logs/exports/history; agent CSRF/rebinding tests.
- **CI:** analyze + format + unit on every PR; build matrix nightly; performance regression gate on engine benchmarks.

---

## 9. Risks & Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| **Isar Community has no web support** (confirmed in Spike A) | Web cannot save data | Accepted: web is in-memory with import/export (§3.4.1); saved web storage deferred to Phase 5 |
| **Web users lose work** (reload, crash, closed tab) | Frustration, lost trust | Plain "web does not save" notice, unsaved indicator, leave-page warning, export reminders |
| **Isar Community long-term maintenance** | Native persistence stranded on an unmaintained library | Repository interfaces carry no Isar types, so Drift/SQLite can replace it without touching domain/UI; contract test suite makes a swap checkable |
| **Web CORS limits which APIs are reachable** | Web users hit blocked requests | Accepted: web ships as Lite (§4.1) with clear capability UI and CORS-specific errors; agent/relay deferred to Phase 5 |
| **Canvas performance/UX on mobile** | Poor flow editing | Early spike; simplified mobile editing mode (list + connect sheet); virtualization |
| **Scope creep (Postman parity)** | Never ships | Strict phase gates; P0/P1/P2 tags; focus on flow differentiator |
| **Expression/extractor complexity** | Support burden | Small well-specified language, great error messages, UI pickers instead of typing |
| **JS runtime across 6 platforms + CLI + isolates** | Scripting inconsistent or missing on some targets; 1.0 slips | Spike E in Phase 0; single `ScriptRuntime` interface; shared conformance suite; fallback: ship scripting on native first and mark it "coming soon" on Web Lite |
| **Postman-compat expectations** | Users expect every imported script to work | Publish the supported subset; static import check with per-call warnings |
| **Flutter desktop gaps** (multi-window, native menus, tray) | UX papercuts | Evaluate packages in Phase 0; accept limited multi-window at 1.0 |
| **Large payload jank** | Bad perception | Isolate parsing, lazy trees, caps |
| **Secrets leakage** | Trust loss | Redaction by default, tests, secure storage, no telemetry |
| **App Store review** (dev tools hitting arbitrary hosts, local network) | Launch delay | Proper permission strings, clear purpose, test accounts |
| **Solo-dev bandwidth** | Delay | Pure-Dart engine package + CLI allows incremental testing; ship phases independently |

---

## 10. Open Questions / Decisions Needed

1. **Name & identity:** "Nokho-Flow" — confirm package IDs (`com.nokho.flow`?), domain, license (open-source core vs closed?).
2. **Business model:** free/local-only forever vs paid cloud sync/team tier? Affects data model (`rev`, sync) now.
3. ~~**Web scope:** full-feature (with agent) or "lite" viewer/runner?~~ **Decided 2026-11-13: Lite first** (§4.1); agent revisited post-1.0.
4. ~~**Scripting:** declarative-only for 1.0, or must support Postman-style JS?~~ **Decided 2026-11-13: JS scripting ships in 1.0** alongside declarative steps (§2.5.1, §3.5.1).
5. ~~**Shared vs inline request nodes:** default behavior when dragging a saved request onto canvas?~~ **Decided 2026-11-13: shared reference by default**, with one-click "Make local copy" (§2.4 "Shared request nodes").
6. ~~**Variable typing rule** for `"{{x}}"` (type-preserving vs always-string).~~ **Decided 2026-11-13: type-preserving** for whole-value templates in JSON contexts (§3.5.2).
7. **Open-source strategy:** engine + CLI as OSS for adoption?
8. **Git-friendly storage** as primary format vs Isar-primary with export (Bruno-style)? Recommendation: Isar primary at 1.0, folder export in Phase 5.
9. **Target minimum OS versions** (iOS 15+? Android 8+? macOS 11+?).
10. **Localization languages** for launch.

---

## 11. Immediate Next Steps

1. Review/answer the rest of §10 (3–6 are decided; 1 — package IDs and license — is needed before scaffolding).
2. Create repo structure from §3.2 and the Phase-0 spike branches.
3. Write ADR-001 (persistence), ADR-002 (canvas), ADR-003 (HTTP adapters & agent), ADR-004 (expression language), ADR-005 (JS runtime).
4. Draft `.nokho.json` v1 schema + 3 sample flows used as the acceptance fixtures for Phase 2.
5. Set up the `shelf` demo/test API server (reused for onboarding and tests).
