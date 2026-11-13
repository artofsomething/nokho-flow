import 'http_request_spec.dart';

/// What came back from a single HTTP exchange.
class HttpResult {
  const HttpResult({
    required this.statusCode,
    required this.reasonPhrase,
    required this.headers,
    required this.bodyBytes,
    required this.elapsed,
  });

  final int statusCode;
  final String reasonPhrase;
  final List<HttpHeader> headers;
  final List<int> bodyBytes;
  final Duration elapsed;

  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  /// All values for [name], matched case-insensitively, in received order.
  List<String> headerValues(String name) {
    final wanted = name.toLowerCase();
    return [
      for (final h in headers)
        if (h.name.toLowerCase() == wanted) h.value,
    ];
  }
}
