import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import 'package:skill_up/data/mock/mock_config.dart';
import 'package:skill_up/data/mock/mock_data.dart';
import 'package:skill_up/data/models/user_model.dart';
import 'package:skill_up/data/themes/image_string.dart';

class ProfileController extends GetxController {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseStorage get _storage => FirebaseStorage.instance;
  final _picker = ImagePicker();

  final RxBool isFetchingProfile = true.obs;
  final RxBool isUploadingPhoto = false.obs;

  final userName = ''.obs;
  final tagLine = ''.obs;
  final aboutText = ''.obs;
  final skills = <String>[].obs;

  final Rx<UserRole> role = UserRole.student.obs;
  final paymentMethod = ''.obs;
  final RxString photoUrl = ''.obs;

  final List<Map<String, String>> menuItems = const [
    {"icon": "account", "title": "accountInfo"},
    {"icon": "edit", "title": "editProfile"},
    {"icon": "payment", "title": "paymentOption"},
    {"icon": "certificate", "title": "myCertificates"},
    {"icon": "terms", "title": "termsConditions"},
    {"icon": "help", "title": "helpCenter"},
    {"icon": "invite", "title": "inviteFriends"},
    {"icon": "logout", "title": "logOut"},
  ];

  StreamSubscription<User?>? _authSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _profileSub;

  String? get uid => _auth.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();

    if (useMockData) {
      _initMockProfile();
      return;
    }

    _authSub = _auth.authStateChanges().listen((user) {
      _profileSub?.cancel();

      if (user == null) {
        _clear();
        isFetchingProfile.value = false;
        return;
      }

      isFetchingProfile.value = true;
      _listenToProfile(user.uid);
    });
  }

  void _initMockProfile() {
    final data = MockDataService.instance.mockUser;
    userName.value = data['fullName'] as String;
    tagLine.value = data['tagLine'] as String;
    aboutText.value = data['about'] as String;
    skills.assignAll((data['skills'] as List).cast<String>());
    role.value = UserRole.fromString(data['role'] as String);
    paymentMethod.value = data['paymentMethod'] as String;
    final raw = data['photoUrl'] as String? ?? '';
    photoUrl.value = raw.isNotEmpty ? raw : ImageStringProfile.userProfile;
    isFetchingProfile.value = false;
  }

  void _listenToProfile(String userId) {
    _profileSub = _firestore.collection('users').doc(userId).snapshots().listen(
      (doc) async {
        if (!doc.exists) {
          await _firestore.collection('users').doc(userId).set({
            'uid': userId,
            'fullName': _auth.currentUser?.displayName ?? '',
            'email': _auth.currentUser?.email ?? '',
            'role': 'student',
            'photoUrl': _auth.currentUser?.photoURL?.isNotEmpty == true
                ? _auth.currentUser!.photoURL!
                : ImageStringProfile.userProfile,
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          return;
        }

        final data = doc.data() ?? {};

        userName.value = (data['fullName'] ?? data['name'] ?? '').toString();
        tagLine.value = (data['tagLine'] ?? '').toString();
        aboutText.value = (data['about'] ?? '').toString();

        final rawSkills = data['skills'];
        if (rawSkills is List) {
          skills.assignAll(rawSkills.map((e) => e.toString()).toList());
        } else {
          skills.clear();
        }

        role.value = UserRole.fromString((data['role'] ?? 'student').toString());
        paymentMethod.value = (data['paymentMethod'] ?? '').toString();
        final rawPhotoUrl = (data['photoUrl'] ?? '').toString();
        photoUrl.value = rawPhotoUrl.isNotEmpty
            ? rawPhotoUrl
            : ImageStringProfile.userProfile;

        isFetchingProfile.value = false;
      },
      onError: (_) => isFetchingProfile.value = false,
    );
  }

  void _clear() {
    userName.value = '';
    tagLine.value = '';
    aboutText.value = '';
    skills.clear();
    role.value = UserRole.student;
    paymentMethod.value = '';
    photoUrl.value = ImageStringProfile.userProfile;
  }

  @override
  void onClose() {
    _profileSub?.cancel();
    _authSub?.cancel();
    super.onClose();
  }

  // ----------------- Getters -----------------
  String get roleLabel => role.value == UserRole.teacher ? 'roleTeacher'.tr : 'roleStudent'.tr;

  String get paymentMethodLabel {
    switch (paymentMethod.value) {
      case 'paypal':
        return 'paypal'.tr;
      case 'apple_pay':
        return 'applePay'.tr;
      case 'google_pay':
        return 'googlePay'.tr;
      case 'mastercard':
        return 'mastercard'.tr;
      default:
        return 'notSet'.tr;
    }
  }

  // ----------------- Actions -----------------
  Future<void> saveProfile({
    required String name,
    required String tag,
    required String about,
  }) async {
    if (useMockData) {
      userName.value = name;
      tagLine.value = tag;
      aboutText.value = about;
      return;
    }

    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return;

    await _firestore.collection('users').doc(currentUid).set({
      'fullName': name,
      'name': name,
      'tagLine': tag,
      'about': about,
      'skills': skills.map((e) => e.toString()).toList(),
    }, SetOptions(merge: true));

    await _auth.currentUser?.updateDisplayName(name);
  }

  Future<void> changeProfileImage() async {
    if (useMockData) {
      Get.snackbar('mockMode'.tr, 'imageUploadSimulated'.tr,
          snackPosition: SnackPosition.BOTTOM);
      photoUrl.value = ImageStringProfile.userProfile;
      return;
    }

    if (uid == null) return;

    try {
      isUploadingPhoto.value = true;

      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (picked == null) return;

      final imageFile = File(picked.path);

      final ext = picked.path.split('.').last.toLowerCase().trim();
      final safeExt = ext.isEmpty ? 'jpg' : ext;

      final ref = _storage.ref().child("profile_images/$uid.$safeExt");

      await ref.putFile(imageFile);

      final url = await ref.getDownloadURL();

      await _firestore.collection('users').doc(uid).set({
        'photoUrl': url,
      }, SetOptions(merge: true));

      await _auth.currentUser?.updatePhotoURL(url);
      photoUrl.value = url;

      Get.snackbar('success'.tr, 'profileImageUpdated'.tr,
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('error'.tr, 'failedUpdateImage'.tr,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isUploadingPhoto.value = false;
    }
  }

  Future<void> shareInviteLink() async {
    final current = _auth.currentUser;
    if (useMockData) {
      final inviteLink = 'https://skillup.app/invite?uid=mock-user-001';
      final message = 'inviteMessage'.trParams({'link': inviteLink});
      await Share.share(message, subject: 'inviteSubject'.tr);
      return;
    }

    if (current == null) {
      Get.snackbar('error'.tr, 'notLoggedIn'.tr,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final inviteLink = 'https://skillup.app/invite?uid=${current.uid}';
    final message = 'inviteMessage'.trParams({'link': inviteLink});

    await Share.share(message, subject: 'inviteSubject'.tr);
  }

  Future<void> logout() async {
    if (useMockData) {
      Get.offAllNamed('/signIn');
      return;
    }
    try {
      await _auth.signOut();
      Get.offAllNamed('/signIn');
    } catch (e) {
      Get.snackbar('error'.tr, 'failedSignOut'.tr,
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
