import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/firestore_service.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final db = FirestoreService();
  final codeController = TextEditingController();
  late Future<List<Student>> future = db.getStudents();
  Student? selected;
  String message = '';

  Future<void> checkIn() async {
    if (selected == null) {
      setState(() => message = 'Select your name first');
      return;
    }
    final ok = await db.sessionExists(codeController.text.trim());
    if (!ok) {
      setState(() => message = 'Invalid session code');
      return;
    }
    await db.setPresent(selected!.id, true);
    setState(() => message = '${selected!.name} marked present!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Check-in')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<Student>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
              children: [
                DropdownButton<Student>(
                  isExpanded: true,
                  hint: const Text('Select your name'),
                  value: selected,
                  items: [
                    for (var s in snapshot.data!)
                      DropdownMenuItem(value: s, child: Text(s.name)),
                  ],
                  onChanged: (s) => setState(() => selected = s),
                ),
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(labelText: 'Session code'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                    onPressed: checkIn, child: const Text('Check In')),
                const SizedBox(height: 16),
                Text(message, style: const TextStyle(fontSize: 18)),
              ],
            );
          },
        ),
      ),
    );
  }
}