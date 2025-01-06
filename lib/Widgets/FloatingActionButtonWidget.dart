import 'package:flutter/material.dart';
import '../Screens/NewTaskPage.dart';

class FloatingActionButtonWidget extends StatefulWidget {
  @override
  _FloatingActionButtonWidgetState createState() =>
      _FloatingActionButtonWidgetState();
}

class _FloatingActionButtonWidgetState
    extends State<FloatingActionButtonWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Container(
          height: 60.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
          if (_isExpanded) {
            Future.delayed(Duration(milliseconds: 300), () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewTaskPage()),
              );
            });
          }
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200), // Slightly faster expansion
          width: _isExpanded ? 150.0 : 56.0,
          height: 56.0,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 157, 68, 240),
            borderRadius: BorderRadius.circular(28.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: Colors.white),
              if (_isExpanded)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Add Task',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
