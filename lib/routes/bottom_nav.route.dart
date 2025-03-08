import 'package:flutter/material.dart';
import 'package:group_pay_client/auth/acception_wait.screen.dart';
import 'package:group_pay_client/auth/login_screen.dart';
import 'package:group_pay_client/auth/signup_screen.dart';
import 'package:group_pay_client/dashboard/dashboard.dart';
import 'package:group_pay_client/settings/settings.screen.dart';

const Color inActiveIconColor = Color(0xFFB6B6B6);

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int currentSelectedIndex = 0;

  void updateCurrentIndex(int index) {
    setState(() {
      currentSelectedIndex = index;
    });
  }

  final pages = [
    Dashboard(),
    PendingRequestScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentSelectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: updateCurrentIndex,
        currentIndex: currentSelectedIndex,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        elevation: 0.5,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.dashboard,
              color: inActiveIconColor,
            ),
            activeIcon: Icon(
              Icons.dashboard,
              color: Colors.deepPurple,
            ),
            label: 'Dashboard',
            tooltip: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.group,
              color: inActiveIconColor,
            ),
            activeIcon: Icon(
              Icons.group,
              color: Colors.deepPurple,
            ),
            label: 'Manage',
            tooltip: 'Manage Students',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,
              color: inActiveIconColor,
            ),
            activeIcon: Icon(
              Icons.settings,
              color: Colors.deepPurple,
            ),
            label: 'Settings',
            tooltip: 'Settings',
          ),
        ],
      ),
    );
  }
}
