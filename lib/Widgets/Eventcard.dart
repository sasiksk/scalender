import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scalender/Screens/NewTaskPage.dart';
import '../Data/DatabaseHelper.dart';
import '../Event.dart';

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
    }
  }

  Future<void> _deleteEvent(BuildContext context, int eventId) async {
    final db = await DatabaseHelper.getDatabase();
    await db.delete(
      'EventTask',
      where: 'eid = ?',
      whereArgs: [eventId],
    );
    (context as Element).markNeedsBuild();
  }

  void _updateEvent(BuildContext context, int eventId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewTaskPage(eventId: eventId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: isChecked
                              ? const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.red,
                                  fontSize: 16,
                                )
                              : const TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 2, 1, 41),
                                  fontWeight: FontWeight.bold,
                                ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          event.description.length > 15
                              ? '${event.description.substring(0, 15)}...'
                              : event.description,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: isChecked
                              ? const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.red,
                                )
                              : const TextStyle(
                                  color: Color.fromARGB(255, 2, 1, 41),
                                ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Due: ${DateFormat('jm').format(event.date)}',
                          overflow: TextOverflow.ellipsis,
                          style: isChecked
                              ? const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.red,
                                )
                              : const TextStyle(
                                  color: Color.fromARGB(255, 2, 1, 41),
                                ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Status: ${event.status}',
                          overflow: TextOverflow.ellipsis,
                          style: isChecked
                              ? const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.red,
                                )
                              : const TextStyle(
                                  color: Color.fromARGB(255, 2, 1, 41),
                                ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          event.status == 'Pending'
                              ? Icons.check_box_outline_blank
                              : Icons.check_box,
                          color: event.status == 'Pending'
                              ? Colors.grey
                              : Colors.red,
                        ),
                        onPressed: () {
                          _handleCheckboxToggle(context, event);
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
