import 'package:flutter/material.dart';
import 'package:group_pay_client/dashboard/pay_now.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Model for Payment
class PaymentItem {
  final String title;
  final String description;
  final double amount;
  final DateTime dueDate;
  final bool isUrgent;
  final String bank_upi;
  final String postId;

  PaymentItem({
    required this.title,
    required this.description,
    required this.amount,
    required this.dueDate,
    this.isUrgent = false,
    required this.bank_upi,
    required this.postId,
  });
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<PaymentItem> pendingPayments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAdminPosts();
  }

  var code;

  Future<void> _fetchAdminPosts() async {
    setState(() => _isLoading = true); // Show loading state

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('students')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final adminCode = userDoc.data()?['adminCode'] as String?;
        code = adminCode;

        if (adminCode != null) {
          final postsSnapshot = await FirebaseFirestore.instance
              .collection('posts')
              .where('adminCode', isEqualTo: adminCode)
              .get();

          setState(() {
            pendingPayments = postsSnapshot.docs.map((doc) {
              final data = doc.data();
              return PaymentItem(
                title: data['title'] ?? 'No Title',
                description: data['description'] ?? 'No Description',
                amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
                dueDate: (data['lastDate'] as Timestamp?)?.toDate() ??
                    DateTime.now(),
                bank_upi: data['bank_upi'] ?? 'No UPI',
                postId: data['postId'],
              );
            }).toList();
            pendingPayments.sort((a, b) => a.dueDate.compareTo(b.dueDate));
          });
        }
      }
    }

    setState(() => _isLoading = false); // Hide loading state
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "GroupPay",
          style: TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.deepPurple),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.deepPurple),
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchAdminPosts,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount:
                    pendingPayments.isEmpty ? 1 : pendingPayments.length + 1,
                itemBuilder: (context, index) {
                  if (pendingPayments.isEmpty) {
                    return const Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text("No pending payments found."),
                        ),
                      ),
                    );
                  }

                  if (index == 0) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "Pending Payments",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    );
                  }

                  return _buildPaymentCard(pendingPayments[index - 1]);
                },
              ),
            ),
    );
  }

  Widget _buildPaymentCard(PaymentItem payment) {
    // Calculate days remaining
    final daysRemaining = payment.dueDate.difference(DateTime.now()).inDays;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Urgent Tag
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  payment.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                if (payment.isUrgent)
                  const Text(
                    "URGENT",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              payment.description,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),

            // Amount and Due Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "\₹${payment.amount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                if (payment.dueDate.isBefore(DateTime.now()))
                  const Text(
                    "Overdue",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  Text(
                    "Due in $daysRemaining days",
                    style: TextStyle(
                      color: daysRemaining <= 3 ? Colors.red : Colors.grey,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Payment Button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentScreen(
                          title: payment.title,
                          description: payment.description,
                          amount: payment.amount,
                          dueDate: payment.dueDate,
                          bank_upi: payment.bank_upi,
                          postId: payment.postId,
                        ),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.monetization_on_rounded,
                    color: Colors.deepPurple,
                  ),
                  label: Text(
                    'Make Payment',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
