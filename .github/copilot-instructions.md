# AI Coding Agent Instructions for Skill Up Flutter App

## Architecture Overview
This is a Flutter learning platform app using GetX for state management. Key components:
- **Screens**: Each in `lib/view/screens/{screenName}/` with MVC pattern: `{screenName}_binding.dart`, `{screenName}_controller.dart`, `{screenName}_view.dart`
- **State Management**: GetX with `GetBuilder` for UI updates, `Rx` variables for reactive state
- **Services**: Singleton classes in `lib/services/` for business logic (e.g., `AuthService.instance`)
- **Data**: Models in `lib/data/models/` with `fromJson`/`toJson`, repositories in `lib/data/repositories/` for data access
- **Backend**: Firebase Auth + Firestore for user management and data storage
- **Localization**: GetX translations in `lib/data/translation/` (ar, en)

## Key Patterns
- **Bindings**: Use `Get.lazyPut<Controller>(() => Controller())` for screen-specific controllers; `Get.put(..., permanent: true)` for app-wide (e.g., `UserController`)
- **Navigation**: `Get.offNamed('/route')` or `Get.toNamed('/route')` using constants from `lib/utils/routes/routes_string.dart`
- **Error Handling**: `Get.snackbar("Title", "Message", snackPosition: SnackPosition.BOTTOM)` for user feedback
- **Auth Flow**: `AuthService.instance.signInWithEmail()` stores user data in Firestore `users` collection with role-based navigation
- **Data Models**: Always include null-safety in `fromJson` (e.g., `(json['field'] ?? '').toString()`)
- **Controllers**: Extend `GetxController`, use `TextEditingController` for forms, `.obs` for reactive vars

## Workflows
- **Build/Run**: Standard `flutter run` or `flutter build apk`; no custom scripts
- **Dependencies**: `flutter pub get` after adding packages in `pubspec.yaml`
- **Firebase**: Config in `firebase_options.dart`; ensure `google-services.json` for Android
- **Testing**: Basic widget tests in `test/widget_test.dart`; no integration tests

## Conventions
- File naming: snake_case for files (e.g., `sign_in_view.dart`), PascalCase for classes
- Imports: Relative paths within lib/, absolute for external packages
- Static data: JSON files in `assets/data/` loaded via rootBundle
- Images: Stored in `assets/images/` with paths in `lib/themes/image_string.dart`

## Examples
- New screen: Create folder `lib/view/screens/newScreen/`, add binding with `Get.lazyPut<NewScreenController>(() => NewScreenController())`, controller extending `GetxController`, view using `GetBuilder<NewScreenController>`
- Add service method: In singleton service, add async method calling Firebase/Firestore
- Localization: Add keys to `ar.dart` and `en.dart`, use `tr` in widgets

Focus on GetX patterns, Firebase integration, and the MVC screen structure for consistency.</content>
<parameter name="filePath">c:\Users\LENOVO\StudioProjects\skill_up-Design\skill_up-307e272204271edd8f1b4966eded8c837966c152\.github\copilot-instructions.md