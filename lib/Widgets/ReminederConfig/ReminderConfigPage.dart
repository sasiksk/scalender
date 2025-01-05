import 'package:flutter/material.dart';
import 'package:scalender/Widgets/ReminederConfig/CustomReminderDialog.dart';

class ReminderConfigPage extends StatefulWidget {
  const ReminderConfigPage({super.key});

  @override
  _ReminderConfigPageState createState() => _ReminderConfigPageState();
}

class _ReminderConfigPageState extends State<ReminderConfigPage> {
  String _reminderText = "10 Min Before"; // Default reminder text
  String _customUnit = "minutes"; // Initialize the custom unit variable
  String _customValue = ""; // Initialize the custom value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Reminder Time"),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text("At Start"),
            onTap: () {
              setState(() {
                _reminderText = "At Start";
              });
              Navigator.pop(context, _reminderText);
            },
          ),
          ListTile(
            title: Text("1 Min Before"),
            onTap: () {
              setState(() {
                _reminderText = "1 Min Before";
              });
              Navigator.pop(context, _reminderText);
            },
          ),
          ListTile(
            title: Text("5 Min Before"),
            onTap: () {
              setState(() {
                _reminderText = "5 Min Before";
              });
              Navigator.pop(context, _reminderText);
            },
          ),
          ListTile(
            title: Text("10 Min Before"),
            onTap: () {
              setState(() {
                _reminderText = "10 Min Before";
              });
              Navigator.pop(context, _reminderText);
            },
          ),
          ListTile(
            title: Text("30 Min Before"),
            onTap: () {
              setState(() {
                _reminderText = "30 Min Before";
              });
              Navigator.pop(context, _reminderText);
            },
          ),
          ListTile(
            title: Text("1 Hour Before"),
            onTap: () {
              setState(() {
                _reminderText = "1 Hour Before";
              });
              Navigator.pop(context, _reminderText);
            },
          ),
          ListTile(
            title: Text("Custom"),
            onTap: () async {
              final result = await showDialog<String>(
                context: context,
                builder: (BuildContext context) {
                  return CustomReminderDialog();
                },
              );
              if (result != null) {
                setState(() {
                  _reminderText = result;
                });
                Navigator.pop(context, _reminderText);
              }
            },
          ),
        ],
      ),
    );
  }
}
