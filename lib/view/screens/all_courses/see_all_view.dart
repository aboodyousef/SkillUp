import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:skill_up/data/models/course_model.dart';
import 'package:skill_up/view/screens/MyCourses/course_details_view.dart';
import 'package:skill_up/view/screens/home/course_card.dart';
import 'package:skill_up/view/screens/all_courses/see_all_controller.dart';

class SeeAllCoursesView extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> rawCourses;
  final List<CourseModel> modelCourses;

  const SeeAllCoursesView({
    super.key,
    required this.title,
    required this.rawCourses,
    required this.modelCourses,
  });

  @override
  State<SeeAllCoursesView> createState() => _SeeAllCoursesViewState();
}

class _SeeAllCoursesViewState extends State<SeeAllCoursesView> {
  late final SeeAllController ctrl;

  @override
  void initState() {
    super.initState();
    ctrl = Get.put(
      SeeAllController(
        rawData: widget.rawCourses,
        modelData: widget.modelCourses,
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<SeeAllController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: ctrl.searchController,
              onChanged: ctrl.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'searchAnyCourse'.tr,
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: Obx(
                  () => ctrl.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            ctrl.searchController.clear();
                            ctrl.onSearchChanged('');
                          },
                        )
                      : const SizedBox.shrink(),
                ),
                filled: true,
                fillColor: const Color(0xfff5f6fb),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              final models = ctrl.filteredModels;
              final raw = ctrl.filteredRaw;

              if (models.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off,
                          size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'noCoursesFound'.tr,
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              if (widget.title == 'continueWatching'.tr) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: models.length,
                  itemBuilder: (context, index) {
                    final course = models[index];
                    final courseRaw =
                        index < raw.length ? raw[index] : <String, dynamic>{};
                    return _buildCourseListTile(course, courseRaw);
                  },
                );
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  itemCount: models.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final course = models[index];
                    return CourseCard(course: course);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseListTile(CourseModel course, Map<String, dynamic> raw) {
    final coverUrl = course.coverImage.isNotEmpty
            ? course.coverImage
            : course.imageUrl.isNotEmpty
                ? course.imageUrl
                : 'assets/course_images/general.png';

    return GestureDetector(
      onTap: () => Get.to(() => CourseDetailsView(course: raw)),
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
                    coverUrl,
                    height: 70,
                    width: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(Icons.image, color: Colors.white70, size: 30),
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
                      course.title,
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
                        'instructor': course.instructor,
                        'category': course.category,
                      }),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (i) => Icon(
                            Icons.star,
                            size: 14,
                            color: i < course.rating.round()
                                ? Colors.orange
                                : Colors.grey.shade300,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          course.rating.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                    if (course.progress > 0) ...[
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: course.progress.clamp(0.0, 1.0),
                        minHeight: 4,
                        backgroundColor: const Color(0xffe0d7ff),
                        valueColor: const AlwaysStoppedAnimation(Colors.blue),
                      ),
                    ],
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
