# SkillUp

**SkillUp** is a cross-platform mobile learning platform built with Flutter and Firebase. The application lets learners browse and search courses, watch video-based lessons, keep track of their learning progress, save courses of interest, and receive notifications - while teachers get a dedicated workspace to publish new video lessons.

## Overview

SkillUp is a Flutter application that combines a course-learning experience with an authenticated user profile, powered by Firebase for authentication, cloud data storage, and real-time features. The repository contains the complete client implementation, including Firebase integration, local demo/mock data, and multi-language support.

## Problem Statement

Self-paced learners often face fragmented learning experiences: discovering relevant content is difficult, progress tracking is inconsistent across sessions, and learners receive little contextual guidance as they move through a curriculum. SkillUp addresses this by centralizing course discovery, learning progress, saved content, and user context within a single mobile experience.

## Key Features

The following capabilities are implemented in the current source code:

- **Authentication & user flows**
  - Welcome, Join, Sign In, Sign Up, Forgot Password, and Email Verification screens.
  - Email/password authentication and Google Sign-In via Firebase Authentication.
  - Role-aware navigation (`student` / `teacher`) driven by the user document in Firestore.
- **Home & discovery**
  - Personalised "Continue Watching" list based on enrollment progress.
  - "Trending Now" course section.
  - Global search with debounced input and category filtering.
  - Interest-based course scoring with keyword matching and fallback search.
- **Learning experience**
  - Course details with structured video lessons.
  - In-app video playback via `video_player`.
  - Teacher video creation flow using `file_picker` (teacher role gated).
- **Personal library**
  - "My Courses" with enrolled courses and progress indicators.
  - Saved courses / bookmarks.
- **Engagement**
  - Notifications feed (welcome, course updates, achievements, reminders).
  - Profile area with profile editing, help center, certificates, and payment options.
- **Localization**
  - English and Arabic translations via GetX (`l10n` / translation services).
- **Demo mode**
  - Mock data service that generates courses/lessons from bundled assets when Firebase is not configured.

## Technology Stack

- **Framework:** Flutter (Dart SDK `^3.8.1`)
- **State management & routing:** GetX (`get: ^4.7.2`)
- **Backend / Firebase:** `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `firebase_database`, `firebase_messaging`, `google_sign_in`
- **Video:** `video_player`
- **Media / files:** `file_picker`, `image_picker`
- **Local storage / device:** `shared_preferences`, `connectivity_plus`, `geolocator`, `app_settings`, `url_launcher`, `share_plus`, `http`, `smooth_page_indicator`
- **Internationalization:** `flutter_localizations`, `intl`
- **UI icons / fonts:** `font_awesome_flutter`, `fluentui_system_icons`, `cupertino_icons`

## Architecture Overview

The app follows a feature-oriented screen structure built on top of GetX:

- **Screens:** each feature lives in `lib/view/screens/<feature>/` with a `*_binding.dart`, `*_controller.dart`, and `*_view.dart` triplet (GetX pattern).
- **Controllers:** app-wide controllers (e.g. `lib/controllers/user_controller.dart`) use `Get.put(..., permanent: true)`; screen-scoped controllers use `Get.lazyPut`.
- **Services:** singletons such as `AuthService` and `AiRecommenderService` under `lib/services/`.
- **Data:** models with `fromJson`/`toJson`, repositories under `lib/data/repositories/`, and mock repositories/services under `lib/data/mock/`.
- **Routing:** named routes declared in `lib/utils/routes/` via GetX `GetPage`.
- **Backend:** Firebase Auth + Firestore (+ Storage/Database/Messaging where used); graceful mock mode via `lib/data/mock/mock_config.dart`.

## Project Structure

```
skill_up/
  lib/
    main.dart
    firebase_options.dart
    controllers/
    data/
      models/
      repositories/
      mock/
      themes/
      translation/
    services/
    utils/
      bindings/
      image_helper.dart
      routes/
    view/
      screens/
  assets/
    course_images/
    data/
    images/
    thumbnails/
    videos/
  android/
  ios/
  web/
  test/
  firebase.json
  pubspec.yaml
```

## Prerequisites

- Flutter SDK (Dart SDK `^3.8.1` or newer)
- Android SDK / Xcode (for running on device or emulator)
- Firebase project (for production backend configuration)
- Google account (for Google Sign-In)

## Installation

```sh
git clone <repository-url>
cd skill_up
flutter pub get
flutter run
```

## Firebase Configuration

The application uses Firebase via the FlutterFire plugins.

- Generated Firebase options live in `lib/firebase_options.dart` (`DefaultFirebaseOptions`).
- Platform-specific Firebase config files:
  - Android: `android/app/google-services.json`
  - iOS: `ios/Runner/GoogleService-Info.plist`
  - Web: injected through the generated web options.
- `firebase.json` contains the FlutterFire platform mapping.

**Local setup for cloned repositories:**

1. Create a Firebase project at the Firebase console.
2. Register the Android app with package name `com.skillup.skill_up` and download `google-services.json`, placing it at `android/app/google-services.json`.
3. Register the iOS app with bundle identifier `com.skillup.skillUp` and download `GoogleService-Info.plist`, placing it at `ios/Runner/GoogleService-Info.plist`.
4. Run `flutterfire configure` (or manually update `lib/firebase_options.dart`) for the remaining platforms.

> The Firebase client configuration files (`android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`) are treated as local development files and are excluded from version control.

## Running the Application

```sh
flutter pub get
flutter run
```

The application initializes Firebase when available and falls back to bundled mock data when Firebase is not configured (mock mode is enabled by default via `lib/data/mock/mock_config.dart`).

## Screenshots

> Screenshots are not included in the repository yet.

This section will be updated with real application screenshots before the first public release.

## Future Improvements

- Add unit / integration test coverage beyond the current smoke test.
- Add CI/CD workflows for build validation.
- Harden backend security rules and add monitoring.
- Expand localization coverage.

## Author

**SkillUp** is an open-source learning-platform project authored as part of the SkillUp initiative.

> Author and contact details are intentionally not published in this repository.
