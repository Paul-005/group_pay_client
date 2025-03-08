import 'package:flutter/material.dart';

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

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Make Payment",
          style: TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.deepPurple),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment Details
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "payment.title",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "payment.description",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Amount:",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[800],
                          ),
                        ),
                        Text(
                          "454.00",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Due Date:",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[800],
                          ),
                        ),
                        Text(
                          "12/4/2021",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Payment Options
            const Text(
              "Choose Payment Method:",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),

            // Pay via Google Pay
            _buildPaymentOption(
              icon: Icons.payment,
              title: "Pay via Google Pay",
              onTap: () {
                // TODO: Implement Google Pay integration
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Redirecting to Google Pay...")),
                );
              },
            ),

            const SizedBox(height: 12),

            // Pay via Cash
            _buildPaymentOption(
              icon: Icons.money,
              title: "Pay via Cash",
              onTap: () {
                // TODO: Mark payment as paid via cash
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Marked as paid via cash.")),
                );
              },
            ),

            const SizedBox(height: 12),

            // Let Someone Else Pay
            _buildPaymentOption(
              icon: Icons.people,
              title: "Let Someone Else Pay",
              onTap: () {
                // TODO: Implement "Let Someone Else Pay" logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Request sent to another user.")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Reusable Payment Option Widget
  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.deepPurple),
        onTap: onTap,
      ),
    );
  }
}
