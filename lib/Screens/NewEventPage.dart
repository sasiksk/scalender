import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scalender/Data/DatabaseHelper.dart';
import 'package:scalender/Widgets/Categoryconfig/AddCategoryDialog.dart';
import 'package:scalender/Widgets/ReminederConfig/ReminderConfigPage.dart';
import '../Widgets/home/CustomText.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart' as cl;

class NewEventPage extends StatefulWidget {
  @override
  _NewEventPageState createState() => _NewEventPageState();
}

class _NewEventPageState extends State<NewEventPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  String? _selCat;
  List<String> _category = [];
  bool _isReminderSet = false;

  String _reminderText = "10 Min Before";

  @override
  void initState() {
    super.initState();
    _startDateController.text = DateFormat('yMMMd').format(DateTime.now());
    _endDateController.text = DateFormat('yMMMd').format(DateTime.now());
    _loadCategories();
  }

  void _loadCategories() async {
    final db = await DatabaseHelper.getDatabase();
    final List<Map<String, dynamic>> categories = await db.query('Categories');
    setState(() {
      _category =
          categories.map((category) => category['name'] as String).toList();
    });
  }

  void _addEvent() async {
    if (_formKey.currentState!.validate()) {
      final erid = await DatabaseHelper.getNextEventTaskId();

      if (_isReminderSet) {
        DateTime eventDateTime =
            DateFormat('yMMMd').add_jm().parse(_startDateController.text);
        DateTime reminderDateTime =
            dbreminder.calculateReminderTime(_reminderText, eventDateTime);

        if (reminderDateTime.isBefore(DateTime.now())) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Invalid Reminder'),
                content: Text(
                    'Cannot set a reminder for a past time. Event not added.'),
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
          return; // Exit the function without adding the event
        }
        final newEvent = {
          'eid': erid,
          'type': 'Event',
          'title': _titleController.text,
          'descr': _descriptionController.text,
          'stdatetime': _startDateController.text,
          'enddatetime': _endDateController.text,
          'catname': _selCat,
          'status': 'Pending',
          'alarm': _isReminderSet ? true : false,
          'reminder_time':
              DateFormat('yMMMd').add_jm().format(reminderDateTime),
        };
        final newReminder = {
          'rid': erid,
          'reminder_time':
              DateFormat('yMMMd').add_jm().format(reminderDateTime),
          'reminder_text': _titleController.text,
        };

        await dbtask.insertEventTask(newEvent);
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Event added successfully'),
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

  void _presentDateTimePicker(TextEditingController controller) async {
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
        final pickedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          controller.text = DateFormat('yMMMd').add_jm().format(pickedDateTime);
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

        print('Category Name: $categoryName, Color: $categoryColor');
        _category.add(categoryName.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Event'),
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
                      controller: _startDateController,
                      labelText: 'Start Date',
                      readOnly: true,
                      onTap: () => _presentDateTimePicker(_startDateController),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please select a start date';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _endDateController,
                      labelText: 'End Date',
                      readOnly: true,
                      onTap: () => _presentDateTimePicker(_endDateController),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please select an end date';
                        }
                        DateTime startDate = DateFormat('yMMMd')
                            .add_jm()
                            .parse(_startDateController.text);
                        DateTime endDate =
                            DateFormat('yMMMd').add_jm().parse(value);
                        if (endDate.isBefore(startDate)) {
                          return 'End date must be after start date';
                        }
                        return null;
                      },
                    ),
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
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReminderConfigPage(),
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _addEvent();
                    }
                  },
                  child: const Text('Add Event'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
