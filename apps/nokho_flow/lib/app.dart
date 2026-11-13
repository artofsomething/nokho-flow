import 'package:flutter/material.dart';
import 'package:nokho_ui/nokho_ui.dart';

class NokhoFlowApp extends StatelessWidget {
  const NokhoFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nokho-Flow',
      debugShowCheckedModeBanner: false,
      theme: NokhoTheme.light(),
      darkTheme: NokhoTheme.dark(),
      home: const _HomePlaceholder(),
    );
  }
}

class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nokho-Flow')),
      body: const Center(child: Text('Phase 0 scaffold')),
    );
  }
}
