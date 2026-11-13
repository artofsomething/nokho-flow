import 'package:nokho_core/nokho_core.dart';

/// Sends requests on one platform. The UI reads [capabilities] to hide or
/// explain options the platform cannot honour (notably on Web Lite).
abstract interface class HttpAdapter {
  HttpCapabilities get capabilities;

  Future<HttpResult> send(HttpRequestSpec spec);
}

class HttpCapabilities {
  const HttpCapabilities({
    required this.customMethods,
    required this.forbiddenHeaders,
    required this.cookieJar,
    required this.redirectControl,
    required this.timings,
    required this.proxy,
    required this.clientCertificates,
    required this.disableTlsVerification,
  });

  /// Everything available: native desktop and mobile.
  const HttpCapabilities.full()
    : customMethods = true,
      forbiddenHeaders = true,
      cookieJar = true,
      redirectControl = true,
      timings = true,
      proxy = true,
      clientCertificates = true,
      disableTlsVerification = true;

  /// Browser `fetch`: Web Lite (docs/PLAN.md section 4.1).
  const HttpCapabilities.webLite()
    : customMethods = false,
      forbiddenHeaders = false,
      cookieJar = false,
      redirectControl = false,
      timings = false,
      proxy = false,
      clientCertificates = false,
      disableTlsVerification = false;

  final bool customMethods;

  /// Can set headers browsers reserve (Host, Cookie, User-Agent, ...).
  final bool forbiddenHeaders;
  final bool cookieJar;
  final bool redirectControl;
  final bool timings;
  final bool proxy;
  final bool clientCertificates;
  final bool disableTlsVerification;
}
