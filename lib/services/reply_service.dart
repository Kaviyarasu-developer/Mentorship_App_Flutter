import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reply_model.dart';
import 'api_config.dart';

class ReplyService {
  static Future<List<ReplyModel>> getReplies(int questionId) async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/reply/$questionId"),
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);

      return data.map((e) => ReplyModel.fromJson(e)).toList();
    }

    return [];
  }

  static Future<void> createReply(
    int questionId,
    int userId,
    String message,
  ) async {
    await http.post(
      Uri.parse("${ApiConfig.baseUrl}/reply"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "questionId": questionId,
        "userId": userId,
        "message": message,
      }),
    );
  }
}
