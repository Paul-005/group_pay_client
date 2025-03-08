import 'package:flutter/material.dart';
import 'package:group_pay_client/dashboard/pay_now.dart';

// Model for Payment
class PaymentItem {
  final String title;
  final String description;
  final double amount;
  final DateTime dueDate;
  final bool isUrgent;

  PaymentItem({
    required this.title,
    required this.description,
    required this.amount,
    required this.dueDate,
    this.isUrgent = false,
  });
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // Mock data - replace with actual data fetching logic
  final List<PaymentItem> pendingPayments = [
    PaymentItem(
      title: "Rent Split",
      description: "Monthly apartment rent for June",
      amount: 450.00,
      dueDate: DateTime.now().add(const Duration(days: 5)),
      isUrgent: true,
    ),
    PaymentItem(
      title: "Utilities Shared",
      description: "Electricity and water bill",
      amount: 120.50,
      dueDate: DateTime.now().add(const Duration(days: 10)),
    ),
    PaymentItem(
      title: "Groceries Group",
      description: "Monthly grocery expenses",
      amount: 75.25,
      dueDate: DateTime.now().add(const Duration(days: 15)),
    ),
  ];

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
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount:
                    pendingPayments.length + 1, // Extra item for the heading
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // First item: Header text
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
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
                  // Remaining items: Payment cards
                  return _buildPaymentCard(pendingPayments[index - 1]);
                },
              ),
            ),
          ],
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
            Text(
              payment.description,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "\$${payment.amount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                Text(
                  "Due in $daysRemaining days",
                  style: TextStyle(
                    color: daysRemaining <= 3 ? Colors.red : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentScreen(),
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
