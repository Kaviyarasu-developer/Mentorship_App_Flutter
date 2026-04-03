import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'api_config.dart';

class UserService {
  static Future<List<UserModel>> getStudents() async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/students/getall"),
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => UserModel.fromJson(e)).toList();
    }

    return [];
  }

  static Future<List<UserModel>> getMentors() async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/mentor/getall"),
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => UserModel.fromJson(e)).toList();
    }

    return [];
  }

  static Future<List<UserModel>> getStaff() async {
    final response = await http.get( 
      Uri.parse("${ApiConfig.baseUrl}/staff/getall"),
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => UserModel.fromJson(e)).toList();
    }

    return [];
  }
}
