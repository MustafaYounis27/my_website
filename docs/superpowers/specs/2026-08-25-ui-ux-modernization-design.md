# Portfolio UI/UX Modernization — Design

**Date:** 2026-08-25
**Status:** Approved (visual direction, dark palette and page structure validated in the visual companion)

## Goal

Rebuild the portfolio's visual system and page structure so the site reads as a modern, senior-engineer
portfolio in both light and dark mode — without changing content, routes, or the resume PDF behaviour
shipped earlier today.

## Decisions

| Decision | Choice |
|---|---|
| Visual direction | **Indigo Aurora** — evolves the existing indigo/purple identity: soft aurora glows, frosted-glass surfaces, one shared card style |
| Dark mode | **Indigo Night** — violet-tinted black (`#0B0A18`) canvas, aurora still glowing, accents lifted for contrast |
| Scope | Full: visual system **and** layout restructure of every section |
| Availability pill | Not included. Hero shows a neutral location line instead |
| Motion | Tasteful — scroll reveal, hover lift, animated theme cross-fade; honours reduced-motion |

## Problems in the current code this fixes

1. **No design tokens.** Every widget re-declares its own gradient, border, shadow and radius inline
   (`about_section.dart`, `skills_section.dart`, `contact_section.dart`, `project_card.dart` all repeat
   the same `LinearGradient` + `Border.all(outline.withOpacity(0.2))` + `BoxShadow` block). Changing the
   look means editing six files.
2. **Dark mode is an afterthought.** `#6366F1` is used as the primary in both themes; against the dark
   surface `#1A1B26` it fails WCAG AA for body-size text. There is one flat surface colour, so cards,
   nav and background have no elevation separation.
3. **Deprecated APIs.** `withOpacity` (deprecated, precision loss) and `ColorScheme.background`
   (deprecated) are used throughout.
4. **Flat page rhythm.** Every section is `SectionHeader` + content with the same 24px gap; nothing
   signals hierarchy or progress through the page.
5. **Structure.** Hero is a single column, experience is a flat card list, all five projects have equal
   visual weight, contact is a button row, footer is a bare copyright string.

## Architecture

Three layers, built bottom-up. Each layer is independently testable and has one job.

### Layer 1 — Tokens (`lib/src/core/design/`)

| File | Responsibility |
|---|---|
| `app_tokens.dart` | Spacing scale, radii, durations, curves, breakpoint-aware section padding. Pure constants, no Flutter theme dependency beyond `Duration`/`Curve`. |
| `app_palette.dart` | The two palettes as immutable data: canvas, aurora stops, surface ladder (`surface`, `surfaceRaised`, `surfaceGlass`), hairline, ink ladder (`ink`, `inkMuted`, `inkSubtle`), brand pair, gradient stops, shadow specs. |
| `app_theme.dart` (rewritten) | Builds `ThemeData` from a palette. Registers `AppSurfaces` as a `ThemeExtension` so widgets read tokens via `Theme.of(context).extension<AppSurfaces>()` rather than hardcoding. |

**Token values**

```
Spacing   4 · 8 · 12 · 16 · 24 · 32 · 48 · 64 · 96
Radii     sm 10 · md 14 · lg 20 · xl 28 · pill 999
Motion    fast 180ms · base 320ms · slow 520ms · theme 400ms
Curves    standard easeOutCubic · emphasized easeOutQuint
```

**Light — Indigo Aurora**

```
canvas        #FBFBFE      aurora    indigo .26 @ 10% 0%,  violet .22 @ 94% 8%
surface       #FFFFFF      glass     white @ 72% + blur 12
hairline      #0F0F1E @ 8%
ink           #14142B  ·  inkMuted #5A5A75  ·  inkSubtle #8B8BA3
brand         #4F46E5  ·  brandAlt #A855F7  ·  brandSoft indigo @ 10%
gradient      #6366F1 → #A855F7 (135°)
shadow        0 14 34 rgba(20,20,43,.09)
```

**Dark — Indigo Night**

```
canvas        #0B0A18      aurora    indigo .30 @ 10% 0%,  violet .24 @ 95% 15%
surface       #141327      glass     white @ 5.5% + blur 12
hairline      #FFFFFF @ 10%
ink           #F2F1FA  ·  inkMuted #9E9CBB  ·  inkSubtle #8482A6
brand         #A5B4FC  ·  brandAlt #C084FC  ·  brandSoft #818CF8 @ 14%
gradient      #A5B4FC → #C084FC (135°)
shadow        0 16 36 rgba(0,0,0,.5)
```

Brand accents are lifted from the `#6366F1` family to the `#A5B4FC` family in dark mode specifically so
accent-on-canvas text clears WCAG AA (4.5:1). Filled buttons in dark mode use **dark ink on a light
accent** rather than white-on-indigo, for the same reason.

### Layer 2 — Primitives (`lib/src/widgets/common/`)

Each is small, has no knowledge of CV data, and is used by at least two sections.

| Widget | Purpose |
|---|---|
| `AuroraBackground` | Paints the canvas + two radial aurora stops behind page content. One instance per page, behind the scroll view. |
| `GlassCard` | The single card style: surface colour, hairline border, radius, shadow, optional blur. Replaces every ad-hoc `Container(decoration: …)` in the sections. |
| `HoverLift` | Wraps a child; on pointer hover translates -4px and deepens the shadow over `fast`. Mouse-only, no-op on touch. |
| `Reveal` | Fade + 16px rise when the child first scrolls into view, using `VisibilityDetector`-free geometry off the existing `ScrollController`. Honours reduced-motion. Replaces the unconditional `flutter_animate` calls that fire even off-screen today. |
| `GradientText` | Applies the brand gradient to text via `ShaderMask`. |
| `SectionShell` | Vertical rhythm + numbered eyebrow (`01 — ABOUT`), title, subtitle, and the section's `GlobalKey` anchor. Replaces `SectionHeader`. |
| `TagChip` | The one chip style for skills, technologies and periods. |
| `StatTile` | Number + label in a glass tile. |

### Layer 3 — Sections (rewritten to consume the above)

| Section | New structure |
|---|---|
| **Nav** (`nav_bar.dart`) | Frosted pill, blur over content, scroll-spy active state with an animated indicator. Adds Resume (already added). Mobile keeps the bottom sheet, restyled. |
| **Hero** | Two columns ≥1024px: left = location line, name (display), gradient role, summary, CTA row (Download CV / View my work / LinkedIn / GitHub); right = gradient-ringed portrait. Single centred column below 1024px. |
| **Stats** | Four `StatTile`s under the hero. 2×2 grid on mobile. |
| **About** | Story card (flex 1.5) + education card (flex 1) side by side; stacked on mobile. |
| **Skills** | Three category cards — Mobile, Backend & Data, Delivery & Practices — each a `TagChip` wrap. Categories are a static map in the widget; any skill not in the map falls into "Delivery & Practices" so nothing is dropped. |
| **Experience** | Vertical timeline: gradient rail, one node per role, node for the current role is gradient-filled with a glow, past roles are muted. Card per role with period chip and highlights. |
| **Projects** | Featured-first: `projects.first` (My TAI) as a wide card with description, tech chips and store links; the rest in a 3-up (desktop) / 2-up (tablet) / 1-up (mobile) grid. `/projects` page keeps the full uniform grid. |
| **Contact** | Full-width gradient CTA band — headline, sub, then Email / WhatsApp / LinkedIn / GitHub buttons. The existing contact form stays below it, restyled in a `GlassCard`. |
| **Footer** | Replaces the bare `bottomNavigationBar` copyright: name + year on the left, "Built with Flutter · Deployed on Netlify" on the right. |

## Stats — data derivation

All four numbers are computed from `cv.json`; none are hardcoded in the widget.

| Tile | Source | Today's value |
|---|---|---|
| Years experience | `cv.yearsExperience` if present, else `currentYear - earliest experience start year` | 5 (override) / 4 (computed) |
| Projects shipped | `cv.projects.length` | 5 |
| App stores | count of distinct store hosts across all `project.stores` (apple, play, huawei, microsoft) | 4 |
| Technologies | `cv.skills.length` | 13 |

`yearsExperience` is a new **optional** integer field on `CV`. The computed fallback is 4 because the
earliest listed role starts 03/2022, while the resume claims 5+; the override field lets the resume and
the site agree without inventing a number in code. Add `"yearsExperience": 5` to `assets/data/cv.json`.

## Motion

- `Reveal` on each section: 320ms fade + 16px rise, 60ms stagger between siblings, fires once.
- `HoverLift` on project cards, stat tiles, and contact buttons: 180ms.
- Theme toggle: `AnimatedTheme` at 400ms so canvas, surfaces and text cross-fade instead of snapping.
- Gradient text and the aurora are static — no continuously animating background.
- All of the above collapse to instant when `MediaQuery.disableAnimations` is true.

## Responsive

Existing `Breakpoints` (600 / 1024) are kept; `contentMaxWidth` goes 1100 → 1160.

| Width | Hero | Stats | About | Skills | Projects |
|---|---|---|---|---|---|
| < 600 | 1 col, centred | 2×2 | stacked | 1 col | 1 col |
| 600–1024 | 1 col, centred | 4-up | stacked | 2 col | 2 col |
| ≥ 1024 | 2 col | 4-up | side by side | 3 col | featured + 3-up |

## Out of scope

- Content changes to `cv.json` beyond adding `yearsExperience`.
- The resume PDF pipeline (shipped earlier today; untouched).
- `/admin` page — restyled only by inheriting the new theme, no layout work.
- Any new dependency. `flutter_animate`, `google_fonts`, `provider` and `url_launcher` are already present
  and sufficient.

## Verification

1. `flutter analyze` — must report **zero** errors and, unlike today, zero `withOpacity` /
   `ColorScheme.background` deprecation warnings in `lib/`.
2. `flutter test` — the three existing tests keep passing. Add:
   - a token test asserting light and dark palettes define every field,
   - a widget test asserting the stats row renders four tiles from a fixture CV,
   - a widget test asserting the skills categoriser drops no skill.
3. `flutter build web --release` succeeds.
4. Manual pass at 390px, 800px and 1440px in both themes, toggling the theme on each page.

## Risks

- **Blur cost on web.** `BackdropFilter` is expensive in CanvasKit. Mitigation: blur only the nav pill
  and hero glass tiles — never inside scrolling lists or per-project cards.
- **Regression surface.** Every section widget is rewritten. Mitigation: build the token and primitive
  layers first with tests, then convert sections one at a time, keeping the app buildable at each step.
