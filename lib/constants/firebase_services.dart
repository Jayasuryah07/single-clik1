import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:single_clik/utils/shar_preferences.dart';

class FirebaseService {

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotification() async {
    try {
      // Request Notification Permission
      NotificationSettings settings = await firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint("❌ Notification permission denied.");
        return;
      }
      String? fcmToken;
      if (Platform.isIOS) {
        fcmToken = await FirebaseMessaging.instance
            .getAPNSToken();
        debugPrint('APNS Token: $fcmToken');
      } else {
        FirebaseMessaging messaging =
            FirebaseMessaging.instance;
        fcmToken = await messaging.getToken();
        debugPrint('APNS Token: $fcmToken');
      }
      // Get FCM Token (Ensure it's not null)
      if (fcmToken != null) {
        await SharPreferences.setString(SharPreferences.fcmToken, fcmToken);
        debugPrint("✅ FCM Token: $fcmToken");
      } else {
        debugPrint("⚠️ Failed to retrieve FCM Token");
      }

      // Enable Auto Initialization
      await firebaseMessaging.setAutoInitEnabled(true);

      // Configure Foreground Notifications
      await firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint("✅ Firebase Notifications Initialized Successfully");
    } catch (e) {
      debugPrint("❌ Firebase Messaging Error: $e");
    }
  }
}
