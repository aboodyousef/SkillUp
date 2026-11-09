import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';

import 'package:skill_up/data/models/course_model.dart';
import 'package:skill_up/data/models/user_model.dart';
import 'package:skill_up/controllers/user_controller.dart';
import 'package:skill_up/data/mock/mock_config.dart';
import 'package:skill_up/data/mock/mock_data.dart';

class HomeController extends GetxController {
  // ----------------- Bottom Nav -----------------
  RxInt currentIndex = 0.obs;
  void changeTab(int index) => currentIndex.value = index;

  // ----------------- Firebase -----------------
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // ----------------- User -----------------
  final UserController userCtrl = Get.find<UserController>();

  // ----------------- Search (Home) -----------------
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  void onSearchChanged(String v) => searchQuery.value = v.trim().toLowerCase();

  // ----------------- UI data -----------------
  final skills = <String>[].obs;

  // Raw maps (for CourseDetails)
  final trendingRaw = <Map<String, dynamic>>[].obs;
  final continueRaw = <Map<String, dynamic>>[].obs;

  // UI Models
  final continueWatchingCourses = <CourseModel>[].obs;
  final trendingCourses = <CourseModel>[].obs;

  final RxBool isLoadingTrending = false.obs;
  final RxBool isLoadingContinue = false.obs;

  //Filtered lists
  List<CourseModel> get filteredTrending {
    final q = searchQuery.value;
    if (q.isEmpty) return trendingCourses;

    return trendingCourses.where((c) {
      final title = c.title.toLowerCase();
      final ins = c.instructor.toLowerCase();
      final cat = c.category.toLowerCase();
      return title.contains(q) || ins.contains(q) || cat.contains(q);
    }).toList();
  }

  List<CourseModel> get filteredContinue {
    final q = searchQuery.value;
    if (q.isEmpty) return continueWatchingCourses;

    return continueWatchingCourses.where((c) {
      final title = c.title.toLowerCase();
      final ins = c.instructor.toLowerCase();
      final cat = c.category.toLowerCase();
      return title.contains(q) || ins.contains(q) || cat.contains(q);
    }).toList();
  }

  //Lifecycle
  @override
  void onInit() {
    super.onInit();
    loadSkills();
    loadTrending();

    if (useMockData) {
      ever(userCtrl.isReady, (ready) {
        if (ready == true && userCtrl.uid.value.isNotEmpty) {
          if (userCtrl.role.value == UserRole.student) {
            loadContinueWatching(userCtrl.uid.value);
          }
        }
      });
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  //Skills
  Future<void> loadSkills() async {
    if (useMockData) {
      skills.assignAll(MockDataService.instance.skillCategories.take(8));
      return;
    }
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/home_data.json');
      final data = json.decode(jsonString);

      if (data['skills'] != null) {
        skills.assignAll(List<String>.from(data['skills']));
      } else {
        skills.clear();
      }
    } catch (_) {
      skills.clear();
    }
  }

  //Continue Watching
  Future<void> loadContinueWatching(String uid) async {
    if (useMockData) {
      try {
        isLoadingContinue.value = true;
        continueWatchingCourses.clear();
        continueRaw.clear();

        final mockData = MockDataService.instance;
        final items = mockData.getContinueWatching();

        for (final raw in items) {
          continueRaw.add(Map<String, dynamic>.from(raw));
          continueWatchingCourses.add(CourseModel.fromJson({
            "id": raw["id"],
            "title": raw["title"],
            "instructor": raw["instructor"],
            "category": raw["category"],
            "imageUrl": raw["coverImage"] ?? raw["imageUrl"],
            "coverImage": raw["coverImage"] ?? raw["imageUrl"],
            "progress": raw["progress"] ?? 0.0,
            "rating": double.tryParse(raw["rating"]?.toString() ?? '0') ?? 0,
          }));
        }
      } finally {
        isLoadingContinue.value = false;
      }
      return;
    }

    try {
      isLoadingContinue.value = true;
      continueWatchingCourses.clear();
      continueRaw.clear();

      final enrollSnap = await _firestore
          .collection('users')
          .doc(uid)
          .collection('enrollments')
          .orderBy('updatedAt', descending: true)
          .limit(10)
          .get();

      if (enrollSnap.docs.isEmpty) return;

      final List<CourseModel> temp = [];
      final List<Map<String, dynamic>> rawTemp = [];

      for (final enrollDoc in enrollSnap.docs) {
        final enroll = enrollDoc.data();
        final String videoId = (enroll['videoId'] ?? '').toString();
        if (videoId.isEmpty) continue;

        final videoDoc =
            await _firestore.collection('videos').doc(videoId).get();
        if (!videoDoc.exists) continue;

        final v = videoDoc.data() as Map<String, dynamic>;

        final int p = (enroll['progress'] ?? 0) is int
            ? enroll['progress']
            : int.tryParse(enroll['progress'].toString()) ?? 0;

        final double normalized = (p.clamp(0, 100)) / 100.0;

        final rawMap = <String, dynamic>{
          "id": videoDoc.id,
          "title": (v['title'] ?? '').toString(),
          "instructor": (v['createdByName'] ?? '').toString(),
          "category": (v['subject'] ?? '').toString(),
          "imageUrl": (v['thumbnailUrl'] ?? '').toString(),
          "videoUrl": (v['videoUrl'] ?? '').toString(),
          "description": (v['description'] ?? '').toString(),
          "level": (v['level'] ?? '').toString(),
          "progress": normalized,
          "rating": (v['rating'] ?? 0.0) is num ? (v['rating'] ?? 0.0) : 0.0,
        };

        rawTemp.add(rawMap);

        temp.add(CourseModel.fromJson({
          "id": rawMap["id"],
          "title": rawMap["title"],
          "instructor": rawMap["instructor"],
          "category": rawMap["category"],
          "imageUrl": rawMap["imageUrl"],
          "progress": rawMap["progress"],
          "rating": rawMap["rating"],
        }));
      }

      continueRaw.assignAll(rawTemp);
      continueWatchingCourses.assignAll(temp);
    } finally {
      isLoadingContinue.value = false;
    }
  }

  //Trending + AI Ranking
  Future<void> loadTrending() async {
    if (useMockData) {
      try {
        isLoadingTrending.value = true;
        trendingCourses.clear();
        trendingRaw.clear();

        final mockData = MockDataService.instance;
        final items = mockData.allCourses;

        // AI ranking based on user interests
        final sorted = List<Map<String, dynamic>>.from(items);
        sorted.sort((a, b) {
          final aScore = _calculateScore(a);
          final bScore = _calculateScore(b);
          return bScore.compareTo(aScore);
        });

        for (final raw in sorted) {
          trendingRaw.add(Map<String, dynamic>.from(raw));
          trendingCourses.add(CourseModel.fromJson({
            "id": raw["id"],
            "title": raw["title"],
            "instructor": raw["instructor"],
            "category": raw["category"],
            "imageUrl": raw["coverImage"] ?? raw["imageUrl"],
            "coverImage": raw["coverImage"] ?? raw["imageUrl"],
            "progress": 0.0,
            "rating": double.tryParse(raw["rating"]?.toString() ?? '0') ?? 0,
          }));
        }
      } finally {
        isLoadingTrending.value = false;
      }
      return;
    }

    try {
      isLoadingTrending.value = true;
      trendingCourses.clear();
      trendingRaw.clear();

      final snap = await _firestore
          .collection('videos')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      final List<Map<String, dynamic>> rawTemp = [];
      final List<CourseModel> temp = [];

      for (final doc in snap.docs) {
        final d = doc.data();
        rawTemp.add({
          "id": doc.id,
          "title": d['title'] ?? '',
          "instructor": d['createdByName'] ?? '',
          "category": d['subject'] ?? '',
          "imageUrl": d['thumbnailUrl'] ?? '',
          "videoUrl": d['videoUrl'] ?? '',
          "description": d['description'] ?? '',
          "level": d['level'] ?? '',
          "rating": (d['rating'] ?? 0.0) is num ? (d['rating'] ?? 0.0) : 0.0,
        });
      }

      //AI Ranking (based on interests)
      rawTemp.sort((a, b) {
        final aScore = _calculateScore(a);
        final bScore = _calculateScore(b);
        return bScore.compareTo(aScore);
      });

      for (final r in rawTemp) {
        temp.add(CourseModel.fromJson({
          "id": r["id"],
          "title": r["title"],
          "instructor": r["instructor"],
          "category": r["category"],
          "imageUrl": r["imageUrl"],
          "progress": 0.0,
          "rating": r["rating"],
        }));
      }

      trendingRaw.assignAll(rawTemp);
      trendingCourses.assignAll(temp);
    } finally {
      isLoadingTrending.value = false;
    }
  }

  //Refresh Home
  Future<void> refreshHome({required String uid}) async {
    await Future.wait([
      loadTrending(),
      if (uid.isNotEmpty) loadContinueWatching(uid),
    ]);
  }

  //AI Score
  int _calculateScore(Map<String, dynamic> video) {
    int score = 0;

    final subject = (video['category'] ?? '').toString().toLowerCase();
    final title = (video['title'] ?? '').toString().toLowerCase();

    for (final interest in userCtrl.interests) {
      final i = interest.toLowerCase();
      if (subject.contains(i)) score += 5;
      if (title.contains(i)) score += 1;
    }

    return score;
  }

  //Helpers
  Map<String, dynamic> trendingMapAt(int index) => trendingRaw[index];
  Map<String, dynamic> continueMapAt(int index) => continueRaw[index];
}
