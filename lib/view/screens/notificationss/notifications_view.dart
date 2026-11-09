import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'notifications_controller.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationsController ctrl = Get.isRegistered<NotificationsController>()
        ? Get.find<NotificationsController>()
        : Get.put(NotificationsController());

    return Scaffold(
      appBar: AppBar(
        title: Text('notifications'.tr),
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ctrl.items.isEmpty) {
          return Center(
            child: Text(
              'noNotifications'.tr,
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.separated(
          itemCount: ctrl.items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final n = ctrl.items[index];

            return ListTile(
              leading: Icon(
                n['isRead'] ? Icons.notifications : Icons.notifications_active,
                color: n['isRead'] ? Colors.grey : Colors.blue,
              ),
              title: Text(
                n['title'],
                style: TextStyle(
                  fontWeight:
                      n['isRead'] ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Text(n['body']),
              onTap: () => ctrl.openNotification(n),
            );
          },
        );
      }),
    );
  }
}
