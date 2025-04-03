import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentStatusButton extends StatefulWidget {
  final String postId;
  final VoidCallback? onPaymentConfirmed;

  const PaymentStatusButton({
    Key? key,
    required this.postId,
    this.onPaymentConfirmed,
  }) : super(key: key);

  @override
  State<PaymentStatusButton> createState() => _PaymentStatusButtonState();
}

class _PaymentStatusButtonState extends State<PaymentStatusButton> {
  bool _isLoading = false;

  Future<void> _markAsPaid() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Create the user map object that matches the structure in unpaid array
      final userMap = {
        'email': user.email,
        'uid': user.uid,
      };

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .update({
        'paid': FieldValue.arrayUnion([userMap]),
        'unpaid': FieldValue.arrayRemove([userMap]),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment marked as completed'),
            backgroundColor: Colors.green,
          ),
        );
      }

      widget.onPaymentConfirmed?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update payment status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _markAsPaid,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.deepPurple,
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.check_circle_outline),
                      SizedBox(width: 8),
                      Text(
                        'Mark as Paid',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
