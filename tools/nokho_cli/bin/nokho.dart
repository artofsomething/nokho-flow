import 'dart:io';

const _version = '0.1.0';

void main(List<String> args) {
  if (args.contains('--version')) {
    stdout.writeln('nokho $_version');
    return;
  }
  stdout.writeln('nokho $_version - headless Nokho-Flow runner');
  stdout.writeln('Usage: nokho run <flow.nokho.json> [--env <name>]');
  if (args.isNotEmpty && args.first == 'run') {
    stderr.writeln('`run` is not implemented yet (Phase 3).');
    exitCode = 64;
  }
}
