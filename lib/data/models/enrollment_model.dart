class EnrollmentModel {
  final String courseId;
  final int progress;
  final String minutesText;
  final DateTime enrolledAt;
  final DateTime updatedAt;

  EnrollmentModel({
    required this.courseId,
    required this.progress,
    required this.minutesText,
    required this.enrolledAt,
    required this.updatedAt,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    return EnrollmentModel(
      courseId: (json['videoId'] ?? json['courseId'] ?? '').toString(),
      progress: (json['progress'] ?? 0).toInt(),
      minutesText: (json['minutesText'] ?? '0% Done').toString(),
      enrolledAt: _parseDate(json['enrolledAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'videoId': courseId,
        'progress': progress,
        'minutesText': minutesText,
        'enrolledAt': enrolledAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  static DateTime _parseDate(dynamic val) {
    if (val == null) return DateTime.now();
    if (val is DateTime) return val;
    if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
    return DateTime.now();
  }
}
