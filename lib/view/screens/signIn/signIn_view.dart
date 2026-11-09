import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skill_up/view/screens/signIn/signIn_controller.dart';

class SignInView extends StatelessWidget {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SignInController>(
      init: SignInController(),
      builder: (ctrl) {
        return Scaffold(
          appBar: AppBar(
            leading: BackButton(onPressed: () => Get.offNamed('/join')),
            title: Text(
              'signIn'.tr,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'email'.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: ctrl.emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'emailHint'.tr,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'password'.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => TextField(
                      controller: ctrl.passwordController,
                      obscureText: ctrl.isPasswordHidden.value,
                      decoration: InputDecoration(
                        hintText: 'passwordHint'.tr,
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            ctrl.isPasswordHidden.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: ctrl.togglePassword,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Get.toNamed('/forgetPass'),
                      child: Text(
                        'resetPassword'.tr,
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  Obx(
                    () => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: ctrl.isLoading.value ? null : ctrl.signIn,
                      child: ctrl.isLoading.value
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'signInTitle'.tr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 80),

                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade400,
                          thickness: 1,
                          endIndent: 10,
                        ),
                      ),
                      Text(
                        'orSignInWith'.tr,
                        style: const TextStyle(color: Colors.black),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade400,
                          thickness: 1,
                          indent: 10,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Obx(
                    () => signWithButton(
                      icon: Icons.g_mobiledata,
                      text: 'signInWithGoogle'.tr,
                      disabled: ctrl.isLoading.value,
                      onTap: ctrl.signInWithGoogle,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('dontHaveAccount'.tr),
                      GestureDetector(
                        onTap: () => Get.offNamed('/signUp'),
                        child: Text(
                          'signUpHere'.tr,
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

Widget signWithButton({
  required IconData icon,
  required String text,
  VoidCallback? onTap,
  bool disabled = false,
}) {
  return InkWell(
    onTap: disabled ? null : onTap,
    borderRadius: BorderRadius.circular(8),
    child: Opacity(
      opacity: disabled ? 0.6 : 1.0,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(icon), const SizedBox(width: 10), Text(text)],
        ),
      ),
    ),
  );
}
