import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:skill_up/data/models/course_model.dart';

class SeeAllController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  final List<Map<String, dynamic>> _allRaw;
  final List<CourseModel> _allModels;

  SeeAllController({
    required List<Map<String, dynamic>> rawData,
    required List<CourseModel> modelData,
  })  : _allRaw = rawData,
        _allModels = modelData;

  List<Map<String, dynamic>> get allRaw => List.unmodifiable(_allRaw);
  List<CourseModel> get allModels => List.unmodifiable(_allModels);

  List<Map<String, dynamic>> get filteredRaw {
    final q = searchQuery.value;
    if (q.isEmpty) return _allRaw;
    return _allRaw.where((c) {
      final title = (c['title'] ?? '').toString().toLowerCase();
      final instructor = (c['instructor'] ?? '').toString().toLowerCase();
      final category = (c['category'] ?? '').toString().toLowerCase();
      return title.contains(q) ||
          instructor.contains(q) ||
          category.contains(q);
    }).toList();
  }

  List<CourseModel> get filteredModels {
    final q = searchQuery.value;
    if (q.isEmpty) return _allModels;
    return _allModels.where((c) {
      final title = c.title.toLowerCase();
      final instructor = c.instructor.toLowerCase();
      final category = c.category.toLowerCase();
      return title.contains(q) ||
          instructor.contains(q) ||
          category.contains(q);
    }).toList();
  }

  void onSearchChanged(String v) {
    searchQuery.value = v.trim().toLowerCase();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
