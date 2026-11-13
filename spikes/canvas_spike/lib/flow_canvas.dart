import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'graph_controller.dart';

/// Pannable, zoomable node graph.
///
/// Nodes are real widgets, laid out once at a fixed world size and placed by
/// a [Flow] delegate, so panning and zooming repaint without rebuilding or
/// relaying out any node. Edges and the dot grid are one [CustomPaint]
/// underneath. Both layers skip whatever is outside the viewport.
class FlowCanvas extends StatefulWidget {
  const FlowCanvas({super.key, required this.controller});

  final GraphController controller;

  @override
  State<FlowCanvas> createState() => _FlowCanvasState();
}

class _FlowCanvasState extends State<FlowCanvas> {
  double _scaleAtGestureStart = 1;

  GraphController get _c => widget.controller;

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScaleEvent) {
      // Browser pinch (ctrl + wheel).
      _c.zoomAt(event.localPosition, event.scale);
    } else if (event is PointerScrollEvent) {
      final zoomModifier =
          HardwareKeyboard.instance.isControlPressed ||
          HardwareKeyboard.instance.isMetaPressed;
      if (kIsWeb && !zoomModifier) {
        // Browsers report trackpad scrolling as wheel events: pan.
        _c.panBy(-event.scrollDelta);
      } else {
        // Desktop mouse wheel: zoom around the cursor.
        _c.zoomAt(event.localPosition, math.exp(-event.scrollDelta.dy / 400));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Listener(
      onPointerSignal: _onPointerSignal,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        // Covers mouse drag, touch drag, touch pinch and (on desktop)
        // trackpad two-finger pan and pinch.
        onScaleStart: (_) => _scaleAtGestureStart = _c.scale,
        onScaleUpdate: (d) {
          _c.panBy(d.focalPointDelta);
          if (d.scale != 1) {
            _c.setScaleAt(d.localFocalPoint, _scaleAtGestureStart * d.scale);
          }
        },
        child: ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              RepaintBoundary(
                child: CustomPaint(
                  painter: _BackgroundPainter(
                    _c,
                    edgeColor: scheme.outline,
                    gridColor: scheme.outlineVariant,
                  ),
                ),
              ),
              Flow(
                delegate: _NodeFlowDelegate(_c),
                children: [
                  for (final node in _c.nodes)
                    RepaintBoundary(child: NodeCard(node: node)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NodeFlowDelegate extends FlowDelegate {
  _NodeFlowDelegate(this.controller) : super(repaint: controller);

  final GraphController controller;

  @override
  Size getSize(BoxConstraints constraints) => constraints.biggest;

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) =>
      BoxConstraints.tight(NodeData.size);

  @override
  void paintChildren(FlowPaintingContext context) {
    final visible = controller.visibleWorldRect(context.size);
    final scale = controller.scale;
    for (var i = 0; i < context.childCount; i++) {
      final node = controller.nodes[i];
      if (!visible.overlaps(node.rect)) continue;
      final screen = controller.toScreen(node.position);
      context.paintChild(
        i,
        transform: Matrix4.diagonal3Values(scale, scale, 1)
          ..setTranslationRaw(screen.dx, screen.dy, 0),
      );
    }
  }

  @override
  bool shouldRepaint(_NodeFlowDelegate oldDelegate) =>
      oldDelegate.controller != controller;
}

class _BackgroundPainter extends CustomPainter {
  _BackgroundPainter(
    this.controller, {
    required this.edgeColor,
    required this.gridColor,
  }) : super(repaint: controller);

  final GraphController controller;
  final Color edgeColor;
  final Color gridColor;

  static const _gridStep = 40.0;

  @override
  void paint(Canvas canvas, Size size) {
    final visible = controller.visibleWorldRect(size);
    final scale = controller.scale;
    canvas
      ..save()
      ..translate(controller.translation.dx, controller.translation.dy)
      ..scale(scale);

    // Dot grid, skipped when zoomed far out (too many dots to matter).
    if (scale >= 0.35) {
      final x0 = (visible.left / _gridStep).floor() * _gridStep;
      final y0 = (visible.top / _gridStep).floor() * _gridStep;
      final cols = ((visible.right - x0) / _gridStep).ceil() + 1;
      final rows = ((visible.bottom - y0) / _gridStep).ceil() + 1;
      final points = Float32List(cols * rows * 2);
      var p = 0;
      for (var r = 0; r < rows; r++) {
        for (var c = 0; c < cols; c++) {
          points[p++] = x0 + c * _gridStep;
          points[p++] = y0 + r * _gridStep;
        }
      }
      canvas.drawRawPoints(
        ui.PointMode.points,
        points,
        Paint()
          ..color = gridColor
          ..strokeWidth = 2 / scale
          ..strokeCap = StrokeCap.round,
      );
    }

    // All visible edges in one path, one draw call.
    final path = Path();
    for (final edge in controller.edges) {
      final a = controller.nodes[edge.from].outPort;
      final b = controller.nodes[edge.to].inPort;
      if (!visible.overlaps(Rect.fromPoints(a, b).inflate(60))) continue;
      final bend = math.max(40.0, (b.dx - a.dx).abs() / 2);
      path
        ..moveTo(a.dx, a.dy)
        ..cubicTo(a.dx + bend, a.dy, b.dx - bend, b.dy, b.dx, b.dy);
    }
    canvas
      ..drawPath(
        path,
        Paint()
          ..color = edgeColor
          ..style = PaintingStyle.stroke
          // Keep edges readable when zoomed out, without getting fat.
          ..strokeWidth = math.max(1.5, 1.2 / scale),
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_BackgroundPainter oldDelegate) =>
      oldDelegate.controller != controller ||
      oldDelegate.edgeColor != edgeColor ||
      oldDelegate.gridColor != gridColor;
}

class NodeCard extends StatelessWidget {
  const NodeCard({super.key, required this.node});

  final NodeData node;

  static Color _accent(NodeKind kind) => switch (kind) {
    NodeKind.start => const Color(0xFF2E9E6B),
    NodeKind.request => const Color(0xFF3D6FE0),
    NodeKind.condition => const Color(0xFFC98A1A),
    NodeKind.delay => const Color(0xFF8A63D2),
    NodeKind.end => const Color(0xFFC2484D),
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = _accent(node.kind);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          _Port(color: scheme.outline),
          Container(
            width: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  node.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  node.subtitle,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 11,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          _Port(color: scheme.outline),
        ],
      ),
    );
  }
}

class _Port extends StatelessWidget {
  const _Port({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: DecoratedBox(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: const SizedBox.square(dimension: 8),
      ),
    );
  }
}
