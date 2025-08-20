// Web implementation: sends events to Google Analytics via gtag()
import 'dart:js' as js;
import 'dart:js_util' as js_util;

void trackEvent(String name, {Map<String, Object?>? params}) {
  try {
    final fn = js.context['gtag'];
    if (fn != null) {
      final jsParams = params == null ? null : js_util.jsify(params);
      final args = jsParams == null ? ['event', name] : ['event', name, jsParams];
      if (fn is js.JsFunction) {
        fn.apply(args);
      } else {
        // Fallback if gtag is attached differently
        js.context.callMethod('gtag', args);
      }
    }
  } catch (_) {
    // No-op if gtag not available
  }
}
