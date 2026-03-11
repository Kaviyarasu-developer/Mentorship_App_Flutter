import 'user_model.dart';

class ReplyModel {
  final int id;
  final String message;
  final String createdAt;
  final String role;
  final UserModel user;

  ReplyModel({
    required this.id,
    required this.message,
    required this.createdAt,
    required this.role,
    required this.user,
  });

  factory ReplyModel.fromJson(Map<String, dynamic> json) {
    return ReplyModel(
      id: json["id"],
      message: json["message"] ?? "",
      createdAt: json["createdAt"] ?? "",
      role: json["role"] ?? "",
      user: UserModel.fromJson(json["user"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "message": message,
      "createdAt": createdAt,
      "user": user.toJson(),
    };
  }
}
