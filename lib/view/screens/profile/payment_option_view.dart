import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:skill_up/data/mock/mock_config.dart';

class PaymentOptionView extends StatefulWidget {
  const PaymentOptionView({super.key});

  @override
  State<PaymentOptionView> createState() => _PaymentOptionViewState();
}

class _PaymentOptionViewState extends State<PaymentOptionView> {
  String selectedMethod = 'paypal';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentMethod();
  }

  Future<void> _loadCurrentMethod() async {
    if (useMockData) {
      selectedMethod = 'paypal';
      setState(() => isLoading = false);
      return;
    }

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        setState(() => isLoading = false);
        return;
      }

      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['paymentMethod'] != null) {
          selectedMethod = data['paymentMethod'] as String;
        }
      }
    } catch (e) {
      debugPrint("Error loading paymentMethod: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _savePaymentMethod() async {
    if (useMockData) {
      Get.back();
      Get.snackbar('done'.tr, 'savedPayment'.tr,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set(
          {
            'paymentMethod': selectedMethod,
          },
          SetOptions(merge: true),
        );
      }

      Get.back();
      Get.snackbar('done'.tr, 'savedPayment'.tr,
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      debugPrint("Error saving paymentMethod: $e");
      Get.snackbar('error'.tr, 'failedSavePayment'.tr,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF6C4EFF);

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'paymentOptionTitle'.tr,
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RadioListTile<String>(
            value: 'paypal',
            groupValue: selectedMethod,
            activeColor: primaryPurple,
            title: Text('paypal'.tr),
            subtitle: Text('paypalSubtitle'.tr),
            secondary: const Icon(Icons.account_balance_wallet_outlined),
            onChanged: (v) => setState(() => selectedMethod = v!),
          ),

          RadioListTile<String>(
            value: 'apple_pay',
            groupValue: selectedMethod,
            activeColor: primaryPurple,
            title: Text('applePay'.tr),
            subtitle: Text('applePaySubtitle'.tr),
            secondary: const Icon(Icons.apple),
            onChanged: (v) => setState(() => selectedMethod = v!),
          ),

          RadioListTile<String>(
            value: 'google_pay',
            groupValue: selectedMethod,
            activeColor: primaryPurple,
            title: Text('googlePay'.tr),
            subtitle: Text('googlePaySubtitle'.tr),
            secondary: const Icon(Icons.g_mobiledata),
            onChanged: (v) => setState(() => selectedMethod = v!),
          ),

          RadioListTile<String>(
            value: 'mastercard',
            groupValue: selectedMethod,
            activeColor: primaryPurple,
            title: Text('mastercard'.tr),
            subtitle: Text('mastercardSubtitle'.tr),
            secondary: const Icon(Icons.credit_card),
            onChanged: (v) => setState(() => selectedMethod = v!),
          ),

          const SizedBox(height: 24),

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
              onPressed: _savePaymentMethod,
              child: Text(
                'savePaymentMethod'.tr,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
