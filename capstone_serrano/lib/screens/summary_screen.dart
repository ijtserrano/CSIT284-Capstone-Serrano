import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/firestore_service.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = FirestoreService();
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Summary')),
      body: FutureBuilder<List<Student>>(
        future: db.getStudents(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final students = snapshot.data!;
          final present = students.where((s) => s.isPresent).length;
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Total: ${students.length}',
                    style: const TextStyle(fontSize: 22)),
                Text('Present: $present',
                    style: const TextStyle(fontSize: 22, color: Colors.green)),
                Text('Absent: ${students.length - present}',
                    style: const TextStyle(fontSize: 22, color: Colors.red)),
              ],
            ),
          );
        },
      ),
    );
  }
}