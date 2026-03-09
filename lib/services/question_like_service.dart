import 'package:http/http.dart' as http;
import 'api_config.dart';

class QuestionLikeService {
  static Future<void> like(int questionId, int userId) async {
    await http.post(
      Uri.parse("${ApiConfig.baseUrl}/questionlike/$questionId?userId=$userId"),
    );
  }

  static Future<void> unlike(int questionId, int userId) async {
    await http.delete(
      Uri.parse("${ApiConfig.baseUrl}/questionlike/$questionId?userId=$userId"),
    );
  }
}
