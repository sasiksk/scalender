import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scalender/Data/DatabaseHelper.dart';
import 'package:scalender/Widgets/Categoryconfig/AddCategoryDialog.dart';

import 'package:flutter_colorpicker/flutter_colorpicker.dart' as cl;

Future<void> loadEventData(
    int eventId,
    TextEditingController titleController,
    TextEditingController descriptionController,
    TextEditingController dateTimeController,
    String? selCat,
    bool isReminderSet,
    Function setState) async {
  final db = await DatabaseHelper.getDatabase();
  final List<Map<String, dynamic>> eventTasks = await db.query(
    'EventTask',
    where: 'eid = ?',
    whereArgs: [eventId],
  );

  if (eventTasks.isNotEmpty) {
    final eventTask = eventTasks.first;
    setState(() {
      titleController.text = eventTask['title'];
      descriptionController.text = eventTask['descr'];
      dateTimeController.text = eventTask['stdatetime'];
      selCat = eventTask['catname'];
      isReminderSet = eventTask['alarm'] == 1;
    });
  }
}

Future<void> loadCategories(Function setState, List<String> category) async {
  final db = await DatabaseHelper.getDatabase();
  final List<Map<String, dynamic>> categories = await db.query('Categories');
  setState(() {
    category =
        categories.map((category) => category['name'] as String).toList();
  });
}

Future<void> presentDateTimePicker(BuildContext context,
    TextEditingController dateTimeController, Function setState) async {
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
        dateTimeController.text =
            DateFormat('yMMMd').add_jm().format(selectedDateTime);
      });
    }
  }
}

Future<void> showDeleteCategoryDialog(
    BuildContext context, List<String> category, Function setState) async {
  final result = await showDialog<String>(
    context: context,
    builder: (context) => DeleteCategoryDialog(categories: category),
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
              await deleteCategory(context, categoryName, category, setState);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}

Future<void> deleteCategory(BuildContext context, String categoryName,
    List<String> category, Function setState) async {
  try {
    final categoryId = await dbtask.getCategoryId(categoryName);
    final defaultCategoryId = await dbtask.getCategoryId('default');

    await dbtask.updateCategoryId(categoryId, defaultCategoryId);
    await dbcategory.deleteCategory(categoryId);

    setState(() {
      category.remove(categoryName);
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

Future<void> showAddCategoryDialog(
    BuildContext context, List<String> category, Function setState) async {
  final result = await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) => AddCategoryDialog(),
  );
  if (result != null) {
    final categoryName = result['name'];
    var categoryColor = cl.colorToHex(result['color']);

    if (category.contains(categoryName)) {
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
      setState(() {});

      final newCategory = {
        'name': categoryName,
        'color': categoryColor,
      };

      dbcategory.insertCategory(newCategory);
      category.add(categoryName.toString());
      print('Category Name: $categoryName, Color: $categoryColor');
    }
  }
}

Future<void> addTask({
  required GlobalKey<FormState> formKey,
  required TextEditingController titleController,
  required TextEditingController descriptionController,
  required TextEditingController dateTimeController,
  required String? selectedCategory,
  required bool isReminderSet,
  required String reminderText,
  required int? eventId,
  required BuildContext context,
}) async {
  await addTask(
    formKey: formKey,
    titleController: titleController,
    descriptionController: descriptionController,
    dateTimeController: dateTimeController,
    selectedCategory: selectedCategory,
    isReminderSet: isReminderSet,
    reminderText: reminderText,
    eventId: eventId,
    context: context,
  );
}

class DeleteCategoryDialog extends StatelessWidget {
  final List<String> categories;

  DeleteCategoryDialog({required this.categories});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Category to Delete'),
      content: SingleChildScrollView(
        child: Column(
          children: categories.map((category) {
            return ListTile(
              title: Text(category),
              onTap: () {
                Navigator.pop(context, category);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
