import 'package:flutter/material.dart';
import '../../others/widgets/reusables/app_drawer.dart';
import 'body_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(Icons.menu, color: Colors.white, size: 25),
            );
          },
        ),

        backgroundColor: Colors.orange[600],
        title: Text(
          'Africa\'s Talking',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium!.apply(color: Colors.white),
        ),
      ),
      drawer: AppDrawer(),
      body: BodyScreen(),
    );
  }
}
