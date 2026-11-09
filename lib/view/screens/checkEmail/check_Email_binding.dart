import 'package:get/get.dart';
import 'package:skill_up/view/screens/checkEmail/check_Email_controller.dart';

class CheckEmailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CheckEmailController>(() => CheckEmailController());
  }
}
