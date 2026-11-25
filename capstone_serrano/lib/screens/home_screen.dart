import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/firestore_service.dart';
import 'detail_screen.dart';
import 'summary_screen.dart';
import 'session_screen.dart';
import 'checkin_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final db = FirestoreService();
  late Future<List<Student>> future = db.getStudents();

  void refresh() {
    setState(() {
      future = db.getStudents();
    });
  }

  void showNameDialog({Student? student}) {
    final controller = TextEditingController(text: student?.name ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(student == null ? 'Add Student' : 'Edit Student'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(context);
              if (student == null) {
                await db.addStudent(name);
              } else {
                await db.updateName(student.id, name);
              }
              refresh();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text('Attendance Checker'),
  actions: [
    IconButton(
      icon: const Icon(Icons.qr_code),
      tooltip: 'Start Session',
      onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const SessionScreen())),
    ),
    IconButton(
      icon: const Icon(Icons.bar_chart),
      tooltip: 'Summary',
      onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const SummaryScreen())),
    ),
        IconButton(
      icon: const Icon(Icons.how_to_reg),
      tooltip: 'Check In',
      onPressed: () async {
        await Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CheckInScreen()));
        refresh();
      },
    ),
  ],
),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showNameDialog(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Student>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final students = snapshot.data!;
          if (students.isEmpty) {
            return const Center(child: Text('No students yet'));
          }
          return ListView(
            children: [
              for (var s in students)
                ListTile(
                  leading: Checkbox(
                    value: s.isPresent,
                    onChanged: (v) async {
                      await db.setPresent(s.id, v ?? false);
                      refresh();
                    },
                  ),
                  title: Text(s.name),
                  subtitle: Text(s.isPresent ? 'Present' : 'Absent'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DetailScreen(s.name)),
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => showNameDialog(student: s),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await db.deleteStudent(s.id);
                          refresh();
                        },
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}