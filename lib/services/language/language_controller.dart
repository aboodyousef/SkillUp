import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'language_service.dart';

class LanguageController extends GetxController {
  static LanguageController get to => Get.find();

  final Rx<Locale> currentLocale = Rx<Locale>(const Locale('en'));

  @override
  void onInit() {
    super.onInit();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final code = await LanguageService.getSavedLocale();
    currentLocale.value = Locale(code);
    Get.updateLocale(currentLocale.value);
  }

  Future<void> switchToEnglish() async {
    await _setLocale(const Locale('en'));
  }

  Future<void> switchToArabic() async {
    await _setLocale(const Locale('ar'));
  }

  Future<void> toggleLanguage() async {
    if (currentLocale.value.languageCode == 'en') {
      await switchToArabic();
    } else {
      await switchToEnglish();
    }
  }

  Future<void> _setLocale(Locale locale) async {
    currentLocale.value = locale;
    await LanguageService.saveLocale(locale.languageCode);
    Get.updateLocale(locale);
  }

  bool get isArabic => currentLocale.value.languageCode == 'ar';

  bool get isEnglish => currentLocale.value.languageCode == 'en';
}
