// Web implementation: sends events to Google Analytics via gtag()
import 'dart:js_interop';

@JS('gtag')
external void _gtag(JSAny a, JSAny b, [JSAny? c]);

void trackEvent(String name, {Map<String, Object?>? params}) {
  try {
    if (params != null) {
      _gtag('event'.toJS, name.toJS, params.jsify());
    } else {
      _gtag('event'.toJS, name.toJS);
    }
  } catch (_) {
    // No-op if gtag not available
  }
}
