import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class AuthService {
  static Future<Map<String, dynamic>?> login(
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return null;
  }
}
