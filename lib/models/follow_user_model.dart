class FollowUserModel {
  final int id;
  final String name;
  final String username;
  final String role;

  FollowUserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.role,
  });

  factory FollowUserModel.fromJson(Map<String, dynamic> json) {
    return FollowUserModel(
      id: json["id"],
      name: json["name"] ?? "",
      username: json["username"] ?? "",
      role: json["role"] ?? "",
    );
  }
}
