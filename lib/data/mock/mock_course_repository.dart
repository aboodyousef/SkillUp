import 'package:skill_up/data/mock/mock_data.dart';
import 'package:skill_up/data/models/course_model.dart';

class MockCourseRepository {
  final MockDataService _mock = MockDataService.instance;

  List<Map<String, dynamic>> getAllCourses() =>
      _mock.allCourses;

  List<CourseModel> getAllCourseModels() =>
      _mock.courseModels;

  Map<String, dynamic>? getCourseById(String id) =>
      _mock.courseById(id);

  List<Map<String, dynamic>> getLessonsForCourse(String courseId) =>
      _mock.lessonsForCourse(courseId);

  List<Map<String, dynamic>> getReviewsForCourse(String courseId) =>
      _mock.mockReviewsForCourse(courseId);

  List<Map<String, dynamic>> getContinueWatching() =>
      _mock.getContinueWatching();

  List<Map<String, dynamic>> searchCourses(String query) =>
      _mock.searchCourses(query);

  /// Ranked trending: AI-sorted based on user interests
  List<Map<String, dynamic>> getTrending(List<String> userInterests) {
    final items = _mock.allCourses;
    final sorted = List<Map<String, dynamic>>.from(items);
    sorted.sort((a, b) {
      final aScore = _interestScore(a, userInterests);
      final bScore = _interestScore(b, userInterests);
      return bScore.compareTo(aScore);
    });
    return sorted;
  }

  int _interestScore(Map<String, dynamic> course, List<String> interests) {
    int score = 0;
    final category = (course['category'] ?? '').toString().toLowerCase();
    final title = (course['title'] ?? '').toString().toLowerCase();
    for (final interest in interests) {
      final i = interest.toLowerCase();
      if (category.contains(i)) score += 5;
      if (title.contains(i)) score += 1;
    }
    return score;
  }
}
