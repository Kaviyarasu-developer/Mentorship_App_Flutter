class ReplyCreateModel {
  final int questionId;
  final int userId;
  final String message;

  ReplyCreateModel({
    required this.questionId,
    required this.userId,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {"questionId": questionId, "userId": userId, "message": message};
  }
}
