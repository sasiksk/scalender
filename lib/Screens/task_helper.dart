import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scalender/Data/DatabaseHelper.dart';
import 'package:scalender/Notifiction/Nofticationhelper.dart';

Future<void> manageNotification(int eventId, DateTime reminderDateTime,
    bool isReminderSet, String title, String description) async {
  final notificationService = NotificationService();

  if (isReminderSet) {
    // If reminder is set, schedule the notification
    await notificationService.scheduleNotification(
      eventId,
      title,
      description,
      reminderDateTime,
    );
  } else {
    // If reminder is not set, cancel the notification
    await notificationService.cancelNotification(eventId);
  }
}

Future<void> addOrUpdateTask({
  required GlobalKey<FormState> formKey,
  required TextEditingController titleController,
  required TextEditingController descriptionController,
  required TextEditingController dateTimeController,
  required String? selectedCategory,
  required bool isReminderSet,
  required String reminderText,
  int? eventId,
  required BuildContext context,
}) async {
  if (formKey.currentState!.validate()) {
    final erid = eventId ?? await DatabaseHelper.getNextEventTaskId();

    DateTime taskDateTime =
        DateFormat('yMMMd').add_jm().parse(dateTimeController.text);
    DateTime? reminderDateTime;

    if (isReminderSet) {
      reminderDateTime =
          dbreminder.calculateReminderTime(reminderText, taskDateTime);

      if (reminderDateTime.isBefore(DateTime.now())) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Invalid Reminder'),
              content: Text(
                  'Cannot set a reminder for a past time. Task not added.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        return; // Exit the function without adding the task
      }
    }

    final catid = await dbtask.getCategoryId(selectedCategory!);
    final newTask = {
      'eid': erid,
      'type': 'Task',
      'title': titleController.text,
      'descr': descriptionController.text,
      'stdatetime': dateTimeController.text,
      'enddatetime': null,
      'catid': catid,
      'status': 'Pending',
      'alarm': isReminderSet ? true : false,
      'reminder_time': isReminderSet ? reminderDateTime.toString() : null,
    };

    if (eventId == null) {
      await dbtask.insertEventTask(newTask);
    } else {
      await dbtask.updateEventTask(newTask, erid);
      // Manage notification for existing task
      await manageNotification(erid, reminderDateTime!, isReminderSet,
          titleController.text, descriptionController.text);
    }

    await checkNotificationPermission();

    // Schedule the notification for new task
    if (eventId == null && isReminderSet) {
      await manageNotification(erid, reminderDateTime!, isReminderSet,
          titleController.text, descriptionController.text);
    }

    // Show a success message or navigate to another page
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(
              'Task ${eventId == null ? 'added' : 'updated'} successfully'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

Future<void> checkNotificationPermission() async {
  try {
    // Check if notification permission is already granted
    if (!await Permission.notification.isGranted) {
      // Request notification permission
      final status = await Permission.notification.request();

      // Check the updated status
      if (status.isGranted) {
        // Reinitialize notifications if permission is granted
        await NotificationService.init();
        print("Permission Granted");
      } else if (status.isDenied) {
        print("Permission Denied. Notifications will not work.");
      } else if (status.isPermanentlyDenied) {
        print(
            "Permission Permanently Denied. Please enable notifications in settings.");
      }
    } else {
      print("Permission already granted.");
    }
  } catch (e) {
    // Handle any unexpected errors
    print("Error while checking or requesting notification permission: $e");
  }
}
