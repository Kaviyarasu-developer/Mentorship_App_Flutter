class QuestionCreateModel {
  final int userId;
  final String message;

  QuestionCreateModel({required this.userId, required this.message});

  Map<String, dynamic> toJson() {
    return {"userId": userId, "message": message};
  }
}
