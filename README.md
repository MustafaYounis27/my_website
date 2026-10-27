# Mustafa Mahmoud Younis — Flutter Web Portfolio

A responsive, production-ready portfolio website for Mustafa Mahmoud Younis (Senior Mobile Engineer) built with Flutter Web.

Features:
- Dynamic content from `assets/data/cv.json`
- Light/Dark theme with persistence
- Smooth section scrolling and sticky navigation
- Projects with modal details and external links
- Accessible UI (semantics, labels, contrast)
- SEO: crawler-readable copy, JSON-LD, robots.txt, sitemap.xml and a 1200×630 social card (`web/og-image.jpg`)
- WebAssembly build with automatic JS fallback
- Admin JSON editor page (debug builds only)

## Project Structure
- `lib/src/app.dart` — App root and routes
- `lib/src/models/` — CV data models
- `lib/src/state/` — Providers (theme, CV loading/override)
- `lib/src/widgets/` — UI components (hero, navbar, sections)
- `lib/src/pages/` — Pages (`HomePage`, `ProjectsPage`, `ResumePage`, `AdminPage`)
- `assets/data/cv.json` — Portfolio content
- `assets/images/` — Project icons and screenshots (WebP)
- `web/index.html` — SEO meta, structured data, crawler copy and loading splash
- `web/404.html` — SPA deep-link fallback

## Local Development
1) Install Flutter (stable) and enable web: `flutter config --enable-web`
2) Get deps: `flutter pub get`
3) Run in Chrome: `flutter run -d chrome`

## Content Editing
- Update `assets/data/cv.json` to change profile, experience, projects, etc.
- `headline` is the one-liner in the hero; `summary` is the longer story in About.
- `availability` shows as a badge under your name; leave it empty to hide it.
- `usersReached` feeds the "Users reached" stat; omit it to hide the tile.
- `testimonials` (`quote`, `author`, `role`) renders a "What people say" section once it has entries.
- Projects take optional `highlights` (case-study bullets), `link` and `github`.
- When you change content, also update the hidden `#seo` block and JSON-LD in `web/index.html` so search engines see the same text.
- Admin page: run in debug (`flutter run -d chrome`) and open `/admin` to edit JSON in-browser. The route and stored overrides are disabled in release builds.

## Build for Web
```bash
bash build_web.sh
```
Output in `build/web/`.

## Deploy (Firebase Hosting)

Live site: **https://mustafa-younis-portfolio.web.app**

### Manual
Prereqs: `npm i -g firebase-tools`, `firebase login`

```bash
bash deploy.sh
```

### Automatic (push to `main`)
Set GitHub secret `FIREBASE_SERVICE_ACCOUNT` (Firebase service account JSON). The workflow in `.github/workflows/deploy-firebase.yml` builds and deploys on every push to `main`.

## Tests
```bash
flutter test
```

## Notes
- Theme preference is saved via `shared_preferences`.
- Web URL strategy is path-based (no hash). Firebase Hosting rewrites unknown routes to `index.html` (`firebase.json`).
- Replace placeholder images in `assets/images/` as needed.
