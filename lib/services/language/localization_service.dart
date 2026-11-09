import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'language_controller.dart';

class LocalizationService {
  static Future<void> changeLocale(Locale locale) async {
    final ctrl = Get.find<LanguageController>();
    if (locale.languageCode == 'ar') {
      await ctrl.switchToArabic();
    } else {
      await ctrl.switchToEnglish();
    }
  }

  static bool get isRTL {
    if (!Get.isRegistered<LanguageController>()) return false;
    return Get.find<LanguageController>().isArabic;
  }
}
