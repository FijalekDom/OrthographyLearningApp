import 'package:orthography_learning_app/models/Exercise.dart';
import 'package:orthography_learning_app/services/database.dart';

class ExerciseRepository {

  Future<List<Exercise>> getAllExercises() async {
    try {
      final db = DBProvider.db.getDb();
      List<Map> results = await db.query(
          "Exercise", columns: Exercise.columns,
      );
      List<Exercise> exercises = new List();
      results.forEach((result) {
        Exercise exercise = Exercise.fromMapFromAPI(result);
        exercises.add(exercise);
      });
      return exercises;
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  Future<bool> addExercise(Exercise exercise) async {
    DBProvider.db.getDb();
    final db = await DBProvider.db.database;
    try {
      await db.rawQuery("INSERT INTO Exercise ('exerciseId', 'exerciseType') "
                  "values (?, ?)",
              [exercise.exerciseId, exercise.exerciseType]);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}