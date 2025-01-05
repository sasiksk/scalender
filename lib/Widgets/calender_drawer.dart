import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:scalender/Data/DatabaseHelper.dart';
import 'package:scalender/HomePage.dart';
import 'package:scalender/Report.dart';

class CalendarDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        width: 250, // Set the width of the drawer

        child: SafeArea(
          child: Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.green),
                child: Text(
                  'Simple Task Calendar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              Slidable(
                key: const ValueKey(0),
                startActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        Navigator.pop(context); // Close drawer.
                      },
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      icon: Icons.home,
                      label: 'Home',
                    ),
                  ],
                ),
                child: ListTile(
                  leading: Icon(Icons.home),
                  title: Text('Home'),
                  onTap: () {
                    Navigator.pop(context); // Close drawer.
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    ); // Navigate to Report.
                  },
                ),
              ),
              Slidable(
                key: const ValueKey(1),
                startActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        Navigator.pop(context); // Close drawer.
                      },
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      icon: Icons.calendar_today,
                      label: 'Calendar',
                    ),
                  ],
                ),
                child: ListTile(
                  leading: Icon(Icons.calendar_today),
                  title: Text('Calendar'),
                  onTap: () {
                    Navigator.pop(context); // Close drawer.
                  },
                ),
              ),
              Slidable(
                key: const ValueKey(2),
                startActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        Navigator.pop(context); // Close drawer.
                      },
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      icon: Icons.settings,
                      label: 'Settings',
                    ),
                  ],
                ),
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  onTap: () {
                    Navigator.pop(context); // Close drawer.
                  },
                ),
              ),
              Slidable(
                key: const ValueKey(3),
                startActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DatabaseHelperPage()),
                        ); // Navigate to DatabaseHelperPage.
                      },
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      icon: Icons.data_thresholding,
                      label: 'Database helper',
                    ),
                  ],
                ),
                child: ListTile(
                  leading: Icon(Icons.data_thresholding),
                  title: Text('Database helper'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DatabaseHelperPage()),
                    ); // Navigate to DatabaseHelperPage.
                  },
                ),
              ),
              Slidable(
                key: const ValueKey(4),
                startActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        DatabaseHelper
                            .dropDatabase(); // Call dropDatabase function.
                        Navigator.pop(context); // Close drawer.
                      },
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      icon: Icons.arrow_drop_down_circle_sharp,
                      label: 'Drop database',
                    ),
                  ],
                ),
                child: ListTile(
                  leading: Icon(Icons.arrow_drop_down_circle_sharp),
                  title: Text('Drop database'),
                  onTap: () {
                    DatabaseHelper
                        .dropDatabase(); // Call dropDatabase function.
                    Navigator.pop(context); // Close drawer.
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
