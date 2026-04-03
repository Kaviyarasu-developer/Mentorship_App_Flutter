class AnnouncementModel {
  final int id;
  final String title;
  final String content;
  final String? imageUrl;
  final String adminName;
  final String createdAt;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.adminName,
    required this.createdAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json["id"],
      title: json["title"],
      content: json["content"],
      imageUrl: json["imageUrl"],
      adminName: json["adminName"],
      createdAt: json["createdAt"],
    );
  }
}
