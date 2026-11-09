import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:skill_up/controllers/user_controller.dart';
import 'package:skill_up/data/models/user_model.dart';
import 'package:skill_up/data/themes/image_string.dart';
import 'package:skill_up/data/mock/mock_config.dart';
import 'package:skill_up/data/mock/mock_data.dart';
import 'package:skill_up/utils/image_helper.dart';
import 'package:skill_up/view/screens/MyCourses/course_details_controller.dart';
import 'package:skill_up/view/screens/MyCourses/MyCourses_controller.dart';
import 'package:skill_up/view/screens/MyCourses/video_player_view.dart';

class CourseDetailsView extends StatefulWidget {
  final Map<String, dynamic> course;

  const CourseDetailsView({super.key, required this.course});

  @override
  State<CourseDetailsView> createState() => _CourseDetailsViewState();
}

class _CourseDetailsViewState extends State<CourseDetailsView> {
  late final CourseDetailsController ctrl;
  late final UserController userCtrl;

  late final String id;
  late final String title;
  late final String instructor;
  late final String category;
  late final String imageUrl;
  late final String videoUrl;
  late final String description;
  late final String level;

  late final double price;
  late final double rating;
  late final int students;
  late final double hours;
  late final int reviewsCount;

  List<Map<String, dynamic>> _lessons = [];
  List<Map<String, dynamic>> _reviews = [];

  bool get isTeacher => userCtrl.role.value == UserRole.teacher;

  @override
  void initState() {
    super.initState();

    ctrl = Get.isRegistered<CourseDetailsController>()
        ? Get.find<CourseDetailsController>()
        : Get.put(CourseDetailsController());

    userCtrl = Get.find<UserController>();

    final course = widget.course;

    id = (course["id"] ?? "").toString();
    title = (course["title"] ?? "Course Title").toString();
    instructor = (course["instructor"] ?? "Instructor").toString();
    category = (course["category"] ?? "Category").toString();

    imageUrl = ((course["coverImage"] as String?)?.isNotEmpty == true
            ? course["coverImage"]
            : course["imageUrl"] ?? 'assets/course_images/general.png')
        .toString();

    videoUrl = (course["videoUrl"] ?? "").toString();

    description = (course["description"] ?? "").toString();
    level = (course["level"] ?? "").toString();

    price = (course["price"] as num?)?.toDouble() ?? 0.0;
    rating = (course["rating"] as num?)?.toDouble() ?? 0.0;
    students = (course["students"] as int?) ?? 0;
    hours = (course["hours"] as num?)?.toDouble() ?? 0.0;
    reviewsCount = (course["reviewsCount"] as int?) ?? 0;

    ctrl.setCourse(id, widget.course);

    if (useMockData) {
      _lessons = MockDataService.instance.lessonsForCourse(id);
      _reviews = MockDataService.instance.mockReviewsForCourse(id);
      ctrl.isEnrolled.value = true;
    } else {
      if (id.isNotEmpty) {
        if (isTeacher) {
          ctrl.setTeacherMode();
        } else {
          ctrl.watchEnrollStatus(id);
        }
      }
    }
  }

  Future<void> enrollCourse() async {
    if (useMockData) {
      ctrl.isEnrolled.value = true;
      Get.snackbar('enrolled'.tr, 'enrolledSuccess'.tr,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar('error'.tr, 'mustBeLoggedIn'.tr,
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      if (id.isEmpty) {
        Get.snackbar('error'.tr, 'courseIdMissing'.tr,
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('enrollments')
          .doc(id);

      await docRef.set({
        'videoId': id,
        'progress': 0,
        'minutesText': '0% Done',
        'enrolledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (Get.isRegistered<MyCoursesController>()) {
        await Get.find<MyCoursesController>().loadCourses();
      }

      Get.snackbar('done'.tr, 'enrolledSuccess'.tr,
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      debugPrint("Enroll error: $e");
      Get.snackbar('error'.tr, 'failedToEnroll'.tr,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void openVideoIfAllowed() {
    if (videoUrl.isEmpty) {
      Get.snackbar('missingVideo'.tr, 'noVideoUrl'.tr,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final canWatch = isTeacher || ctrl.isEnrolled.value;
    if (!canWatch) {
      Get.snackbar('lockedVideo'.tr, 'lockedVideoMsg'.tr,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    Get.to(() => VideoPlayerView(videoUrl: videoUrl, title: title));
  }

  Widget _buildCourseImage(String url) {
    final cover = url.isNotEmpty ? url : 'assets/course_images/general.png';

    if (cover.startsWith('assets/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: 220,
          width: double.infinity,
          child: Image.asset(cover, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _imagePlaceholder(),
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 220,
        width: double.infinity,
        child: Image.network(
          cover,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _imagePlaceholder(),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(Icons.image, color: Colors.white70, size: 40),
      ),
    );
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
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(
                ctrl.isSaved.value ? Icons.bookmark : Icons.bookmark_border,
                color: ctrl.isSaved.value ? Colors.blue : Colors.grey,
              ),
              onPressed: ctrl.toggleSave,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() {
                    final checking = ctrl.isCheckingEnroll.value;
                    final enrolled = ctrl.isEnrolled.value;
                    final canWatch = isTeacher || enrolled;

                    return Stack(
                      children: [
                        _buildCourseImage(imageUrl),

                        if (price > 0)
                          Positioned(
                            right: 16,
                            top: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "\$${price.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                        if (!isTeacher && checking)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),

                        if (!isTeacher && !checking && !enrolled)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.35),
                                borderRadius: itemRadius(18),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.lock,
                                      color: Colors.white, size: 40),
                                  const SizedBox(height: 10),
                                  Text(
                                    'lockedVideo'.tr,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'enrollToUnlock'.tr,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  SizedBox(
                                    height: 40,
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                        ),
                                      ),
                                      onPressed: enrollCourse,
                                      icon: const Icon(Icons.school),
                                      label: Text('enrollNow'.tr),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (canWatch && videoUrl.isNotEmpty)
                          Positioned.fill(
                            child: Center(
                              child: IconButton(
                                iconSize: 72,
                                icon: const Icon(Icons.play_circle_fill,
                                    color: Colors.white),
                                onPressed: openVideoIfAllowed,
                              ),
                            ),
                          ),

                        if (videoUrl.isEmpty)
                          Positioned(
                            left: 12,
                            right: 12,
                            bottom: 12,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'noVideoUrl'.tr,
                                style: const TextStyle(color: Colors.white70),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
                  const SizedBox(height: 16),

                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "${'reviewsCount'.trParams({'count': reviewsCount.toString()})} | $category",
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoCard(
                        icon: Icons.people_alt_outlined,
                        label: 'students'.tr,
                        value: students.toString(),
                      ),
                      _infoCard(
                        icon: Icons.access_time,
                        label: 'duration'.tr,
                        value: hours > 0 ? 'hours'.trParams({'count': hours.toString()}) : "-",
                      ),
                      _infoCard(
                        icon: Icons.verified_outlined,
                        label: 'certificate'.tr,
                        value: 'included'.tr,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _tabItem('about'.tr, 0, ctrl),
                        _tabItem('lessons'.tr, 1, ctrl),
                        _tabItem('reviews'.tr, 2, ctrl),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  Obx(() {
                    if (ctrl.selectedTab.value == 0) {
                      return _aboutSection(
                        instructor: instructor,
                        description: description,
                        level: level,
                      );
                    } else if (ctrl.selectedTab.value == 1) {
                      return _lessonsSection();
                    } else {
                      return _reviewsSection(rating, reviewsCount);
                    }
                  }),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          SafeArea(
            top: false,
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: isTeacher
                  ? Container(
                      alignment: Alignment.center,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xfff5f6fb),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        'youAreInstructor'.tr,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : Obx(() {
                      if (ctrl.isEnrolled.value) {
                        return SizedBox(
                          height: 48,
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: openVideoIfAllowed,
                            icon: const Icon(Icons.play_arrow),
                            label: Text(
                              'watchVideo'.tr,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }

                      return SizedBox(
                        height: 48,
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: enrollCourse,
                          child: Text(
                            price > 0
                                ? 'enrollCoursePrice'.trParams({'price': price.toStringAsFixed(0)})
                                : 'enrollCourse'.tr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    }),
            ),
          ),
        ],
      ),
    );
  }

  BorderRadius itemRadius(double r) => BorderRadius.circular(r);

  Widget _infoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xfff7f2ff),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _tabItem(String title, int index, CourseDetailsController ctrl) {
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
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          if (isSelected)
            Container(
              height: 2,
              width: 60,
              color: Colors.blue,
            ),
        ],
      ),
    );
  }

  Widget _aboutSection({
    required String instructor,
    required String description,
    required String level,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: const AssetImage(ImageStringProfile.userProfile),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  instructor,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  level.isNotEmpty ? 'levelLabel'.trParams({'level': level}) : 'instructorLabel'.tr,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'aboutThisCourse'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 8),
        Text(
          description.isNotEmpty
              ? description
              : 'noDescription'.tr,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _lessonsSection() {
    if (_lessons.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'noLessons'.tr,
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: _lessons
          .map(
            (lesson) => Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xffe0d7ff)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.play_circle_fill, color: Colors.blue),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson["title"] ?? '',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        if ((lesson["description"] ?? '').isNotEmpty)
                          Text(
                            lesson["description"],
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDuration(lesson["durationSeconds"] ?? 0),
                    style:
                        const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  String _formatDuration(dynamic seconds) {
    final secs = (seconds is int) ? seconds : int.tryParse(seconds.toString()) ?? 0;
    final m = secs ~/ 60;
    final s = secs % 60;
    return '$m:${s.toString().padLeft(2, '0')} ${'mins'.trParams({'count': m.toString()})}';
  }

  Widget _reviewsSection(double rating, int reviewsCount) {
    if (_reviews.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'noReviews'.tr,
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              rating.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.star, color: Colors.orange, size: 18),
                    Icon(Icons.star, color: Colors.orange, size: 18),
                    Icon(Icons.star, color: Colors.orange, size: 18),
                    Icon(Icons.star, color: Colors.orange, size: 18),
                    Icon(Icons.star_half, color: Colors.orange, size: 18),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'reviewsCount'.trParams({'count': reviewsCount.toString()}),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._reviews.map((r) => _reviewTile(r)),
      ],
    );
  }

  Widget _reviewTile(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xfff7f2ff),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: resolveImage(
                  review['userPhotoUrl']?.toString() ?? '',
                  fallbackAsset: ImageStringProfile.userProfile,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  review['userName'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Row(
                children: List.generate(
                  (review['rating'] as num?)?.toInt() ?? 0,
                  (_) => const Icon(Icons.star,
                      color: Colors.orange, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            review['comment'] ?? '',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
