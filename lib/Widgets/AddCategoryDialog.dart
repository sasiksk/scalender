import 'package:flutter/material.dart';
import 'ColorPickerDialog.dart';

class AddCategoryDialog extends StatefulWidget {
  @override
  _AddCategoryDialogState createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final TextEditingController _categoryController = TextEditingController();
  Color _selectedColor = Colors.yellow;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Category'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _categoryController,
            decoration: InputDecoration(labelText: 'Category Name'),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Text('Color:'),
              SizedBox(width: 10),
              GestureDetector(
                onTap: () async {
                  final color = await showDialog<Color>(
                    context: context,
                    builder: (context) =>
                        ColorPickerDialog(initialColor: _selectedColor),
                  );
                  if (color != null) {
                    setState(() {
                      _selectedColor = color;
                    });
                  }
                },
                child: Container(
                  width: 24,
                  height: 24,
                  color: _selectedColor,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'name': _categoryController.text,
              'color': _selectedColor,
            });
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
