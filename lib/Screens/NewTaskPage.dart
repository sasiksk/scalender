import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:scalender/Screens/task_helper.dart';
import 'package:scalender/Widgets/ReminederConfig/ReminderConfigPage.dart';
import 'package:scalender/Data/DatabaseHelper.dart'; // Import DatabaseHelper
import '../Widgets/Categoryconfig/AddCategoryDialog.dart';
import '../Widgets/Categoryconfig/DeleteCategoryDialog.dart';
import '../Widgets/home/CustomText.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart' as cl;

// Import task_helper

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
      final categoryId = eventTask['catid'];
      final category = await db.query(
        'Categories',
        where: 'catid = ?',
        whereArgs: [categoryId],
      );
      if (category.isNotEmpty) {
        _selCat = category.first['name'] as String?;
      }
      setState(() {
        _titleController.text = eventTask['title'];
        _descriptionController.text = eventTask['descr'];
        _dateTimeController.text = eventTask['stdatetime'];
        _selCat = category.first['name'] as String?;

        _isReminderSet = eventTask['alarm'] == 1;
      });
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

  void _showDeleteCategoryDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => DeleteCategoryDialog(categories: _category),
    );
    if (result != null) {
      final categoryName = result;

      if (categoryName.toLowerCase() == 'default') {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Cannot Delete'),
            content: Text('The default category cannot be deleted.'),
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
        return;
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Delete Category'),
          content: Text(
              'Are you sure you want to delete the category "$categoryName"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteCategory(categoryName);
              },
              child: Text('Delete'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _deleteCategory(String categoryName) async {
    try {
      final categoryId = await dbtask.getCategoryId(categoryName);
      final defaultCategoryId = await dbtask.getCategoryId('default');

      await dbtask.updateCategoryId(categoryId, defaultCategoryId);
      await dbcategory.deleteCategory(categoryId);

      setState(() {
        _category.remove(categoryName);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category "$categoryName" deleted.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting category: $e')),
      );
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
          _selCat = categoryName;
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
    await addOrUpdateTask(
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventId != null ? 'Update Task' : 'New Task'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(
                  255, 224, 241, 177), // Light violet (top-left)
              // Lighter blue (middle)
              const Color.fromARGB(
                  255, 184, 222, 241), // Light sky blue (bottom-right)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
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
                Text('Add to Category ',
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: GoogleFonts.tinos().fontFamily)),
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
                            child: Text(category,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontFamily:
                                        GoogleFonts.tinos().fontFamily)),
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
                          _showAddCategoryDialog();
                        } else if (value == 'Delete') {
                          _showDeleteCategoryDialog();
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
                        onTap: _presentDateTimePicker,
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
                Divider(),
                const SizedBox(height: 80),
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
                        onPressed: _addTask, // Call the _addTask function
                        child: const Text('Add Task'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
