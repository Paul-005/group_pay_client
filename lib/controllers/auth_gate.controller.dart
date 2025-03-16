import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:group_pay_client/auth/join_group.dart';
import 'package:group_pay_client/auth/signup_screen.dart';
import 'package:group_pay_client/dashboard/dashboard.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignupPage();
        }

        if (snapshot.hasData && snapshot.data != null) {
          return _buildLoggedInContent(snapshot.data!);
        }

        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _buildLoggedInContent(User user) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('students')
          .doc(user.uid)
          .snapshots(), // Use snapshots() for real-time updates
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final profileCompleted = data?['profile_completed'] as int?;

          if (profileCompleted == 1) {
            return StudentAdminCodeEntry();
          } else {
            return Dashboard();
          }
        } else {
          return Dashboard();
        }
      },
    );
  }
}
