import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:skill_up/data/models/course_model.dart';
import 'package:skill_up/view/screens/saved/saved_controller.dart';

class CourseCard extends StatelessWidget {
  final CourseModel course;

  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final coverUrl =
        course.coverImage.isNotEmpty ? course.coverImage : course.imageUrl;
    final SavedController savedCtrl = Get.find<SavedController>();

    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            ),
            child: Stack(
              children: [
                SizedBox(
                  height: 110,
                  width: double.infinity,
                  child: Image.asset(
                    coverUrl,
                    height: 110,
                    width: double.infinity,
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
                Positioned(
                  top: 6,
                  right: 6,
                  child: Obx(() {
                    final isSaved = savedCtrl.isSaved(course.id);
                    return GestureDetector(
                      onTap: () => savedCtrl.toggleSave(
                        course.id,
                        courseData: course.toJson(),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: isSaved ? Colors.blue : Colors.white,
                          size: 20,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Text(
              course.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "By ${course.instructor}",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                ...List.generate(
                  5,
                  (index) => Icon(
                    Icons.star,
                    size: 14,
                    color: index < course.rating.round()
                        ? Colors.orange
                        : Colors.grey.shade300,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  course.rating.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: course.progress.clamp(0.0, 1.0),
                    minHeight: 4,
                    backgroundColor: const Color(0xffe0d7ff),
                    valueColor: const AlwaysStoppedAnimation(Colors.blue),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "${(course.progress.clamp(0.0, 1.0) * 100).round()}% Done",
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
