import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:skill_up/controllers/user_controller.dart';
import 'package:skill_up/data/models/user_model.dart';
import 'package:skill_up/data/mock/mock_config.dart';
import 'package:skill_up/data/mock/mock_data.dart';

class MyCoursesController extends GetxController {
  var selectedTab = 0.obs;

  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = "".obs;

  final RxList<Map<String, dynamic>> allCourses = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;

  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    loadCourses();
  }

  Future<void> loadCourses() async {
    if (useMockData) {
      try {
        isLoading.value = true;
        allCourses.clear();

        final userCtrl = Get.find<UserController>();
        final mock = MockDataService.instance;

        if (userCtrl.role.value == UserRole.teacher) {
          final items = mock.allCourses.take(4).toList();
          for (final raw in items) {
            allCourses.add({
              "id": raw["id"],
              "title": raw["title"],
              "instructor": raw["instructor"],
              "category": raw["category"] ?? 'Video',
              "progress": 100,
              "minutesText": "Published",
              "imageUrl": raw["coverImage"] ?? raw["imageUrl"],
              "coverImage": raw["coverImage"] ?? raw["imageUrl"],
              "price": 0,
              "rating": 0,
              "students": 0,
              "hours": 0,
              "reviewsCount": 0,
            });
          }
        } else {
          final enrollments = mock.mockEnrollments;
          for (final enroll in enrollments) {
            final course = mock.courseById(enroll['videoId'] as String);
            if (course != null) {
              allCourses.add({
                "id": course["id"],
                "title": course["title"],
                "instructor": course["instructor"],
                "category": course["category"] ?? 'Video',
                "progress": enroll['progress'] ?? 0,
                "minutesText": enroll['minutesText'] ?? '0% Done',
                "imageUrl": course["coverImage"] ?? course["imageUrl"],
                "coverImage": course["coverImage"] ?? course["imageUrl"],
                "price": 0,
                "rating": double.tryParse(
                        course["rating"]?.toString() ?? '0') ??
                    0,
                "students": 0,
                "hours": 0,
                "reviewsCount": 0,
              });
            }
          }
        }

        isLoading.value = false;
      } catch (_) {
        isLoading.value = false;
      }
      return;
    }

    try {
      isLoading.value = true;

      final user = _auth.currentUser;
      if (user == null) {
        allCourses.clear();
        isLoading.value = false;
        return;
      }

      final userCtrl = Get.find<UserController>();
      final role = userCtrl.role.value;

      if (role == UserRole.teacher) {
        final snapshot = await _firestore
            .collection('videos')
            .where('createdBy', isEqualTo: user.uid)
            .get();

        final List<Map<String, dynamic>> temp = [];

        for (final doc in snapshot.docs) {
          final data = doc.data();
          temp.add({
            "id": doc.id,
            "title": data['title'] ?? '',
            "instructor": data['createdByName'] ?? '',
            "category": data['subject'] ?? 'Video',
            "progress": 100,
            "minutesText": "Published",
            "imageUrl": data['thumbnailUrl'] ?? '',
            "coverImage": data['thumbnailUrl'] ?? '',
            "price": 0,
            "rating": 0,
            "students": 0,
            "hours": 0,
            "reviewsCount": 0,
          });
        }

        allCourses.assignAll(temp);
      } else {
        final enrollSnap = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('enrollments')
            .get();

        if (enrollSnap.docs.isEmpty) {
          allCourses.clear();
        } else {
          final List<Map<String, dynamic>> temp = [];

          for (final enrollDoc in enrollSnap.docs) {
            final enrollData = enrollDoc.data();
            final String videoId = enrollData['videoId'] ?? '';

            if (videoId.isEmpty) continue;

            final videoDoc =
                await _firestore.collection('videos').doc(videoId).get();

            if (!videoDoc.exists) continue;

            final v = videoDoc.data()!;
            final int progress = (enrollData['progress'] ?? 0) as int;
            final String minutesText =
                enrollData['minutesText'] ?? "$progress% Done";

            temp.add({
              "id": videoDoc.id,
              "title": v['title'] ?? '',
              "instructor": v['createdByName'] ?? '',
              "category": v['subject'] ?? 'Video',
              "progress": progress,
              "minutesText": minutesText,
              "imageUrl": v['thumbnailUrl'] ?? '',
              "coverImage": v['thumbnailUrl'] ?? '',
              "price": 0,
              "rating": 0,
              "students": 0,
              "hours": 0,
              "reviewsCount": 0,
            });
          }

          allCourses.assignAll(temp);
        }
      }

      isLoading.value = false;
    } catch (e) {
      debugPrint("Error loading courses: $e");
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> get filteredCourses {
    List<Map<String, dynamic>> list;

    if (selectedTab.value == 1) {
      list = allCourses
          .where((c) => ((c["progress"] as int?) ?? 0) < 100)
          .toList();
    } else if (selectedTab.value == 2) {
      list = allCourses
          .where((c) => ((c["progress"] as int?) ?? 0) == 100)
          .toList();
    } else {
      list = allCourses.toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list.where((course) {
        final title = (course["title"] ?? "").toString().toLowerCase();
        final instructor =
            (course["instructor"] ?? "").toString().toLowerCase();
        final category =
            (course["category"] ?? "").toString().toLowerCase();

        return title.contains(q) ||
            instructor.contains(q) ||
            category.contains(q);
      }).toList();
    }

    return list;
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  void onSearchChanged(String value) {
    searchQuery.value = value.toLowerCase();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
