import 'package:cloud_firestore/cloud_firestore.dart';

class SavedRepository {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _savedRef(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('saved');
  }

  Future<void> saveCourse({
    required String uid,
    required String videoId,
  }) async {
    await _savedRef(uid).doc(videoId).set({
      'videoId': videoId,
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeSaved({
    required String uid,
    required String videoId,
  }) async {
    await _savedRef(uid).doc(videoId).delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchSaved(String uid) {
    return _savedRef(uid)
        .orderBy('savedAt', descending: true)
        .snapshots();
  }

  Future<bool> isSaved({
    required String uid,
    required String videoId,
  }) async {
    final doc = await _savedRef(uid).doc(videoId).get();
    return doc.exists;
  }
}
