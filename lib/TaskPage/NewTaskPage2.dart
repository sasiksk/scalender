import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scalender/TaskPage/NewTaskPageHelper.dart';
import 'package:scalender/Widgets/ReminederConfig/ReminderConfigPage.dart';
import 'package:scalender/Data/DatabaseHelper.dart';
import '../Widgets/Categoryconfig/AddCategoryDialog.dart';
import '../Widgets/home/CustomText.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart' as cl;

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
    loadCategories(setState, _category);
    if (widget.eventId != null) {
      loadEventData(widget.eventId!, _titleController, _descriptionController,
          _dateTimeController, _selCat, _isReminderSet, setState);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Task'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 224, 241, 177),
              const Color.fromARGB(255, 184, 222, 241),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
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
              Divider(),
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
                      value: _category.contains(_selCat) ? _selCat : null,
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
                  PopupMenuButton<String>(
                    onSelected: (String value) {
                      if (value == 'Add') {
                        showAddCategoryDialog(context, _category, setState);
                      } else if (value == 'Delete') {
                        showDeleteCategoryDialog(context, _category, setState);
                        setState(() {}); // Reload the dropdown menu
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return {'Add', 'Delete'}.map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        );
                      }).toList();
                    },
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
                    onPressed: () {
                      presentDateTimePicker(
                          context, _dateTimeController, setState);
                    },
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
              Divider(),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _formKey.currentState?.reset();
                        _titleController.clear();
                        _descriptionController.clear();
                        _dateTimeController.clear();
                        setState(() {
                          _selCat = null;
                          _isReminderSet = false;
                          _reminderText = "10 Min Before";
                        });
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Back'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        addTask(
                          formKey: _formKey,
                          titleController: _titleController,
                          descriptionController: _descriptionController,
                          dateTimeController: _dateTimeController,
                          selectedCategory: _selCat,
                          isReminderSet: _isReminderSet,
                          reminderText: _reminderText,
                          eventId: widget.eventId,
                          context: context,
                        );
                      },
                      child: const Text('Add Task'),
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
