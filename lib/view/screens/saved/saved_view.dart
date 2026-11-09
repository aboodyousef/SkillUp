import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'saved_controller.dart';
import 'package:skill_up/view/screens/MyCourses/course_details_view.dart';

class SavedView extends StatelessWidget {
  const SavedView({super.key});

  @override
  Widget build(BuildContext context) {
    final SavedController ctrl = Get.find<SavedController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('savedCourses'.tr),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ctrl.savedCourses.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: ctrl.savedCourses.length,
          itemBuilder: (context, index) {
            final course = ctrl.savedCourses[index];
            return _buildSavedCard(ctrl, course);
          },
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'noSavedCourses'.tr,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'savedCoursesHint'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedCard(SavedController ctrl, Map<String, dynamic> course) {
    final imageUrl = ((course["coverImage"] as String?)?.isNotEmpty == true
            ? course["coverImage"]
            : course["imageUrl"] ??
                'assets/course_images/general.png')
        .toString();

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
                  child: Image.asset(
                    imageUrl,
                    height: 70,
                    width: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade300,
                      child: const Center(
                        child:
                            Icon(Icons.image, color: Colors.white70, size: 30),
                      ),
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
                      course["title"] ?? '',
                      maxLines: 2,
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
                          color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_remove,
                    color: Colors.blue),
                onPressed: () {
                  ctrl.toggleSave(course['id']);
                },
                tooltip: 'removeSaved'.tr,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
