import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:group_pay_client/controllers/auth_gate.controller.dart';
import 'package:group_pay_client/controllers/auth_screens.controller.dart';
import 'package:group_pay_client/routes/bottom_nav.route.dart';
import 'package:group_pay_client/controllers/notification_controller.dart'; // Import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GroupPay',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: AuthGate(),
    );
  }
}
