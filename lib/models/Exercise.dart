import 'package:orthography_learning_app/models/ExerciseType.dart';

class Exercise {
  int exerciseId;
  String exerciseType;
  static final columns = ["exerciseId", "exerciseType"];

  Exercise({this.exerciseId, this.exerciseType});

  factory Exercise.fromMap(Map<String, dynamic> json) => new Exercise(
    exerciseId: json["exerciseId"],
    exerciseType: json["exerciseType"]
  );

  factory Exercise.fromMapFromAPI(Map<String, dynamic> json) => new Exercise(
    exerciseId: json["id"],
    exerciseType: json["exerciseType"]
  );

  Map<String, dynamic> toMap() => {
    'exerciseId': exerciseId,
    'exerciseType': exerciseType
  };

}