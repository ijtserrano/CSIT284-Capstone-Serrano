import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/student.dart';

class FirestoreService {
  static const projectId = 'attendance-checker-a9642';
  static const apiKey = 'PASTE_YOUR_API_KEY';
  static const root =
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents';
  static const base = '$root/students';
  static const headers = {'Content-Type': 'application/json'};

  // READ
  Future<List<Student>> getStudents() async {
    final res = await http.get(Uri.parse('$base?key=$apiKey&pageSize=100'));
    if (res.statusCode != 200) throw Exception(res.body);
    final docs = (jsonDecode(res.body)['documents'] ?? []) as List;
    return docs.map((d) {
      final f = d['fields'] ?? {};
      return Student(
        id: (d['name'] as String).split('/').last,
        name: f['name']?['stringValue'] ?? '',
        isPresent: f['isPresent']?['booleanValue'] ?? false,
      );
    }).toList();
  }

  // CREATE
  Future<void> addStudent(String name) async {
    await http.post(
      Uri.parse('$base?key=$apiKey'),
      headers: headers,
      body: jsonEncode({
        'fields': {
          'name': {'stringValue': name},
          'isPresent': {'booleanValue': false},
        }
      }),
    );
  }

  // UPDATE
  Future<void> setPresent(String id, bool value) async {
    await http.patch(
      Uri.parse('$base/$id?key=$apiKey&updateMask.fieldPaths=isPresent'),
      headers: headers,
      body: jsonEncode({
        'fields': {
          'isPresent': {'booleanValue': value}
        }
      }),
    );
  }

  Future<void> updateName(String id, String name) async {
    await http.patch(
      Uri.parse('$base/$id?key=$apiKey&updateMask.fieldPaths=name'),
      headers: headers,
      body: jsonEncode({
        'fields': {
          'name': {'stringValue': name}
        }
      }),
    );
  }

  // DELETE
  Future<void> deleteStudent(String id) async {
    await http.delete(Uri.parse('$base/$id?key=$apiKey'));
  }

  // CREATE SESSION
  Future<void> createSession(String code) async {
    await http.post(
      Uri.parse('$root/sessions?key=$apiKey'),
      headers: headers,
      body: jsonEncode({
        'fields': {
          'code': {'stringValue': code},
          'createdAt': {'stringValue': DateTime.now().toIso8601String()},
        }
      }),
    );
  }

  // CHECK IF A SESSION CODE EXISTS
  Future<bool> sessionExists(String code) async {
    final res = await http.post(
      Uri.parse('$root:runQuery?key=$apiKey'),
      headers: headers,
      body: jsonEncode({
        'structuredQuery': {
          'from': [
            {'collectionId': 'sessions'}
          ],
          'where': {
            'fieldFilter': {
              'field': {'fieldPath': 'code'},
              'op': 'EQUAL',
              'value': {'stringValue': code}
            }
          },
          'limit': 1
        }
      }),
    );
    final list = jsonDecode(res.body) as List;
    return list.isNotEmpty && list.first['document'] != null;
  }
}