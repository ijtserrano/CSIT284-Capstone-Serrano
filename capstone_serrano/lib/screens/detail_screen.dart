import 'package:flutter/material.dart';
import '../widgets/student_card.dart';

class DetailScreen extends StatelessWidget {
  final String name;
  const DetailScreen(this.name, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student')),
      body: Center(child: StudentCard(name)),
    );
  }
}