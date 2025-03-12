import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

final Uri _url = Uri.parse(
    'upi://pay?pa=babuckurian@okicici&pn=Admin&am=100&cu=INR&tn=Payment%20for%20services');

Future<void> _launchGPayUrl(BuildContext context) async {
  try {
    if (await canLaunchUrl(_url)) {
      await launchUrl(_url);
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
  const PaymentScreen({super.key});

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
                const SizedBox(height: 30),
                _buildSharePaymentButton(context),
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
        children: const [
          Text("Payment Summary",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple)),
          SizedBox(height: 20),
          Text("Title: Gym Membership",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text("Description: Monthly membership fee",
              style: TextStyle(fontSize: 16, color: Colors.grey)),
          Divider(height: 35, thickness: 1),
          Text("Amount: ₹500.00",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple)),
          SizedBox(height: 12),
          Text("Due Date: 10/03/2025",
              style: TextStyle(fontSize: 16, color: Colors.grey)),
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
        _buildPaymentMethodCard(context,
            icon: Icons.account_balance_wallet,
            name: "Google Pay",
            color: Colors.blue,
            onTap: () => _launchGPayUrl(context)),
        _buildPaymentMethodCard(context,
            icon: Icons.credit_card,
            name: "Credit Card",
            color: Colors.purple,
            onTap: () {}),
        _buildPaymentMethodCard(context,
            icon: Icons.group,
            name: "Let Others Pay",
            color: Colors.green,
            onTap: () {}),
        _buildPaymentMethodCard(context,
            icon: Icons.money,
            name: "Cash",
            color: Colors.orange,
            onTap: () {}),
      ],
    );
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

  Widget _buildSharePaymentButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: Colors.deepPurple),
        onPressed: () {},
        icon: const Icon(Icons.share, color: Colors.white),
        label: const Text("Share Payment Request",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      ),
    );
  }
}
