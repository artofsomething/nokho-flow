# Spike B — Flow canvas: results log

Raw results per step. The decision goes in ADR 0002 once every step is done.

Setup: Flutter 3.44.6, no canvas packages. Code: `spikes/canvas_spike`.

## Step B2 — Custom prototype: render, pan, zoom (2026-11-13)

Approach:

- **Nodes are real widgets**, laid out once at a fixed world size and placed by a `Flow` delegate. Pan and zoom only repaint; no node is rebuilt or laid out again. Each node sits in its own `RepaintBoundary`.
- **Edges and the dot grid are one `CustomPaint`** under the nodes. All visible edges go into a single path and one draw call.
- **Both layers cull** to the viewport: nodes outside it are not painted (so not hit-testable either), edges are skipped by bounding box.
- **One controller** (`GraphController`, a `ChangeNotifier`) owns the graph and the viewport (scale + translation) and drives both layers through `repaint:`.
- Input: drag pans; pinch and trackpad gestures go through `GestureDetector`'s scale callbacks; mouse wheel zooms around the cursor on desktop. On web, wheel events pan (browsers report trackpad scrolling as wheel) and ctrl/cmd + wheel zooms.

Checked:

| Check | Result |
|---|---|
| 200 nodes, 247 edges generated and rendered | Pass (web, release build, in-app browser pane) |
| Fit to screen | Pass: whole graph visible at 12% in a 718 × 523 viewport |
| Zoom in/out around the viewport centre (buttons) | Pass |
| Pan by mouse drag | Pass |
| Pan by wheel scroll (web) | Pass |
| Unit tests: zoom keeps the point under the cursor fixed, scale clamps, coordinate round-trip, fit contains the graph | Pass (6 tests incl. one widget test) |
| macOS debug build | Compiles |

Not checked yet:

- Trackpad pinch and two-finger pan on macOS, and a real mouse wheel: only synthetic mouse input in the browser pane was used.
- Touch (step B6), frame times (step B5), 500 nodes beyond a visual load.

Notes:

- Dragging on a node currently pans the canvas, because nodes have no gesture handling yet. Node drag comes in B3 and will need to win over the canvas pan.
- Below 35% zoom the dot grid is hidden; at 12% node text is unreadable. A simplified node rendering at low zoom (level of detail) is a likely follow-up.
