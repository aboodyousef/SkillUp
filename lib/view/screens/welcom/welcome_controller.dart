import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:skill_up/data/mock/mock_config.dart';
import 'package:skill_up/data/themes/image_string.dart';
import 'package:skill_up/utils/routes/routes.dart';

class WelcomeController extends GetxController {
  void chickConnection() async {
    if (useMockData) {
      getLocation();
      Get.offAllNamed(RoutesString.signIn);
      return;
    }

    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi)) {
      getLocation();
      Get.offAllNamed(RoutesString.signIn);
    } else {
      Get.snackbar(
        'noInternet'.tr,
        'noInternetMsg'.tr,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  final currentPage = 0.obs;
  final PageController pageController = PageController();
  List<Map<String, dynamic>> get pages => [
    {"image": ImageStringWelcome.welcome1, "title": 'welcomeStep'.tr},
    {"image": ImageStringWelcome.welcome2, "title": 'welcomeEmpower'.tr},
    {"image": ImageStringWelcome.welcome3, "title": 'welcomeExplore'.tr},
    {"image": ImageStringWelcome.welcome4, "title": 'welcomeStart'.tr},
  ];

void nextPage() {
    if (currentPage.value < 3) {
      currentPage.value++;
      pageController.nextPage(
        duration: 300.milliseconds,
        curve: Curves.easeIn,
      );
    }
  }

  void skipToLogin() {}

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

Future<void> getLocation() async {
  if (useMockData) return;
  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      Get.snackbar(
        'locationDenied'.tr,
        'locationDeniedMsg'.tr,
      );
      return;
    }
  }

  Position position = await Geolocator.getCurrentPosition();
  Get.snackbar(
    'currentLocation'.tr,
    'locationInfo'.trParams({'lat': position.latitude.toString(), 'lng': position.longitude.toString()}),
  );
}
