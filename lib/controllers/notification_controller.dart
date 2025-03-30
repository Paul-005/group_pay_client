import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationController {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static Future<void> setupPushNotifications(BuildContext context) async {
    try {
      // Request permission (iOS)
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: true, // For provisional authorization (iOS)
      );

      print('Notification permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Please enable notifications in settings to receive important updates.'),
            backgroundColor: Colors.red,
          ),
        );
      }

      // Get token
      String? token = await _firebaseMessaging.getToken();
      print("FCM Token: $token");

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        print('FCM Token refreshed: $newToken');
        // TODO: Send new token to server
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Foreground message received!');
        print('Message data: ${message.data}');

        if (message.notification != null) {
          print('Notification title: ${message.notification?.title}');
          print('Notification body: ${message.notification?.body}');
          // displayNotification(message); // Remove local notification display
        }
      });

      // Handle when app is opened from terminated state via notification
      FirebaseMessaging.instance
          .getInitialMessage()
          .then((RemoteMessage? message) {
        if (message != null) {
          print('App opened from terminated state via notification');
          // Handle navigation based on message.data
        }
      });

      // Handle when app is in background and opened via notification
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('App opened from background via notification');
        // Handle navigation based on message.data
      });

      // Set background handler
      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
    } catch (e) {
      print('Error setting up push notifications: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to setup notifications: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print("Handling a background message: ${message.messageId}");
    // displayNotification(message); // Remove local notification display
  }
}
