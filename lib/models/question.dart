class QuestionModel {
  final String category;
  final String categoryCode;
  final List<Question> questions;

  QuestionModel(
      {required this.category,
      required this.categoryCode,
      required this.questions});
}

class Question {
  final String text;
  final int questionNo;

  Question({required this.text, required this.questionNo});
}
