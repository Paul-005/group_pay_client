import 'package:flutter/material.dart';
import 'package:group_pay_client/auth/join_group.dart';
import 'package:group_pay_client/auth/login_screen.dart';
import 'package:group_pay_client/auth/signup_screen.dart';
import 'package:group_pay_client/controllers/auth_gate.controller.dart';
import 'package:group_pay_client/routes/bottom_nav.route.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GroupPay Client',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: AuthGate(),
    );
  }
}
