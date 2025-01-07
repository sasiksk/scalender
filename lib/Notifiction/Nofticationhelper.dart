/*import 'dart:ui';

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
}*/

import 'dart:io';
import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Callback for foreground and background notifications
  static Future<void> onDidReceiveNotification(
      NotificationResponse notificationResponse) async {
    print("Notification received: ${notificationResponse.payload}");
  }

  // Initialize notification service
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

    // Initialize time zones
    await initializeTimeZone();

    // Create notification channels
    await createNotificationChannels();

    // Request notification permissions
    await requestNotificationPermission();
  }

  // Initialize time zones
  static Future<void> initializeTimeZone() async {
    tz.initializeTimeZones();
  }

  // Create notification channels
  static Future<void> createNotificationChannels() async {
    const AndroidNotificationChannel instantNotificationChannel =
        AndroidNotificationChannel(
      'instant_notification_channel_id_SK', // Unique channel ID
      'Instant Notifications_SK', // Name of the channel
      description: 'Channel for instant notifications', // Description
      importance: Importance.max,
    );

    const AndroidNotificationChannel reminderChannel =
        AndroidNotificationChannel(
      'reminder_channel_SK', // Unique channel ID
      'Reminder Channel_SK', // Name of the channel
      description: 'Channel for scheduled reminders', // Description
      importance: Importance.high,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation
          .createNotificationChannel(instantNotificationChannel);
      await androidImplementation.createNotificationChannel(reminderChannel);
    }
  }

  // Show instant notification
  static Future<void> showInstantNotification(
      String title, String body, String eventId) async {
    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        'instant_notification_channel_id_SK', // Must match created channel ID
        'Instant Notifications_SK',
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
      0, // Notification ID
      'Reminder: $title',
      body,
      platformChannelSpecifics,
      payload: eventId, // Pass event ID as payload
    );
  }

  // Schedule notification
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
            'reminder_channel_SK', // Must match created channel ID
            'Reminder Channel_SK',
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
      print('Error scheduling notification: $e');
    }
  }

  // Cancel notification
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  // Request notification permissions
  static Future<void> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      // Handle Android permissions (Android 13+)
      final androidPlugin =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final bool? granted1 =
            await androidPlugin.requestExactAlarmsPermission();
        final bool? granted2 =
            await androidPlugin.requestNotificationsPermission();
        final granted = granted1! && granted2!;
        if (granted == true) {
          print("Android notification permissions granted.");
        } else {
          print("Android notification permissions denied.");
        }
      }
    } else if (Platform.isIOS) {
      // Handle iOS permissions
      final bool? permissionGranted = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      if (permissionGranted == true) {
        print("iOS notification permissions granted.");
      } else {
        print("iOS notification permissions denied.");
      }
    }
  }
}
