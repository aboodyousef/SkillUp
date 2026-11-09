import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsRepository {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _ref(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications');
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watch(String uid) {
    return _ref(uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> markAsRead({
    required String uid,
    required String notifId,
  }) async {
    await _ref(uid).doc(notifId).update({'isRead': true});
  }

  Future<void> create({
    required String uid,
    required String title,
    required String body,
    String? type,
    String? videoId,
  }) async {
    await _ref(uid).add({
      'title': title,
      'body': body,
      'type': type ?? 'INFO',
      'videoId': videoId,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
