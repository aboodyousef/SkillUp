import 'package:skill_up/data/mock/mock_data.dart';
import 'package:skill_up/data/models/enrollment_model.dart';

class MockEnrollmentRepository {
  final MockDataService _mock = MockDataService.instance;

  List<Map<String, dynamic>> getEnrollments() =>
      _mock.mockEnrollments;

  List<EnrollmentModel> getEnrollmentModels() =>
      _mock.enrollmentModels;

  bool isEnrolled(String courseId) =>
      _mock.mockEnrollments.any((e) => e['videoId'] == courseId);

  /// Simulate enrolling in a course (adds to in-memory list).
  void enroll(String courseId) {
    // In a real app this would persist; for mock it's a no-op
    // since we already include enrollment data statically.
  }

  List<Map<String, dynamic>> getMyCourses() {
    final result = <Map<String, dynamic>>[];
    for (final enroll in _mock.mockEnrollments) {
      final course = _mock.courseById(enroll['videoId'] as String);
      if (course != null) {
        result.add({
          ...course,
          'progress': enroll['progress'],
          'minutesText': enroll['minutesText'],
        });
      }
    }
    return result;
  }
}
