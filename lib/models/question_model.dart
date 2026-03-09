import 'user_model.dart';

class QuestionModel {
  final int id;
  final String message;
  final int likesCount;
  final int replyCount;
  final String createdAt;
  final UserModel user;

  QuestionModel({
    required this.id,
    required this.message,
    required this.likesCount,
    required this.replyCount,
    required this.createdAt,
    required this.user,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json["id"],
      message: json["message"] ?? "",
      likesCount: json["likesCount"] ?? 0,
      replyCount: json["replyCount"] ?? 0,
      createdAt: json["createdAt"] ?? "",
      user: UserModel.fromJson(json["user"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "message": message,
      "likesCount": likesCount,
      "replyCount": replyCount,
      "createdAt": createdAt,
      "user": user.toJson(),
    };
  }
}
