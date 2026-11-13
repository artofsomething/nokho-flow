import 'dart:ui';

import 'package:flutter/foundation.dart';

enum NodeKind { start, request, condition, delay, end }

class NodeData {
  NodeData({
    required this.index,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.position,
  });

  /// World-space size of every node in the spike.
  static const size = Size(180, 64);

  /// Position in [GraphController.nodes]; also the Flow child index.
  final int index;
  final NodeKind kind;
  final String title;
  final String subtitle;

  /// Top-left corner in world coordinates.
  Offset position;

  Rect get rect => position & size;
  Offset get inPort => position + Offset(0, size.height / 2);
  Offset get outPort => position + Offset(size.width, size.height / 2);
}

class EdgeData {
  const EdgeData(this.from, this.to);

  final int from;
  final int to;
}

/// Holds the graph and the viewport (pan + zoom). Notifies on every change;
/// the canvas repaints from it without rebuilding widgets.
class GraphController extends ChangeNotifier {
  static const minScale = 0.1;
  static const maxScale = 3.0;

  final List<NodeData> nodes = [];
  final List<EdgeData> edges = [];

  double _scale = 1;
  Offset _translation = Offset.zero;

  double get scale => _scale;
  Offset get translation => _translation;

  Offset toScreen(Offset world) => world * _scale + _translation;
  Offset toWorld(Offset screen) => (screen - _translation) / _scale;

  /// The part of the world currently inside a viewport of [viewport] size.
  Rect visibleWorldRect(Size viewport) =>
      toWorld(Offset.zero) & (viewport / _scale);

  void panBy(Offset screenDelta) {
    if (screenDelta == Offset.zero) return;
    _translation += screenDelta;
    notifyListeners();
  }

  /// Sets the zoom to [newScale], keeping the world point under
  /// [focalScreen] fixed on screen.
  void setScaleAt(Offset focalScreen, double newScale) {
    final clamped = newScale.clamp(minScale, maxScale);
    if (clamped == _scale) return;
    final world = toWorld(focalScreen);
    _scale = clamped;
    _translation = focalScreen - world * _scale;
    notifyListeners();
  }

  void zoomAt(Offset focalScreen, double factor) =>
      setScaleAt(focalScreen, _scale * factor);

  Rect get contentBounds {
    if (nodes.isEmpty) return Rect.zero;
    var bounds = nodes.first.rect;
    for (final n in nodes) {
      bounds = bounds.expandToInclude(n.rect);
    }
    return bounds;
  }

  /// Zooms and pans so the whole graph is visible with [padding] around it.
  void fit(Size viewport, {double padding = 48}) {
    final bounds = contentBounds;
    if (bounds.isEmpty || viewport.isEmpty) return;
    final sx = (viewport.width - padding * 2) / bounds.width;
    final sy = (viewport.height - padding * 2) / bounds.height;
    _scale = (sx < sy ? sx : sy).clamp(minScale, maxScale);
    _translation = viewport.center(Offset.zero) - bounds.center * _scale;
    notifyListeners();
  }

  /// Replaces the graph with a layered test graph of [count] nodes:
  /// columns of 10, each node linked to the next column, plus extra
  /// diagonal links on about a third of them (roughly 1.25 edges per node).
  void generate(int count) {
    const rows = 10;
    const dx = 260.0;
    const dy = 110.0;
    nodes.clear();
    edges.clear();
    for (var i = 0; i < count; i++) {
      final col = i ~/ rows;
      final row = i % rows;
      final kind = col == 0
          ? NodeKind.start
          : switch (i % 9) {
              0 => NodeKind.condition,
              4 => NodeKind.delay,
              _ => NodeKind.request,
            };
      nodes.add(
        NodeData(
          index: i,
          kind: kind,
          title: switch (kind) {
            NodeKind.start => 'Start $row',
            NodeKind.request => '${_methods[i % _methods.length]} /items/$i',
            NodeKind.condition => 'If status == 200',
            NodeKind.delay => 'Wait 500 ms',
            NodeKind.end => 'End',
          },
          subtitle: 'node $i',
          // Stagger alternate columns so edges are not all straight lines.
          position: Offset(col * dx, row * dy + (col.isOdd ? 30 : 0)),
        ),
      );
    }
    for (var i = 0; i < count; i++) {
      final next = i + rows;
      if (next >= count) continue;
      edges.add(EdgeData(i, next));
      final row = i % rows;
      final col = i ~/ rows;
      if ((row + col) % 3 == 0 && row < rows - 1 && next + 1 < count) {
        edges.add(EdgeData(i, next + 1));
      }
    }
    notifyListeners();
  }

  static const _methods = ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'];
}
