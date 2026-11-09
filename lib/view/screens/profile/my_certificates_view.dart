import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:skill_up/data/mock/mock_config.dart';
import 'package:skill_up/data/mock/mock_data.dart';

class MyCertificatesView extends StatelessWidget {
  const MyCertificatesView({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'myCertificatesTitle'.tr,
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: useMockData
          ? _buildMockCertificates()
          : uid == null
              ? Center(child: Text('notLoggedIn'.tr))
              : _buildFirebaseCertificates(uid),
    );
  }

  Widget _buildMockCertificates() {
    final certs = MockDataService.instance.mockCertificates;

    if (certs.isEmpty) {
      return Center(child: Text('noCertificates'.tr));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: certs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final data = certs[index];
        return ListTile(
          leading: const Icon(Icons.workspace_premium_outlined),
          title: Text(data['title'] ?? 'certificate'.tr),
          subtitle:
              Text('${data['issuer'] ?? 'unknown'.tr} • ${data['date'] ?? ''}'),
          tileColor: const Color(0xFFF7F7FB),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }

  Widget _buildFirebaseCertificates(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('certificates')
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('noCertificates'.tr),
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final title = data['title'] ?? 'certificate'.tr;
            final issuer = data['issuer'] ?? 'unknown'.tr;
            final date = data['date'] ?? '';

            return ListTile(
              leading: const Icon(Icons.workspace_premium_outlined),
              title: Text(title),
              subtitle: Text('$issuer • $date'),
              tileColor: const Color(0xFFF7F7FB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            );
          },
        );
      },
    );
  }
}
