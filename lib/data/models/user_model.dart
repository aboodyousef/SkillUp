enum UserRole {
  student,
  teacher;

  String get value {
    switch (this) {
      case UserRole.student:
        return 'student';
      case UserRole.teacher:
        return 'teacher';
    }
  }

  static UserRole fromString(String value) {
    switch (value) {
      case 'teacher':
        return UserRole.teacher;
      default:
        return UserRole.student;
    }
  }
}
