import 'package:get/get.dart';
import 'package:skill_up/controllers/user_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<UserController>(UserController(), permanent: true);
  }
}
