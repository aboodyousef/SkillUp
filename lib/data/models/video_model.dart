import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skill_up/data/models/user_model.dart';

class VideoModel {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final String thumbnailUrl;
  final String subject;
  final String level;
  final String createdBy;
  final String createdByName;
  final UserRole createdByRole;
  final DateTime createdAt;

  VideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.subject,
    required this.level,
    required this.createdBy,
    required this.createdByName,
    this.createdByRole = UserRole.student,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'subject': subject,
      'level': level,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdByRole': createdByRole.value,
      'createdAt': createdAt,
    };
  }

  factory VideoModel.fromMap(String id, Map<String, dynamic> map) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      if (val is DateTime) return val;
      return DateTime.now();
    }

    return VideoModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      subject: map['subject'] ?? '',
      level: map['level'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdByName: map['createdByName'] ?? '',
      createdByRole: UserRole.fromString((map['createdByRole'] ?? 'student').toString()),
      createdAt: parseDate(map['createdAt']),
    );
  }
}
