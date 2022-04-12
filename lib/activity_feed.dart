import 'package:flutter/material.dart';



class ActivityFeedPage extends StatefulWidget {
  const ActivityFeedPage({Key? key}) : super(key: key);

  @override
  State<ActivityFeedPage> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<ActivityFeedPage> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(child: Text('You have pressed the button $_count times.')),
      backgroundColor: Colors.blueGrey.shade200,
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _count++),
        tooltip: 'Increment Counter',
        child: const Icon(Icons.add),
      ),
    );
  }
}