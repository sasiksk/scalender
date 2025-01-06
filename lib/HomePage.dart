import 'package:flutter/material.dart';
import 'package:scalender/Widgets/CalendarPage.dart';
import 'package:scalender/Widgets/calender_drawer.dart';
import 'package:scalender/Widgets/custom_app_bar.dart';
import '../Screens/NewTaskPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: CalendarDrawer(),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              CustomSliverAppBar(),
              SliverFillRemaining(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: CalendarPage(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        shape: const CircularNotchedRectangle(),
        notchMargin: 5.0,
        clipBehavior: Clip.antiAlias,
        child: Container(
          height: kBottomNavigationBarHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 152, 142, 245),
                const Color.fromARGB(255, 184, 222, 241),
                const Color.fromARGB(255, 111, 197, 240),
                const Color.fromARGB(255, 152, 142, 245),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {
                  setState(() {});
                },
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  setState(() {});
                },
              ),
              SizedBox(width: 56.0), // Space for the floating action button
              IconButton(
                icon: const Icon(Icons.favorite_border_outlined),
                onPressed: () {
                  setState(() {});
                },
              ),
              IconButton(
                icon: const Icon(Icons.account_circle_outlined),
                onPressed: () {
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 152, 142, 245),
              const Color.fromARGB(255, 184, 222, 241),
              const Color.fromARGB(255, 111, 197, 240),
              const Color.fromARGB(255, 152, 142, 245),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.add, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewTaskPage()),
                );
              },
              iconSize: 24.0,
            ),
          ],
        ),
      ),
    );
  }
}
