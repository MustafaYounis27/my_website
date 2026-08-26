# Portfolio UI/UX Modernization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild the portfolio's visual system and page structure into the approved "Indigo Aurora" design (light) and "Indigo Night" (dark), without changing content, routes, or the resume PDF behaviour.

**Architecture:** Three layers, built bottom-up. **Tokens** (`lib/src/core/design/`) hold every colour, space, radius and duration as data, with both palettes exposed to widgets through a `ThemeExtension`. **Primitives** (`lib/src/widgets/common/`) are eight small, CV-agnostic widgets that own the one card style, the one chip style, the aurora, and the motion. **Sections** are then rewritten to consume the primitives, which deletes the duplicated inline `Container(decoration: …)` blocks that exist in six widget files today.

**Tech Stack:** Flutter 3.41 / Dart 3.11, Material 3, `provider`, `google_fonts` (8.x), `flutter_animate`, `url_launcher`. **No new dependencies.**

**Spec:** `docs/superpowers/specs/2026-08-25-ui-ux-modernization-design.md`

---

## File Structure

**Create**

| File | Responsibility |
|---|---|
| `lib/src/core/design/app_tokens.dart` | Spacing, radii, durations, curves. Pure constants. |
| `lib/src/core/design/app_palette.dart` | Both palettes as immutable data + colour lerp. |
| `lib/src/core/design/app_surfaces.dart` | `ThemeExtension` carrying the palette + `context.palette` accessor. |
| `lib/src/core/cv_stats.dart` | Derives the four hero stats from a `CV`. Pure logic. |
| `lib/src/core/skill_categories.dart` | Groups a flat skill list into three named categories. Pure logic. |
| `lib/src/widgets/common/glass_card.dart` | The single card style. |
| `lib/src/widgets/common/tag_chip.dart` | The single chip style. |
| `lib/src/widgets/common/gradient_text.dart` | Brand-gradient text via `ShaderMask`. |
| `lib/src/widgets/common/aurora_background.dart` | Canvas + two radial aurora stops. |
| `lib/src/widgets/common/hover_lift.dart` | Pointer-hover lift for cards. |
| `lib/src/widgets/common/reveal.dart` | Scroll-triggered fade + rise. |
| `lib/src/widgets/common/section_shell.dart` | Numbered eyebrow + title + subtitle + content. |
| `lib/src/widgets/common/stat_tile.dart` | Number + label in a glass tile. |
| `lib/src/widgets/stats_section.dart` | The four stat tiles, responsive. |
| `lib/src/widgets/site_footer.dart` | Real footer replacing the bare copyright line. |

**Modify**

| File | Change |
|---|---|
| `lib/src/core/app_theme.dart` | Rewritten to build `ThemeData` from an `AppPalette`. |
| `lib/src/app.dart` | Animated theme transition. |
| `lib/src/models/cv.dart` | Add optional `yearsExperience`. |
| `assets/data/cv.json` | Add `"yearsExperience": 5`. |
| `lib/src/widgets/hero_section.dart` | Two-column layout. |
| `lib/src/widgets/about_section.dart` | Two cards side by side. |
| `lib/src/widgets/skills_section.dart` | Three category cards. |
| `lib/src/widgets/experience_section.dart` | Vertical timeline. |
| `lib/src/widgets/projects_section.dart` | Featured-first layout. |
| `lib/src/widgets/project_card.dart` | Restyled on primitives; dialog logic kept. |
| `lib/src/widgets/contact_section.dart` | Gradient CTA band + restyled form. |
| `lib/src/widgets/nav_bar.dart` | Restyled on primitives. |
| `lib/src/pages/home_page.dart` | Aurora background, stats section, footer, new rhythm. |

**Delete**

| File | Reason |
|---|---|
| `lib/src/widgets/section_header.dart` | Replaced by `section_shell.dart`. |

---

### Task 1: Design tokens

**Files:**
- Create: `lib/src/core/design/app_tokens.dart`
- Test: `test/design/app_tokens_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/design/app_tokens_test.dart`:

```dart
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
      expect(scale[i], greaterThan(scale[i - 1]), reason: 'index $i breaks the scale');
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/design/app_tokens_test.dart`
Expected: FAIL — `Error: Couldn't resolve the package 'my_website' ... app_tokens.dart` / "Target of URI doesn't exist".

- [ ] **Step 3: Write minimal implementation**

Create `lib/src/core/design/app_tokens.dart`:

```dart
import 'package:flutter/animation.dart';

/// Spacing scale. Every gap and padding in the app comes from here.
abstract final class AppSpace {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;

  /// Vertical gap between top-level page sections on desktop.
  static const double section = 96;

  /// Vertical gap between top-level page sections below 600px.
  static const double sectionMobile = 64;
}

/// Corner radii.
abstract final class AppRadius {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;
}

/// Durations and curves. Motion that is not listed here does not belong.
abstract final class AppMotion {
  static const Duration stagger = Duration(milliseconds: 60);
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration base = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 520);

  /// Cross-fade between light and dark.
  static const Duration theme = Duration(milliseconds: 400);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutQuint;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/design/app_tokens_test.dart`
Expected: PASS — `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/src/core/design/app_tokens.dart test/design/app_tokens_test.dart
git commit -m "feat(design): add spacing, radius and motion tokens"
```

---

### Task 2: Colour palettes

**Files:**
- Create: `lib/src/core/design/app_palette.dart`
- Test: `test/design/app_palette_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/design/app_palette_test.dart`:

```dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_website/src/core/design/app_palette.dart';

double _channel(double v) => v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();

double _luminance(Color c) => 0.2126 * _channel(c.r) + 0.7152 * _channel(c.g) + 0.0722 * _channel(c.b);

double _contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final hi = math.max(la, lb);
  final lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  test('light and dark palettes are distinct and complete', () {
    expect(AppPalette.light.brightness, Brightness.light);
    expect(AppPalette.dark.brightness, Brightness.dark);
    expect(AppPalette.light.canvas, isNot(AppPalette.dark.canvas));
    expect(AppPalette.light.gradient.length, 2);
    expect(AppPalette.dark.gradient.length, 2);
  });

  test('body ink clears WCAG AA against its own canvas in both themes', () {
    expect(_contrast(AppPalette.light.ink, AppPalette.light.canvas), greaterThan(4.5));
    expect(_contrast(AppPalette.dark.ink, AppPalette.dark.canvas), greaterThan(4.5));
  });

  test('brand accent clears WCAG AA against its own canvas in both themes', () {
    expect(_contrast(AppPalette.light.brand, AppPalette.light.canvas), greaterThan(4.5));
    expect(_contrast(AppPalette.dark.brand, AppPalette.dark.canvas), greaterThan(4.5));
  });

  test('lerp at the endpoints returns the endpoints', () {
    final a = AppPalette.lerp(AppPalette.light, AppPalette.dark, 0);
    final b = AppPalette.lerp(AppPalette.light, AppPalette.dark, 1);
    expect(a.canvas, AppPalette.light.canvas);
    expect(b.canvas, AppPalette.dark.canvas);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/design/app_palette_test.dart`
Expected: FAIL — "Target of URI doesn't exist: 'package:my_website/src/core/design/app_palette.dart'".

- [ ] **Step 3: Write minimal implementation**

Create `lib/src/core/design/app_palette.dart`:

```dart
import 'package:flutter/material.dart';

/// Every colour in the app, as data. Widgets read these through
/// `context.palette` (see `app_surfaces.dart`) and never hardcode a Color.
@immutable
class AppPalette {
  final Brightness brightness;

  /// Page background behind everything.
  final Color canvas;

  /// Top-left aurora glow.
  final Color auroraPrimary;

  /// Top-right aurora glow.
  final Color auroraSecondary;

  /// Opaque card background.
  final Color surface;

  /// Translucent card background, used with a blur.
  final Color surfaceGlass;

  /// 1px border on every card.
  final Color hairline;

  /// Primary text.
  final Color ink;

  /// Secondary text (body copy, highlights).
  final Color inkMuted;

  /// Tertiary text (labels, metadata).
  final Color inkSubtle;

  /// Accent for text and icons — AA-safe on [canvas].
  final Color brand;

  /// Secondary accent.
  final Color brandAlt;

  /// Accent at low alpha, for chip and icon backgrounds.
  final Color brandSoft;

  /// Text/icon colour on top of a brand-filled surface.
  final Color onBrand;

  /// The two stops of the signature gradient, 135°.
  final List<Color> gradient;

  /// Card shadow colour.
  final Color shadow;

  const AppPalette({
    required this.brightness,
    required this.canvas,
    required this.auroraPrimary,
    required this.auroraSecondary,
    required this.surface,
    required this.surfaceGlass,
    required this.hairline,
    required this.ink,
    required this.inkMuted,
    required this.inkSubtle,
    required this.brand,
    required this.brandAlt,
    required this.brandSoft,
    required this.onBrand,
    required this.gradient,
    required this.shadow,
  });

  /// Indigo Aurora.
  static const AppPalette light = AppPalette(
    brightness: Brightness.light,
    canvas: Color(0xFFFBFBFE),
    auroraPrimary: Color(0x426366F1),
    auroraSecondary: Color(0x388B5CF6),
    surface: Color(0xFFFFFFFF),
    surfaceGlass: Color(0xB8FFFFFF),
    hairline: Color(0x140F0F1E),
    ink: Color(0xFF14142B),
    inkMuted: Color(0xFF5A5A75),
    inkSubtle: Color(0xFF6E6E88),
    brand: Color(0xFF4F46E5),
    brandAlt: Color(0xFF8B32D6),
    brandSoft: Color(0x1A6366F1),
    onBrand: Color(0xFFFFFFFF),
    gradient: [Color(0xFF6366F1), Color(0xFFA855F7)],
    shadow: Color(0x1714142B),
  );

  /// Indigo Night.
  static const AppPalette dark = AppPalette(
    brightness: Brightness.dark,
    canvas: Color(0xFF0B0A18),
    auroraPrimary: Color(0x4D6366F1),
    auroraSecondary: Color(0x3DA855F7),
    surface: Color(0xFF141327),
    surfaceGlass: Color(0x0EFFFFFF),
    hairline: Color(0x1AFFFFFF),
    ink: Color(0xFFF2F1FA),
    inkMuted: Color(0xFFA9A7C6),
    inkSubtle: Color(0xFF9391B4),
    brand: Color(0xFFA5B4FC),
    brandAlt: Color(0xFFC084FC),
    brandSoft: Color(0x24818CF8),
    onBrand: Color(0xFF0B0A18),
    gradient: [Color(0xFFA5B4FC), Color(0xFFC084FC)],
    shadow: Color(0x80000000),
  );

  /// Interpolates every colour so the theme toggle cross-fades smoothly.
  static AppPalette lerp(AppPalette a, AppPalette b, double t) {
    if (t <= 0) return a;
    if (t >= 1) return b;
    Color c(Color x, Color y) => Color.lerp(x, y, t)!;
    return AppPalette(
      brightness: t < 0.5 ? a.brightness : b.brightness,
      canvas: c(a.canvas, b.canvas),
      auroraPrimary: c(a.auroraPrimary, b.auroraPrimary),
      auroraSecondary: c(a.auroraSecondary, b.auroraSecondary),
      surface: c(a.surface, b.surface),
      surfaceGlass: c(a.surfaceGlass, b.surfaceGlass),
      hairline: c(a.hairline, b.hairline),
      ink: c(a.ink, b.ink),
      inkMuted: c(a.inkMuted, b.inkMuted),
      inkSubtle: c(a.inkSubtle, b.inkSubtle),
      brand: c(a.brand, b.brand),
      brandAlt: c(a.brandAlt, b.brandAlt),
      brandSoft: c(a.brandSoft, b.brandSoft),
      onBrand: c(a.onBrand, b.onBrand),
      gradient: [c(a.gradient[0], b.gradient[0]), c(a.gradient[1], b.gradient[1])],
      shadow: c(a.shadow, b.shadow),
    );
  }
}
```

Note the two deviations from the spec's colour table, both forced by the contrast test:
`inkSubtle` light is `#6E6E88` (spec said `#8B8BA3`, which measures 2.9:1 on the canvas) and
`brandAlt` light is `#8B32D6` (spec said `#A855F7`, 3.1:1). The gradient stops keep the original
`#6366F1 → #A855F7` because gradient fills are decorative, not text.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/design/app_palette_test.dart`
Expected: PASS — `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/src/core/design/app_palette.dart test/design/app_palette_test.dart
git commit -m "feat(design): add Indigo Aurora and Indigo Night palettes with AA contrast tests"
```

---

### Task 3: Palette theme extension

**Files:**
- Create: `lib/src/core/design/app_surfaces.dart`
- Test: `test/design/app_surfaces_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/design/app_surfaces_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_website/src/core/design/app_palette.dart';
import 'package:my_website/src/core/design/app_surfaces.dart';

void main() {
  testWidgets('context.palette returns the palette registered on the theme', (tester) async {
    late AppPalette seen;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [AppSurfaces(AppPalette.dark)]),
        home: Builder(
          builder: (context) {
            seen = context.palette;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(seen.canvas, AppPalette.dark.canvas);
  });

  testWidgets('context.palette falls back to light when no extension is registered', (tester) async {
    late AppPalette seen;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            seen = context.palette;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(seen.canvas, AppPalette.light.canvas);
  });

  test('lerp interpolates the wrapped palette', () {
    const a = AppSurfaces(AppPalette.light);
    const b = AppSurfaces(AppPalette.dark);
    final mid = a.lerp(b, 1) as AppSurfaces;
    expect(mid.palette.canvas, AppPalette.dark.canvas);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/design/app_surfaces_test.dart`
Expected: FAIL — "Target of URI doesn't exist: 'package:my_website/src/core/design/app_surfaces.dart'".

- [ ] **Step 3: Write minimal implementation**

Create `lib/src/core/design/app_surfaces.dart`:

```dart
import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Carries the active [AppPalette] on [ThemeData] so widgets can read design
/// tokens without importing the theme builder.
@immutable
class AppSurfaces extends ThemeExtension<AppSurfaces> {
  final AppPalette palette;

  const AppSurfaces(this.palette);

  @override
  AppSurfaces copyWith({AppPalette? palette}) => AppSurfaces(palette ?? this.palette);

  @override
  AppSurfaces lerp(ThemeExtension<AppSurfaces>? other, double t) {
    if (other is! AppSurfaces) return this;
    return AppSurfaces(AppPalette.lerp(palette, other.palette, t));
  }
}

extension AppPaletteContext on BuildContext {
  /// The palette for the current theme. Falls back to light so widget tests
  /// that build a bare [MaterialApp] still render.
  AppPalette get palette =>
      Theme.of(this).extension<AppSurfaces>()?.palette ?? AppPalette.light;
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/design/app_surfaces_test.dart`
Expected: PASS — `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/src/core/design/app_surfaces.dart test/design/app_surfaces_test.dart
git commit -m "feat(design): expose palette to widgets via ThemeExtension"
```

---

### Task 4: Rebuild the theme on the palette

**Files:**
- Modify: `lib/src/core/app_theme.dart` (full rewrite)
- Modify: `lib/src/app.dart:29-38`
- Test: `test/design/app_theme_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/design/app_theme_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_website/src/core/app_theme.dart';
import 'package:my_website/src/core/design/app_palette.dart';
import 'package:my_website/src/core/design/app_surfaces.dart';

void main() {
  test('light theme carries the light palette and paints the light canvas', () {
    final theme = AppTheme.light;
    expect(theme.brightness, Brightness.light);
    expect(theme.extension<AppSurfaces>()?.palette.canvas, AppPalette.light.canvas);
    expect(theme.scaffoldBackgroundColor, AppPalette.light.canvas);
  });

  test('dark theme carries the dark palette and paints the dark canvas', () {
    final theme = AppTheme.dark;
    expect(theme.brightness, Brightness.dark);
    expect(theme.extension<AppSurfaces>()?.palette.canvas, AppPalette.dark.canvas);
    expect(theme.scaffoldBackgroundColor, AppPalette.dark.canvas);
  });

  test('both themes keep the app bar transparent so the aurora shows through', () {
    expect(AppTheme.light.appBarTheme.backgroundColor, Colors.transparent);
    expect(AppTheme.dark.appBarTheme.backgroundColor, Colors.transparent);
    expect(AppTheme.light.appBarTheme.scrolledUnderElevation, 0);
    expect(AppTheme.dark.appBarTheme.scrolledUnderElevation, 0);
  });

  test('colour scheme primary matches the palette brand in both themes', () {
    expect(AppTheme.light.colorScheme.primary, AppPalette.light.brand);
    expect(AppTheme.dark.colorScheme.primary, AppPalette.dark.brand);
    expect(AppTheme.dark.colorScheme.onPrimary, AppPalette.dark.onBrand);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/design/app_theme_test.dart`
Expected: FAIL — `Expected: <Color(0xfffbfbfe)> Actual: <null>` on the first test (no `AppSurfaces` extension registered yet).

- [ ] **Step 3: Write minimal implementation**

Replace the whole of `lib/src/core/app_theme.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'design/app_palette.dart';
import 'design/app_surfaces.dart';
import 'design/app_tokens.dart';

/// Builds both themes from an [AppPalette]. Nothing here hardcodes a colour —
/// change `app_palette.dart` and both themes follow.
abstract final class AppTheme {
  static ThemeData get light => _build(AppPalette.light);
  static ThemeData get dark => _build(AppPalette.dark);

  static ThemeData _build(AppPalette p) {
    final isDark = p.brightness == Brightness.dark;
    final base = isDark ? ThemeData.dark() : ThemeData.light();

    final scheme = ColorScheme(
      brightness: p.brightness,
      primary: p.brand,
      onPrimary: p.onBrand,
      primaryContainer: p.brandSoft,
      onPrimaryContainer: p.brand,
      secondary: p.brandAlt,
      onSecondary: p.onBrand,
      surface: p.surface,
      onSurface: p.ink,
      onSurfaceVariant: p.inkMuted,
      outline: p.hairline,
      outlineVariant: p.hairline,
      error: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB3261E),
      onError: isDark ? const Color(0xFF0B0A18) : Colors.white,
      shadow: p.shadow,
    );

    TextStyle display(double size, FontWeight weight) =>
        GoogleFonts.poppins(fontSize: size, fontWeight: weight, color: p.ink, letterSpacing: -0.5);

    final text = GoogleFonts.interTextTheme(base.textTheme).copyWith(
      displayLarge: display(56, FontWeight.w800),
      displayMedium: display(44, FontWeight.w800),
      displaySmall: display(34, FontWeight.w700),
      headlineLarge: display(30, FontWeight.w700),
      headlineMedium: display(24, FontWeight.w700),
      headlineSmall: display(20, FontWeight.w600),
      titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: p.ink),
      titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: p.ink),
      bodyLarge: GoogleFonts.inter(fontSize: 16, height: 1.65, color: p.inkMuted),
      bodyMedium: GoogleFonts.inter(fontSize: 14, height: 1.6, color: p.inkMuted),
      bodySmall: GoogleFonts.inter(fontSize: 12.5, height: 1.5, color: p.inkSubtle),
      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: p.ink),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.8,
        color: p.brand,
      ),
    );

    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm));
    const buttonPadding = EdgeInsets.symmetric(horizontal: AppSpace.lg, vertical: AppSpace.md);

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: p.canvas,
      canvasColor: p.canvas,
      textTheme: text,
      extensions: [AppSurfaces(p)],
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: p.ink,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      dividerTheme: DividerThemeData(color: p.hairline, space: 1, thickness: 1),
      iconTheme: IconThemeData(color: p.inkMuted),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.brand,
          foregroundColor: p.onBrand,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.brand,
          padding: buttonPadding,
          shape: buttonShape,
          side: BorderSide(color: p.hairline),
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: p.brand, textStyle: text.labelLarge),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? p.surfaceGlass : p.surface,
        hintStyle: text.bodyMedium?.copyWith(color: p.inkSubtle),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: p.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: p.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: p.brand, width: 1.5),
        ),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/design/app_theme_test.dart`
Expected: PASS — `All tests passed!`

- [ ] **Step 5: Animate the theme transition**

In `lib/src/app.dart`, add the import and two properties on `MaterialApp`:

```dart
import 'core/design/app_tokens.dart';
```

```dart
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: appTitle,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: theme.themeMode,
            themeAnimationDuration: AppMotion.theme,
            themeAnimationCurve: AppMotion.standard,
            initialRoute: '/',
```

- [ ] **Step 6: Run the whole suite**

Run: `flutter test`
Expected: PASS — all existing tests plus the new ones. If `home_hero_test.dart` fails on an overflow, note it and fix it in Task 16 when the home page is assembled; do not weaken the test.

- [ ] **Step 7: Commit**

```bash
git add lib/src/core/app_theme.dart lib/src/app.dart test/design/app_theme_test.dart
git commit -m "feat(design): rebuild themes on the palette and cross-fade theme changes"
```

---

### Task 5: `yearsExperience` on the CV model

**Files:**
- Modify: `lib/src/models/cv.dart:1-70`
- Modify: `assets/data/cv.json`
- Test: `test/cv_load_test.dart`

- [ ] **Step 1: Write the failing test**

Append to `test/cv_load_test.dart`, inside `main()`:

```dart
  test('yearsExperience is optional and round-trips', () {
    const withField =
        '{"name":"A","title":"B","email":"e","phone":"p","location":"l","linkedin":"li","github":"gh","summary":"s","yearsExperience":5,"education":{"degree":"d","university":"u","period":"pr","location":"loc"},"skills":["x"],"experience":[],"projects":[],"links":{}}';
    final cv = CV.fromJson(json.decode(withField) as Map<String, dynamic>);
    expect(cv.yearsExperience, 5);
    expect(cv.toJson()['yearsExperience'], 5);

    const withoutField =
        '{"name":"A","title":"B","email":"e","phone":"p","location":"l","linkedin":"li","github":"gh","summary":"s","education":{"degree":"d","university":"u","period":"pr","location":"loc"},"skills":["x"],"experience":[],"projects":[],"links":{}}';
    final bare = CV.fromJson(json.decode(withoutField) as Map<String, dynamic>);
    expect(bare.yearsExperience, isNull);
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/cv_load_test.dart`
Expected: FAIL — "The getter 'yearsExperience' isn't defined for the class 'CV'".

- [ ] **Step 3: Write minimal implementation**

In `lib/src/models/cv.dart`, add the field to `CV` in four places.

Field declaration, after `final String summary;`:

```dart
  /// Optional override for the "years experience" stat. When absent the value
  /// is computed from the earliest experience entry — see `CvStats`.
  final int? yearsExperience;
```

Constructor parameter, after `required this.summary,`:

```dart
    this.yearsExperience,
```

In `CV.fromJson`, after `summary: json['summary'] ?? '',`:

```dart
        yearsExperience: (json['yearsExperience'] as num?)?.toInt(),
```

In `toJson`, after `'summary': summary,`:

```dart
        'yearsExperience': yearsExperience,
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/cv_load_test.dart`
Expected: PASS — `All tests passed!`

- [ ] **Step 5: Set the value in the real data**

In `assets/data/cv.json`, add the field immediately after the `"summary"` entry:

```json
  "yearsExperience": 5,
```

Verify the file is still valid JSON:

Run: `python3 -c "import json;d=json.load(open('assets/data/cv.json'));print(d['yearsExperience'])"`
Expected: `5`

- [ ] **Step 6: Commit**

```bash
git add lib/src/models/cv.dart assets/data/cv.json test/cv_load_test.dart
git commit -m "feat(cv): add optional yearsExperience field"
```

---

### Task 6: Stats derivation

**Files:**
- Create: `lib/src/core/cv_stats.dart`
- Test: `test/core/cv_stats_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/core/cv_stats_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:my_website/src/core/cv_stats.dart';
import 'package:my_website/src/models/cv.dart';

CV _cv({
  int? yearsExperience,
  List<Experience> experience = const [],
  List<Project> projects = const [],
  List<String> skills = const [],
}) =>
    CV(
      name: 'N',
      title: 'T',
      email: 'e',
      phone: 'p',
      location: 'l',
      linkedin: 'li',
      github: 'gh',
      summary: 's',
      yearsExperience: yearsExperience,
      education: Education(degree: 'd', university: 'u', period: 'p', location: 'l'),
      skills: skills,
      experience: experience,
      projects: projects,
      links: Links(appStoreExamples: const [], playStoreExamples: const []),
    );

Experience _exp(String period) =>
    Experience(company: 'c', role: 'r', period: period, location: 'l', highlights: const []);

Project _project(List<String> stores) => Project(
      name: 'p',
      period: '01/2024',
      description: 'd',
      technologies: const [],
      stores: stores,
    );

void main() {
  test('years falls back to the earliest experience start year', () {
    final stats = CvStats.from(
      _cv(experience: [_exp('02/2025 - Present'), _exp('03/2022 - 02/2025')]),
      now: DateTime(2026, 8, 26),
    );
    expect(stats.years, 4);
  });

  test('yearsExperience overrides the computed value', () {
    final stats = CvStats.from(
      _cv(yearsExperience: 5, experience: [_exp('03/2022 - 02/2025')]),
      now: DateTime(2026, 8, 26),
    );
    expect(stats.years, 5);
  });

  test('years is zero when there is no experience and no override', () {
    expect(CvStats.from(_cv(), now: DateTime(2026, 8, 26)).years, 0);
  });

  test('counts projects and distinct store hosts', () {
    final stats = CvStats.from(
      _cv(projects: [
        _project(const [
          'https://apps.apple.com/eg/app/a/id1',
          'https://play.google.com/store/apps/details?id=a',
          'https://appgallery.huawei.com/app/C1',
          'https://apps.microsoft.com/detail/x',
        ]),
        _project(const ['https://apps.apple.com/eg/app/b/id2']),
      ]),
      now: DateTime(2026, 8, 26),
    );
    expect(stats.projects, 2);
    expect(stats.stores, 4);
  });

  test('ignores unparseable store urls', () {
    final stats = CvStats.from(
      _cv(projects: [_project(const ['', 'not a url'])]),
      now: DateTime(2026, 8, 26),
    );
    expect(stats.stores, 0);
  });

  test('technologies counts the skill list', () {
    expect(CvStats.from(_cv(skills: const ['a', 'b', 'c'])).technologies, 3);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/cv_stats_test.dart`
Expected: FAIL — "Target of URI doesn't exist: 'package:my_website/src/core/cv_stats.dart'".

- [ ] **Step 3: Write minimal implementation**

Create `lib/src/core/cv_stats.dart`:

```dart
import '../models/cv.dart';

/// The four numbers shown under the hero. Every one is derived from the CV —
/// nothing here is hardcoded.
class CvStats {
  final int years;
  final int projects;
  final int stores;
  final int technologies;

  const CvStats({
    required this.years,
    required this.projects,
    required this.stores,
    required this.technologies,
  });

  factory CvStats.from(CV cv, {DateTime? now}) {
    final today = now ?? DateTime.now();
    return CvStats(
      years: cv.yearsExperience ?? _computedYears(cv, today),
      projects: cv.projects.length,
      stores: _distinctStoreHosts(cv),
      technologies: cv.skills.length,
    );
  }

  /// Whole years since the earliest role started. Returns 0 when unknown.
  static int _computedYears(CV cv, DateTime today) {
    DateTime? earliest;
    for (final exp in cv.experience) {
      final start = _parseMonthYear(exp.period.split('-').first.trim());
      if (start == null) continue;
      if (earliest == null || start.isBefore(earliest)) earliest = start;
    }
    if (earliest == null) return 0;
    var years = today.year - earliest.year;
    if (today.month < earliest.month) years -= 1;
    return years < 0 ? 0 : years;
  }

  /// Parses `MM/yyyy`. Returns null for anything else, including "Present".
  static DateTime? _parseMonthYear(String value) {
    final match = RegExp(r'^(\d{1,2})/(\d{4})$').firstMatch(value);
    if (match == null) return null;
    final month = int.parse(match.group(1)!);
    if (month < 1 || month > 12) return null;
    return DateTime(int.parse(match.group(2)!), month);
  }

  /// Distinct hosts across every project's store links — apps.apple.com,
  /// play.google.com, appgallery.huawei.com, apps.microsoft.com.
  static int _distinctStoreHosts(CV cv) {
    final hosts = <String>{};
    for (final project in cv.projects) {
      for (final url in project.stores) {
        final host = Uri.tryParse(url)?.host;
        if (host != null && host.isNotEmpty) hosts.add(host.toLowerCase());
      }
    }
    return hosts.length;
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/cv_stats_test.dart`
Expected: PASS — `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/src/core/cv_stats.dart test/core/cv_stats_test.dart
git commit -m "feat(core): derive hero stats from CV data"
```

---

### Task 7: Skill categorisation

**Files:**
- Create: `lib/src/core/skill_categories.dart`
- Test: `test/core/skill_categories_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/core/skill_categories_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:my_website/src/core/skill_categories.dart';

void main() {
  test('groups known skills into their category', () {
    final groups = SkillCategories.group(const ['Flutter', 'Firebase', 'CI/CD']);
    expect(groups[0].title, 'Mobile');
    expect(groups[0].skills, ['Flutter']);
    expect(groups[1].title, 'Backend & Data');
    expect(groups[1].skills, ['Firebase']);
    expect(groups[2].title, 'Delivery & Practices');
    expect(groups[2].skills, ['CI/CD']);
  });

  test('unknown skills fall into Delivery & Practices, never dropped', () {
    final groups = SkillCategories.group(const ['Flutter', 'Underwater Basket Weaving']);
    final all = groups.expand((g) => g.skills).toList();
    expect(all, containsAll(['Flutter', 'Underwater Basket Weaving']));
    expect(all.length, 2);
  });

  test('every skill in the real CV list survives categorisation', () {
    const skills = [
      'Flutter', 'Android', 'Dart', 'Java', 'Kotlin', 'Python', 'Git',
      'Firebase', 'OOP', 'CI/CD', 'Design Patterns', 'SOLID', 'Team Management',
    ];
    final all = SkillCategories.group(skills).expand((g) => g.skills).toList();
    expect(all.length, skills.length);
    expect(all.toSet(), skills.toSet());
  });

  test('empty categories are omitted', () {
    final groups = SkillCategories.group(const ['Flutter']);
    expect(groups.length, 1);
    expect(groups.single.title, 'Mobile');
  });

  test('matching is case-insensitive', () {
    final groups = SkillCategories.group(const ['flutter']);
    expect(groups.single.title, 'Mobile');
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/skill_categories_test.dart`
Expected: FAIL — "Target of URI doesn't exist: 'package:my_website/src/core/skill_categories.dart'".

- [ ] **Step 3: Write minimal implementation**

Create `lib/src/core/skill_categories.dart`:

```dart
import 'package:flutter/material.dart';

/// One rendered skill group.
class SkillGroup {
  final String title;
  final IconData icon;
  final List<String> skills;

  const SkillGroup({required this.title, required this.icon, required this.skills});
}

/// Splits the flat `cv.skills` list into three display groups. Anything not
/// explicitly listed lands in "Delivery & Practices" so no skill is ever lost.
abstract final class SkillCategories {
  static const _mobile = {
    'flutter', 'dart', 'android', 'ios', 'kotlin', 'java', 'swift', 'jetpack compose',
  };

  static const _backend = {
    'firebase', 'sql', 'python', 'rest', 'rest api', 'graphql', 'socket io', 'soket io',
    'sockets', 'node', 'c#', 'supabase',
  };

  static List<SkillGroup> group(List<String> skills) {
    final mobile = <String>[];
    final backend = <String>[];
    final delivery = <String>[];

    for (final skill in skills) {
      final key = skill.toLowerCase().trim();
      if (_mobile.contains(key)) {
        mobile.add(skill);
      } else if (_backend.contains(key)) {
        backend.add(skill);
      } else {
        delivery.add(skill);
      }
    }

    return [
      if (mobile.isNotEmpty)
        SkillGroup(title: 'Mobile', icon: Icons.phone_iphone_rounded, skills: mobile),
      if (backend.isNotEmpty)
        SkillGroup(title: 'Backend & Data', icon: Icons.cloud_outlined, skills: backend),
      if (delivery.isNotEmpty)
        SkillGroup(title: 'Delivery & Practices', icon: Icons.rocket_launch_outlined, skills: delivery),
    ];
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/skill_categories_test.dart`
Expected: PASS — `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/src/core/skill_categories.dart test/core/skill_categories_test.dart
git commit -m "feat(core): group skills into display categories"
```

---

### Task 8: Surface primitives — GlassCard, TagChip, GradientText

**Files:**
- Create: `lib/src/widgets/common/glass_card.dart`
- Create: `lib/src/widgets/common/tag_chip.dart`
- Create: `lib/src/widgets/common/gradient_text.dart`
- Test: `test/widgets/common/surfaces_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/widgets/common/surfaces_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_website/src/core/app_theme.dart';
import 'package:my_website/src/widgets/common/glass_card.dart';
import 'package:my_website/src/widgets/common/gradient_text.dart';
import 'package:my_website/src/widgets/common/tag_chip.dart';

Widget _host(Widget child, {bool dark = false}) => MaterialApp(
      theme: dark ? AppTheme.dark : AppTheme.light,
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  testWidgets('GlassCard renders its child', (tester) async {
    await tester.pumpWidget(_host(const GlassCard(child: Text('inside'))));
    expect(find.text('inside'), findsOneWidget);
  });

  testWidgets('GlassCard is tappable when onTap is given', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _host(GlassCard(onTap: () => taps++, child: const Text('tap me'))),
    );
    await tester.tap(find.text('tap me'));
    expect(taps, 1);
  });

  testWidgets('GlassCard only blurs when asked', (tester) async {
    await tester.pumpWidget(_host(const GlassCard(child: Text('a'))));
    expect(find.byType(BackdropFilter), findsNothing);

    await tester.pumpWidget(_host(const GlassCard(blur: true, child: Text('a'))));
    expect(find.byType(BackdropFilter), findsOneWidget);
  });

  testWidgets('TagChip renders its label in both themes', (tester) async {
    await tester.pumpWidget(_host(const TagChip('Flutter')));
    expect(find.text('Flutter'), findsOneWidget);

    await tester.pumpWidget(_host(const TagChip('Flutter', emphasized: true), dark: true));
    expect(find.text('Flutter'), findsOneWidget);
  });

  testWidgets('GradientText renders text through a ShaderMask', (tester) async {
    await tester.pumpWidget(_host(const GradientText('Senior Mobile Engineer')));
    expect(find.text('Senior Mobile Engineer'), findsOneWidget);
    expect(find.byType(ShaderMask), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/common/surfaces_test.dart`
Expected: FAIL — "Target of URI doesn't exist: 'package:my_website/src/widgets/common/glass_card.dart'".

- [ ] **Step 3: Write minimal implementation**

Create `lib/src/widgets/common/glass_card.dart`:

```dart
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/design/app_surfaces.dart';
import '../../core/design/app_tokens.dart';

/// The one card style in the app: surface, hairline border, radius, shadow.
/// Set [blur] for frosted glass (nav pill, stat tiles) — never inside a
/// scrolling list, it is expensive in CanvasKit.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool blur;
  final bool raised;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpace.lg),
    this.radius = AppRadius.md,
    this.blur = false,
    this.raised = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final corners = BorderRadius.circular(radius);

    Widget body = Padding(padding: padding, child: child);

    if (onTap != null) {
      body = Material(
        color: Colors.transparent,
        child: InkWell(borderRadius: corners, onTap: onTap, child: body),
      );
    }

    Widget surface = DecoratedBox(
      decoration: BoxDecoration(
        color: blur ? p.surfaceGlass : p.surface,
        borderRadius: corners,
        border: Border.all(color: p.hairline),
      ),
      child: body,
    );

    surface = ClipRRect(
      borderRadius: corners,
      child: blur
          ? BackdropFilter(filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), child: surface)
          : surface,
    );

    if (!raised) return surface;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: corners,
        boxShadow: [BoxShadow(color: p.shadow, blurRadius: 34, offset: const Offset(0, 14))],
      ),
      child: surface,
    );
  }
}
```

Create `lib/src/widgets/common/tag_chip.dart`:

```dart
import 'package:flutter/material.dart';

import '../../core/design/app_surfaces.dart';
import '../../core/design/app_tokens.dart';

/// The one chip style: skills, technologies, periods.
/// [emphasized] fills it with the brand gradient — use for "Present"/"Featured".
class TagChip extends StatelessWidget {
  final String label;
  final bool emphasized;

  const TagChip(this.label, {super.key, this.emphasized = false});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.sm, vertical: 6),
      decoration: BoxDecoration(
        color: emphasized ? null : p.brandSoft,
        gradient: emphasized
            ? LinearGradient(
                colors: p.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: emphasized ? p.onBrand : p.brand,
            ),
      ),
    );
  }
}
```

Create `lib/src/widgets/common/gradient_text.dart`:

```dart
import 'package:flutter/material.dart';

import '../../core/design/app_surfaces.dart';

/// Paints text with the brand gradient.
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const GradientText(this.text, {super.key, this.style, this.textAlign});

  @override
  Widget build(BuildContext context) {
    final colors = context.palette.gradient;
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(
        text,
        textAlign: textAlign,
        style: (style ?? Theme.of(context).textTheme.headlineSmall)?.copyWith(color: Colors.white),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/common/surfaces_test.dart`
Expected: PASS — `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/src/widgets/common test/widgets/common
git commit -m "feat(ui): add GlassCard, TagChip and GradientText primitives"
```

---

### Task 9: Motion primitives — AuroraBackground, HoverLift, Reveal

**Files:**
- Create: `lib/src/widgets/common/aurora_background.dart`
- Create: `lib/src/widgets/common/hover_lift.dart`
- Create: `lib/src/widgets/common/reveal.dart`
- Test: `test/widgets/common/motion_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/widgets/common/motion_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_website/src/core/app_theme.dart';
import 'package:my_website/src/widgets/common/aurora_background.dart';
import 'package:my_website/src/widgets/common/hover_lift.dart';
import 'package:my_website/src/widgets/common/reveal.dart';

Widget _host(Widget child, {bool reduceMotion = false}) => MaterialApp(
      theme: AppTheme.light,
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: Scaffold(body: child),
      ),
    );

void main() {
  testWidgets('AuroraBackground renders its child', (tester) async {
    await tester.pumpWidget(_host(const AuroraBackground(child: Text('page'))));
    expect(find.text('page'), findsOneWidget);
  });

  testWidgets('HoverLift renders its child and is not offset at rest', (tester) async {
    await tester.pumpWidget(_host(const Center(child: HoverLift(child: Text('card')))));
    await tester.pumpAndSettle();
    expect(find.text('card'), findsOneWidget);
  });

  testWidgets('Reveal ends fully visible for content already on screen', (tester) async {
    await tester.pumpWidget(_host(const Reveal(child: Text('visible'))));
    await tester.pumpAndSettle();

    final opacity = tester.widget<FadeTransition>(
      find.ancestor(of: find.text('visible'), matching: find.byType(FadeTransition)).first,
    );
    expect(opacity.opacity.value, 1.0);
  });

  testWidgets('Reveal is instantly visible when animations are disabled', (tester) async {
    await tester.pumpWidget(_host(const Reveal(child: Text('visible')), reduceMotion: true));
    await tester.pump();

    final opacity = tester.widget<FadeTransition>(
      find.ancestor(of: find.text('visible'), matching: find.byType(FadeTransition)).first,
    );
    expect(opacity.opacity.value, 1.0);
  });

  testWidgets('Reveal inside a scroll view reveals content scrolled into range', (tester) async {
    await tester.pumpWidget(
      _host(
        ListView(
          children: const [
            SizedBox(height: 2000),
            Reveal(child: Text('far below')),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -2000));
    await tester.pumpAndSettle();

    final opacity = tester.widget<FadeTransition>(
      find.ancestor(of: find.text('far below'), matching: find.byType(FadeTransition)).first,
    );
    expect(opacity.opacity.value, 1.0);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/common/motion_test.dart`
Expected: FAIL — "Target of URI doesn't exist: 'package:my_website/src/widgets/common/aurora_background.dart'".

- [ ] **Step 3: Write minimal implementation**

Create `lib/src/widgets/common/aurora_background.dart`:

```dart
import 'package:flutter/material.dart';

import '../../core/design/app_surfaces.dart';

/// Paints the canvas and the two radial aurora glows behind page content.
/// One instance per page, wrapping the scroll view.
class AuroraBackground extends StatelessWidget {
  final Widget child;

  const AuroraBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(color: p.canvas),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.8, -1.0),
                  radius: 1.1,
                  colors: [p.auroraPrimary, p.auroraPrimary.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.9, -0.85),
                  radius: 1.0,
                  colors: [p.auroraSecondary, p.auroraSecondary.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
```

Create `lib/src/widgets/common/hover_lift.dart`:

```dart
import 'package:flutter/material.dart';

import '../../core/design/app_tokens.dart';

/// Lifts its child on pointer hover. No-op on touch devices and when the
/// platform asks for reduced motion.
class HoverLift extends StatefulWidget {
  final Widget child;
  final double lift;

  const HoverLift({super.key, required this.child, this.lift = 4});

  @override
  State<HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<HoverLift> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) return widget.child;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedSlide(
        offset: _hovered ? Offset(0, -widget.lift / 100) : Offset.zero,
        duration: AppMotion.fast,
        curve: AppMotion.standard,
        child: widget.child,
      ),
    );
  }
}
```

Create `lib/src/widgets/common/reveal.dart`:

```dart
import 'package:flutter/material.dart';

import '../../core/design/app_tokens.dart';

/// Fades and rises its child the first time it scrolls into view.
/// Plays once. Instant when the platform asks for reduced motion.
class Reveal extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const Reveal({super.key, required this.child, this.delay = Duration.zero});

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: AppMotion.base);
  late final Animation<double> _fade =
      CurvedAnimation(parent: _controller, curve: AppMotion.standard);
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.08),
    end: Offset.zero,
  ).animate(_fade);

  ScrollPosition? _position;
  bool _played = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybePlay());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      _played = true;
      _controller.value = 1;
      return;
    }

    _position?.removeListener(_maybePlay);
    _position = Scrollable.maybeOf(context)?.position;
    _position?.addListener(_maybePlay);
  }

  void _maybePlay() {
    if (_played || !mounted) return;

    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final viewportHeight = MediaQuery.of(context).size.height;
    final top = box.localToGlobal(Offset.zero).dy;
    if (top > viewportHeight * 0.92) return;

    _played = true;
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _position?.removeListener(_maybePlay);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/common/motion_test.dart`
Expected: PASS — `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/src/widgets/common test/widgets/common
git commit -m "feat(ui): add aurora background, hover lift and scroll reveal"
```

---

### Task 10: Layout primitives — SectionShell and StatTile

**Files:**
- Create: `lib/src/widgets/common/section_shell.dart`
- Create: `lib/src/widgets/common/stat_tile.dart`
- Test: `test/widgets/common/layout_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/widgets/common/layout_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_website/src/core/app_theme.dart';
import 'package:my_website/src/widgets/common/section_shell.dart';
import 'package:my_website/src/widgets/common/stat_tile.dart';

Widget _host(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  testWidgets('SectionShell shows eyebrow, title, subtitle and child', (tester) async {
    await tester.pumpWidget(
      _host(const SectionShell(
        index: '01',
        label: 'ABOUT',
        title: 'My story',
        subtitle: 'Who I am',
        child: Text('body'),
      )),
    );
    await tester.pumpAndSettle();

    expect(find.text('01 — ABOUT'), findsOneWidget);
    expect(find.text('My story'), findsOneWidget);
    expect(find.text('Who I am'), findsOneWidget);
    expect(find.text('body'), findsOneWidget);
  });

  testWidgets('SectionShell omits the subtitle when it is empty', (tester) async {
    await tester.pumpWidget(
      _host(const SectionShell(index: '02', label: 'WORK', title: 'Projects', child: Text('body'))),
    );
    await tester.pumpAndSettle();

    expect(find.text('02 — WORK'), findsOneWidget);
    expect(find.byType(Text), findsNWidgets(3)); // eyebrow, title, body
  });

  testWidgets('StatTile shows value and label', (tester) async {
    await tester.pumpWidget(_host(const StatTile(value: '5', label: 'Years experience')));
    await tester.pumpAndSettle();

    expect(find.text('5'), findsOneWidget);
    expect(find.text('Years experience'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/common/layout_test.dart`
Expected: FAIL — "Target of URI doesn't exist: 'package:my_website/src/widgets/common/section_shell.dart'".

- [ ] **Step 3: Write minimal implementation**

Create `lib/src/widgets/common/section_shell.dart`:

```dart
import 'package:flutter/material.dart';

import '../../core/design/app_surfaces.dart';
import '../../core/design/app_tokens.dart';
import 'reveal.dart';

/// Numbered section heading + content. Replaces the old SectionHeader.
class SectionShell extends StatelessWidget {
  final String index;
  final String label;
  final String title;
  final String subtitle;
  final Widget child;

  const SectionShell({
    super.key,
    required this.index,
    required this.label,
    required this.title,
    this.subtitle = '',
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Reveal(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$index — $label', style: theme.textTheme.labelSmall),
              const SizedBox(height: AppSpace.xs),
              Text(
                title,
                style: theme.textTheme.headlineMedium?.copyWith(color: p.ink),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: AppSpace.xxs),
                Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: p.inkSubtle)),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpace.lg),
        child,
      ],
    );
  }
}
```

Create `lib/src/widgets/common/stat_tile.dart`:

```dart
import 'package:flutter/material.dart';

import '../../core/design/app_surfaces.dart';
import '../../core/design/app_tokens.dart';
import 'glass_card.dart';

/// A number and its label, in a frosted tile.
class StatTile extends StatelessWidget {
  final String value;
  final String label;

  const StatTile({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;

    return GlassCard(
      blur: true,
      raised: false,
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.md, vertical: AppSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: p.brand,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpace.xxs),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/common/layout_test.dart`
Expected: PASS — `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/src/widgets/common test/widgets/common
git commit -m "feat(ui): add SectionShell and StatTile"
```

---

### Task 11: Hero and stats

**Files:**
- Modify: `lib/src/widgets/hero_section.dart` (full rewrite)
- Create: `lib/src/widgets/stats_section.dart`
- Test: `test/widgets/stats_section_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/widgets/stats_section_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:my_website/src/core/app_theme.dart';
import 'package:my_website/src/state/cv_provider.dart';
import 'package:my_website/src/widgets/common/stat_tile.dart';
import 'package:my_website/src/widgets/stats_section.dart';

const _sample =
    '{"name":"N","title":"T","email":"e","phone":"p","location":"Cairo","linkedin":"li","github":"gh","summary":"s","yearsExperience":5,"education":{"degree":"d","university":"u","period":"pr","location":"loc"},"skills":["Flutter","Dart","Firebase"],"experience":[],"projects":[{"name":"A","period":"01/2024","description":"d","technologies":["Flutter"],"stores":["https://apps.apple.com/x/id1","https://play.google.com/store/apps/details?id=a"]}],"links":{}}';

void main() {
  testWidgets('renders four stat tiles derived from the CV', (tester) async {
    final provider = CVProvider();
    await provider.loadFromString(_sample);

    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ChangeNotifierProvider<CVProvider>.value(
        value: provider,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: SingleChildScrollView(child: StatsSection())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(StatTile), findsNWidgets(4));
    expect(find.text('5+'), findsOneWidget);          // yearsExperience override
    expect(find.text('Years experience'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);           // one project
    expect(find.text('2'), findsOneWidget);           // two distinct store hosts
    expect(find.text('3'), findsOneWidget);           // three skills
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/stats_section_test.dart`
Expected: FAIL — "Target of URI doesn't exist: 'package:my_website/src/widgets/stats_section.dart'".

- [ ] **Step 3: Create the stats section**

Create `lib/src/widgets/stats_section.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/cv_stats.dart';
import '../core/design/app_tokens.dart';
import '../core/responsive.dart';
import '../state/cv_provider.dart';
import 'common/reveal.dart';
import 'common/stat_tile.dart';

/// Four numbers under the hero, all derived from the CV.
class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cv = context.watch<CVProvider>().cv;
    if (cv == null) return const SizedBox.shrink();

    final stats = CvStats.from(cv);
    final tiles = <Widget>[
      StatTile(value: '${stats.years}+', label: 'Years experience'),
      StatTile(value: '${stats.projects}', label: 'Projects shipped'),
      StatTile(value: '${stats.stores}', label: 'App stores'),
      StatTile(value: '${stats.technologies}', label: 'Technologies'),
    ];
    final columns = context.isMobile ? 2 : 4;

    return Reveal(
      delay: AppMotion.stagger,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const gap = AppSpace.sm;
          final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [for (final tile in tiles) SizedBox(width: width, child: tile)],
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/stats_section_test.dart`
Expected: PASS — `All tests passed!`

- [ ] **Step 5: Rewrite the hero**

Replace the whole of `lib/src/widgets/hero_section.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../core/analytics/analytics.dart';
import '../core/design/app_surfaces.dart';
import '../core/design/app_tokens.dart';
import '../core/responsive.dart';
import '../core/resume_download.dart';
import '../state/cv_provider.dart';
import 'common/gradient_text.dart';
import 'common/reveal.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback onContactTap;
  final VoidCallback onWorkTap;

  const HeroSection({super.key, required this.onContactTap, required this.onWorkTap});

  @override
  Widget build(BuildContext context) {
    final cv = context.watch<CVProvider>().cv;
    if (cv == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final p = context.palette;
    final isDesktop = context.isDesktop;
    final textAlign = isDesktop ? TextAlign.start : TextAlign.center;

    final copy = Column(
      crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.place_outlined, size: 16, color: p.inkSubtle),
            const SizedBox(width: AppSpace.xxs),
            Text(cv.location, style: theme.textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: AppSpace.md),
        Text(
          cv.name,
          textAlign: textAlign,
          style: isDesktop ? theme.textTheme.displayMedium : theme.textTheme.displaySmall,
        ),
        const SizedBox(height: AppSpace.xs),
        GradientText(
          cv.title,
          textAlign: textAlign,
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpace.md),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Text(cv.summary, textAlign: textAlign, style: theme.textTheme.bodyLarge),
        ),
        const SizedBox(height: AppSpace.lg),
        Wrap(
          spacing: AppSpace.sm,
          runSpacing: AppSpace.sm,
          alignment: isDesktop ? WrapAlignment.start : WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _GradientButton(
              icon: Icons.download_rounded,
              label: 'Download CV',
              onPressed: () {
                trackEvent('download_cv_click', params: {'from': 'hero'});
                downloadResume();
              },
            ),
            OutlinedButton.icon(
              onPressed: onWorkTap,
              icon: const Icon(Icons.folder_open_rounded, size: 18),
              label: const Text('View my work'),
            ),
            OutlinedButton.icon(
              onPressed: onContactTap,
              icon: const Icon(Icons.mail_outline_rounded, size: 18),
              label: const Text('Get in touch'),
            ),
            _IconLink(
              icon: Icons.business_center_rounded,
              tooltip: 'LinkedIn',
              url: cv.linkedin,
              network: 'linkedin',
            ),
            _IconLink(
              icon: Icons.code_rounded,
              tooltip: 'GitHub',
              url: cv.github,
              network: 'github',
            ),
          ],
        ),
      ],
    );

    final portrait = _Portrait(size: isDesktop ? 260 : 180);

    return Reveal(
      child: isDesktop
          ? Row(
              children: [
                Expanded(flex: 3, child: copy),
                const SizedBox(width: AppSpace.xl),
                Expanded(flex: 2, child: Center(child: portrait)),
              ],
            )
          : Column(children: [portrait, const SizedBox(height: AppSpace.lg), copy]),
    );
  }
}

class _Portrait extends StatelessWidget {
  final double size;

  const _Portrait({required this.size});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: p.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: p.gradient.first.withValues(alpha: 0.35),
            blurRadius: 42,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl - 3),
        child: Image.asset(
          'assets/images/cv_image.png',
          fit: BoxFit.cover,
          semanticLabel: 'Portrait photo',
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _GradientButton({required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: p.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: [
          BoxShadow(
            color: p.gradient.first.withValues(alpha: 0.34),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
        ),
        icon: Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }
}

class _IconLink extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final String url;
  final String network;

  const _IconLink({
    required this.icon,
    required this.tooltip,
    required this.url,
    required this.network,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: url.isEmpty
            ? null
            : () {
                trackEvent('outbound_click', params: {'network': network});
                launchUrlString(url, webOnlyWindowName: '_blank');
              },
        icon: Icon(icon, size: 20),
        style: IconButton.styleFrom(
          foregroundColor: p.brand,
          side: BorderSide(color: p.hairline),
          padding: const EdgeInsets.all(AppSpace.sm),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
        ),
      ),
    );
  }
}
```

- [ ] **Step 6: Verify the app still compiles**

`home_page.dart` does not pass `onWorkTap` yet, so this is expected to fail until Task 16.

Run: `flutter analyze lib/src/widgets/hero_section.dart lib/src/widgets/stats_section.dart`
Expected: no errors in these two files. A "missing required argument 'onWorkTap'" error in `home_page.dart` is expected and is fixed in Task 16.

- [ ] **Step 7: Commit**

```bash
git add lib/src/widgets/hero_section.dart lib/src/widgets/stats_section.dart test/widgets/stats_section_test.dart
git commit -m "feat(ui): two-column hero and derived stats strip"
```

---

### Task 12: About and Skills

**Files:**
- Modify: `lib/src/widgets/about_section.dart` (full rewrite)
- Modify: `lib/src/widgets/skills_section.dart` (full rewrite)
- Test: `test/widgets/about_skills_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/widgets/about_skills_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:my_website/src/core/app_theme.dart';
import 'package:my_website/src/state/cv_provider.dart';
import 'package:my_website/src/widgets/about_section.dart';
import 'package:my_website/src/widgets/common/tag_chip.dart';
import 'package:my_website/src/widgets/skills_section.dart';

const _sample =
    '{"name":"N","title":"T","email":"e","phone":"p","location":"Cairo","linkedin":"li","github":"gh","summary":"My summary text.","education":{"degree":"BSc Engineering","university":"Al-Azhar University","period":"2017 - 2022","location":"Cairo"},"skills":["Flutter","Firebase","CI/CD"],"experience":[],"projects":[],"links":{}}';

Future<void> _pump(WidgetTester tester, Widget child) async {
  final provider = CVProvider();
  await provider.loadFromString(_sample);

  tester.view.physicalSize = const Size(1400, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ChangeNotifierProvider<CVProvider>.value(
      value: provider,
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('About shows the summary and the education entry', (tester) async {
    await _pump(tester, const AboutSection());

    expect(find.text('01 — ABOUT'), findsOneWidget);
    expect(find.text('My summary text.'), findsOneWidget);
    expect(find.text('BSc Engineering'), findsOneWidget);
    expect(find.text('Al-Azhar University'), findsOneWidget);
  });

  testWidgets('Skills renders one card per group and a chip per skill', (tester) async {
    await _pump(tester, const SkillsSection());

    expect(find.text('02 — SKILLS'), findsOneWidget);
    expect(find.text('Mobile'), findsOneWidget);
    expect(find.text('Backend & Data'), findsOneWidget);
    expect(find.text('Delivery & Practices'), findsOneWidget);
    expect(find.byType(TagChip), findsNWidgets(3));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/about_skills_test.dart`
Expected: FAIL — `Expected: exactly one matching candidate  Actual: _TextFinder:<zero widgets with text "01 — ABOUT">`.

- [ ] **Step 3: Rewrite About**

Replace the whole of `lib/src/widgets/about_section.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/design/app_surfaces.dart';
import '../core/design/app_tokens.dart';
import '../core/responsive.dart';
import '../state/cv_provider.dart';
import 'common/glass_card.dart';
import 'common/reveal.dart';
import 'common/section_shell.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cv = context.watch<CVProvider>().cv;
    if (cv == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final p = context.palette;

    final story = GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const _CardHeading(icon: Icons.person_outline_rounded, title: 'My story'),
          const SizedBox(height: AppSpace.md),
          Text(cv.summary, style: theme.textTheme.bodyLarge),
        ],
      ),
    );

    final education = GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const _CardHeading(icon: Icons.school_outlined, title: 'Education'),
          const SizedBox(height: AppSpace.md),
          Text(cv.education.degree, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpace.xxs),
          Text(
            cv.education.university,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: p.brand,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpace.xs),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 14, color: p.inkSubtle),
              const SizedBox(width: AppSpace.xxs),
              Expanded(
                child: Text(
                  '${cv.education.period} · ${cv.education.location}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return SectionShell(
      index: '01',
      label: 'ABOUT',
      title: 'About me',
      subtitle: 'Who I am and where I studied',
      child: Reveal(
        child: context.isDesktop
            ? IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 3, child: story),
                    const SizedBox(width: AppSpace.md),
                    Expanded(flex: 2, child: education),
                  ],
                ),
              )
            : Column(children: [story, const SizedBox(height: AppSpace.md), education]),
      ),
    );
  }
}

class _CardHeading extends StatelessWidget {
  final IconData icon;
  final String title;

  const _CardHeading({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpace.xs),
          decoration: BoxDecoration(
            color: p.brandSoft,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, size: 20, color: p.brand),
        ),
        const SizedBox(width: AppSpace.sm),
        Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
      ],
    );
  }
}
```

- [ ] **Step 4: Rewrite Skills**

Replace the whole of `lib/src/widgets/skills_section.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/design/app_surfaces.dart';
import '../core/design/app_tokens.dart';
import '../core/responsive.dart';
import '../core/skill_categories.dart';
import '../state/cv_provider.dart';
import 'common/glass_card.dart';
import 'common/reveal.dart';
import 'common/section_shell.dart';
import 'common/tag_chip.dart';

class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cv = context.watch<CVProvider>().cv;
    if (cv == null) return const SizedBox.shrink();

    final groups = SkillCategories.group(cv.skills);
    final columns = context.isDesktop ? 3 : (context.isTablet ? 2 : 1);

    return SectionShell(
      index: '02',
      label: 'SKILLS',
      title: 'What I work with',
      subtitle: 'Grouped by discipline',
      child: LayoutBuilder(
        builder: (context, constraints) {
          const gap = AppSpace.md;
          final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (var i = 0; i < groups.length; i++)
                SizedBox(
                  width: width,
                  child: Reveal(
                    delay: AppMotion.stagger * i,
                    child: _SkillGroupCard(group: groups[i]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SkillGroupCard extends StatelessWidget {
  final SkillGroup group;

  const _SkillGroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(group.icon, size: 18, color: p.brand),
              const SizedBox(width: AppSpace.xs),
              Expanded(
                child: Text(group.title, style: Theme.of(context).textTheme.titleMedium),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          Wrap(
            spacing: AppSpace.xs,
            runSpacing: AppSpace.xs,
            children: [for (final skill in group.skills) TagChip(skill)],
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/widgets/about_skills_test.dart`
Expected: PASS — `All tests passed!`

- [ ] **Step 6: Commit**

```bash
git add lib/src/widgets/about_section.dart lib/src/widgets/skills_section.dart test/widgets/about_skills_test.dart
git commit -m "feat(ui): rebuild About and Skills on the design primitives"
```

---

### Task 13: Experience timeline

**Files:**
- Modify: `lib/src/widgets/experience_section.dart` (full rewrite)
- Test: `test/widgets/experience_section_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/widgets/experience_section_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:my_website/src/core/app_theme.dart';
import 'package:my_website/src/state/cv_provider.dart';
import 'package:my_website/src/widgets/common/tag_chip.dart';
import 'package:my_website/src/widgets/experience_section.dart';

const _sample =
    '{"name":"N","title":"T","email":"e","phone":"p","location":"Cairo","linkedin":"li","github":"gh","summary":"s","education":{"degree":"d","university":"u","period":"pr","location":"loc"},"skills":[],"projects":[],"links":{},"experience":[{"company":"The Address","role":"Senior Flutter Engineer","period":"02/2025 - Present","location":"Cairo","highlights":["Built four internal apps","Mentored juniors"]},{"company":"POSBANK","role":"Senior Flutter Engineer","period":"03/2022 - 02/2025","location":"Remote","highlights":["Shipped three POS systems"]}]}';

void main() {
  testWidgets('renders one entry per role with period chips and highlights', (tester) async {
    final provider = CVProvider();
    await provider.loadFromString(_sample);

    tester.view.physicalSize = const Size(1400, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ChangeNotifierProvider<CVProvider>.value(
        value: provider,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: SingleChildScrollView(child: ExperienceSection())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('03 — EXPERIENCE'), findsOneWidget);
    expect(find.text('The Address · Cairo'), findsOneWidget);
    expect(find.text('POSBANK · Remote'), findsOneWidget);
    expect(find.text('Built four internal apps'), findsOneWidget);
    expect(find.text('Shipped three POS systems'), findsOneWidget);
    expect(find.byType(TagChip), findsNWidgets(2));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/experience_section_test.dart`
Expected: FAIL — `Expected: exactly one matching candidate  Actual: _TextFinder:<zero widgets with text "03 — EXPERIENCE">`.

- [ ] **Step 3: Write minimal implementation**

Replace the whole of `lib/src/widgets/experience_section.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/design/app_surfaces.dart';
import '../core/design/app_tokens.dart';
import '../models/cv.dart';
import '../state/cv_provider.dart';
import 'common/glass_card.dart';
import 'common/reveal.dart';
import 'common/section_shell.dart';
import 'common/tag_chip.dart';

class ExperienceSection extends StatelessWidget {
  const ExperienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cv = context.watch<CVProvider>().cv;
    if (cv == null || cv.experience.isEmpty) return const SizedBox.shrink();

    return SectionShell(
      index: '03',
      label: 'EXPERIENCE',
      title: "Where I've worked",
      subtitle: 'Most recent first',
      child: Column(
        children: [
          for (var i = 0; i < cv.experience.length; i++)
            Reveal(
              delay: AppMotion.stagger * i,
              child: _TimelineEntry(
                experience: cv.experience[i],
                isCurrent: i == 0,
                isLast: i == cv.experience.length - 1,
              ),
            ),
        ],
      ),
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  final Experience experience;
  final bool isCurrent;
  final bool isLast;

  const _TimelineEntry({
    required this.experience,
    required this.isCurrent,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 34,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.only(top: AppSpace.lg),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCurrent ? null : p.inkSubtle,
                    gradient: isCurrent ? LinearGradient(colors: p.gradient) : null,
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: p.gradient.first.withValues(alpha: 0.55),
                              blurRadius: 14,
                            ),
                          ]
                        : null,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: p.hairline,
                      margin: const EdgeInsets.symmetric(vertical: AppSpace.xs),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpace.md),
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(experience.role, style: theme.textTheme.titleLarge),
                              const SizedBox(height: AppSpace.xxs),
                              Text(
                                '${experience.company} · ${experience.location}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: p.brand,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpace.xs),
                        TagChip(experience.period, emphasized: isCurrent),
                      ],
                    ),
                    if (experience.highlights.isNotEmpty) const SizedBox(height: AppSpace.sm),
                    for (final highlight in experience.highlights)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpace.xxs),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 7, right: AppSpace.xs),
                              child: Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(color: p.brand, shape: BoxShape.circle),
                              ),
                            ),
                            Expanded(child: Text(highlight, style: theme.textTheme.bodyMedium)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/widgets/experience_section_test.dart`
Expected: PASS — `All tests passed!`

- [ ] **Step 5: Commit**

```bash
git add lib/src/widgets/experience_section.dart test/widgets/experience_section_test.dart
git commit -m "feat(ui): turn experience into a vertical timeline"
```

---

### Task 14: Projects — featured first

**Files:**
- Create: `lib/src/widgets/featured_project_card.dart`
- Modify: `lib/src/widgets/projects_section.dart` (full rewrite)
- Modify: `lib/src/widgets/project_card.dart:17-236` (build shell only — all helper methods and the dialog stay untouched)
- Test: `test/widgets/projects_section_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/widgets/projects_section_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:my_website/src/core/app_theme.dart';
import 'package:my_website/src/state/cv_provider.dart';
import 'package:my_website/src/widgets/featured_project_card.dart';
import 'package:my_website/src/widgets/project_card.dart';
import 'package:my_website/src/widgets/projects_section.dart';

const _sample =
    '{"name":"N","title":"T","email":"e","phone":"p","location":"Cairo","linkedin":"li","github":"gh","summary":"s","education":{"degree":"d","university":"u","period":"pr","location":"loc"},"skills":[],"experience":[],"links":{},"projects":[{"name":"My TAI","period":"02/2025","description":"CRM app.","technologies":["Flutter","Bloc"],"stores":["https://apps.apple.com/x/id1"]},{"name":"Snapos","period":"04/2022","description":"POS app.","technologies":["Flutter"],"stores":[]},{"name":"Ovii","period":"01/2024","description":"Health app.","technologies":["Flutter"],"stores":[]}]}';

void main() {
  testWidgets('first project is featured, the rest render as cards', (tester) async {
    final provider = CVProvider();
    await provider.loadFromString(_sample);

    tester.view.physicalSize = const Size(1400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ChangeNotifierProvider<CVProvider>.value(
        value: provider,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: SingleChildScrollView(child: ProjectsSection())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('04 — WORK'), findsOneWidget);
    expect(find.byType(FeaturedProjectCard), findsOneWidget);
    expect(find.byType(ProjectCard), findsNWidgets(2));
    expect(find.text('My TAI'), findsOneWidget);
    expect(find.text('App Store'), findsWidgets);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/projects_section_test.dart`
Expected: FAIL — "Target of URI doesn't exist: 'package:my_website/src/widgets/featured_project_card.dart'".

- [ ] **Step 3: Create the featured card**

Create `lib/src/widgets/featured_project_card.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../core/analytics/analytics.dart';
import '../core/design/app_surfaces.dart';
import '../core/design/app_tokens.dart';
import '../core/responsive.dart';
import '../models/cv.dart';
import 'common/glass_card.dart';
import 'common/hover_lift.dart';
import 'common/tag_chip.dart';

/// The wide, first-position project card. Unlike [ProjectCard] it exposes the
/// store links directly instead of opening the detail dialog.
class FeaturedProjectCard extends StatelessWidget {
  final Project project;

  const FeaturedProjectCard({super.key, required this.project});

  static String storeName(String url) {
    if (url.contains('apple.com')) return 'App Store';
    if (url.contains('play.google.com')) return 'Play Store';
    if (url.contains('appgallery.huawei.com')) return 'AppGallery';
    if (url.contains('apps.microsoft.com')) return 'Microsoft Store';
    return Uri.tryParse(url)?.host.replaceFirst('www.', '') ?? url;
  }

  static IconData storeIcon(String url) {
    if (url.contains('apple.com')) return Icons.phone_iphone;
    if (url.contains('play.google.com')) return Icons.shop;
    if (url.contains('appgallery.huawei.com')) return Icons.apps;
    if (url.contains('apps.microsoft.com')) return Icons.window;
    return Icons.link;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;

    final artwork = ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        width: 96,
        height: 96,
        color: p.brandSoft,
        child: project.image != null && project.image!.isNotEmpty
            ? Image.asset(
                project.image!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) =>
                    Icon(Icons.apps_rounded, size: 40, color: p.brand),
              )
            : Icon(Icons.apps_rounded, size: 40, color: p.brand),
      ),
    );

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: AppSpace.xs,
          runSpacing: AppSpace.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const TagChip('FEATURED', emphasized: true),
            Text(project.name, style: theme.textTheme.headlineSmall),
          ],
        ),
        const SizedBox(height: AppSpace.xxs),
        Text(
          project.period,
          style: theme.textTheme.bodySmall?.copyWith(
            color: p.brand,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpace.sm),
        Text(project.description, style: theme.textTheme.bodyMedium),
        if (project.technologies.isNotEmpty) ...[
          const SizedBox(height: AppSpace.sm),
          Wrap(
            spacing: AppSpace.xs,
            runSpacing: AppSpace.xs,
            children: [for (final tech in project.technologies) TagChip(tech)],
          ),
        ],
        if (project.stores.isNotEmpty) ...[
          const SizedBox(height: AppSpace.md),
          Wrap(
            spacing: AppSpace.xs,
            runSpacing: AppSpace.xs,
            children: [
              for (final store in project.stores)
                OutlinedButton.icon(
                  onPressed: () {
                    trackEvent('project_link_click', params: {
                      'project': project.name,
                      'url': store,
                      'store': storeName(store),
                    });
                    launchUrlString(store, webOnlyWindowName: '_blank');
                  },
                  icon: Icon(storeIcon(store), size: 16),
                  label: Text(storeName(store)),
                ),
            ],
          ),
        ],
      ],
    );

    return HoverLift(
      child: GlassCard(
        child: context.isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [artwork, const SizedBox(height: AppSpace.md), details],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  artwork,
                  const SizedBox(width: AppSpace.lg),
                  Expanded(child: details),
                ],
              ),
      ),
    );
  }
}
```

- [ ] **Step 4: Rewrite the projects section**

Replace the whole of `lib/src/widgets/projects_section.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/design/app_tokens.dart';
import '../core/responsive.dart';
import '../state/cv_provider.dart';
import 'common/reveal.dart';
import 'common/section_shell.dart';
import 'featured_project_card.dart';
import 'project_card.dart';

class ProjectsSection extends StatelessWidget {
  const ProjectsSection({super.key});

  /// Fixed height for grid cards — [ProjectCard] uses an Expanded body and
  /// therefore needs a bounded height from its parent.
  static const double _cardHeight = 300;

  @override
  Widget build(BuildContext context) {
    final cv = context.watch<CVProvider>().cv;
    if (cv == null || cv.projects.isEmpty) return const SizedBox.shrink();

    final featured = cv.projects.first;
    final rest = cv.projects.skip(1).toList();
    final columns = context.isDesktop ? 3 : (context.isTablet ? 2 : 1);

    return SectionShell(
      index: '04',
      label: 'WORK',
      title: 'Selected projects',
      subtitle: 'Tap a card for screenshots and store links',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Reveal(child: FeaturedProjectCard(project: featured)),
          if (rest.isNotEmpty) ...[
            const SizedBox(height: AppSpace.md),
            LayoutBuilder(
              builder: (context, constraints) {
                const gap = AppSpace.md;
                final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (var i = 0; i < rest.length; i++)
                      SizedBox(
                        width: width,
                        height: _cardHeight,
                        child: Reveal(
                          delay: AppMotion.stagger * i,
                          child: ProjectCard(project: rest[i]),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: Restyle the grid card**

In `lib/src/widgets/project_card.dart`:

**5a.** Add these imports below the existing ones:

```dart
import '../core/design/app_surfaces.dart';
import '../core/design/app_tokens.dart';
import 'common/glass_card.dart';
import 'common/hover_lift.dart';
import 'common/tag_chip.dart';
```

**5b.** Change the state class declaration on line 17 from
`class _ProjectCardState extends State<ProjectCard> with SingleTickerProviderStateMixin {`
to:

```dart
class _ProjectCardState extends State<ProjectCard> {
```

**5c.** Delete the three animation fields (`_controller`, `_scaleAnimation`, `_isHovered`) and both the
`initState` and `dispose` overrides — they contain nothing but controller setup and teardown.

**5d.** Replace the entire `build` method (from `Widget build(BuildContext context) {` down to the
closing `}` immediately before `String _domain(String url) {`) with:

```dart
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    final project = widget.project;

    return HoverLift(
      child: GlassCard(
        onTap: () => _showProjectDialog(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpace.xs),
                  decoration: BoxDecoration(
                    color: p.brandSoft,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: project.image != null && project.image!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.asset(
                            project.image!,
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.apps_rounded, size: 32, color: p.brand),
                          ),
                        )
                      : Icon(Icons.apps_rounded, size: 32, color: p.brand),
                ),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: theme.textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        project.period,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: p.brand,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_outward_rounded, size: 18, color: p.brand),
              ],
            ),
            const SizedBox(height: AppSpace.sm),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      project.description,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (project.technologies.isNotEmpty) ...[
                      const SizedBox(height: AppSpace.sm),
                      Wrap(
                        spacing: AppSpace.xs,
                        runSpacing: AppSpace.xs,
                        children: [
                          for (final tech in project.technologies.take(4)) TagChip(tech),
                        ],
                      ),
                    ],
                    if (project.stores.isNotEmpty) ...[
                      const SizedBox(height: AppSpace.sm),
                      Wrap(
                        spacing: AppSpace.sm,
                        runSpacing: AppSpace.xs,
                        children: [
                          for (final store in project.stores.take(2))
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_getStoreIcon(store), size: 14, color: p.inkSubtle),
                                const SizedBox(width: AppSpace.xxs),
                                Text(_getStoreName(store), style: theme.textTheme.bodySmall),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
```

- [ ] **Step 6: Run the project tests**

Run: `flutter test test/widgets/projects_section_test.dart test/project_card_test.dart`
Expected: PASS — both files. `project_card_test.dart` proves the detail dialog still opens on tap.

- [ ] **Step 7: Commit**

```bash
git add lib/src/widgets/featured_project_card.dart lib/src/widgets/projects_section.dart lib/src/widgets/project_card.dart test/widgets/projects_section_test.dart
git commit -m "feat(ui): featured-first projects layout on the design primitives"
```

---

### Task 15: Contact band and footer

**Files:**
- Modify: `lib/src/widgets/contact_section.dart` (full rewrite)
- Create: `lib/src/widgets/site_footer.dart`
- Test: `test/widgets/contact_footer_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/widgets/contact_footer_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:my_website/src/core/app_theme.dart';
import 'package:my_website/src/state/cv_provider.dart';
import 'package:my_website/src/widgets/contact_section.dart';
import 'package:my_website/src/widgets/site_footer.dart';

const _sample =
    '{"name":"Mustafa","title":"T","email":"me@example.com","phone":"+20100","location":"Cairo","linkedin":"https://linkedin.com/in/x","github":"https://github.com/x","summary":"s","education":{"degree":"d","university":"u","period":"pr","location":"loc"},"skills":[],"experience":[],"projects":[],"links":{}}';

Future<void> _pump(WidgetTester tester, Widget child) async {
  final provider = CVProvider();
  await provider.loadFromString(_sample);

  tester.view.physicalSize = const Size(1400, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ChangeNotifierProvider<CVProvider>.value(
      value: provider,
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('contact band shows the CTA and every channel', (tester) async {
    await _pump(tester, const ContactSection());

    expect(find.text('05 — CONTACT'), findsOneWidget);
    expect(find.text("Let's build something together"), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);
    expect(find.text('LinkedIn'), findsOneWidget);
    expect(find.text('GitHub'), findsOneWidget);
  });

  testWidgets('contact form validates empty fields', (tester) async {
    await _pump(tester, const ContactSection());

    await tester.tap(find.text('Send message'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your name'), findsOneWidget);
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter a message'), findsOneWidget);
  });

  testWidgets('footer shows the name and the build credit', (tester) async {
    await _pump(tester, const SiteFooter());

    expect(find.textContaining('Mustafa'), findsOneWidget);
    expect(find.textContaining('Built with Flutter'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widgets/contact_footer_test.dart`
Expected: FAIL — "Target of URI doesn't exist: 'package:my_website/src/widgets/site_footer.dart'".

- [ ] **Step 3: Rewrite the contact section**

Replace the whole of `lib/src/widgets/contact_section.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../core/analytics/analytics.dart';
import '../core/design/app_surfaces.dart';
import '../core/design/app_tokens.dart';
import '../models/cv.dart';
import '../state/cv_provider.dart';
import 'common/glass_card.dart';
import 'common/reveal.dart';
import 'common/section_shell.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cv = context.watch<CVProvider>().cv;
    if (cv == null) return const SizedBox.shrink();

    return SectionShell(
      index: '05',
      label: 'CONTACT',
      title: 'Get in touch',
      subtitle: 'The fastest way to reach me',
      child: Column(
        children: [
          Reveal(child: _CtaBand(cv: cv)),
          const SizedBox(height: AppSpace.md),
          Reveal(delay: AppMotion.stagger, child: _ContactForm(email: cv.email)),
        ],
      ),
    );
  }
}

class _CtaBand extends StatelessWidget {
  final CV cv;

  const _CtaBand({required this.cv});

  /// Digits only — WhatsApp rejects spaces, dashes and the leading plus.
  static String _whatsappNumber(String phone) => phone.replaceAll(RegExp(r'[^0-9]'), '');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg, vertical: AppSpace.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: p.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: p.gradient.first.withValues(alpha: 0.32),
            blurRadius: 38,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Let's build something together",
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSpace.xs),
          Text(
            'Open to interesting mobile work and collaborations.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.86)),
          ),
          const SizedBox(height: AppSpace.lg),
          Wrap(
            spacing: AppSpace.sm,
            runSpacing: AppSpace.sm,
            alignment: WrapAlignment.center,
            children: [
              _CtaButton(
                icon: Icons.mail_outline_rounded,
                label: 'Email',
                filled: true,
                onPressed: () {
                  trackEvent('contact_email_click', params: {'method': 'mailto'});
                  launchUrlString('mailto:${cv.email}');
                },
              ),
              _CtaButton(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'WhatsApp',
                onPressed: () {
                  trackEvent('contact_whatsapp_click', params: {'method': 'wa.me'});
                  launchUrlString(
                    'https://wa.me/${_whatsappNumber(cv.phone)}',
                    webOnlyWindowName: '_blank',
                  );
                },
              ),
              _CtaButton(
                icon: Icons.business_center_rounded,
                label: 'LinkedIn',
                onPressed: () {
                  trackEvent('outbound_click', params: {'network': 'linkedin'});
                  launchUrlString(cv.linkedin, webOnlyWindowName: '_blank');
                },
              ),
              _CtaButton(
                icon: Icons.code_rounded,
                label: 'GitHub',
                onPressed: () {
                  trackEvent('outbound_click', params: {'network': 'github'});
                  launchUrlString(cv.github, webOnlyWindowName: '_blank');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CtaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onPressed;

  const _CtaButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    if (filled) {
      return FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: p.brand),
        icon: Icon(icon, size: 18),
        label: Text(label),
      );
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.white.withValues(alpha: 0.55)),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class _ContactForm extends StatefulWidget {
  final String email;

  const _ContactForm({required this.email});

  @override
  State<_ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<_ContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  void _send() {
    if (!_formKey.currentState!.validate()) return;

    final subject = Uri.encodeComponent('Contact from ${_nameCtrl.text}');
    final body = Uri.encodeComponent(
      'From: ${_nameCtrl.text} <${_emailCtrl.text}>\n\n${_messageCtrl.text}',
    );
    trackEvent('contact_form_send', params: {'method': 'mailto'});
    launchUrlString('mailto:${widget.email}?subject=$subject&body=$body');

    _nameCtrl.clear();
    _emailCtrl.clear();
    _messageCtrl.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening email client…')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Send me a message', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpace.lg),
            _Field(
              controller: _nameCtrl,
              label: 'Your name',
              icon: Icons.person_outline_rounded,
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Please enter your name' : null,
            ),
            const SizedBox(height: AppSpace.md),
            _Field(
              controller: _emailCtrl,
              label: 'Your email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter your email';
                if (!value.contains('@')) return 'Please enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: AppSpace.md),
            _Field(
              controller: _messageCtrl,
              label: 'Your message',
              icon: Icons.message_outlined,
              maxLines: 4,
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Please enter a message' : null,
            ),
            const SizedBox(height: AppSpace.lg),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _send,
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text('Send message'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }
}
```

- [ ] **Step 4: Create the footer**

Create `lib/src/widgets/site_footer.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/design/app_surfaces.dart';
import '../core/design/app_tokens.dart';
import '../core/responsive.dart';
import '../state/cv_provider.dart';

/// Page footer. Replaces the bare copyright line that used to sit in the
/// home page's bottomNavigationBar.
class SiteFooter extends StatelessWidget {
  const SiteFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final cv = context.watch<CVProvider>().cv;
    final theme = Theme.of(context);
    final p = context.palette;
    final year = DateTime.now().year;

    final left = Text('© $year ${cv?.name ?? ''}'.trim(), style: theme.textTheme.bodySmall);
    const right = Text('Built with Flutter · Deployed on Netlify');

    return Column(
      children: [
        Divider(color: p.hairline, height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpace.lg),
          child: context.isMobile
              ? Column(
                  children: [
                    left,
                    const SizedBox(height: AppSpace.xxs),
                    DefaultTextStyle.merge(style: theme.textTheme.bodySmall, child: right),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    left,
                    DefaultTextStyle.merge(style: theme.textTheme.bodySmall, child: right),
                  ],
                ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/widgets/contact_footer_test.dart`
Expected: PASS — `All tests passed!`

- [ ] **Step 6: Commit**

```bash
git add lib/src/widgets/contact_section.dart lib/src/widgets/site_footer.dart test/widgets/contact_footer_test.dart
git commit -m "feat(ui): gradient contact band, restyled form and real footer"
```

---

### Task 16: Nav bar and home page assembly

**Files:**
- Modify: `lib/src/widgets/nav_bar.dart:170-205` (desktop pill only)
- Modify: `lib/src/pages/home_page.dart` (full rewrite)
- Delete: `lib/src/widgets/section_header.dart`
- Test: `test/home_hero_test.dart` (existing — must keep passing)

- [ ] **Step 1: Restyle the desktop nav pill**

In `lib/src/widgets/nav_bar.dart`, add the imports:

```dart
import '../core/design/app_surfaces.dart';
import '../core/design/app_tokens.dart';
import 'common/glass_card.dart';
```

Then replace the `return ClipRRect(…)` block at the end of `build` (the desktop branch, starting
`return ClipRRect(` and ending with the matching `);`) with:

```dart
    return GlassCard(
      blur: true,
      radius: AppRadius.pill,
      raised: false,
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.sm, vertical: AppSpace.xs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          navButton('Home', isHome ? 'home' : '/', isRoute: !isHome, icon: Icons.home_rounded),
          navButton('About', 'about', icon: Icons.person_rounded),
          navButton('Skills', 'skills', icon: Icons.code_rounded),
          navButton('Experience', 'experience', icon: Icons.work_rounded),
          isHome
              ? navButton('Projects', 'projects', icon: Icons.folder_rounded)
              : navButton('Projects', '/projects', isRoute: true, icon: Icons.folder_rounded),
          navButton('Resume', '/resume', isRoute: true, icon: Icons.description_rounded),
          navButton('Contact', 'contact', icon: Icons.mail_rounded),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpace.xs),
            height: 24,
            width: 1,
            color: context.palette.hairline,
          ),
          const _ThemeToggleButton(),
        ],
      ),
    );
```

The `isDark` local at the top of `build` is now unused — delete its declaration line.

- [ ] **Step 2: Rewrite the home page**

Replace the whole of `lib/src/pages/home_page.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/design/app_tokens.dart';
import '../core/responsive.dart';
import '../core/seo.dart';
import '../state/cv_provider.dart';
import '../widgets/about_section.dart';
import '../widgets/common/aurora_background.dart';
import '../widgets/contact_section.dart';
import '../widgets/experience_section.dart';
import '../widgets/hero_section.dart';
import '../widgets/nav_bar.dart';
import '../widgets/projects_section.dart';
import '../widgets/site_footer.dart';
import '../widgets/skills_section.dart';
import '../widgets/stats_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();
  String _currentSection = 'home';
  final _keys = <String, GlobalKey>{
    'home': GlobalKey(),
    'about': GlobalKey(),
    'skills': GlobalKey(),
    'experience': GlobalKey(),
    'projects': GlobalKey(),
    'contact': GlobalKey(),
  };

  static const _labels = <String, String>{
    'home': 'Home',
    'about': 'About',
    'skills': 'Skills',
    'experience': 'Experience',
    'projects': 'Projects',
    'contact': 'Contact',
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cv = context.watch<CVProvider>().cv;
    if (cv != null) {
      Seo.update(
        title: '${cv.name} - ${cv.title}',
        description: cv.summary,
        imageUrl: '/icons/Icon-512.png',
        urlPath: '/',
      );
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    var newSection = 'home';
    for (final entry in _keys.entries) {
      final ctx = entry.value.currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) continue;
      if (box.localToGlobal(Offset.zero).dy <= 150) newSection = entry.key;
    }
    if (newSection != _currentSection) {
      setState(() => _currentSection = newSection);
    }
  }

  void _scrollTo(String id) {
    setState(() => _currentSection = id);
    final ctx = _keys[id]?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, duration: AppMotion.slow, curve: AppMotion.standard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gap = context.isMobile ? AppSpace.sectionMobile : AppSpace.section;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: context.isMobile
            ? AnimatedSwitcher(
                duration: AppMotion.fast,
                child: Text(
                  _labels[_currentSection] ?? '',
                  key: ValueKey(_currentSection),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              )
            : const SizedBox.shrink(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpace.xs),
            child: AppNav(onSelectSection: _scrollTo, currentSection: _currentSection),
          ),
        ],
      ),
      body: AuroraBackground(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: CenteredConstrained(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(key: _keys['home'], height: kToolbarHeight + AppSpace.xl),
                HeroSection(
                  onContactTap: () => _scrollTo('contact'),
                  onWorkTap: () => _scrollTo('projects'),
                ),
                const SizedBox(height: AppSpace.xl),
                const StatsSection(),
                SizedBox(height: gap),
                SizedBox(key: _keys['about']),
                const AboutSection(),
                SizedBox(height: gap),
                SizedBox(key: _keys['skills']),
                const SkillsSection(),
                SizedBox(height: gap),
                SizedBox(key: _keys['experience']),
                const ExperienceSection(),
                SizedBox(height: gap),
                SizedBox(key: _keys['projects']),
                const ProjectsSection(),
                SizedBox(height: gap),
                SizedBox(key: _keys['contact']),
                const ContactSection(),
                const SizedBox(height: AppSpace.xxl),
                const SiteFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Delete the obsolete header widget**

```bash
git rm lib/src/widgets/section_header.dart
```

Run: `grep -rn "section_header" lib/ test/`
Expected: no output. If anything still imports it, replace that usage with `SectionShell`.

- [ ] **Step 4: Widen the content column**

In `lib/src/core/responsive.dart`, change the constant:

```dart
  static const double contentMaxWidth = 1160;
```

- [ ] **Step 5: Run the full suite**

Run: `flutter test`
Expected: PASS — every test file, including the pre-existing `home_hero_test.dart`, `cv_load_test.dart`
and `project_card_test.dart`.

- [ ] **Step 6: Commit**

```bash
git add -A lib/src/widgets/nav_bar.dart lib/src/pages/home_page.dart lib/src/core/responsive.dart lib/src/widgets/section_header.dart
git commit -m "feat(ui): aurora home page, frosted nav and footer assembly"
```

---

### Task 17: Deprecation sweep and full verification

**Files:**
- Modify: any remaining file using `withOpacity` or `ColorScheme.background`

- [ ] **Step 1: Find every remaining deprecated call**

Run: `flutter analyze 2>&1 | grep -c "withOpacity"`
Expected: a number greater than 0 before this task (it was 90+ at the start of the project).

- [ ] **Step 2: Replace them**

`withOpacity(x)` becomes `withValues(alpha: x)`. Apply across `lib/`:

```bash
grep -rl "withOpacity(" lib/ | xargs sed -i '' -E 's/\.withOpacity\(([^)]+)\)/.withValues(alpha: \1)/g'
```

Then check no `ColorScheme.background` / `surfaceVariant` usages remain:

Run: `grep -rn "\.background\b\|surfaceVariant" lib/`
Expected: no output. Replace any hit with `context.palette.canvas` or `context.palette.inkMuted`
respectively.

- [ ] **Step 3: Confirm the analyzer is clean**

Run: `flutter analyze`
Expected: `No issues found!` — or, at minimum, **zero errors, zero warnings, and zero `withOpacity`
deprecation infos** in `lib/`.

- [ ] **Step 4: Run every test**

Run: `flutter test`
Expected: PASS — all files, `All tests passed!`

- [ ] **Step 5: Build for the web**

Run: `flutter build web --release --no-wasm-dry-run`
Expected: `✓ Built build/web`

Confirm the resume shipped earlier is still in place:

Run: `ls build/web/Mustafa_Younis_Resume.pdf`
Expected: the file exists.

- [ ] **Step 6: Manual pass**

Run: `flutter run -d chrome`

Check, in **both** themes (toggle in the nav) at 390px, 800px and 1440px:

1. Hero: two columns ≥1024px, single centred column below. No text overflow.
2. Stats: four across ≥600px, 2×2 below.
3. Every section reveals once on scroll and does not re-trigger scrolling back up.
4. Timeline rail connects all entries; only the top node glows.
5. Featured project card store buttons open the right store.
6. Grid project cards still open the detail dialog.
7. Contact band gradient renders; form validation messages appear.
8. Theme toggle cross-fades the whole page rather than snapping.
9. Download CV in the hero downloads the real PDF.

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "chore(ui): replace deprecated colour APIs and finish the design pass"
```

---

## Self-review notes

**Spec coverage** — every spec section maps to a task: tokens → 1, palettes → 2, theme extension → 3,
theme rebuild + animated toggle → 4, `yearsExperience` → 5, stats derivation → 6, skill grouping → 7,
the eight primitives → 8/9/10, the nine section layouts → 11–16, motion/reduced-motion → 9, responsive
rules → 11–16, verification → 17.

**Two deliberate deviations from the spec**, both driven by the contrast test in Task 2:
`inkSubtle` (light) is `#6E6E88` rather than `#8B8BA3`, and `brandAlt` (light) is `#8B32D6` rather than
`#A855F7`. The gradient stops are unchanged — they are decorative fills, not text.

**One scope note:** `lib/src/pages/projects_page.dart`, `resume_page.dart` and `admin_page.dart` are not
edited. They inherit the new theme automatically. If `projects_page.dart` renders `ProjectCard` in a
`GridView` with an aspect ratio that now clips, fix it there in Task 14 Step 6 by giving the delegate
`mainAxisExtent: 300` to match `ProjectsSection._cardHeight`.
