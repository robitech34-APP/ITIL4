import 'package:hive/hive.dart';

part 'exam_result.g.dart';

@HiveType(typeId: 0)
class ExamResult extends HiveObject {
  @HiveField(0)
  final int score;

  @HiveField(1)
  final int totalQuestions;

  @HiveField(2)
  final int timeTakenSeconds;

  @HiveField(3)
  final DateTime date;

  ExamResult({
    required this.score,
    required this.totalQuestions,
    required this.timeTakenSeconds,
    required this.date,
  });
}
