import 'package:get/get.dart';
import 'package:skill_up/view/screens/signUp/signUp_controller.dart';


class SignUpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignUpController>(() => SignUpController());
  }
}
