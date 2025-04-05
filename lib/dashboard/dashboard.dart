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
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(
              Icons.account_balance_wallet_rounded,
              color: Color(0xFF7E57C2),
              size: 28,
            ),
            SizedBox(width: 12),
            Text(
              "GroupPay",
              style: TextStyle(
                color: Color(0xFF673AB7),
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF7E57C2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Color(0xFF7E57C2),
              ),
              onPressed: () {
                // TODO: Implement notifications
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF7E57C2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.logout_rounded,
                color: Color(0xFF7E57C2),
              ),
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7E57C2).withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7E57C2)),
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchAdminPosts,
              color: const Color(0xFF7E57C2),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF7E57C2),
                            Color(0xFF673AB7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7E57C2).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Payment Summary",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${pendingPayments.length}",
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Text(
                                    "Pending Payments",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.receipt_long_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(
                      child: const Text(
                        "Recent Payments",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF673AB7),
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 16),
                  ),
                  pendingPayments.isEmpty
                      ? SliverFillRemaining(
                          child: Container(
                            margin: const EdgeInsets.all(20),
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF7E57C2).withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF7E57C2)
                                        .withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 48,
                                    color: Color(0xFF7E57C2),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  "All Caught Up!",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF673AB7),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "No pending payments at the moment",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) =>
                                  _buildPaymentCard(pendingPayments[index]),
                              childCount: pendingPayments.length,
                            ),
                          ),
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildPaymentCard(PaymentItem payment) {
    final daysRemaining = payment.dueDate.difference(DateTime.now()).inDays;
    final isOverdue = payment.dueDate.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _navigateToPayment(payment),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              payment.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              payment.description,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isOverdue
                              ? Colors.red.withOpacity(0.1)
                              : Colors.deepPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        // Show "Pay Today" when zero days left
                        child: Text(
                          daysRemaining == 0
                              ? "Pay Today"
                              : isOverdue
                                  ? "Overdue"
                                  : "$daysRemaining days left",
                          style: TextStyle(
                            color: isOverdue ? Colors.red : Colors.deepPurple,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF7E57C2), // Deep Purple 400
                          Color(0xFF673AB7), // Deep Purple 500
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _navigateToPayment(payment),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Amount Due',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "₹${payment.amount.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Text(
                                    'Pay Now',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToPayment(PaymentItem payment) {
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
  }
}
