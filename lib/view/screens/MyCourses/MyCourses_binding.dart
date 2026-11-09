import 'package:get/get.dart';
import 'package:skill_up/view/screens/MyCourses/MyCourses_controller.dart';

class MycoursesBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<MyCoursesController>(() => MyCoursesController());
  }
}