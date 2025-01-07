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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.blueAccent, width: 2),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(
                  255, 228, 230, 224), // Light violet (top-left)
              // Lighter blue (middle)
              const Color.fromARGB(255, 184, 222, 241),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add New Category',
                style: TextStyle(
                  fontFamily: 'Times New Roman',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyan,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                style: TextStyle(
                    fontFamily: 'Times New Roman',
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: 'Category Name',
                  labelStyle: TextStyle(fontFamily: 'Times New Roman'),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'Color:',
                    style: TextStyle(
                        fontFamily: 'Times New Roman', color: Colors.cyan),
                  ),
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
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                          fontFamily: 'Times New Roman', color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        'name': _categoryController.text,
                        'color': _selectedColor,
                      });
                    },
                    child: Text(
                      'Add',
                      style: TextStyle(fontFamily: 'Times New Roman'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
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
