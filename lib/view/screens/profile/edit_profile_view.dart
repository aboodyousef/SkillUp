import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'profile_controller.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final ProfileController profileCtrl = Get.find<ProfileController>();

  late TextEditingController nameController;
  late TextEditingController tagController;
  late TextEditingController aboutController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: profileCtrl.userName.value);
    tagController = TextEditingController(text: profileCtrl.tagLine.value);
    aboutController = TextEditingController(text: profileCtrl.aboutText.value);
  }

  @override
  void dispose() {
    nameController.dispose();
    tagController.dispose();
    aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF6C4EFF);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'editProfileTitle'.tr,
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: Obx(() {
                return ElevatedButton.icon(
                  onPressed: profileCtrl.isUploadingPhoto.value
                      ? null
                      : profileCtrl.changeProfileImage,
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  label: Text(
                    profileCtrl.isUploadingPhoto.value
                        ? 'uploading'.tr
                        : 'changeProfileImage'.tr,
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'fullName'.tr,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tagController,
              decoration: InputDecoration(
                labelText: 'tagLine'.tr,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: aboutController,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  labelText: 'aboutMe'.tr,
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await profileCtrl.saveProfile(
                    name: nameController.text.trim(),
                    tag: tagController.text.trim(),
                    about: aboutController.text.trim(),
                  );
                  Get.back();
                },
                child: Text(
                  'saveChanges'.tr,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
