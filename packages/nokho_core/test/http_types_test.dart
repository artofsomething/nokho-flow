import 'package:nokho_core/nokho_core.dart';
import 'package:test/test.dart';

void main() {
  test('request method is upper-cased, custom methods allowed', () {
    final spec = HttpRequestSpec(
      method: 'propfind',
      url: Uri.parse('http://x'),
    );
    expect(spec.method, 'PROPFIND');
  });

  test('headerValues is case-insensitive and keeps duplicates in order', () {
    const result = HttpResult(
      statusCode: 200,
      reasonPhrase: 'OK',
      headers: [
        HttpHeader('Set-Cookie', 'a=1'),
        HttpHeader('Content-Type', 'application/json'),
        HttpHeader('set-cookie', 'b=2'),
      ],
      bodyBytes: [],
      elapsed: Duration.zero,
    );
    expect(result.headerValues('SET-COOKIE'), ['a=1', 'b=2']);
    expect(result.isSuccess, isTrue);
  });
}
