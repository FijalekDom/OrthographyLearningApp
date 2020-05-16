import 'package:orthography_learning_app/services/database.dart';

class ExerciseWordsRepository {
  Future<bool> addExerciseWordsFromList(int exerciseId, int wordId) async {
    DBProvider.db.getDb();
    final db = await DBProvider.db.database;
    try {
      await db.rawQuery("INSERT INTO ExerciseWords ('exerciseId', 'wordId') "
          "values (?, ?)", [exerciseId, wordId]);

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}