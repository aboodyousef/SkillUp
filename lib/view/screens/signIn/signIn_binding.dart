import 'package:get/get.dart';
import 'package:skill_up/view/screens/signIn/signIn_controller.dart';

class SignInBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignInController>(() => SignInController());
  }
}
