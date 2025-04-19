import 'package:flutter/material.dart';
import 'package:group_pay_client/auth/login_screen.dart';
import 'package:group_pay_client/auth/signup_screen.dart';

class AuthController extends StatefulWidget {
  const AuthController({super.key});

  @override
  State<AuthController> createState() => _AuthControllerState();
}

class _AuthControllerState extends State<AuthController> {
  int _currentIndex = 0;

  void _navigateToSignup() {
    setState(() {
      _currentIndex = 1;
    });
  }

  void _navigateToLogin() {
    setState(() {
      _currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          LoginPage(
            onSignupPressed: _navigateToSignup,
          ),
          SignupPage(
            onLoginPressed: _navigateToLogin,
          ),
        ],
      ),
    );
  }
}
