/// Runs user JavaScript. Implementations live in `nokho_script`; the engine
/// only knows this interface. See docs/PLAN.md section 3.5.1.
abstract interface class ScriptRuntime {
  Future<ScriptResult> run(
    String source, {
    ScriptLimits limits = const ScriptLimits(),
  });
}

class ScriptLimits {
  const ScriptLimits({this.timeout = const Duration(seconds: 5)});

  final Duration timeout;
}

sealed class ScriptResult {
  const ScriptResult();
}

class ScriptSuccess extends ScriptResult {
  const ScriptSuccess({this.logs = const []});

  final List<String> logs;
}

class ScriptFailure extends ScriptResult {
  const ScriptFailure(this.message, {this.line});

  final String message;

  /// 1-based line in the user's script, when known.
  final int? line;
}

/// Used when no runtime was injected: script steps fail with a clear reason
/// instead of being skipped.
class UnavailableScriptRuntime implements ScriptRuntime {
  const UnavailableScriptRuntime();

  @override
  Future<ScriptResult> run(
    String source, {
    ScriptLimits limits = const ScriptLimits(),
  }) async =>
      const ScriptFailure('Scripting is not available on this platform.');
}
