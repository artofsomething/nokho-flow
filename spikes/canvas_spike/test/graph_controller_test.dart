import 'package:canvas_spike/flow_canvas.dart';
import 'package:canvas_spike/graph_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GraphController viewport', () {
    test('zoomAt keeps the world point under the cursor fixed', () {
      final c = GraphController()..panBy(const Offset(37, -12));
      const focal = Offset(300, 200);
      final worldBefore = c.toWorld(focal);
      c.zoomAt(focal, 1.7);
      expect(c.scale, closeTo(1.7, 1e-9));
      final worldAfter = c.toWorld(focal);
      expect(worldAfter.dx, closeTo(worldBefore.dx, 1e-9));
      expect(worldAfter.dy, closeTo(worldBefore.dy, 1e-9));
    });

    test('scale is clamped to the allowed range', () {
      final c = GraphController();
      c.zoomAt(Offset.zero, 1000);
      expect(c.scale, GraphController.maxScale);
      c.zoomAt(Offset.zero, 0.000001);
      expect(c.scale, GraphController.minScale);
    });

    test('toScreen and toWorld are inverses', () {
      final c = GraphController()
        ..panBy(const Offset(120, 45))
        ..zoomAt(const Offset(10, 10), 0.4);
      const world = Offset(812.5, -93);
      final back = c.toWorld(c.toScreen(world));
      expect(back.dx, closeTo(world.dx, 1e-9));
      expect(back.dy, closeTo(world.dy, 1e-9));
    });

    test('fit shows the whole graph inside the viewport', () {
      final c = GraphController()..generate(200);
      const viewport = Size(1200, 800);
      c.fit(viewport);
      final visible = c.visibleWorldRect(viewport);
      final bounds = c.contentBounds;
      expect(visible.left, lessThanOrEqualTo(bounds.left));
      expect(visible.top, lessThanOrEqualTo(bounds.top));
      expect(visible.right, greaterThanOrEqualTo(bounds.right));
      expect(visible.bottom, greaterThanOrEqualTo(bounds.bottom));
    });
  });

  group('generated graph', () {
    test('200 nodes get roughly 1.25 edges each, all valid', () {
      final c = GraphController()..generate(200);
      expect(c.nodes, hasLength(200));
      expect(c.edges.length, inInclusiveRange(230, 270));
      for (final e in c.edges) {
        expect(e.from, inInclusiveRange(0, 199));
        expect(e.to, inInclusiveRange(0, 199));
        expect(e.from, isNot(e.to));
      }
    });
  });

  testWidgets('canvas builds 200 node cards and pans by drag', (tester) async {
    final c = GraphController()..generate(200);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: FlowCanvas(controller: c)),
      ),
    );
    expect(find.byType(NodeCard), findsNWidgets(200));

    final before = c.translation;
    await tester.drag(find.byType(FlowCanvas), const Offset(-150, 60));
    await tester.pump();
    // Drag distance minus the gesture's touch slop.
    expect(c.translation.dx, lessThan(before.dx - 100));
    expect(c.translation.dy, greaterThan(before.dy + 30));
  });
}
