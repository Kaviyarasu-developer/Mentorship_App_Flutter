import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String role;

  @HiveField(3)
  final String username;

  UserModel({
    required this.id,
    required this.name,
    required this.role,
    required this.username,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"],
      name: json["name"],
      role: json["role"],
      username: json["username"],
    );
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name, "username": username, "role": role};
  }
}
