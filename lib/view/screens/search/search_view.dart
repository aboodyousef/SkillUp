import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:skill_up/view/screens/MyCourses/course_details_view.dart';
import 'package:skill_up/view/screens/saved/saved_controller.dart';
import 'package:skill_up/view/screens/search/search_controller.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final SearchScreenController ctrl = Get.put(SearchScreenController());

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
          'searchCourses'.tr,
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
              controller: ctrl.queryController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'searchAnyCourse'.tr,
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: Obx(
                  () => ctrl.queryText.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: ctrl.clearSearch,
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
              onSubmitted: (_) => ctrl.onSearchSubmitted(),
            ),
          ),
          Obx(() {
            if (ctrl.categories.isEmpty) return const SizedBox.shrink();
            return SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: ctrl.categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = ctrl.categories[index];
                  final isSelected = ctrl.selectedCategory.value == cat;
                  return FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => ctrl.setCategory(cat),
                    selectedColor: Colors.blue.shade100,
                    checkmarkColor: Colors.blue,
                    backgroundColor: const Color(0xfff5f6fb),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.blue : Colors.grey.shade700,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                },
              ),
            );
          }),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              switch (ctrl.status.value) {
                case SearchStatus.idle:
                  return _buildIdleState();
                case SearchStatus.loading:
                  return _buildLoadingState();
                case SearchStatus.results:
                  return _buildResultsList(ctrl);
                case SearchStatus.empty:
                  return _buildEmptyState();
                case SearchStatus.error:
                  return _buildErrorState(ctrl);
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildIdleState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'searchAnyCourse'.tr,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'noCoursesFound'.tr,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(SearchScreenController ctrl) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              '${'error'.tr}: ${ctrl.errorMessage.value}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ctrl.onSearchSubmitted(),
              child: Text('tryAgain'.tr),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(SearchScreenController ctrl) {
    final results = ctrl.results;
    if (results.isEmpty) return _buildEmptyState();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final course = results[index];
        return _buildResultItem(course);
      },
    );
  }

  Widget _buildResultItem(dynamic course) {
    final imageUrl = (course.coverImage.isNotEmpty
            ? course.coverImage
            : course.imageUrl) ??
        'assets/course_images/general.png';
    final SavedController savedCtrl = Get.find<SavedController>();

    return GestureDetector(
      onTap: () {
        final courseMap = <String, dynamic>{
          'id': course.id,
          'title': course.title,
          'instructor': course.instructor,
          'category': course.category,
          'imageUrl': course.imageUrl,
          'coverImage': course.coverImage,
          'rating': course.rating,
          'progress': course.progress,
        };
        Get.to(() => CourseDetailsView(course: courseMap));
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
                      child: const Icon(Icons.image, color: Colors.white70, size: 30),
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
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Obx(() {
                final isSaved = savedCtrl.isSaved(course.id);
                return IconButton(
                  icon: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: isSaved ? Colors.blue : Colors.grey,
                  ),
                  onPressed: () => savedCtrl.toggleSave(
                    course.id,
                    courseData: course.toJson(),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
