import 'package:flutter/material.dart';

class StudentCard extends StatelessWidget {
  final String name;
  const StudentCard(this.name, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(name, style: const TextStyle(fontSize: 20));
  }
}