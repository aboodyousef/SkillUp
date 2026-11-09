import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:skill_up/services/language/language_controller.dart';
import 'package:skill_up/utils/routes/routes.dart';
import 'package:skill_up/view/screens/welcom/welcome_controller.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WelcomeController>(
      builder: (ctrl) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GetBuilder<LanguageController>(
                        builder: (langCtrl) => IconButton(
                          icon: const Icon(Icons.translate),
                          tooltip: langCtrl.isArabic ? 'تغيير اللغة' : 'Change Language',
                          onPressed: () => langCtrl.toggleLanguage(),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.offAllNamed(RoutesString.join);
                        },
                        child: Text(
                          'skip'.tr,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: ctrl.pageController,
                    itemCount: ctrl.pages.length,
                    onPageChanged: (index) => ctrl.currentPage.value = index,
                    itemBuilder: (context, index) {
                      final page = ctrl.pages[index];
                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(page["image"], height: 300),
                            const SizedBox(height: 20),
                            Text(
                              textAlign: TextAlign.center,
                              page["title"].toString(),
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 70),
                  child: SmoothPageIndicator(
                    controller: ctrl.pageController,
                    count: ctrl.pages.length,
                    effect: WormEffect(
                      dotHeight: 12,
                      dotWidth: 12,
                      activeDotColor: Colors.blue,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (ctrl.currentPage.value == ctrl.pages.length - 1) {
                      Get.offAllNamed(RoutesString.join);
                    } else {
                      ctrl.nextPage();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      height: 60,
                      width: MediaQuery.sizeOf(context).width * 0.6,
                      child: Text(
                        'continu'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}