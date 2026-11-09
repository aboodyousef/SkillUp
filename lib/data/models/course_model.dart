class CourseModel {
  final String id;
  final String title;
  final String instructor;
  final String category;
  final String imageUrl;
  final String coverImage;
  final double rating;
  final double progress;

  CourseModel({
    required this.id,
    required this.title,
    required this.instructor,
    required this.category,
    required this.imageUrl,
    this.coverImage = '',
    required this.rating,
    required this.progress,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      instructor: (json['instructor'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
      coverImage: (json['coverImage'] ?? json['imageUrl'] ?? '').toString(),
      rating: (json['rating'] ?? 0).toDouble(),
      progress: (json['progress'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'instructor': instructor,
      'category': category,
      'imageUrl': imageUrl,
      'coverImage': coverImage,
      'rating': rating,
      'progress': progress,
    };
  }
}
