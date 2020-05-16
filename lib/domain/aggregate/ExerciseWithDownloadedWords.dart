
import 'package:orthography_learning_app/domain/models/Exercise.dart';

class ExerciseWithDownloadedWords extends Exercise {
  int count;

  ExerciseWithDownloadedWords(int exerciseId, String exerciseType, int count)
      : super(exerciseId: exerciseId, exerciseType: exerciseType)
  {
    this.count = count;
  }

  factory ExerciseWithDownloadedWords.fromMap(Map<String, dynamic> json) => new ExerciseWithDownloadedWords(
      json["exerciseId"],
      json["exerciseType"],
      json["count"]
  );
}