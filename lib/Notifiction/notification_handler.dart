//final GlobalKey<_HomePageState> homePageKey = GlobalKey<_HomePageState>();
/*import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    tz.initializeTimeZones();

    if (await Permission.notification.isGranted) {
      print('Permission granted for notifications');
    } else {
      await Permission.notification.request();
      if (await Permission.notification.isGranted) {
        print('Permission granted for notifications');
      } else {
        print('Permission denied for notifications');
      }
    }
  }

  static Future<void> scheduleNotification(
      int tid, String tododetails, DateTime scheduledTime) async {
    final tz.TZDateTime tzScheduledTime =
        tz.TZDateTime.from(scheduledTime, tz.local);
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'yourChannelId',
      'YourChannelName',
      channelDescription: 'YourChannelDescription',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      tid,
      'Reminder',
      'It\'s time for your event: $tododetails',
      tzScheduledTime,
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
          androidScheduleMode: 
      androidAllowWhileIdle: true,
    );
  }

  static Future<void> cancelNotification(int tid) async {
    await flutterLocalNotificationsPlugin.cancel(tid);
  }

  static Future<void> scheduleDailyNotification(List<String> todoList) async {
    // Cancel the previous daily notification if any
    await cancelNotification(0);

    if (todoList.isEmpty) {
      // No need to schedule a notification if the to-do list is empty
      return;
    }

    // Get the current date
    final now = DateTime.now();

    // Schedule a notification for 8 AM every day
    final scheduledTime = DateTime(now.year, now.month, now.day, 8, 0);
    await scheduleNotification(
        0, 'Today\'s To-Do List: ${todoList.join(', ')}', scheduledTime);
  }

  static Future<void> updateToDoListNotification(List<String> todoList) async {
    // Update or cancel the daily notification based on the current to-do list
    await scheduleDailyNotification(todoList);
  }
}*/
