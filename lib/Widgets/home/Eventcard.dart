import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scalender/HomePage.dart';
import 'package:scalender/Notifiction/Nofticationhelper.dart';
import 'package:scalender/Screens/NewTaskPage.dart';
import '../../Data/DatabaseHelper.dart';
import '../../Data/Event.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final bool isChecked;

  EventCard({required this.event, this.isChecked = false});

  Future<void> _handleCheckboxToggle(BuildContext context, Event event) async {
    bool? result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              event.status == 'Completed' ? 'Mark as Pending?' : 'Completed?'),
          content: Text(event.status == 'Completed'
              ? 'Do you want to mark this event as pending?'
              : 'Do you want to mark this event as completed?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      // Determine the new status
      String newStatus = event.status == 'Completed' ? 'Pending' : 'Completed';

      // Update the status in the database
      final db = await DatabaseHelper.getDatabase();
      await db.update(
        'EventTask',
        {'status': newStatus},
        where: 'eid = ?',
        whereArgs: [event.id],
      );

      // Update the status in the UI
      event.status = newStatus;
      (context as Element).markNeedsBuild();

      // Check if the notification needs to be canceled
      if (newStatus == 'Completed' && event.alarm) {
        await NotificationService().cancelNotification(event.id);
      }
    }
  }

  Future<void> _deleteEvent(BuildContext context, int eventId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete this event?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final db = await DatabaseHelper.getDatabase();
                await db.delete(
                  'EventTask',
                  where: 'eid = ?',
                  whereArgs: [eventId],
                );
                await NotificationService().cancelNotification(eventId);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => HomePage()),
                  (Route<dynamic> route) => false,
                );
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _updateEvent(BuildContext context, int eventId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewTaskPage(eventId: eventId),
      ),
    );
  }

  void _showEventDetailsDialog(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.blueAccent, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'Title:${event.title}',
                  style: TextStyle(
                    fontFamily: 'Times New Roman',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyan,
                  ),
                ),
                Divider(
                  color: Colors.black,
                ),

                // Details
                SizedBox(
                  child: Text(
                    'Description: ${event.description}',
                    style: TextStyle(
                      fontFamily: 'Times New Roman',
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Due: ${DateFormat('yMMMd').add_jm().format(event.date)}',
                  style: TextStyle(
                    fontFamily: 'Times New Roman',
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Status: ${event.status}',
                  style: TextStyle(
                    fontFamily: 'Times New Roman',
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Alarm: ${event.alarm ? "Set" : "Not Set"}',
                  style: TextStyle(
                    fontFamily: 'Times New Roman',
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _updateEvent(context, event.id);
                      },
                      child: Text(
                        'Edit',
                        style: TextStyle(
                          fontFamily: 'Times New Roman',
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Close',
                        style: TextStyle(
                          fontFamily: 'Times New Roman',
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _deleteEvent(context, event.id);
                      },
                      child: Text(
                        'Delete',
                        style: TextStyle(
                          fontFamily: 'Times New Roman',
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      //onTap: () => _updateEvent(context, event.id),
      onLongPress: () => _showEventDetailsDialog(context, event),

      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  // First Column
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      icon: Icon(
                        event.status == 'Pending'
                            ? Icons.check_box_outline_blank
                            : Icons.check_box,
                        color: event.status == 'Pending'
                            ? Colors.grey
                            : Colors.red,
                        size: 17,
                      ),
                      onPressed: () {
                        _handleCheckboxToggle(context, event);
                      },
                    ),
                  ),
                  // Second Column
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: isChecked
                              ? const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.red,
                                  fontSize: 14,
                                )
                              : const TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 2, 1, 41),
                                  fontWeight: FontWeight.bold,
                                ),
                        ),
                        Text(
                          'Due: ${DateFormat('jm').format(event.date)}',
                          overflow: TextOverflow.ellipsis,
                          style: isChecked
                              ? const TextStyle(
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.red,
                                )
                              : const TextStyle(
                                  fontSize: 12,
                                  color: Color.fromARGB(255, 2, 1, 41),
                                ),
                        ),
                      ],
                    ),
                  ),
                  // Third Column
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.description.length > 15
                              ? '${event.description.substring(0, 15)}...'
                              : event.description,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: isChecked
                              ? const TextStyle(
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.red,
                                )
                              : const TextStyle(
                                  fontSize: 12,
                                  color: Color.fromARGB(255, 2, 1, 41),
                                ),
                        ),
                        Text(
                          'Status: ${event.status}',
                          overflow: TextOverflow.ellipsis,
                          style: isChecked
                              ? const TextStyle(
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.red,
                                )
                              : const TextStyle(
                                  fontSize: 12,
                                  color: Color.fromARGB(255, 2, 1, 41),
                                ),
                        ),
                      ],
                    ),
                  ),
                  // Fourth Column
                  Expanded(
                    flex: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            event.alarm ? Icons.alarm : Icons.alarm_off,
                            color: Colors.red,
                            size: 16,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(event.alarm
                                    ? 'Alarm is set for this event.'
                                    : 'Alarm is not set for this event.'),
                              ),
                            );
                          },
                        ),
                        PopupMenuButton<String>(
                          onSelected: (String value) {
                            if (value == 'Update') {
                              _updateEvent(context, event.id);
                            } else if (value == 'Delete') {
                              _deleteEvent(context, event.id);
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return {'Update', 'Delete'}.map((String choice) {
                              return PopupMenuItem<String>(
                                value: choice,
                                child: Text(choice),
                              );
                            }).toList();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
