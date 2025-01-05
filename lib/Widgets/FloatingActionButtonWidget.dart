import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../Screens/NewEventPage.dart';
import '../Screens/NewTaskPage.dart';

class FloatingActionButtonWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.add_event,
      backgroundColor: const Color.fromARGB(255, 157, 68, 240),
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      children: [
        SpeedDialChild(
          child: Icon(Icons.event, color: Colors.white, size: 30),
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          label: 'Add Event',
          labelStyle: TextStyle(
            fontSize: 16.0,
            color: Colors.black87,
          ),
          labelBackgroundColor: Colors.white,
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => NewEventPage()));
          },
        ),
        SpeedDialChild(
          child: Icon(Icons.task, color: Colors.white, size: 30),
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          label: 'Add Task',
          labelStyle: TextStyle(
            fontSize: 16.0,
            color: Colors.black87,
          ),
          labelBackgroundColor: Colors.white,
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => NewTaskPage()));
          },
        ),
      ],
    );
  }
}
