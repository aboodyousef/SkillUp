import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skill_up/view/screens/checkEmail/check_Email_controller.dart';

class CheckEmailView extends StatelessWidget {
  const CheckEmailView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckEmailController>(
      init: CheckEmailController(),
      builder: (ctrl) {
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/png/CheckEmail.png', height: 200),
                  const SizedBox(height: 40),
                  Text(
                    'checkEmailTitle'.tr,
                    style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'checkEmailDesc'.tr,
                    style: TextStyle(
                      color: Colors.grey[600],
                      overflow: TextOverflow.visible,
                      height: 1.5,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {},
                    style: ButtonStyle(
                      minimumSize: WidgetStateProperty.all(
                        const Size(double.infinity, 50),
                      ),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      backgroundColor: WidgetStateProperty.all(Colors.blue),
                    ),
                    child: Text(
                      'resendEmail'.tr,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.arrow_back_ios_new, color: Colors.black),
                        const SizedBox(width: 5),
                        Text(
                          'backToLogin'.tr,
                          style: const TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ],
                    ),
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
