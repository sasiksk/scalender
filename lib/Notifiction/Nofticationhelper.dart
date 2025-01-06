import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> onDidReceiveNotification(
      NotificationResponse notificationResponse) async {
    print("Notification receive");
  }

  static Future<void> init() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings("@mipmap/ic_launcher");
    const DarwinInitializationSettings iOSInitializationSettings =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: iOSInitializationSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotification,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveNotification,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> showInstantNotification(
      String title, String body, String eventId) async {
    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        'instant_notification_channel_id',
        'Instant Notifications',
        importance: Importance.max,
        priority: Priority.high,
        color: Color(0xFFFFD700), // Golden color
        styleInformation: BigTextStyleInformation(
          'Reminder: $title\n$body',
          summaryText: body,
        ),
      ),
      iOS: DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Reminder: $title',
      body,
      platformChannelSpecifics,
      payload: eventId, // Pass the event ID as the payload
    );
  }

  Future<void> scheduleNotification(
    int id,
    String title,
    String body,
    DateTime scheduledTime,
  ) async {
    if (scheduledTime.isBefore(DateTime.now())) {
      print(
          'Scheduled time is in the past. Notification will not be scheduled.');
      return;
    }

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        'Reminder: $title',
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'reminder_channel',
            'Reminder Channel',
            importance: Importance.high,
            priority: Priority.high,
            color: Color(0xFFFFD700), // Golden color
            styleInformation: BigTextStyleInformation(
              'Reminder: $title\n$body',
              contentTitle: 'Reminder: $title',
              summaryText: body,
            ),
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
        androidScheduleMode: AndroidScheduleMode.exact,
      );
      print('Notification scheduled successfully for $scheduledTime');
    } catch (e) {
      // Log the error more comprehensively (e.g., using a logger library)
      // or provide a user-friendly error message
      print('Error scheduling notification: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
