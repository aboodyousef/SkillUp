import 'dart:io';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:skill_up/data/models/user_model.dart';
import 'package:skill_up/data/themes/image_string.dart';
import 'package:skill_up/services/auth_service.dart';

class SignUpController extends GetxController {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;
  final isLoading = false.obs;

  final Rx<UserRole> selectedRole = UserRole.student.obs;

  final RxString pickedImagePath = ''.obs;

  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseStorage get _storage => FirebaseStorage.instance;

  void togglePassword() => isPasswordHidden.value = !isPasswordHidden.value;
  void toggleConfirmPassword() =>
      isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;

  void setRole(UserRole role) => selectedRole.value = role;

  Future<void> pickProfileImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: false,
    );

    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    if (file.path == null) return;

    pickedImagePath.value = file.path!;
    Get.snackbar(
      'done'.tr,
      'imageSelected'.tr,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<String> _uploadProfileImage(String uid) async {
    if (pickedImagePath.value.isEmpty) return '';

    try {
      final f = File(pickedImagePath.value);
      final ext = f.path.split('.').last.toLowerCase().trim();
      final safeExt = ext.isEmpty ? 'jpg' : ext;

      final ref = _storage.ref().child("profile_images/$uid.$safeExt");

      final contentType = (safeExt == 'jpg' || safeExt == 'jpeg')
          ? 'image/jpeg'
          : 'image/$safeExt';

      await ref.putFile(
        f,
        SettableMetadata(contentType: contentType),
      );

      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint("profile image upload failed: $e");
      return '';
    }
  }

  Future<void> signUp() async {
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (fullName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'fullName'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar(
        'error'.tr,
        'confirmPassword'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (password.length < 6) {
      Get.snackbar(
        'error'.tr,
        'password'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user;
      if (user == null) throw Exception("User is null after sign up");

      await user.updateDisplayName(fullName);

      String photoUrl = ImageStringProfile.userProfile;
      if (pickedImagePath.value.isNotEmpty) {
        final uploadedUrl = await _uploadProfileImage(user.uid);
        if (uploadedUrl.isNotEmpty) {
          photoUrl = uploadedUrl;
          await user.updatePhotoURL(photoUrl);
        }
      }

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'fullName': fullName,
        'email': email,
        'role': selectedRole.value.value,
        'photoUrl': photoUrl,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      pickedImagePath.value = '';

      Get.offAllNamed('/home');
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'email-already-in-use') {
        message = "Email is already in use";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email format";
      } else if (e.code == 'weak-password') {
        message = "Weak password";
      } else if (e.code == 'operation-not-allowed') {
        message = "Email/Password sign-in is not enabled in Firebase";
      } else if (e.code == 'network-request-failed') {
        message = "Network error, please check your internet connection";
      } else {
        message = e.message ?? "Unknown error: ${e.code}";
      }

      Get.snackbar(
        'error'.tr,
        message,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      await AuthService.instance.signInWithGoogle();
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
