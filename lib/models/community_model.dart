class CommunityModel {
  int id;
  String name;
  String? description;
  String? field;
  String? imageUrl;
  String? username;
  String? profileImage;
  int members;
  bool isjoined;

  CommunityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.field,
    required this.imageUrl,
    required this.username,
    required this.profileImage,
    required this.members,
    required this.isjoined,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: json["communityId"],
      name: json["communityName"] ?? "",
      description: json["communityDesc"] ?? "",
      field: json["communityField"] ?? "",
      imageUrl: json["communityImage"] ?? "",
      username: json["mentorUsername"],
      profileImage: json["mentorProfile"] ?? "",
      members: json["membersCount"] ?? 0,
      isjoined: json["isJoined"] ?? false,
    );
  }
}
