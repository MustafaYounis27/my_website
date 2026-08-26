import 'package:flutter_test/flutter_test.dart';
import 'package:my_website/src/core/design/app_tokens.dart';

void main() {
  test('spacing scale is strictly increasing', () {
    const scale = [
      AppSpace.xxs,
      AppSpace.xs,
      AppSpace.sm,
      AppSpace.md,
      AppSpace.lg,
      AppSpace.xl,
      AppSpace.xxl,
      AppSpace.xxxl,
      AppSpace.section,
    ];
    for (var i = 1; i < scale.length; i++) {
      expect(
        scale[i],
        greaterThan(scale[i - 1]),
        reason: 'index $i breaks the scale',
      );
    }
  });

  test('radii are ordered and pill is fully rounded', () {
    expect(AppRadius.sm, lessThan(AppRadius.md));
    expect(AppRadius.md, lessThan(AppRadius.lg));
    expect(AppRadius.lg, lessThan(AppRadius.xl));
    expect(AppRadius.pill, greaterThanOrEqualTo(999));
  });

  test('motion durations are ordered fast < base < slow', () {
    expect(AppMotion.fast, lessThan(AppMotion.base));
    expect(AppMotion.base, lessThan(AppMotion.slow));
    expect(AppMotion.stagger, lessThan(AppMotion.fast));
  });
}
