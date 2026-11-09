import 'package:get/get.dart';
import 'package:skill_up/view/screens/joining/join_controller.dart';

class JoinBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JoinController>(() => JoinController());
  }
}
