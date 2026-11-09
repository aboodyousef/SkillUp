import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import 'package:skill_up/data/mock/mock_config.dart';
import 'package:skill_up/view/screens/saved/saved_controller.dart';

class CourseDetailsController extends GetxController {
  RxInt selectedTab = 0.obs;
  void changeTab(int index) => selectedTab.value = index;

  final RxBool isSaved = false.obs;

  late final SavedController _savedCtrl;
  String _courseId = '';
  Map<String, dynamic>? _courseData;

  void setCourse(String id, Map<String, dynamic>? data) {
    _courseId = id;
    _courseData = data;
    _savedCtrl = Get.find<SavedController>();
    isSaved.value = _savedCtrl.isSaved(id);
  }

  void toggleSave() {
    if (_courseId.isEmpty) return;
    isSaved.value = !isSaved.value;
    _savedCtrl.toggleSave(_courseId, courseData: _courseData);
  }

  //Lock / Enroll state
  final RxBool isCheckingEnroll = false.obs;
  final RxBool isEnrolled = false.obs;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _sub;

  String _currentVideoId = '';

  Future<void> watchEnrollStatus(String videoId) async {
    if (useMockData) {
      isCheckingEnroll.value = true;
      await Future.delayed(const Duration(milliseconds: 300));
      isEnrolled.value = true;
      isCheckingEnroll.value = false;
      return;
    }

    if (videoId.isEmpty) {
      isCheckingEnroll.value = false;
      isEnrolled.value = false;
      return;
    }

    if (_currentVideoId == videoId && _sub != null) return;
    _currentVideoId = videoId;

    await _sub?.cancel();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      isCheckingEnroll.value = false;
      isEnrolled.value = false;
      return;
    }

    isCheckingEnroll.value = true;

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('enrollments')
        .doc(videoId);

    _sub = docRef.snapshots().listen((doc) {
      isEnrolled.value = doc.exists;
      isCheckingEnroll.value = false;
    }, onError: (_) {
      isCheckingEnroll.value = false;
      isEnrolled.value = false;
    });
  }

  void setTeacherMode() {
    isCheckingEnroll.value = false;
    isEnrolled.value = true;
    _currentVideoId = '';
    _sub?.cancel();
    _sub = null;
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
