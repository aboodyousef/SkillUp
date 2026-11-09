import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:skill_up/controllers/user_controller.dart';
import 'package:skill_up/data/mock/mock_config.dart';
import 'package:skill_up/data/mock/mock_data.dart';
import 'package:skill_up/data/models/course_model.dart';
import 'package:skill_up/services/ai_recommender.dart';

enum SearchStatus { idle, loading, results, empty, error }

class SearchScreenController extends GetxController {
  final TextEditingController queryController = TextEditingController();
  final RxString queryText = ''.obs;
  final Rx<SearchStatus> status = SearchStatus.idle.obs;
  final RxList<CourseModel> results = <CourseModel>[].obs;
  final RxString selectedCategory = ''.obs;
  final RxList<String> categories = <String>[].obs;
  final RxString errorMessage = ''.obs;

  Timer? _debounce;
  UserController get _userCtrl => Get.find<UserController>();

  @override
  void onInit() {
    super.onInit();
    _loadCategories();
    queryController.addListener(_onQueryChanged);
    debugPrint('[SearchScreenController] initialized');
  }

  @override
  void onClose() {
    _debounce?.cancel();
    queryController.removeListener(_onQueryChanged);
    queryController.dispose();
    super.onClose();
    debugPrint('[SearchScreenController] disposed');
  }

  void _loadCategories() {
    if (useMockData) {
      categories.assignAll(MockDataService.instance.skillCategories);
    }
    debugPrint('[SearchScreenController] categories loaded: ${categories.length}');
  }

  void _onQueryChanged() {
    queryText.value = queryController.text.trim();
  }

  void setCategory(String cat) {
    selectedCategory.value = selectedCategory.value == cat ? '' : cat;
    debugPrint('[SearchScreenController] category filter: "${selectedCategory.value}"');
    _performSearch();
  }

  void search(String query) {
    queryController.text = query;
    _performSearch();
  }

  void onSearchSubmitted() {
    _debounce?.cancel();
    _performSearch();
  }

  void _performSearch() {
    final query = queryText.value;

    if (query.isEmpty && selectedCategory.value.isEmpty) {
      status.value = SearchStatus.idle;
      results.clear();
      debugPrint('[SearchScreenController] idle - empty query and no category');
      return;
    }

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _executeSearch(query);
    });
  }

  Future<void> _executeSearch(String query) async {
    status.value = SearchStatus.loading;
    debugPrint('[SearchScreenController] executing search query="$query" category="${selectedCategory.value}"');

    try {
      List<Map<String, dynamic>> allCourses;
      if (useMockData) {
        allCourses = MockDataService.instance.allCourses;
      } else {
        allCourses = [];
      }

      debugPrint('[SearchScreenController] total courses available: ${allCourses.length}');

      final interests = _userCtrl.interests;
      final enrolledIds = <String>[];
      final savedIds = <String>[];
      final level = '';

      List<Map<String, dynamic>> scored;

      try {
        scored = _aiRecommend(allCourses, query, interests, enrolledIds, savedIds, level);
        debugPrint('[SearchScreenController] AI recommendations returned: ${scored.length}');
      } catch (e) {
        debugPrint('[SearchScreenController] AI search failed: $e');
        scored = _fallbackSearch(allCourses, query);
        debugPrint('[SearchScreenController] fallback search returned: ${scored.length}');
      }

      final categoryFilter = selectedCategory.value;
      if (categoryFilter.isNotEmpty) {
        scored = scored.where((c) {
          final cat = (c['category'] ?? '').toString().toLowerCase();
          return cat.contains(categoryFilter.toLowerCase());
        }).toList();
        debugPrint('[SearchScreenController] after category filter: ${scored.length}');
      }

      if (scored.isEmpty) {
        status.value = SearchStatus.empty;
        results.clear();
        debugPrint('[SearchScreenController] no results found');
        return;
      }

      final models = scored.map((c) => CourseModel.fromJson(c)).toList();
      results.assignAll(models);
      status.value = SearchStatus.results;
      debugPrint('[SearchScreenController] final results: ${results.length}');
    } catch (e) {
      debugPrint('[SearchScreenController] ERROR: $e');
      errorMessage.value = e.toString();
      status.value = SearchStatus.error;
    }
  }

  List<Map<String, dynamic>> _aiRecommend(
    List<Map<String, dynamic>> courses,
    String query,
    List<String> interests,
    List<String> enrolledIds,
    List<String> savedIds,
    String level,
  ) {
    if (query.isEmpty && interests.isEmpty) {
      return _fallbackSearch(courses, query);
    }

    final results = <_ScoredCourse>[];

    for (final course in courses) {
      final score = AiRecommenderService.calculateScore(
        video: course,
        interests: interests,
        savedVideoIds: savedIds,
        enrolledVideoIds: enrolledIds,
        preferredLevel: level,
      );

      final queryScore = _queryMatchScore(course, query);
      final combined = score + queryScore;

      if (query.isEmpty || queryScore > 0) {
        results.add(_ScoredCourse(course, combined));
      }
    }

    results.sort((a, b) => b.score.compareTo(a.score));
    debugPrint('[SearchScreenController] AI scored ${results.length} courses');
    return results.map((r) => r.course).toList();
  }

  int _queryMatchScore(Map<String, dynamic> course, String query) {
    if (query.isEmpty) return 1;

    final q = query.toLowerCase();
    int score = 0;

    final title = (course['title'] ?? '').toString().toLowerCase();
    final instructor = (course['instructor'] ?? '').toString().toLowerCase();
    final category = (course['category'] ?? '').toString().toLowerCase();
    final description = (course['description'] ?? '').toString().toLowerCase();

    if (title.contains(q)) score += 10;
    if (title.startsWith(q)) score += 5;
    if (instructor.contains(q)) score += 8;
    if (category.contains(q)) score += 6;
    if (description.contains(q)) score += 4;

    final List<dynamic>? keywords = course['searchKeywords'] as List<dynamic>?;
    if (keywords != null) {
      for (final kw in keywords) {
        if (kw.toString().toLowerCase().contains(q)) {
          score += 7;
          break;
        }
      }
    }

    final titleWords = title.split(' ');
    for (final word in titleWords) {
      if (word == q) score += 3;
    }

    return score;
  }

  List<Map<String, dynamic>> _fallbackSearch(
    List<Map<String, dynamic>> courses,
    String query,
  ) {
    if (query.isEmpty) return courses;

    final q = query.toLowerCase();
    final results = <Map<String, dynamic>>[];

    for (final course in courses) {
      final title = (course['title'] ?? '').toString().toLowerCase();
      final instructor = (course['instructor'] ?? '').toString().toLowerCase();
      final category = (course['category'] ?? '').toString().toLowerCase();
      final description = (course['description'] ?? '').toString().toLowerCase();

      final matches = title.contains(q) ||
          instructor.contains(q) ||
          category.contains(q) ||
          description.contains(q);

      if (matches) {
        results.add(course);
      }
    }

    debugPrint('[SearchScreenController] fallback matched ${results.length} courses');
    return results;
  }

  void clearSearch() {
    queryController.clear();
    queryText.value = '';
    selectedCategory.value = '';
    results.clear();
    status.value = SearchStatus.idle;
    debugPrint('[SearchScreenController] search cleared');
  }
}

class _ScoredCourse {
  final Map<String, dynamic> course;
  final int score;
  _ScoredCourse(this.course, this.score);
}
