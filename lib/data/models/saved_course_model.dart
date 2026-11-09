class SavedCourseModel {
  final String id;
  final String courseId;
  final DateTime savedAt;

  SavedCourseModel({
    required this.id,
    required this.courseId,
    required this.savedAt,
  });

  factory SavedCourseModel.fromJson(Map<String, dynamic> json) {
    return SavedCourseModel(
      id: (json['id'] ?? '').toString(),
      courseId: (json['courseId'] ?? json['videoId'] ?? '').toString(),
      savedAt: json['savedAt'] is DateTime
          ? json['savedAt'] as DateTime
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'savedAt': savedAt.toIso8601String(),
    };
  }
}
