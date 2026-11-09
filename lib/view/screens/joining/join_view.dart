import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skill_up/view/screens/joining/join_controller.dart';

class JoinView extends StatelessWidget {
  const JoinView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<JoinController>(
      builder: (ctrl) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child: Image.asset('assets/images/png/welcome5.png')),
                const SizedBox(height: 30),
                Text(
                  'joinTitle'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 40),
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Get.offNamed('/signIn'),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        height: 50,
                        width: 160,
                        margin: const EdgeInsets.all(5),
                        child: Center(
                          child: Text(
                            'signIn'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.offNamed('/signUp'),
                      child: Container(
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue),
                        ),
                        height: 50,
                        width: 160,
                        child: Center(
                          child: Text(
                            'signUp'.tr,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
