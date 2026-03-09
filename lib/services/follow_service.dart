import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'api_config.dart';

class FollowService {
  static Future<void> follow(int followerId, int followingId) async {
    await http.post(
      Uri.parse(
        "${ApiConfig.baseUrl}/follow/$followingId?followerId=$followerId",
      ),
    );
  }

  static Future<void> unfollow(int followerId, int followingId) async {
    await http.delete(
      Uri.parse(
        "${ApiConfig.baseUrl}/follow/$followingId?followerId=$followerId",
      ),
    );
  }

  static Future<List<UserModel>> getFollowers(int userId) async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/follow/followers/$userId"),
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);

      return data.map((e) => UserModel.fromJson(e)).toList();
    }

    return [];
  }

  static Future<List<UserModel>> getFollowing(int userId) async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/follow/following/$userId"),
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);

      return data.map((e) => UserModel.fromJson(e)).toList();
    }

    return [];
  }
}
