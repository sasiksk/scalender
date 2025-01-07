import 'package:flutter/material.dart';
import 'package:scalender/Widgets/ReminederConfig/CustomReminderDialog.dart';

class ReminderConfigPage extends StatefulWidget {
  const ReminderConfigPage({super.key});

  @override
  _ReminderConfigPageState createState() => _ReminderConfigPageState();
}

class _ReminderConfigPageState extends State<ReminderConfigPage> {
  String _reminderText = "10 Min Before"; // Default reminder text

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Reminder Time"),
      ),
      body: ListView(
        children: [
          _buildListTile("At Start"),
          _buildListTile("1 Min Before"),
          _buildListTile("5 Min Before"),
          _buildListTile("10 Min Before"),
          _buildListTile("30 Min Before"),
          _buildListTile("1 Hour Before"),
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

  ListTile _buildListTile(String text) {
    return ListTile(
      title: Text(text),
      onTap: () {
        setState(() {
          _reminderText = text;
        });
        Navigator.pop(context, _reminderText);
      },
    );
  }
}
