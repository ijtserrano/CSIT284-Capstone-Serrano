import 'dart:math';
import 'package:flutter/material.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  String? code;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Start Session')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (code != null)
              Text('Session code: $code',
                  style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  code = (1000 + Random().nextInt(9000)).toString();
                });
              },
              child: const Text('Generate Session Code'),
            ),
          ],
        ),
      ),
    );
  }
}