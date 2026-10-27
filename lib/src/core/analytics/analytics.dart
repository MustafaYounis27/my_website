import 'analytics_stub.dart' if (dart.library.js_interop) 'analytics_web.dart' as impl;

/// Track a custom analytics event. No-op on non-web platforms.
void trackEvent(String name, {Map<String, Object?>? params}) =>
    impl.trackEvent(name, params: params);
