import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skill_up/controllers/user_controller.dart';
import 'package:skill_up/data/models/user_model.dart';
import 'create_video_controller.dart';

class CreateVideoView extends StatelessWidget {
  const CreateVideoView({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userCtrl = Get.find<UserController>();
    final CreateVideoController ctrl = Get.put(CreateVideoController());

    return Obx(() {
      if (!userCtrl.isReady.value) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      if (userCtrl.role.value != UserRole.teacher) {
        Future.microtask(() {
          Get.snackbar(
            'permissionDenied'.tr,
            'onlyTeachers'.tr,
            snackPosition: SnackPosition.BOTTOM,
          );
          Get.back();
        });

        return const SizedBox.shrink();
      }

      return Scaffold(
        appBar: AppBar(
          title: Text(
            'publishVideo'.tr,
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),

          child: Obx(() {
            return AbsorbPointer(
              absorbing: ctrl.isLoading.value,
              child: SingleChildScrollView(
                child: Column(
                  children: [

                    TextField(
                      controller: ctrl.titleController,
                      decoration: InputDecoration(
                        labelText: 'title'.tr,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: ctrl.descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'description'.tr,
                        alignLabelWithHint: true,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: ctrl.isLoading.value ? null : ctrl.pickVideo,
                        icon: const Icon(Icons.video_library),

                        label: Obx(() {
                          final name = ctrl.selectedVideoName.value;
                          return Text(
                            name.isEmpty ? 'pickVideo'.tr : 'pickedVideo'.trParams({'name': name}),
                            overflow: TextOverflow.ellipsis,
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: ctrl.isLoading.value
                            ? null
                            : ctrl.uploadSelectedVideo,
                        icon: const Icon(Icons.cloud_upload),
                        label: Text('uploadToStorage'.tr),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Obx(() {
                      final showBox = ctrl.uploadStatus.value.isNotEmpty ||
                          ctrl.uploadProgress.value > 0;

                      if (!showBox) return const SizedBox.shrink();

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xfff5f6fb),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ctrl.uploadStatus.value,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: ctrl.uploadProgress.value,
                              minHeight: 6,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${(ctrl.uploadProgress.value * 100).toStringAsFixed(0)}%",
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            if (ctrl.uploadedVideoUrl.value.isNotEmpty)
                              Text(
                                'videoUrlReady'.tr,
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 12),

                    TextField(
                      controller: ctrl.thumbnailUrlController,
                      decoration: InputDecoration(
                        labelText: 'thumbnailUrl'.tr,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: ctrl.subjectController,
                      decoration: InputDecoration(
                        labelText: 'subject'.tr,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: ctrl.levelController,
                      decoration: InputDecoration(
                        labelText: 'level'.tr,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed:
                            ctrl.isLoading.value ? null : ctrl.publishVideo,
                        child: ctrl.isLoading.value
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text('publish'.tr),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      );
    });
  }
}
