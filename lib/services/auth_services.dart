//import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static Future<String> login() async {
    final response = await http.get(
      Uri.parse("http://10.0.2.2:8080/api/students"),
      //headers: {"Content-Type": "application/json"},
      //body: jsonEncode({"email": email, "password": password}),
    );
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      print(response.body);
      return response.body;
    } else {
      throw Exception("Login failed");
    }
  }
}
