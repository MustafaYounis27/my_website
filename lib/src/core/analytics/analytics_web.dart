// Web implementation: sends events to Google Analytics via gtag()
import 'dart:js' as js;

void trackEvent(String name, {Map<String, Object?>? params}) {
  try {
    final fn = js.context['gtag'];
    if (fn != null) {
      if (fn is js.JsFunction) {
        fn.apply(['event', name, params ?? <String, Object?>{}]);
      } else {
        // Fallback if gtag is attached differently
        js.context.callMethod('gtag', ['event', name, params ?? <String, Object?>{}]);
      }
    }
  } catch (_) {
    // No-op if gtag not available
  }
}
