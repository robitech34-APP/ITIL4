import '../data/questions_data.dart';

class Question {
  final String question;
  final List<String> options;
  final int correctIndex;

  Question({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

// Get 40 random questions from 300
List<Question> getRandomQuestions(int count) {
  allQuestions.shuffle();
  return allQuestions.take(count).toList();
}
