import 'package:flutter/material.dart';
import '../models/student.dart';
import 'detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Checker')),
      body: ListView(
        children: [
          for (var s in students)
            ListTile(
              title: Text(s.name),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DetailScreen(s.name)),
                );
              },
            ),
        ],
      ),
    );
  }
}