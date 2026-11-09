import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skill_up/services/language/language_controller.dart';
import 'package:skill_up/utils/image_helper.dart';
import 'package:skill_up/data/themes/image_string.dart';
import 'package:skill_up/data/models/user_model.dart';
import 'profile_controller.dart';
import 'edit_profile_view.dart';
import 'payment_option_view.dart';
import 'my_certificates_view.dart';
import 'help_center_view.dart';
import 'package:skill_up/view/screens/notificationss/notifications_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController ctrl = Get.find<ProfileController>();
    final LanguageController langCtrl = Get.find<LanguageController>();

    const primaryPurple = Colors.blue;
    const lightCard = Color(0xFFF7F7FB);
    const lightIconBg = Color(0xFFEDE7FF);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'myProfile'.tr,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Language switch
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Obx(() => IconButton(
              icon: const Icon(Icons.translate),
              tooltip: langCtrl.isArabic ? 'تغيير اللغة' : 'Change Language',
              onPressed: () => langCtrl.toggleLanguage(),
            )),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => Get.to(() => const NotificationsView()),
              child: Stack(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: const Icon(Icons.notifications_none),
                  ),
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (ctrl.isFetchingProfile.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 50),
                      padding: const EdgeInsets.fromLTRB(16, 60, 16, 20),
                      decoration: BoxDecoration(
                        color: lightCard,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                Obx(() => Text(
                                      ctrl.userName.value,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                                const SizedBox(height: 4),
                                Obx(() => Text(
                                      ctrl.tagLine.value,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    )),
                                const SizedBox(height: 4),
                                if (ctrl.role.value == UserRole.teacher)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.blue.withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.verified,
                                          size: 14,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Verified Teacher',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'aboutMe'.tr,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Obx(() => Text(
                                ctrl.aboutText.value,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              )),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'readMore'.tr,
                              style: const TextStyle(
                                color: primaryPurple,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Container(
                                height: 36,
                                width: 36,
                                decoration: BoxDecoration(
                                  color: lightIconBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.payment,
                                  color: primaryPurple,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Obx(
                                  () => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'preferredPayment'.tr,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        ctrl.paymentMethodLabel,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Get.to(() => const PaymentOptionView()),
                                child: Text(
                                  'change'.tr,
                                  style: const TextStyle(color: primaryPurple),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          Text(
                            'mySkills'.tr,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),

                          Obx(
                            () => Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: ctrl.skills
                                  .map(
                                    (skill) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: lightIconBg,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        skill,
                                        style: const TextStyle(
                                          color: primaryPurple,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Stack(
                          children: [
                            Obx(() {
                              final url = ctrl.photoUrl.value;
                              return CircleAvatar(
                                radius: 45,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 42,
                                  backgroundImage: resolveImage(url, fallbackAsset: ImageStringProfile.userProfile),
                                ),
                              );
                            }),

                            Positioned.fill(
                              child: Obx(() {
                                if (!ctrl.isUploadingPhoto.value) {
                                  return const SizedBox.shrink();
                                }
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }),
                            ),

                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Obx(() {
                                return InkWell(
                                  onTap: ctrl.isUploadingPhoto.value
                                      ? null
                                      : ctrl.changeProfileImage,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: ctrl.menuItems.map((item) {
                      final iconKey = item["icon"]!;
                      final isLogout = iconKey == "logout";

                      return ListTile(
                        leading: _buildIcon(iconKey),
                        title: Text(
                          item["title"]!.tr,
                          style: TextStyle(
                            fontSize: 15,
                            color: isLogout ? Colors.red : Colors.black,
                            fontWeight: isLogout
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: Icon(
                          isLogout ? Icons.logout : Icons.arrow_forward_ios,
                          size: isLogout ? 20 : 16,
                          color: isLogout ? Colors.red : Colors.grey,
                        ),
                        onTap: () {
                          if (iconKey == "account") {
                            _showAccountInfo(ctrl);
                          } else if (iconKey == "edit") {
                            Get.to(() => const EditProfileView());
                          } else if (iconKey == "payment") {
                            Get.to(() => const PaymentOptionView());
                          } else if (iconKey == "certificate") {
                            Get.to(() => const MyCertificatesView());
                          } else if (iconKey == "help") {
                            Get.to(() => const HelpCenterView());
                          } else if (iconKey == "invite") {
                            ctrl.shareInviteLink();
                          } else if (iconKey == "logout") {
                            ctrl.logout();
                          } else {
                            Get.snackbar(
                              'comingSoon'.tr,
                              'comingSoonMsg'.trParams({'title': item["title"]!.tr}),
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _showAccountInfo(ProfileController ctrl) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'accountInfo'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.person_outline, color: Colors.blue),
                  const SizedBox(width: 12),
                  Text(
                    'accountType'.tr,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  Obx(() {
                    final isTeacher = ctrl.role.value == UserRole.teacher;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isTeacher
                            ? Colors.blue.withValues(alpha: 0.1)
                            : Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isTeacher)
                            const Icon(Icons.verified,
                                size: 14, color: Colors.blue),
                          if (!isTeacher)
                            const Icon(Icons.school,
                                size: 14, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            isTeacher ? 'roleTeacher'.tr : 'roleStudent'.tr,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isTeacher ? Colors.blue : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'done'.tr,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(String iconKey) {
    const primaryBlue = Colors.blue;
    const lightIconBg = Color(0xFFEDE7FF);

    IconData iconData;
    switch (iconKey) {
      case "account":
        iconData = Icons.info_outline;
        break;
      case "edit":
        iconData = Icons.person_outline;
        break;
      case "payment":
        iconData = Icons.credit_card;
        break;
      case "certificate":
        iconData = Icons.card_membership;
        break;
      case "terms":
        iconData = Icons.article_outlined;
        break;
      case "help":
        iconData = Icons.help_outline;
        break;
      case "invite":
        iconData = Icons.group_add_outlined;
        break;
      case "logout":
        iconData = Icons.logout;
        break;
      default:
        iconData = Icons.circle;
    }

    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: lightIconBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        iconData,
        color: iconKey == "logout" ? Colors.red : primaryBlue,
      ),
    );
  }
}
