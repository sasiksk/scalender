import 'package:flutter/material.dart';

class CustomReminderDialog extends StatefulWidget {
  @override
  _CustomReminderDialogState createState() => _CustomReminderDialogState();
}

class _CustomReminderDialogState extends State<CustomReminderDialog> {
  String _customValue = '';
  String _customUnit = 'minutes';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Custom Reminder"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: "Enter value",
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                _customValue = value;
              });
            },
          ),
          ListTile(
            title: Text("Minutes"),
            leading: Radio(
              value: "minutes",
              groupValue: _customUnit,
              onChanged: (value) {
                setState(() {
                  _customUnit = value as String;
                });
              },
            ),
          ),
          ListTile(
            title: Text("Hours"),
            leading: Radio(
              value: "hours",
              groupValue: _customUnit,
              onChanged: (value) {
                setState(() {
                  _customUnit = value as String;
                });
              },
            ),
          ),
          ListTile(
            title: Text("Days"),
            leading: Radio(
              value: "days",
              groupValue: _customUnit,
              onChanged: (value) {
                setState(() {
                  _customUnit = value as String;
                });
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            final reminderText = "$_customValue $_customUnit Before";
            Navigator.pop(context, reminderText);
          },
          child: Text("Set"),
        ),
      ],
    );
  }
}
