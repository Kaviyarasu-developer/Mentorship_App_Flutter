import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question_model.dart';
import 'api_config.dart';

class QuestionService {
  static Future<List<QuestionModel>> getQuestions() async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/questions"),
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);

      return data.map((e) => QuestionModel.fromJson(e)).toList();
    }

    return [];
  }

  static Future<void> createQuestion(int userId, String message) async {
    await http.post(
      Uri.parse("${ApiConfig.baseUrl}/questions"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId, "message": message}),
    );
  }
}
