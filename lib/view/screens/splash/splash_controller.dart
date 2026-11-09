import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'package:skill_up/data/mock/mock_config.dart';

class SplashController extends GetxController {
  void chickConnection() async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      Get.offAllNamed('/welcome');
      return;
    }

    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi)) {
      Get.offAllNamed('/welcome');
    } else {
      Get.snackbar(
        'No Internet Connection',
        'Please check your internet connection and try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
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
          'Location Permission Denied',
          'Please enable location services in your device settings.',
        );
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    Get.snackbar(
      'Current Location',
      'Latitude: ${position.latitude}, Longitude: ${position.longitude}',
    );
  }
}
