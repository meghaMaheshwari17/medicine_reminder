class FeedbackModel {
  String feedback;
  String uid;
  FeedbackModel({
    required this.feedback,
    required this.uid,
  });
  // to map - sending the data to our server
  Map<String, dynamic> toMap() {
    return {
      "feedback": feedback,
      "uid": uid,
    };
  }
}
