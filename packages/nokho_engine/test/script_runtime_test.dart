import 'package:nokho_engine/nokho_engine.dart';
import 'package:test/test.dart';

void main() {
  test('unavailable runtime fails scripts instead of skipping them', () async {
    final result = await const UnavailableScriptRuntime().run('1 + 1');
    expect(result, isA<ScriptFailure>());
  });
}
