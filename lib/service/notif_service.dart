import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static Future<void> requestPermission(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    try {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (e) {
      log('ERROR FROM REQUEST PERMISSION NOTIF $e');
    }
  }

  static void getResponseNotif(NotificationResponse notificationResponse) {
    if (notificationResponse.payload != null) {
      log('GET NOTIF RESPONSE ${notificationResponse.payload}');
    }
  }

  static Future<void> initializeNotif() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    InitializationSettings initializationSettings =
        const InitializationSettings(android: androidInitializationSettings);

    await requestPermission(flutterLocalNotificationsPlugin);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveBackgroundNotificationResponse: getResponseNotif);
  }

  static Future<void> showNotif(
    String title,
    String body,
  ) async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      '1',
      'alarm',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
        1, title, body, notificationDetails);
  }
}
