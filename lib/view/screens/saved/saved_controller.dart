import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:skill_up/controllers/user_controller.dart';
import 'package:skill_up/data/mock/mock_config.dart';
import 'package:skill_up/data/mock/mock_data.dart';
import 'package:skill_up/data/repositories/saved_repository.dart';

class SavedController extends GetxController {
  final SavedRepository _repo = SavedRepository();
  late final UserController userCtrl;

  final RxList<Map<String, dynamic>> savedCourses = <Map<String, dynamic>>[].obs;
  final RxSet<String> savedIds = <String>{}.obs;
  final RxBool isLoading = false.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _savedSub;

  @override
  void onInit() {
    super.onInit();
    userCtrl = Get.find<UserController>();

    if (useMockData) {
      _loadMockSaved();
      return;
    }

    if (userCtrl.isReady.value && userCtrl.uid.value.isNotEmpty) {
      _listenSaved();
    } else {
      ever(userCtrl.isReady, (ready) {
        if (ready == true && userCtrl.uid.value.isNotEmpty) {
          _listenSaved();
        }
      });
    }
  }

  bool isSaved(String courseId) => savedIds.contains(courseId);

  void _loadMockSaved() {
    isLoading.value = true;
    savedCourses.clear();
    savedIds.clear();

    final mock = MockDataService.instance;
    for (final saved in mock.savedVideoIds) {
      final course = mock.courseById(saved['videoId'] as String);
      if (course != null) {
        savedCourses.add(Map<String, dynamic>.from(course));
        savedIds.add(course['id'] as String);
      }
    }

    isLoading.value = false;
    debugPrint('[SavedController] mock loaded: ${savedCourses.length} saved, ${savedIds.length} ids');
  }

  void _listenSaved() {
    _savedSub?.cancel();
    isLoading.value = true;

    _savedSub = _repo.watchSaved(userCtrl.uid.value).listen((snap) async {
      final List<Map<String, dynamic>> temp = [];
      final Set<String> tempIds = {};

      for (final doc in snap.docs) {
        final videoId = doc.data()['videoId'] as String? ?? '';
        if (videoId.isEmpty) continue;
        tempIds.add(videoId);

        final videoDoc = await FirebaseFirestore.instance
            .collection('videos')
            .doc(videoId)
            .get();

        if (!videoDoc.exists) continue;

        final v = videoDoc.data()!;
        temp.add({
          'id': videoDoc.id,
          'title': v['title'] ?? '',
          'instructor': v['createdByName'] ?? '',
          'category': v['subject'] ?? '',
          'imageUrl': v['thumbnailUrl'] ?? '',
          'coverImage': v['thumbnailUrl'] ?? '',
          'videoUrl': v['videoUrl'] ?? '',
          'description': v['description'] ?? '',
          'level': v['level'] ?? '',
        });
      }

      savedCourses.assignAll(temp);
      savedIds.assignAll(tempIds);
      isLoading.value = false;
      debugPrint('[SavedController] firebase loaded: ${savedCourses.length} saved, ${savedIds.length} ids');
    });
  }

  Future<void> toggleSave(String courseId, {Map<String, dynamic>? courseData}) async {
    if (courseId.isEmpty) return;

    final isCurrentlySaved = savedIds.contains(courseId);

    if (useMockData) {
      if (isCurrentlySaved) {
        savedIds.remove(courseId);
        savedCourses.removeWhere((c) => c['id'] == courseId);
        _showSnackbar('Course removed from saved');
      } else {
        savedIds.add(courseId);
        if (courseData != null) {
          savedCourses.insert(0, Map<String, dynamic>.from(courseData));
        }
        _showSnackbar('Course saved');
      }
      debugPrint('[SavedController] mock toggle: course=$courseId saved=${!isCurrentlySaved}');
      return;
    }

    final uid = userCtrl.uid.value;
    if (uid.isEmpty) return;

    try {
      if (isCurrentlySaved) {
        await _repo.removeSaved(uid: uid, videoId: courseId);
        savedIds.remove(courseId);
        savedCourses.removeWhere((c) => c['id'] == courseId);
        _showSnackbar('Course removed from saved');
      } else {
        await _repo.saveCourse(uid: uid, videoId: courseId);
        savedIds.add(courseId);
        if (courseData != null) {
          savedCourses.insert(0, Map<String, dynamic>.from(courseData));
        }
        _showSnackbar('Course saved');
      }
    } catch (e) {
      debugPrint('[SavedController] ERROR toggling save: $e');
      _showSnackbar('Error saving course. Please try again.');
    }
  }

  void _showSnackbar(String message) {
    if (!Get.isSnackbarOpen) {
      Get.snackbar(
        '',
        message,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        icon: Icon(
          message.contains('removed') ? Icons.bookmark_remove : Icons.bookmark,
          color: Colors.white,
        ),
      );
    }
  }

  @override
  void onClose() {
    _savedSub?.cancel();
    super.onClose();
  }
}
