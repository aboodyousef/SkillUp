import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import 'package:skill_up/data/mock/mock_config.dart';
import 'package:skill_up/data/mock/mock_data.dart';
import 'package:skill_up/data/translation/app_translation.dart';
import 'package:skill_up/firebase_options.dart';
import 'package:skill_up/services/language/language_controller.dart';
import 'package:skill_up/services/language/language_service.dart';
import 'package:skill_up/utils/routes/routes.dart';
import 'package:skill_up/utils/routes/routes_string.dart';

import 'package:skill_up/controllers/user_controller.dart';
import 'package:skill_up/view/screens/profile/profile_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase even in mock mode because controllers eagerly reference
  // FirebaseAuth.instance / FirebaseFirestore.instance at the field level.
  if (Firebase.apps.isEmpty) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      // Gracefully handle unsupported platforms (Windows/Linux) in mock mode
    }
  }

  // Pre-scan video assets in mock mode
  if (useMockData) {
    await MockDataService.instance.scanVideoAssets();
  }

  // Pre-load saved locale before app starts
  final savedLocale = await LanguageService.getSavedLocale();

  runApp(MyApp(initialLocale: Locale(savedLocale)));
}

class MyApp extends StatelessWidget {
  final Locale initialLocale;

  const MyApp({super.key, required this.initialLocale});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SKILL UP',
      locale: initialLocale,
      fallbackLocale: const Locale('en'),

      initialBinding: BindingsBuilder(() {
        Get.put(UserController(), permanent: true);
        Get.put(ProfileController(), permanent: true);
        Get.put(LanguageController(), permanent: true);
      }),

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      translations: AppTranslation(),

      // Routing
      initialRoute: RoutesString.splash,
      getPages: getPages,

      // Unknown route
      unknownRoute: GetPage(
        name: '/notfound',
        page: () => Scaffold(
          body: Center(
            child: Text('routeNotFound'.tr),
          ),
        ),
      ),
    );
  }
}
