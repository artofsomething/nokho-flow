import 'package:flutter/material.dart';

import 'flow_canvas.dart';
import 'graph_controller.dart';

void main() => runApp(const CanvasSpikeApp());

class CanvasSpikeApp extends StatelessWidget {
  const CanvasSpikeApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF3D5AFE);
    return MaterialApp(
      title: 'Canvas spike',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: seed),
      darkTheme: ThemeData(colorSchemeSeed: seed, brightness: Brightness.dark),
      home: const CanvasSpikePage(),
    );
  }
}

class CanvasSpikePage extends StatefulWidget {
  const CanvasSpikePage({super.key});

  @override
  State<CanvasSpikePage> createState() => _CanvasSpikePageState();
}

class _CanvasSpikePageState extends State<CanvasSpikePage> {
  final _controller = GraphController();
  final _canvasKey = GlobalKey();
  int _nodeCount = 200;

  @override
  void initState() {
    super.initState();
    _controller.generate(_nodeCount);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fit());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Size get _viewport => _canvasKey.currentContext?.size ?? Size.zero;

  void _fit() => _controller.fit(_viewport);

  void _zoom(double factor) =>
      _controller.zoomAt(_viewport.center(Offset.zero), factor);

  void _setNodeCount(int count) {
    setState(() {
      _nodeCount = count;
      _controller.generate(count);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _fit());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  SegmentedButton<int>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: 200, label: Text('200 nodes')),
                      ButtonSegment(value: 500, label: Text('500 nodes')),
                    ],
                    selected: {_nodeCount},
                    onSelectionChanged: (s) => _setNodeCount(s.first),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    tooltip: 'Zoom out',
                    onPressed: () => _zoom(1 / 1.25),
                    icon: const Icon(Icons.remove),
                  ),
                  ListenableBuilder(
                    listenable: _controller,
                    builder: (context, _) => SizedBox(
                      width: 52,
                      child: Text(
                        '${(_controller.scale * 100).round()}%',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Zoom in',
                    onPressed: () => _zoom(1.25),
                    icon: const Icon(Icons.add),
                  ),
                  IconButton(
                    tooltip: 'Fit to screen',
                    onPressed: _fit,
                    icon: const Icon(Icons.fit_screen_outlined),
                  ),
                  const Spacer(),
                  Text(
                    '${_controller.nodes.length} nodes · '
                    '${_controller.edges.length} edges',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: FlowCanvas(
                // New key per graph so the Flow gets a fresh child list.
                key: _canvasKey,
                controller: _controller,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
