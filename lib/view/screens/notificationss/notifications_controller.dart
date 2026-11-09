import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'package:skill_up/controllers/user_controller.dart';
import 'package:skill_up/data/mock/mock_config.dart';
import 'package:skill_up/data/mock/mock_data.dart';
import 'package:skill_up/data/repositories/notifications_repository.dart';

class NotificationsController extends GetxController {
  final NotificationsRepository _repo = NotificationsRepository();
  final UserController userCtrl = Get.find<UserController>();

  final RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _notifSub;

  @override
  void onInit() {
    super.onInit();

    if (useMockData) {
      _loadMockNotifications();
      return;
    }

    if (userCtrl.isReady.value && userCtrl.uid.value.isNotEmpty) {
      _listen();
    } else {
      ever(userCtrl.isReady, (ready) {
        if (ready == true && userCtrl.uid.value.isNotEmpty) {
          _listen();
        }
      });
    }
  }

  void _loadMockNotifications() {
    isLoading.value = true;
    items.assignAll(MockDataService.instance.mockNotifications);
    isLoading.value = false;
  }

  void _listen() {
    _notifSub?.cancel();
    isLoading.value = true;

    _notifSub = _repo.watch(userCtrl.uid.value).listen((snap) {
      final temp = snap.docs.map((d) {
        final data = d.data();
        return {
          'id': d.id,
          'title': data['title'] ?? '',
          'body': data['body'] ?? '',
          'type': data['type'] ?? 'INFO',
          'videoId': data['videoId'],
          'isRead': data['isRead'] ?? false,
          'createdAt': data['createdAt'],
        };
      }).toList();

      items.assignAll(temp);
      isLoading.value = false;
    });
  }

  Future<void> openNotification(Map<String, dynamic> n) async {
    if (useMockData) {
      final idx = items.indexWhere((item) => item['id'] == n['id']);
      if (idx >= 0) {
        items[idx] = Map<String, dynamic>.from(items[idx]);
        items[idx]['isRead'] = true;
        items.refresh();
      }
      return;
    }

    if (n['isRead'] != true) {
      await _repo.markAsRead(
        uid: userCtrl.uid.value,
        notifId: n['id'],
      );
    }
  }

  @override
  void onClose() {
    _notifSub?.cancel();
    super.onClose();
  }
}
