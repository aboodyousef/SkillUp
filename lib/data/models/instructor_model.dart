class InstructorModel {
  final String id;
  final String name;
  final String photoUrl;
  final String bio;
  final double rating;
  final int studentsCount;
  final int coursesCount;

  InstructorModel({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.bio,
    required this.rating,
    required this.studentsCount,
    required this.coursesCount,
  });

  factory InstructorModel.fromJson(Map<String, dynamic> json) {
    return InstructorModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      photoUrl: (json['photoUrl'] ?? '').toString(),
      bio: (json['bio'] ?? '').toString(),
      rating: (json['rating'] ?? 0).toDouble(),
      studentsCount: (json['studentsCount'] ?? 0).toInt(),
      coursesCount: (json['coursesCount'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'photoUrl': photoUrl,
        'bio': bio,
        'rating': rating,
        'studentsCount': studentsCount,
        'coursesCount': coursesCount,
      };
}
