class ReviewModel {
  final String id;
  final String courseId;
  final String userName;
  final String userPhotoUrl;
  final double rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.courseId,
    required this.userName,
    required this.userPhotoUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: (json['id'] ?? '').toString(),
      courseId: (json['courseId'] ?? '').toString(),
      userName: (json['userName'] ?? '').toString(),
      userPhotoUrl: (json['userPhotoUrl'] ?? '').toString(),
      rating: (json['rating'] ?? 0).toDouble(),
      comment: (json['comment'] ?? '').toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
