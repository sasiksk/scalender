import 'package:flutter/material.dart';
import 'package:scalender/Widgets/CalendarPage.dart';
import 'package:scalender/Widgets/FloatingActionButtonWidget.dart';
import 'package:scalender/Widgets/custom_app_bar.dart';
// Import the NotificationHelper
import 'Widgets/calender_drawer.dart'; // Import the separate file for the Drawer.

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    // TODO: implement setState
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: CalendarDrawer(), // Drawer loaded from a separate file.
      body: CustomScrollView(
        slivers: [
          CustomSliverAppBar(),
          SliverFillRemaining(
            child: Column(
              spacing: 3,
              children: [
                CalendarPage(),
                Divider(
                  height: 1,
                  thickness: 1,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButtonWidget(),
    );
  }
}
