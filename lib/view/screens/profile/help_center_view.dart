import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterView extends StatelessWidget {
  const HelpCenterView({super.key});

  Future<void> _sendEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'skillup@Gmail.com',
      queryParameters: {
        'subject': 'helpSubject'.tr,
        'body': 'helpBody'.tr,
      },
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('sendEmailError'.tr, 'couldNotOpenEmail'.tr,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF6C4EFF);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'helpCenterTitle'.tr,
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'helpCenterDesc'.tr,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'helpCenterSubtitle'.tr,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 20),

          ExpansionTile(
            title: Text('faqEnroll'.tr),
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'faqEnrollAnswer'.tr,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('faqForgotPassword'.tr),
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'faqForgotPasswordAnswer'.tr,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('faqBecomeTeacher'.tr),
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'faqBecomeTeacherAnswer'.tr,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          ListTile(
            leading: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFEDE7FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.email_outlined, color: primaryPurple),
            ),
            title: Text('contactSupport'.tr),
            subtitle: Text('sendUsEmail'.tr),
            onTap: _sendEmail,
          ),
        ],
      ),
    );
  }
}
