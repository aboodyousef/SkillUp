import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show rootBundle;

import 'package:skill_up/data/models/course_model.dart';
import 'package:skill_up/data/models/instructor_model.dart';
import 'package:skill_up/data/models/category_model.dart';
import 'package:skill_up/data/models/enrollment_model.dart';

const _courseThemes = <Map<String, dynamic>>[
  {
    'title': 'Java Programming',
    'description': 'Master Java programming from fundamentals to advanced concepts. Learn OOP, collections, multithreading, and build robust applications.',
    'description2': 'Dive into Java streams, lambda expressions, and functional programming patterns.',
    'description3': 'Build a complete enterprise-grade Java application with modern best practices.',
  },
  {
    'title': 'Object-Oriented Programming (OOP)',
    'description': 'Understand the core principles of object-oriented programming: encapsulation, inheritance, polymorphism, and abstraction.',
    'description2': 'Apply design patterns and SOLID principles to write maintainable and scalable code.',
    'description3': 'Implement a full OOP project from scratch using industry-standard patterns.',
  },
  {
    'title': 'C Programming',
    'description': 'Learn C programming from the ground up. Master pointers, memory management, data structures, and system-level programming.',
    'description2': 'Explore advanced C concepts like dynamic memory allocation, file I/O, and preprocessor directives.',
    'description3': 'Build a complete C application with efficient memory management and data structures.',
  },
  {
    'title': 'Flutter Fundamentals',
    'description': 'Learn the foundations of Flutter from scratch. Build your first cross-platform mobile app with Dart and Flutter\'s powerful widget system.',
    'description2': 'Dive deeper into Flutter layouts, state management, and navigation patterns.',
    'description3': 'Complete a real-world project applying everything you learned.',
  },
  {
    'title': 'Dart Programming Mastery',
    'description': 'Master Dart programming language fundamentals including types, functions, collections, and async programming.',
    'description2': 'Explore advanced Dart features like streams, generics, and metaprogramming.',
    'description3': 'Build a command-line tool using advanced Dart patterns.',
  },
  {
    'title': 'UI/UX Design Principles',
    'description': 'Understand the core principles of user interface and user experience design for mobile applications.',
    'description2': 'Learn wireframing, prototyping, and design systems for consistent UIs.',
  },
  {
    'title': 'Firebase & Backend Integration',
    'description': 'Connect your Flutter apps to Firebase services including Authentication, Firestore, and Cloud Storage.',
    'description2': 'Implement real-time data sync, push notifications, and serverless functions.',
  },
  {
    'title': 'Advanced Flutter Layouts',
    'description': 'Master complex layouts, custom painters, animations, and responsive design patterns.',
    'description2': 'Build adaptive UIs that work beautifully on mobile, tablet, and desktop.',
    'description3': 'Create a production-grade dashboard with advanced interaction design.',
  },
  {
    'title': 'Mobile Development Basics',
    'description': 'Start your mobile development journey with core concepts, platform fundamentals, and best practices.',
    'description2': 'Explore native features, sensors, and device capabilities.',
  },
  {
    'title': 'Cyber Security Essentials',
    'description': 'Understand modern threats, vulnerabilities, and defense strategies for securing applications.',
    'description2': 'Implement encryption, secure authentication, and penetration testing.',
  },
  {
    'title': 'Data Science with Python',
    'description': 'Analyze data, build predictive models, and visualize insights using Python and modern ML libraries.',
    'description2': 'Learn statistical analysis, feature engineering, and model deployment.',
  },
  {
    'title': 'iOS Development with Swift',
    'description': 'Build beautiful iOS apps from scratch using Swift and SwiftUI.',
    'description2': 'Master UIKit, Core Data, and App Store deployment workflows.',
  },
  {
    'title': 'Machine Learning Fundamentals',
    'description': 'Understand supervised and unsupervised learning algorithms with hands-on projects.',
    'description2': 'Build and deploy ML models using TensorFlow and scikit-learn.',
  },
  {
    'title': 'React Native for Mobile',
    'description': 'Develop cross-platform mobile apps using React Native and JavaScript.',
    'description2': 'Master navigation, state management, and native module integration.',
  },
  {
    'title': 'Cloud Architecture & DevOps',
    'description': 'Learn cloud infrastructure, CI/CD pipelines, Docker, and Kubernetes.',
    'description2': 'Design scalable microservices and automated deployment strategies.',
  },
  {
    'title': 'GraphQL & API Design',
    'description': 'Build modern APIs with GraphQL: schema design, resolvers, subscriptions, and security.',
    'description2': 'Integrate GraphQL with React, Flutter, and Node.js backends.',
  },
  {
    'title': 'Game Development with Unity',
    'description': 'Create 2D and 3D games using Unity and C# programming.',
    'description2': 'Learn physics, animations, AI behaviors, and game optimization.',
  },
  {
    'title': 'Blockchain & Web3 Development',
    'description': 'Understand blockchain fundamentals, smart contracts, and decentralized applications.',
    'description2': 'Build and deploy Solidity contracts on Ethereum and Polygon.',
  },
];

const _lessonTitles = [
  ['Java Basics: Syntax & Data Types', 'OOP in Java: Classes & Inheritance', 'Advanced Java: Streams & Collections'],
  ['Encapsulation & Inheritance', 'Polymorphism & Abstraction', 'Design Patterns in Practice'],
  ['C Basics: Pointers & Memory', 'Data Structures in C', 'File I/O & System Programming'],
  ['Introduction to Flutter & Widgets', 'Layouts, Navigation & State', 'Capstone: Build a Todo App'],
  ['Dart Basics: Types & Control Flow', 'Async Dart: Futures & Streams', 'Advanced Dart: Generics & Isolates'],
  ['Design Thinking & User Research', 'Wireframing & Prototyping'],
  ['Firebase Auth & Firestore Setup', 'Cloud Functions & Notifications'],
  ['Advanced Widgets & Custom Painters', 'Responsive Layouts', 'Animation Mastery'],
  ['Platform Fundamentals', 'Native Features & Sensors'],
  ['Threat Modeling & Risk Analysis', 'Encryption & Secure Auth', 'Penetration Testing'],
  ['Python for Data Analysis', 'Statistical Modeling', 'ML Model Deployment'],
  ['Swift Basics & SwiftUI', 'UIKit & Core Data', 'App Store Publishing'],
  ['Supervised Learning Algorithms', 'Unsupervised Learning & Clustering', 'Model Deployment'],
  ['React Native Setup & JSX', 'Navigation & State Management', 'Native Modules'],
  ['Cloud Infrastructure & Docker', 'CI/CD Pipelines & Kubernetes'],
  ['GraphQL Schema Design', 'Resolvers & Subscriptions', 'API Security'],
  ['Unity Basics & C#', 'Physics & Animation', 'AI & Game Optimization'],
  ['Blockchain Fundamentals', 'Solidity & Smart Contracts', 'dApp Development'],
];

const _instructorData = [
  {'name': 'Mohammad Youssef', 'bio': 'Java & OOP Expert & Senior Instructor'},
  {'name': 'Lara Hassan', 'bio': 'Systems Programming & C Language Expert'},
  {'name': 'Ahmed Ali', 'bio': 'Senior Flutter Developer & Instructor'},
  {'name': 'Sara Khaled', 'bio': 'UI/UX Designer & Frontend Expert'},
  {'name': 'Nadia Ibrahim', 'bio': 'Data Scientist & ML Engineer'},
  {'name': 'Omar Khalil', 'bio': 'Cloud Architect & Firebase Specialist'},
  {'name': 'Hussein Al-Masri', 'bio': 'iOS Developer & Swift Instructor'},
  {'name': 'Rana Al-Zoubi', 'bio': 'DevOps Engineer & Cloud Architect'},
];

const _categoryNames = [
  'Java', 'OOP', 'C Programming', 'Flutter', 'Dart', 'UI/UX',
  'Firebase', 'Mobile Development', 'Web Development',
  'Cyber Security', 'Data Science', 'iOS', 'Machine Learning',
  'React Native', 'Cloud Computing', 'API Design',
  'Game Development', 'Blockchain',
];

const _defaultCover = 'assets/course_images/general.png';

const _courseImageMap = <String, String>{
  'Java Programming': 'assets/course_images/java.png',
  'Object-Oriented Programming (OOP)': 'assets/course_images/oop.png',
  'C Programming': 'assets/course_images/c.png',
  'Flutter Fundamentals': 'assets/course_images/flutter.png',
  'Data Science with Python': 'assets/course_images/python.png',
};

String _imageForCourse(String title) =>
    _courseImageMap[title] ?? _defaultCover;

class MockDataService {
  MockDataService._();
  static final MockDataService instance = MockDataService._();

  Map<String, dynamic> get mockUser => {
        'uid': 'mock-user-001',
        'fullName': 'Abdallah',
        'email': 'abdallah@skillup.app',
        'role': 'student',
        'photoUrl': 'assets/images/png/userProfile.png',
        'interests': <String>[
          'flutter', 'dart', 'ui/ux', 'mobile', 'cyber security'
        ],
        'tagLine': 'Learn something new every day',
        'about':
            'A passionate student exploring the world of mobile development and design.',
        'skills': <String>['Flutter', 'UI/UX', 'Figma', 'Dart', 'Firebase'],
        'paymentMethod': 'paypal',
        'createdAt': DateTime.now().subtract(const Duration(days: 30)),
        'provider': 'password',
      };

  Map<String, dynamic> get mockTeacherUser => {
        'uid': 'mock-teacher-001',
        'fullName': 'Ahmed Ali',
        'email': 'ahmed@skillup.app',
        'role': 'teacher',
        'photoUrl': 'assets/images/png/userProfile.png',
        'interests': <String>[
          'flutter', 'dart', 'teaching', 'mobile', 'backend'
        ],
        'tagLine': 'Empowering students through code',
        'about':
            'Senior Flutter developer with 5+ years of experience teaching mobile development.',
        'skills': <String>[
          'Flutter', 'Firebase', 'Dart', 'State Management', 'API Design'
        ],
        'paymentMethod': 'mastercard',
        'createdAt': DateTime.now().subtract(const Duration(days: 90)),
        'provider': 'password',
      };

  // ---------------------------------------------------------------------------
  // Course cover images mapped statically
  // ---------------------------------------------------------------------------
  String coverForCourseTitle(String title) => _imageForCourse(title);

  // ---------------------------------------------------------------------------
  // Instructors
  // ---------------------------------------------------------------------------
  List<InstructorModel> get instructorModels =>
      _instructorData.asMap().entries.map((e) {
        final i = e.value;
        return InstructorModel(
          id: 'inst-00${e.key + 1}',
          name: i['name'] as String,
          photoUrl: 'assets/images/png/userProfile.png',
          bio: i['bio'] as String,
          rating: 4.5 + (e.key % 5) * 0.1,
          studentsCount: 500 + e.key * 300,
          coursesCount: 2 + e.key,
        );
      }).toList();

  Map<String, dynamic> instructorById(String id) {
    final idx = int.tryParse(id.replaceAll('inst-00', '')) ?? 0;
    final inst = idx >= 1 && idx <= _instructorData.length
        ? _instructorData[idx - 1]
        : _instructorData[0];
    return {
      'id': id,
      'name': inst['name'],
      'photoUrl': 'assets/images/png/userProfile.png',
      'bio': inst['bio'],
      'rating': 4.5 + ((idx - 1) % 5) * 0.1,
      'studentsCount': 500 + (idx - 1) * 300,
      'coursesCount': 2 + (idx - 1),
    };
  }

  // ---------------------------------------------------------------------------
  // Categories
  // ---------------------------------------------------------------------------
  List<CategoryModel> get categoryModels =>
      _categoryNames.asMap().entries.map((e) => CategoryModel(
            id: 'cat-${(e.key + 1).toString().padLeft(2, '0')}',
            name: e.value,
            icon: _categoryIcon(e.value),
          )).toList();

  static String _categoryIcon(String name) {
    const icons = {
      'Java': 'code',
      'OOP': 'layers',
      'C Programming': 'terminal',
      'Flutter': 'flutter_dash',
      'Dart': 'code',
      'UI/UX': 'palette',
      'Firebase': 'storage',
      'Mobile Development': 'smartphone',
      'Web Development': 'language',
      'Cyber Security': 'security',
      'Data Science': 'analytics',
      'iOS': 'apple',
      'Machine Learning': 'psychology',
      'React Native': 'javascript',
      'Cloud Computing': 'cloud',
      'API Design': 'api',
      'Game Development': 'sports_esports',
      'Blockchain': 'currency_bitcoin',
    };
    return icons[name] ?? 'school';
  }

  List<String> get skillCategories =>
      categoryModels.map((c) => c.name).toList();

  // ---------------------------------------------------------------------------
  // Raw course / lesson storage
  // ---------------------------------------------------------------------------
  final List<Map<String, dynamic>> _scannedVideoCourses = [];
  final List<Map<String, dynamic>> _scannedVideoLessons = [];

  // ---------------------------------------------------------------------------
  // Scan video files + assign course covers
  // ---------------------------------------------------------------------------
  Future<void> scanVideoAssets() async {
    _scannedVideoCourses.clear();
    _scannedVideoLessons.clear();

    try {
      final manifestJson = await rootBundle.loadString('AssetManifest.json');
      final manifest = json.decode(manifestJson) as Map<String, dynamic>;

      final allVideoFiles = manifest.keys
          .where((key) => key.startsWith('assets/videos/'))
          .where((key) =>
              key.endsWith('.mp4') || key.endsWith('.mov') || key.endsWith('.avi') ||
              key.endsWith('.mkv') || key.endsWith('.webm'))
          .toList()
        ..sort();

      // Prefer lesson_XX.mp4 files (clean names without spaces)
      final lessonFiles = allVideoFiles
          .where((f) => f.startsWith('assets/videos/lesson_'))
          .toList();
      final whatsappFiles = allVideoFiles
          .where((f) => !f.startsWith('assets/videos/lesson_'))
          .toList();

      final videoFiles = lessonFiles.isNotEmpty ? lessonFiles : whatsappFiles;

      debugPrint('MockData: detected ${videoFiles.length} video files');
      for (final f in videoFiles) {
        debugPrint('MockData: video -> $f');
      }

      if (videoFiles.isEmpty) {
        _buildDefaultCourses();
        return;
      }

      final groups = _groupFiles(videoFiles);

      for (int g = 0; g < groups.length; g++) {
        _addCourseFromGroup(g, groups[g], videoFiles.isNotEmpty);
      }
    } catch (_) {
      _buildDefaultCourses();
    }
  }

  void _addCourseFromGroup(int g, List<String> groupFiles, bool hasVideos) {
    final theme = _courseThemes[g % _courseThemes.length];
    final title = theme['title'] as String;
    final courseId = 'course-${g + 1}';
    final catName = _categoryNames[g % _categoryNames.length];
    final instructorData = _instructorData[g % _instructorData.length];
    final cover = coverForCourseTitle(title);
    final rating = (4.5 + (g % 5) * 0.1).clamp(3.5, 5.0);
    final students = 200 + g * 180;
    final hours = groupFiles.length * 3.5;

    final courseMap = <String, dynamic>{
      'id': courseId,
      'title': theme['title'],
      'instructor': instructorData['name'],
      'category': catName,
      'imageUrl': cover,
      'coverImage': cover,
      'rating': rating,
      'progress': g == 0 ? 0.65 : (g == 1 ? 0.3 : 0.0),
      'videoUrl': groupFiles.first,
      'description': theme['description'],
      'level': ['Beginner', 'Intermediate', 'Advanced'][g % 3],
      'price': 29.99 + g * 10.0,
      'students': students,
      'hours': hours,
      'reviewsCount': (30 + g * 15),
      'minutesText': g == 0 ? '65% Done' : (g == 1 ? '30% Done' : 'Not Started'),
      'searchKeywords': [
        ...theme['title'].toString().toLowerCase().split(' '),
        catName.toLowerCase(),
      ],
    };

    final lessons = <Map<String, dynamic>>[];
    final lessonPool = _lessonTitles[g % _lessonTitles.length];

    for (int l = 0; l < groupFiles.length; l++) {
      final descKey = l == 0 ? 'description' : l == 1 ? 'description2' : 'description3';
      final lessonTitle = l < lessonPool.length
          ? lessonPool[l]
          : '${theme['title']} - Part ${l + 1}';
      final lessonDesc = theme[descKey] as String? ??
          'Detailed lesson covering key concepts in ${theme['title']}.';

      lessons.add({
        'id': '$courseId-lesson-${l + 1}',
        'courseId': courseId,
        'title': lessonTitle,
        'description': lessonDesc,
        'videoUrl': groupFiles[l],
        'thumbnailUrl': cover,
        'coverImage': cover,
        'durationSeconds': (480 + l * 120 + g * 30),
        'order': l + 1,
      });
    }

    courseMap['lessons'] = lessons;
    _scannedVideoCourses.add(courseMap);
    _scannedVideoLessons.addAll(lessons);
  }

  List<List<String>> _groupFiles(List<String> files) {
    if (files.length <= 3) return [files];
    final groups = <List<String>>[];
    int i = 0;
    while (i < files.length) {
      final remaining = files.length - i;
      int groupSize;
      if (remaining <= 4) {
        groupSize = remaining <= 2 ? remaining : 2;
      } else if (remaining == 5) {
        groupSize = 3;
      } else {
        groupSize = 3;
      }
      groups.add(files.sublist(i, i + groupSize));
      i += groupSize;
    }
    return groups;
  }

  // ---------------------------------------------------------------------------
  // Default courses – each gets a unique cover from the pool
  // ---------------------------------------------------------------------------
  void _buildDefaultCourses() {
    _scannedVideoCourses.clear();
    _scannedVideoLessons.clear();

    final courseCount = _courseThemes.length;

    for (int i = 0; i < courseCount; i++) {
      final theme = _courseThemes[i % _courseThemes.length];
      final title = theme['title'] as String;
      final catName = _categoryNames[i % _categoryNames.length];
      final inst = _instructorData[i % _instructorData.length];
      final cover = coverForCourseTitle(title);
      final rating = (4.5 + (i % 5) * 0.1).clamp(3.5, 5.0);
      final progress = i == 0 ? 0.65 : (i == 1 ? 0.3 : 0.0);
      final students = 200 + i * 180;
      final hours = 8.0 + (i % 5) * 2.5;
      final reviews = 30 + i * 15;
      final price = 29.99 + i * 10.0;

      final courseId = 'course-${i + 1}';

      final courseMap = <String, dynamic>{
        'id': courseId,
        'title': theme['title'],
        'instructor': inst['name'],
        'category': catName,
        'imageUrl': cover,
        'coverImage': cover,
        'rating': rating,
        'progress': progress,
        'videoUrl': 'assets/videos/sample_${i + 1}.mp4',
        'description': theme['description'],
        'level': ['Beginner', 'Intermediate', 'Advanced'][i % 3],
        'price': price,
        'students': students,
        'hours': hours,
        'reviewsCount': reviews,
        'minutesText': progress > 0 ? '${(progress * 100).toInt()}% Done' : 'Not Started',
        'searchKeywords': [
          ...theme['title'].toString().toLowerCase().split(' '),
          catName.toLowerCase(),
        ],
      };

      final lessons = <Map<String, dynamic>>[];
      final lessonPool = _lessonTitles[i % _lessonTitles.length];
      final lessonCount = lessonPool.length;

      for (int li = 0; li < lessonCount; li++) {
        lessons.add({
          'id': '$courseId-lesson-${li + 1}',
          'courseId': courseId,
          'title': lessonPool[li],
          'description': 'Detailed lesson covering key topics in ${theme['title']}.',
          'videoUrl': 'assets/videos/sample_${i + 1}.mp4',
          'thumbnailUrl': cover,
          'coverImage': cover,
          'durationSeconds': 600 + li * 120 + i * 30,
          'order': li + 1,
        });
      }

      courseMap['lessons'] = lessons;
      _scannedVideoCourses.add(courseMap);
      _scannedVideoLessons.addAll(lessons);
    }
  }

  // ---------------------------------------------------------------------------
  // Public accessors
  // ---------------------------------------------------------------------------
  List<Map<String, dynamic>> get allCourses =>
      List.unmodifiable(_scannedVideoCourses);

  List<Map<String, dynamic>> get allLessons =>
      List.unmodifiable(_scannedVideoLessons);

  List<Map<String, dynamic>> lessonsForCourse(String courseId) {
    return _scannedVideoLessons
        .where((l) => l['courseId'] == courseId)
        .map((l) => Map<String, dynamic>.from(l))
        .toList()
      ..sort((a, b) => (a['order'] as int).compareTo(b['order'] as int));
  }

  Map<String, dynamic>? courseById(String id) {
    try {
      return Map<String, dynamic>.from(
          _scannedVideoCourses.firstWhere((c) => c['id'] == id));
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Enrollments
  // ---------------------------------------------------------------------------
  List<Map<String, dynamic>> get mockEnrollments {
    final courses = _scannedVideoCourses;
    if (courses.isEmpty) return [];
    return [
      {'videoId': courses[0]['id'], 'progress': 65, 'minutesText': '65% Done', 'enrolledAt': DateTime.now().subtract(const Duration(days: 14)), 'updatedAt': DateTime.now().subtract(const Duration(days: 1))},
      if (courses.length > 1) {'videoId': courses[1]['id'], 'progress': 30, 'minutesText': '30% Done', 'enrolledAt': DateTime.now().subtract(const Duration(days: 7)), 'updatedAt': DateTime.now().subtract(const Duration(hours: 12))},
      if (courses.length > 2) {'videoId': courses[2]['id'], 'progress': 40, 'minutesText': '40% Done', 'enrolledAt': DateTime.now().subtract(const Duration(days: 21)), 'updatedAt': DateTime.now().subtract(const Duration(days: 3))},
      if (courses.length > 3) {'videoId': courses[3]['id'], 'progress': 20, 'minutesText': '20% Done', 'enrolledAt': DateTime.now().subtract(const Duration(days: 5)), 'updatedAt': DateTime.now().subtract(const Duration(days: 2))},
      if (courses.length > 4) {'videoId': courses[4]['id'], 'progress': 10, 'minutesText': '10% Done', 'enrolledAt': DateTime.now().subtract(const Duration(days: 30)), 'updatedAt': DateTime.now().subtract(const Duration(days: 25))},
    ];
  }

  List<EnrollmentModel> get enrollmentModels =>
      mockEnrollments.map((e) => EnrollmentModel.fromJson(e)).toList();

  List<Map<String, dynamic>> get savedVideoIds {
    final courses = _scannedVideoCourses;
    if (courses.isEmpty) return [];
    final ids = <Map<String, dynamic>>[];
    if (courses.length > 6) ids.add({'videoId': courses[6]['id']});
    if (courses.length > 7) ids.add({'videoId': courses[7]['id']});
    return ids;
  }

  // ---------------------------------------------------------------------------
  // Notifications
  // ---------------------------------------------------------------------------
  List<Map<String, dynamic>> get mockNotifications => [
    {'id': 'notif-001', 'title': 'Welcome to SkillUp!', 'body': 'Start your learning journey today. Explore our courses and begin building new skills.', 'type': 'INFO', 'isRead': true, 'createdAt': DateTime.now().subtract(const Duration(days: 30))},
    {'id': 'notif-002', 'title': 'New Course Available', 'body': 'A new Flutter course is now available. Enroll now and master complex UI patterns.', 'type': 'COURSE', 'videoId': 'course-002', 'isRead': false, 'createdAt': DateTime.now().subtract(const Duration(days: 7))},
    {'id': 'notif-003', 'title': 'Course Update', 'body': 'Flutter Fundamentals has been updated with 3 new lessons on state management.', 'type': 'COURSE', 'videoId': 'course-001', 'isRead': false, 'createdAt': DateTime.now().subtract(const Duration(days: 2))},
    {'id': 'notif-004', 'title': 'Achievement Unlocked', 'body': 'Congratulations! You completed 65% of Flutter Fundamentals. Keep going!', 'type': 'ACHIEVEMENT', 'isRead': false, 'createdAt': DateTime.now().subtract(const Duration(days: 1))},
    {'id': 'notif-005', 'title': 'Reminder', 'body': "You haven't studied in 3 days. Come back and continue your learning journey!", 'type': 'REMINDER', 'isRead': false, 'createdAt': DateTime.now().subtract(const Duration(hours: 6))},
  ];

  // ---------------------------------------------------------------------------
  // Reviews
  // ---------------------------------------------------------------------------
  List<Map<String, dynamic>> mockReviewsForCourse(String courseId) {
    final index = int.tryParse(courseId.split('-').last) ?? 0;
    return [
      {'id': 'rev-$courseId-1', 'courseId': courseId, 'userName': 'Mariam Alawneh', 'userPhotoUrl': 'assets/images/png/userProfile.png', 'rating': 5.0, 'comment': 'Amazing course! The instructor explained everything clearly and the projects were very practical.', 'createdAt': DateTime.now().subtract(const Duration(days: 3)).toIso8601String()},
      {'id': 'rev-$courseId-2', 'courseId': courseId, 'userName': 'Khaled Hasan', 'userPhotoUrl': 'assets/images/png/userProfile.png', 'rating': 4.0, 'comment': 'Good content but could use more real-world examples.', 'createdAt': DateTime.now().subtract(const Duration(days: 10)).toIso8601String()},
      {'id': 'rev-$courseId-3', 'courseId': courseId, 'userName': 'Noor Saleh', 'userPhotoUrl': 'assets/images/png/userProfile.png', 'rating': (4.5 + (index % 2) * 0.5).clamp(3.0, 5.0), 'comment': 'I learned a lot from this course. The exercises helped reinforce the concepts.', 'createdAt': DateTime.now().subtract(const Duration(days: 15)).toIso8601String()},
    ];
  }

  // ---------------------------------------------------------------------------
  // Certificates
  // ---------------------------------------------------------------------------
  List<Map<String, dynamic>> get mockCertificates {
    final courses = _scannedVideoCourses;
    if (courses.isEmpty) return [];
    return [
      {'title': courses[0]['title'], 'issuer': 'SkillUp Academy', 'date': DateTime.now().subtract(const Duration(days: 15)).toIso8601String().split('T').first},
      if (courses.length > 1) {'title': courses[1]['title'], 'issuer': 'SkillUp Academy', 'date': DateTime.now().subtract(const Duration(days: 30)).toIso8601String().split('T').first},
    ];
  }

  // ---------------------------------------------------------------------------
  // Continue Watching
  // ---------------------------------------------------------------------------
  List<Map<String, dynamic>> getContinueWatching() {
    final result = <Map<String, dynamic>>[];
    for (final enroll in mockEnrollments) {
      final course = courseById(enroll['videoId'] as String);
      if (course != null) {
        final int p = enroll['progress'] as int;
        final double normalized = (p.clamp(0, 100)) / 100.0;
        course['progress'] = normalized;
        course['minutesText'] = enroll['minutesText'];
        result.add(course);
      }
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  // CourseModel conversion
  // ---------------------------------------------------------------------------
  List<CourseModel> get courseModels =>
      allCourses.map((c) => CourseModel.fromJson(c)).toList();

  // ---------------------------------------------------------------------------
  // Search
  // ---------------------------------------------------------------------------
  List<Map<String, dynamic>> searchCourses(String query) {
    if (query.isEmpty) return allCourses;
    final q = query.toLowerCase();
    return allCourses.where((c) {
      final title = (c['title'] ?? '').toString().toLowerCase();
      final instructor = (c['instructor'] ?? '').toString().toLowerCase();
      final category = (c['category'] ?? '').toString().toLowerCase();
      return title.contains(q) || instructor.contains(q) || category.contains(q);
    }).toList();
  }
}
