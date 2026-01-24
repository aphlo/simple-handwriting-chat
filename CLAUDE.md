# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A hybrid Flutter mobile app (iOS/Android) + Next.js marketing website for a handwriting-based chat application with mirror drawing functionality.

## Build Commands

### Flutter (Mobile) - via Rakefile with FVM

```bash
rake run              # Run on default device
rake run_ios          # Run on iOS simulator
rake run_android      # Run on Android emulator
rake build_ios        # Build iOS
rake build_apk        # Build Android APK
rake build_aab        # Build Android App Bundle (Play Store)
rake check            # Format + lint + test (quality gate)
rake deps             # Get dependencies
rake clean            # Clean build artifacts
```

### Next.js (Web) - via pnpm

```bash
cd web
pnpm install          # Install dependencies
pnpm dev              # Development server (localhost:3000)
pnpm build            # Build static export to ./out
pnpm check            # Biome lint + format
```

## Architecture

### Flutter App (`lib/`)
- **Entry**: `main.dart` - Firebase, AdMob, localization setup
- **Core Feature**: Mirror drawing using `CustomPainter` (`painters/mirror_painter.dart`)
- **Pages**: `mirror_drawing_page.dart` (main drawing), `menu_page.dart`, `webview_page.dart`
- **Services**: `ad_service.dart` (Google Mobile Ads), `review_service.dart` (in-app review)
- **Localization**: `l10n/` with generated `app_localizations_*.dart` files (en/ja)

### Next.js Web (`web/`)
- **App Router**: Dynamic `[lang]` routes for i18n (en/ja)
- **Static Export**: `output: 'export'` in `next.config.ts`, deployed to Firebase Hosting
- **i18n**: Custom dictionary provider with JSON translations in `src/locales/`
- **Path alias**: `@/*` maps to `./src/*`

### Firebase
- Project: `simple-handwriting-chat`
- Hosting: Serves `web/out/`, auto-deploys on merge to main via GitHub Actions
- Services: Analytics (mobile)

## Key Configurations

- **Flutter version**: 3.38.6 (managed via FVM, see `.fvmrc`)
- **Node version**: 20+
- **Package manager**: pnpm (recommended, do not use npm or yarn)
- **Web linting**: Biome (not ESLint)
- **Dart linting**: `analysis_options.yaml` with flutter_lints

## Localization

- **Flutter**: `flutter gen-l10n` after editing ARB files
- **Web**: Edit `web/src/locales/{en,ja}.json`
- Supported: English (en), Japanese (ja)

## Deployment

Web auto-deploys on push to `main` via `.github/workflows/firebase-hosting-merge.yml`.

Manual deploy:
```bash
cd web && pnpm build
firebase deploy --only hosting
```
