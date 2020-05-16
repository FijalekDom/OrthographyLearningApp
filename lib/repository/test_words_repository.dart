import 'package:orthography_learning_app/services/database.dart';

class TestWordsRepository {
  Future<bool> addTestWordsFromList(int testId, int wordId) async {
    DBProvider.db.getDb();
    final db = await DBProvider.db.database;
    try {
      await db.rawQuery("INSERT INTO TestWords ('testId', 'wordId') "
        "values (?, ?)", [testId, wordId]);

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}