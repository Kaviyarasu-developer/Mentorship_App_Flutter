import 'dart:convert';
import 'package:http/http.dart' as http;

class StudentService {
  static const String baseUrl = "http://10.0.2.2:8080/api/students";

  // Fetch all students
  static Future<List<dynamic>> fetchStudents() async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load students");
    }
  }
}
