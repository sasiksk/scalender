import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scalender/HomePage.dart';

class CustomSliverAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const CustomSliverAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.blue.shade300,
      title: Text('Task Calendar'),
      centerTitle: true,
      floating: true,
      snap: true,
      actions: [
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomePage()));
          },
        ),
        IconButton(
          icon: Icon(Icons.exit_to_app),
          onPressed: () {
            SystemNavigator.pop();
          },
        ),
      ],
    );
  }
}
