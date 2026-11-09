import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import 'package:skill_up/data/mock/mock_config.dart';
import 'package:skill_up/data/mock/mock_data.dart';
import 'package:skill_up/data/models/user_model.dart';
import 'package:skill_up/data/themes/image_string.dart';

class UserController extends GetxController {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // Lazy getters avoid crash when Firebase is unavailable (e.g. Windows)

  final RxBool isReady = false.obs;

  final RxString uid = ''.obs;
  final RxString fullName = ''.obs;
  final RxString email = ''.obs;
  final Rx<UserRole> role = UserRole.student.obs;
  final RxString photoUrl = ''.obs;

  final RxList<String> interests = <String>[].obs;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _sub;

  @override
  void onInit() {
    super.onInit();
    if (useMockData) {
      _initMockUser();
    } else {
      _bindAuthListener();
    }
  }

  void _initMockUser() {
    final data = MockDataService.instance.mockUser;
    uid.value = data['uid'] as String;
    fullName.value = data['fullName'] as String;
    email.value = data['email'] as String;
    role.value = UserRole.fromString(data['role'] as String);
    photoUrl.value = (data['photoUrl'] as String?)?.isNotEmpty == true
        ? data['photoUrl'] as String
        : ImageStringProfile.userProfile;
    interests.assignAll((data['interests'] as List).cast<String>());
    isReady.value = true;
  }

  void switchToMockTeacher() {
    final data = MockDataService.instance.mockTeacherUser;
    uid.value = data['uid'] as String;
    fullName.value = data['fullName'] as String;
    email.value = data['email'] as String;
    role.value = UserRole.fromString(data['role'] as String);
    photoUrl.value = (data['photoUrl'] as String?)?.isNotEmpty == true
        ? data['photoUrl'] as String
        : ImageStringProfile.userProfile;
    interests.assignAll((data['interests'] as List).cast<String>());
    isReady.value = true;
  }

  void _bindAuthListener() {
    _auth.authStateChanges().listen((user) async {
      if (user == null) {
        _clear();
        return;
      }

      uid.value = user.uid;
      email.value = user.email ?? '';
      photoUrl.value = user.photoURL?.isNotEmpty == true
          ? user.photoURL!
          : ImageStringProfile.userProfile;

      await _ensureUserDoc(user);
      _listenToUserDoc(user.uid);
    });
  }

  Future<void> _ensureUserDoc(User user) async {
    final ref = _firestore.collection('users').doc(user.uid);
    final doc = await ref.get();

    if (!doc.exists) {
      await ref.set({
        'uid': user.uid,
        'fullName': user.displayName ?? '',
        'email': user.email ?? '',
        'role': UserRole.student.value,
        'photoUrl': user.photoURL?.isNotEmpty == true
            ? user.photoURL!
            : ImageStringProfile.userProfile,
        'interests': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  void _listenToUserDoc(String userId) {
    _sub?.cancel();
    isReady.value = false;

    _sub = _firestore.collection('users').doc(userId).snapshots().listen((doc) {
      final data = doc.data();
      if (data == null) {
        isReady.value = true;
        return;
      }

      fullName.value = (data['fullName'] ?? data['name'] ?? '').toString();
      role.value = UserRole.fromString((data['role'] ?? 'student').toString());
      final rawPhotoUrl = (data['photoUrl'] ?? '').toString();
      photoUrl.value = rawPhotoUrl.isNotEmpty
          ? rawPhotoUrl
          : ImageStringProfile.userProfile;

      final raw = data['interests'];
      if (raw is List) {
        interests.assignAll(raw.map((e) => e.toString()).toList());
      } else {
        interests.clear();
      }

      isReady.value = true;
    }, onError: (_) {
      isReady.value = true;
    });
  }

  void _clear() {
    uid.value = '';
    fullName.value = '';
    email.value = '';
    role.value = UserRole.student;
    photoUrl.value = ImageStringProfile.userProfile;
    interests.clear();
    isReady.value = false;
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
