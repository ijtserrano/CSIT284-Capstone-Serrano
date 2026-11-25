import 'dart:math';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/firestore_service.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  final db = FirestoreService();
  String? code;
  bool loading = false;

  Future<void> start() async {
    setState(() => loading = true);
    final c = (1000 + Random().nextInt(9000)).toString();
    await db.createSession(c);
    setState(() {
      code = c;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Start Session')),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (code != null) ...[
                    QrImageView(data: code!, size: 220),
                    const SizedBox(height: 12),
                    Text('Session code: $code',
                        style: const TextStyle(fontSize: 26)),
                    const SizedBox(height: 8),
                    const Text('Students use this code to check in'),
                    const SizedBox(height: 16),
                  ],
                  ElevatedButton(
                    onPressed: start,
                    child: Text(
                        code == null ? 'Generate Session QR' : 'New Session'),
                  ),
                ],
              ),
      ),
    );
  }
}