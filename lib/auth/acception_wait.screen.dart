import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
// Note: You'll need to add the lottie package to your pubspec.yaml
// dependencies:
//   lottie: ^2.7.0

class PendingRequestScreen extends StatelessWidget {
  final String groupName;

  const PendingRequestScreen({
    super.key,
    this.groupName = "Group", // Default value if group name is not provided
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(24),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 300,
                height: 300,
                child: Lottie.asset(
                  'assets/anims/paper_rocket.json', // Replace with your Lottie asset path
                  width: 280,
                  height: 280,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),
              const SizedBox(height: 40),
              Text(
                "Pending Request",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Your request to join $groupName is pending.\nPlease wait until an admin reviews and accepts your request.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
