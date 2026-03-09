import 'question_model.dart';

class ProfileModel {
  final int id;
  final String name;
  final String username;
  final String role;

  final int followersCount;
  final int followingCount;
  final int questionsCount;

  final List<QuestionModel> questions;

  ProfileModel({
    required this.id,
    required this.name,
    required this.username,
    required this.role,
    required this.followersCount,
    required this.followingCount,
    required this.questionsCount,
    required this.questions,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    List questionsJson = json["questions"] ?? [];

    return ProfileModel(
      id: json["id"],
      name: json["name"] ?? "",
      username: json["username"] ?? "",
      role: json["role"] ?? "",

      followersCount: json["followersCount"] ?? 0,
      followingCount: json["followingCount"] ?? 0,
      questionsCount: json["questionsCount"] ?? 0,

      questions: questionsJson.map((q) => QuestionModel.fromJson(q)).toList(),
    );
  }
}
