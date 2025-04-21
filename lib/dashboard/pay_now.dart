import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> _launchGPayUrl(BuildContext context, Uri url, String code) async {
  try {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      _showFallbackDialog(context);
    }
  } catch (e) {
    _showErrorDialog(context);
  }
}

void _showFallbackDialog(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Please install Google Pay or another UPI app."),
      backgroundColor: Colors.deepPurple,
    ),
  );
}

void _showErrorDialog(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("An error occurred. Please try again later."),
      backgroundColor: Colors.deepPurple,
    ),
  );
}

class PaymentScreen extends StatelessWidget {
  final String title;
  final String description;
  final double amount;
  final DateTime dueDate;
  final String? bank_upi;
  final String postId;

  const PaymentScreen({
    super.key,
    required this.title,
    required this.description,
    required this.amount,
    required this.dueDate,
    required this.postId,
    this.bank_upi,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Make Payment",
          style: TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPaymentSummary(),
                const SizedBox(height: 20),
                const Text("Select Payment Method",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                _buildPaymentMethods(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Payment Summary",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple)),
          const SizedBox(height: 20),
          Text("Title: $title",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text("Description: $description",
              style: TextStyle(fontSize: 16, color: Colors.grey)),
          const Divider(height: 35, thickness: 1),
          Text("Amount: ₹${amount.toStringAsFixed(2)}", // Changed $ to ₹
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple)),
          const SizedBox(height: 12),
          Text(
              "Due Date: ${dueDate.toString().split(' ')[0]}", // Only showing date
              style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildPaymentMethodCard(
          context,
          icon: Icons.account_balance_wallet,
          name: "Google Pay",
          color: Colors.blue,
          onTap: () async {
            final encodedBankUpi =
                bank_upi != null ? Uri.encodeComponent(bank_upi!) : '';
            final url =
                'upi://pay?pa=$encodedBankUpi&pn=Admin&am=$amount&cu=INR&tn=${Uri.encodeComponent("Payment for services")}';
            _launchGPayUrl(context, Uri.parse(url), postId);

            try {
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) return;
              Timestamp createdAt = Timestamp.now();

              // First get the current unpaid array to find the exact user map to remove
              final postDoc = await FirebaseFirestore.instance
                  .collection('posts')
                  .doc(postId)
                  .get();

              final unpaidArray = List<Map<String, dynamic>>.from(
                  postDoc.data()?['unpaid'] ?? []);

              // Find the exact user map in unpaid array
              final userMapToRemove = unpaidArray.firstWhere(
                (map) => map['uid'] == user.uid,
                orElse: () => {
                  'email': user.email,
                  'uid': user.uid,
                  'name': user.displayName,
                },
              );

              // Create the new paid user map
              final paidUserMap = {
                'email': user.email,
                'uid': user.uid,
                'name': user.displayName,
                'payment_date': createdAt,
              };

              // Update Firestore
              await FirebaseFirestore.instance
                  .collection('posts')
                  .doc(postId)
                  .update({
                'paid': FieldValue.arrayUnion([paidUserMap]),
                'unpaid': FieldValue.arrayRemove([userMapToRemove]),
              });

              // Get the group id from the post
              final groupDoc = await FirebaseFirestore.instance
                  .collection('groups')
                  .doc(postDoc.data()?['adminCode'])
                  .get();

              // First, get the current posts array
              final posts = List<Map<String, dynamic>>.from(
                  groupDoc.data()?['posts'] ?? []);
              final postIndex =
                  posts.indexWhere((post) => post['postId'] == postId);

              if (postIndex != -1) {
                posts[postIndex]['paid'] = (posts[postIndex]['paid'] ?? 0) + 1;
              }

              // Update the group document
              await FirebaseFirestore.instance
                  .collection('groups')
                  .doc(postDoc.data()?['adminCode'])
                  .update({
                'posts': posts,
                'payment_date': FieldValue.serverTimestamp(),
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment marked as completed'),
                  backgroundColor: Colors.green,
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to update payment status'),
                  backgroundColor: Colors.red,
                ),
              );
              print(e.toString());
            } finally {
              Navigator.pop(context);
            }
          },
        ),
        _buildPaymentMethodCard(context,
            icon: Icons.group,
            name: "Let Others Pay",
            color: Colors.green,
            onTap: () {}),
        _buildPaymentMethodCard(
          context,
          icon: Icons.money,
          name: "Cash",
          color: Colors.green,
          onTap: () => _handleCashPayment(context),
        ),
      ],
    );
  }

  Future<void> _handleCashPayment(BuildContext context) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Confirm Cash Payment',
            style: TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'By confirming, you indicate that you will pay in cash. The admin will need to verify your payment.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Confirm'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          print('Error: No user logged in');
          throw Exception('No user logged in');
        }

        // First check if the document exists
        final postDoc = await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .get();

        if (!postDoc.exists) {
          print('Error: Post document does not exist with ID: $postId');
          throw Exception('Post document does not exist');
        }

        // Get current cash_payers array
        final currentCashPayers = List<Map<String, dynamic>>.from(
            postDoc.data()?['cash_payers'] ?? []);

        // Add new cash payment with current timestamp
        currentCashPayers.add({
          'email': user.email,
          'uid': user.uid,
          'name': user.displayName ?? 'Unknown',
          'amount': amount,
          'timestamp': DateTime.now().toIso8601String(),
        });

        // Update Firestore with the new array
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .update({
          'cash_payers': currentCashPayers,
        });

        print('Successfully updated Firestore with cash payment');

        if (context.mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Cash payment recorded. Please pay the admin and wait for confirmation.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          );

          // Navigate back
          Navigator.pop(context);
        }
      } catch (e, stackTrace) {
        print('Error in _handleCashPayment:');
        print('Error message: $e');
        print('Stack trace: $stackTrace');

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Error: ${e.toString()}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          );
        }
      }
    }
  }

  Widget _buildPaymentMethodCard(BuildContext context,
      {required IconData icon,
      required String name,
      required Color color,
      required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 10),
              Text(name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
