import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scalender/Widgets/ReminederConfig/ReminderConfigPage.dart';
import 'package:scalender/Data/DatabaseHelper.dart'; // Import DatabaseHelper
import '../Widgets/AddCategoryDialog.dart';
import '../Widgets/CustomText.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart' as cl;
import 'package:scalender/Notifiction/Nofticationhelper.dart';

class NewTaskPage extends StatefulWidget {
  final int? eventId;

  NewTaskPage({this.eventId});

  @override
  _NewTaskPageState createState() => _NewTaskPageState();
}

class _NewTaskPageState extends State<NewTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  String? _selCat;
  List<String> _category = [];
  bool _isReminderSet = false;

  String _reminderText = "10 Min Before";

  @override
  void initState() {
    super.initState();
    _dateTimeController.text =
        DateFormat('yMMMd').add_jm().format(DateTime.now());
    _loadCategories();
    if (widget.eventId != null) {
      _loadEventData(widget.eventId!);
    }
  }

  Future<void> _loadEventData(int eventId) async {
    final db = await DatabaseHelper.getDatabase();
    final List<Map<String, dynamic>> eventTasks = await db.query(
      'EventTask',
      where: 'eid = ?',
      whereArgs: [eventId],
    );

    if (eventTasks.isNotEmpty) {
      final eventTask = eventTasks.first;
      setState(() {
        _titleController.text = eventTask['title'];
        _descriptionController.text = eventTask['descr'];
        _dateTimeController.text = eventTask['stdatetime'];
        _selCat = eventTask['catname'];
        _isReminderSet = eventTask['alarm'] == 1;
      });
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

  void _loadCategories() async {
    final db = await DatabaseHelper.getDatabase();
    final List<Map<String, dynamic>> categories = await db.query('Categories');
    setState(() {
      _category =
          categories.map((category) => category['name'] as String).toList();
    });
  }

  void _presentDateTimePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          _dateTimeController.text =
              DateFormat('yMMMd').add_jm().format(selectedDateTime);
        });
      }
    }
  }

  void _showAddCategoryDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddCategoryDialog(),
    );
    if (result != null) {
      final categoryName = result['name'];
      var categoryColor = cl.colorToHex(result['color']);

      if (_category.contains(categoryName)) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Category Exists'),
            content: Text('The category "$categoryName" already exists.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        setState(() {
          _category.add(categoryName);
        });

        final newCategory = {
          'name': categoryName,
          'color': categoryColor,
        };

        dbcategory.insertCategory(newCategory);
        _category.add(categoryName.toString());
        print('Category Name: $categoryName, Color: $categoryColor');
      }
    }
  }

  void _addTask() async {
    if (_formKey.currentState!.validate()) {
      final erid = await DatabaseHelper.getNextEventTaskId();

      if (_isReminderSet) {
        DateTime taskDateTime =
            DateFormat('yMMMd').add_jm().parse(_dateTimeController.text);
        DateTime reminderDateTime =
            dbreminder.calculateReminderTime(_reminderText, taskDateTime);

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

        final newTask = {
          'eid': erid,
          'type': 'Task',
          'title': _titleController.text,
          'descr': _descriptionController.text,
          'stdatetime': _dateTimeController.text,
          'enddatetime': null,
          'catname': _selCat,
          'status': 'Pending',
          'alarm': _isReminderSet ? true : false,
          'reminder_time': _isReminderSet ? reminderDateTime.toString() : null,
        };

        await dbtask.insertEventTask(newTask);

        await checkNotificationPermission();

        // Schedule the notification

        if (reminderDateTime.isBefore(DateTime.now())) {
          print(
              'Scheduled time is in the past. Notification will not be scheduled.');
          return;
        } else {
          final notificationService = NotificationService();
          await notificationService.scheduleNotification(
              erid,
              _titleController.text,
              _descriptionController.text,
              reminderDateTime);
        }
      }

      // Show a success message or navigate to another page
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Task added successfully'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _titleController,
                labelText: 'Title',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Description',
                hintText: 'Enter description here',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Add to Category '),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(width: 1),
                        ),
                      ),
                      value: _selCat,
                      items: _category.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selCat = newValue!;
                        });
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: _showAddCategoryDialog,
                    icon: const Icon(
                      Icons.playlist_add_circle,
                      size: 30,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _dateTimeController,
                      labelText: 'Date & Time',
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please select a date and time';
                        }
                        return null;
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: _presentDateTimePicker,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _isReminderSet,
                    onChanged: (value) {
                      setState(() {
                        _isReminderSet = value!;
                      });
                    },
                  ),
                  const Text('Set Alarm'),
                  if (_isReminderSet)
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.alarm),
                          onPressed: () async {
                            final result = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                content: ReminderConfigPage(),
                              ),
                            );
                            if (result != null) {
                              setState(() {
                                _reminderText = result;
                              });
                            }
                          },
                        ),
                        Text(_reminderText),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _addTask, // Call the _addTask function
                  child: const Text('Add Task'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
