class LessonModel {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final String videoUrl;
  final String thumbnailUrl;
  final int durationSeconds;
  final int order;

  LessonModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.durationSeconds,
    required this.order,
  });

  String get durationFormatted {
    final h = durationSeconds ~/ 3600;
    final m = (durationSeconds % 3600) ~/ 60;
    final s = durationSeconds % 60;
    if (h > 0) {
      return '${h}h ${m}m';
    }
    return '$m:${s.toString().padLeft(2, '0')} mins';
  }

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: (json['id'] ?? '').toString(),
      courseId: (json['courseId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      videoUrl: (json['videoUrl'] ?? '').toString(),
      thumbnailUrl: (json['thumbnailUrl'] ?? '').toString(),
      durationSeconds: (json['durationSeconds'] ?? 0).toInt(),
      order: (json['order'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'durationSeconds': durationSeconds,
      'order': order,
    };
  }
}
