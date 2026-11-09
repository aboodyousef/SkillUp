import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:skill_up/data/mock/mock_config.dart';
import 'package:skill_up/data/models/user_model.dart';
import 'package:skill_up/data/themes/image_string.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed('/home');
      return;
    }

    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = cred.user;
    if (user == null) throw Exception("User is null after sign up");

    await user.updateDisplayName(fullName);

    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'fullName': fullName,
      'email': email,
      'role': role.value,
      'photoUrl': user.photoURL?.isNotEmpty == true ? user.photoURL! : ImageStringProfile.userProfile,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
      'provider': 'password',
    }, SetOptions(merge: true));

    await _navigateUserByRole(user.uid);
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed('/home');
      return;
    }

    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = cred.user;
    if (user == null) throw Exception("User is null after sign in");

    await _firestore.collection('users').doc(user.uid).set({
      'lastLoginAt': FieldValue.serverTimestamp(),
      'provider': 'password',
    }, SetOptions(merge: true));

    await _navigateUserByRole(user.uid);
  }

  Future<void> signInWithGoogle() async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed('/home');
      return;
    }

    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      return;
    }

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCred = await _auth.signInWithCredential(credential);
    final user = userCred.user;
    if (user == null) throw Exception("User is null after google sign in");

    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();

    final String roleValue = doc.exists
        ? ((doc.data()?['role'] ?? 'student').toString())
        : 'student';
    final UserRole role = UserRole.fromString(roleValue);

    Timestamp? existingCreatedAt;

    if (doc.exists && doc.data() != null && doc.data()!['createdAt'] != null) {
      existingCreatedAt = doc.data()!['createdAt'] as Timestamp;
    }

    await docRef.set({
      'uid': user.uid,
      'fullName': user.displayName ?? '',
      'email': user.email ?? '',
      'photoUrl': user.photoURL?.isNotEmpty == true ? user.photoURL! : ImageStringProfile.userProfile,
      'role': role.value,
      'createdAt': existingCreatedAt ?? FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
      'provider': 'google',
    }, SetOptions(merge: true));

    await _navigateUserByRole(user.uid);
  }

  Future<void> sendPasswordReset(String email) async {
    if (useMockData) {
      Get.snackbar('resetEmailSent'.tr,
          'resetEmailMsg'.trParams({'email': email}),
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    if (useMockData) {
      Get.offAllNamed('/signIn');
      return;
    }
    await _googleSignIn.signOut();
    await _auth.signOut();
    Get.offAllNamed('/signIn');
  }

  Future<void> _navigateUserByRole(String uid) async {
    if (useMockData) {
      Get.offAllNamed('/home');
      return;
    }

    final doc = await _firestore.collection('users').doc(uid).get();
    final role = UserRole.fromString((doc.data()?['role'] ?? 'student').toString());

    if (role == UserRole.teacher) {
      Get.offAllNamed('/home');
    } else {
      Get.offAllNamed('/home');
    }
  }
}
