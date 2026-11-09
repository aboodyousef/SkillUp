import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skill_up/controllers/user_controller.dart';

class CreateVideoController extends GetxController {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final thumbnailUrlController = TextEditingController();
  final subjectController = TextEditingController();
  final levelController = TextEditingController();

  final RxString uploadedVideoUrl = ''.obs;

  // نفس id للـ Storage + Firestore
  final RxString currentVideoDocId = ''.obs;

  RxBool isLoading = false.obs;

  RxDouble uploadProgress = 0.0.obs; // 0..1
  RxString uploadStatus = ''.obs;

  StreamSubscription<TaskSnapshot>? _uploadSub;
  File? selectedVideoFile;


  final RxString selectedVideoName = ''.obs;

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseStorage get _storage => FirebaseStorage.instance;

  // Pick Video
  Future<void> pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
      withData: false,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    if (file.path == null) return;

    selectedVideoFile = File(file.path!);

    //تحديث Rx بدل متغير عادي
    selectedVideoName.value = file.name; 

    uploadStatus.value = "Video selected: ${file.name}";
    Get.snackbar("Selected", file.name, snackPosition: SnackPosition.BOTTOM);
  }

  //Upload Video
  Future<void> uploadSelectedVideo() async {
    final user = _auth.currentUser;
    if (user == null) {
      Get.snackbar("Error", "You are not logged in",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (selectedVideoFile == null) {
      Get.snackbar("Error", "Please select a video first",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;
      uploadProgress.value = 0;
      uploadStatus.value = "Uploading...";

      // نولّد docId مرة واحدة ونحتفظ فيه
      if (currentVideoDocId.value.isEmpty) {
        currentVideoDocId.value = _firestore.collection('videos').doc().id;
      }

      final videoId = currentVideoDocId.value;

      
      final ext = (selectedVideoName.value.split('.').last.toLowerCase()); 
      final safeExt = ext.isEmpty ? 'mp4' : ext;

      final storageRef =
          _storage.ref().child('videos/${user.uid}/$videoId.$safeExt');

      final uploadTask = storageRef.putFile(
        selectedVideoFile!,
        SettableMetadata(
          contentType: 'video/mp4',
          customMetadata: {
            'uid': user.uid,
            'videoId': videoId,
          },
        ),
      );

      _uploadSub?.cancel();
      _uploadSub = uploadTask.snapshotEvents.listen((snapshot) {
        final total = snapshot.totalBytes;
        final sent = snapshot.bytesTransferred;
        if (total > 0) uploadProgress.value = sent / total;
      });

      await uploadTask;

      final url = await storageRef.getDownloadURL();
      uploadedVideoUrl.value = url;

      uploadStatus.value = "Upload completed ✅";

      Get.snackbar("Success", "Video uploaded successfully",
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      uploadStatus.value = "Upload failed ❌";
      Get.snackbar("Error", "Failed to upload video",
          snackPosition: SnackPosition.BOTTOM);
      
      debugPrint("upload error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  //Publish (Firestore)
  Future<void> publishVideo() async {
    final title = titleController.text.trim();
    final desc = descriptionController.text.trim();
    final thumbUrl = thumbnailUrlController.text.trim();
    final subject = subjectController.text.trim();
    final level = levelController.text.trim();

    if (title.isEmpty || desc.isEmpty) {
      Get.snackbar('Error', 'Title & description are required',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (subject.isEmpty) {
      Get.snackbar('Error', 'Subject is required (for student interests)',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    //منع النشر أثناء الرفع
    if (uploadProgress.value > 0 && uploadProgress.value < 1) {
      Get.snackbar('Wait', 'Upload is still in progress',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (uploadedVideoUrl.value.isEmpty) {
      Get.snackbar('Error', 'Please upload a video first',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (currentVideoDocId.value.isEmpty) {
      Get.snackbar('Error', 'Video docId missing, upload again please',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final user = _auth.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'You are not logged in',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;

      final userCtrl = Get.find<UserController>();

      final docRef =
          _firestore.collection('videos').doc(currentVideoDocId.value);

      await docRef.set({
        'title': title,
        'description': desc,
        'videoUrl': uploadedVideoUrl.value,
        'thumbnailUrl': thumbUrl,
        'subject': subject,
        'level': level,
        'searchKeywords': [
          ...title.toLowerCase().split(' '),
          subject.toLowerCase(),
        ],
        'createdBy': user.uid,
        'createdByName': userCtrl.fullName.value,
        'createdByRole': userCtrl.role.value.value,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      //تنظيف بعد النشر
      currentVideoDocId.value = '';
      uploadedVideoUrl.value = '';
      uploadProgress.value = 0;
      uploadStatus.value = '';
      selectedVideoFile = null;

     
      selectedVideoName.value = '';

      Get.back();
      Get.snackbar('Success', 'Video has been published',
          snackPosition: SnackPosition.BOTTOM);

      
      debugPrint("Video published id: ${docRef.id}");
    } catch (e) {
      
      debugPrint("publish error: $e");
      Get.snackbar('Error', 'Failed to publish video',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _uploadSub?.cancel();
    titleController.dispose();
    descriptionController.dispose();
    thumbnailUrlController.dispose();
    subjectController.dispose();
    levelController.dispose();
    super.onClose();
  }
}