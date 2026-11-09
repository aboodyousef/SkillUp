import 'package:get/get.dart';
import 'package:skill_up/view/screens/saved/saved_controller.dart';
import 'package:skill_up/view/screens/search/search_controller.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchScreenController>(() => SearchScreenController());
    if (!Get.isRegistered<SavedController>()) {
      Get.put(SavedController());
    }
  }
}
