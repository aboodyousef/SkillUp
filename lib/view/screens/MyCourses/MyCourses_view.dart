import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skill_up/utils/image_helper.dart';
import 'package:skill_up/view/screens/MyCourses/MyCourses_controller.dart';
import 'package:skill_up/view/screens/MyCourses/course_details_view.dart';

class MyCoursesView extends StatelessWidget {
  const MyCoursesView({super.key});

  @override
  Widget build(BuildContext context) {
    final MyCoursesController ctrl = Get.put(MyCoursesController());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'myCourses'.tr,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Obx(
                () => TextField(
                  controller: ctrl.searchController,
                  onChanged: ctrl.onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'searchCourses'.tr,
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: ctrl.searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              ctrl.searchController.clear();
                              ctrl.onSearchChanged("");
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xfff5f6fb),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _tabItem('all'.tr, 0, ctrl),
                    _tabItem('ongoing'.tr, 1, ctrl),
                    _tabItem('completed'.tr, 2, ctrl),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: Obx(() {
                  if (ctrl.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final list = ctrl.filteredCourses;

                  if (list.isEmpty) {
                    return Center(
                      child: Text(
                        'noCoursesFound'.tr,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final course = list[index];
                      return _courseCard(course);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabItem(String title, int index, MyCoursesController ctrl) {
    final bool isSelected = ctrl.selectedTab.value == index;
    return GestureDetector(
      onTap: () => ctrl.changeTab(index),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          if (isSelected)
            Container(height: 2, width: 60, color: Colors.blue),
        ],
      ),
    );
  }

  Widget _courseCard(Map<String, dynamic> course) {
    final double progress =
        (course["progress"] as num?)?.toDouble() ?? 0.0;
    final bool isCompleted = progress >= 100.0;

    final String statusText = isCompleted ? 'statusCompleted'.tr : 'statusOngoing'.tr;
    final String minutesText =
        (course["minutesText"] as String?) ?? 'percentDone'.trParams({'percent': progress.toInt().toString()});

    final String imageUrl =
        (course["coverImage"] as String?)?.isNotEmpty == true
            ? course["coverImage"] as String
            : (course["imageUrl"] as String? ?? "");

    return GestureDetector(
      onTap: () {
        Get.to(() => CourseDetailsView(course: course));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xfff7f2ff),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 70,
                  width: 70,
                  child: imageUrl.isNotEmpty
                      ? buildCourseCover(imageUrl, height: 70, width: 70, fit: BoxFit.cover)
                      : Container(
                          color: Colors.grey.shade300,
                          child: const Icon(
                            Icons.image,
                            color: Colors.white70,
                            size: 30,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course["title"] ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'byInstructor'.trParams({
                        'instructor': course["instructor"] ?? '',
                        'category': course["category"] ?? '',
                      }),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: isCompleted
                            ? const Color.fromARGB(255, 33, 150, 243)
                            : Colors.grey,
                        fontSize: 11,
                        fontWeight: isCompleted
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: progress / 100,
                            minHeight: 4,
                            backgroundColor: const Color(0xffe0d7ff),
                            valueColor: const AlwaysStoppedAnimation(
                              Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          minutesText,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
