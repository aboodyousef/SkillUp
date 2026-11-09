import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skill_up/data/mock/mock_config.dart';
import 'package:skill_up/view/screens/checkEmail/check_Email_view.dart';

class ForgetPasswordController extends GetxController {
  final emailController = TextEditingController();
  final isLoading = false.obs;

  FirebaseAuth get _auth => FirebaseAuth.instance;

  Future<void> resetPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      Get.snackbar('error'.tr, 'emailHint'.tr,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      Get.off(() => const CheckEmailView());
      return;
    }

    try {
      isLoading.value = true;

      
      await _auth.sendPasswordResetEmail(email: email);

      
      Get.off(() => const CheckEmailView());
    } on FirebaseAuthException catch (e) {
      String msg = 'failedToEnroll'.tr;
      if (e.code == 'user-not-found') msg = "No user found for this email";
      if (e.code == 'invalid-email') msg = "Invalid email format";
      if (e.code == 'network-request-failed') msg = "Network error";
      Get.snackbar('error'.tr, msg, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('error'.tr, e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
