/// A fully resolved HTTP request, ready to hand to an adapter.
///
/// Variables, auth helpers and scripts have already been applied by the time
/// one of these exists.
class HttpRequestSpec {
  HttpRequestSpec({
    required String method,
    required this.url,
    this.headers = const [],
    this.body,
    this.timeout,
  }) : method = method.toUpperCase();

  /// Upper-cased method. Not an enum: custom methods are allowed.
  final String method;
  final Uri url;

  /// Ordered, duplicates allowed (order and repeats matter to some servers).
  final List<HttpHeader> headers;
  final List<int>? body;
  final Duration? timeout;
}

class HttpHeader {
  const HttpHeader(this.name, this.value);

  final String name;
  final String value;

  @override
  String toString() => '$name: $value';
}
