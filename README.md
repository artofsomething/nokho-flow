# Nokho-Flow

API testing client with a visual flow builder: send requests like Postman, then chain them on a graph and pass response values from one request to the next.

Status: Phase 0 scaffold. See [docs/PLAN.md](docs/PLAN.md).

## Layout

| Path | What |
|---|---|
| `apps/nokho_flow` | Flutter app |
| `packages/nokho_core` | Shared entities (pure Dart) |
| `packages/nokho_http` | `HttpAdapter` interface and implementations |
| `packages/nokho_engine` | Flow engine and `ScriptRuntime` interface (pure Dart) |
| `packages/nokho_script` | JS runtime implementations |
| `packages/nokho_storage` | Repositories and persistence |
| `packages/nokho_importers` | cURL, Postman, OpenAPI, HAR importers |
| `packages/nokho_codegen_snippets` | Request to code snippets |
| `packages/nokho_flow_canvas` | Node-graph canvas widget |
| `packages/nokho_ui` | Design system |
| `tools/nokho_cli` | Headless runner (`nokho`) |
| `docs/adr` | Architecture decision records |
| `docs/spikes` | Phase 0 spike briefs |

This is a Dart pub workspace: one `flutter pub get` at the root resolves every package.

## Commands

```bash
flutter pub get
flutter analyze
(cd packages/nokho_core && dart test)
(cd apps/nokho_flow && flutter test)
(cd apps/nokho_flow && flutter run -d macos)
dart run tools/nokho_cli/bin/nokho.dart --version
```

## Running on web

Debug with hot reload (Flutter opens its own Chrome window):

```bash
(cd apps/nokho_flow && flutter run -d chrome)
```

Serve on a fixed port for any browser, release mode:

```bash
(cd apps/nokho_flow && flutter run --release -d web-server --web-hostname localhost --web-port 8123)
```

With Flutter 3.44.6, `-d web-server` in **debug** mode shows a blank page: the injected debug client fails to decode a message and never starts the app. Use `-d chrome` for debugging, or `--release` with `web-server`. `.claude/launch.json` uses the release command for that reason.
