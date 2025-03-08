import 'package:flutter/material.dart';
// Note: You'll need to add the lottie package to your pubspec.yaml
// dependencies:
//   lottie: ^2.7.0

class PendingRequestScreen extends StatelessWidget {
  final String groupName;

  const PendingRequestScreen({
    Key? key,
    this.groupName = "Group", // Default value if group name is not provided
  }) : super(key: key);

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
              // This is where you'd add your Lottie animation
              // For now, we'll use a placeholder Container
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Icon(
                    Icons.hourglass_bottom,
                    size: 80,
                    color: Colors.deepPurple,
                  ),
                ),
                // When implementing with actual Lottie, replace with:
                // Lottie.asset(
                //   '',
                //   width: 200,
                //   height: 200,
                //   fit: BoxFit.contain,
                // ),
              ),
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        "You'll be notified once your request is approved",
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
