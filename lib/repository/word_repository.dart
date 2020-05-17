import 'package:orthography_learning_app/domain/models/Word.dart';
import 'package:orthography_learning_app/services/database.dart';

class WordRepository {

  Future<bool> addWord(String word) async {
    DBProvider.db.getDb();
    final db = await DBProvider.db.database;
    try {
      await db.rawQuery("INSERT INTO Word ('word') values (?)", [word]);

      return true;
    } catch (e) {
    print(e);
    return false;
    }
  }

  Future<int> getWordIdByName(String word) async {
    DBProvider.db.getDb();
    final db = await DBProvider.db.database;
    try {
      var result = await db.rawQuery("SELECT wordId FROM Word WHERE word = ?", [word]);
      print(result);
      return result.isNotEmpty ? result[0]['wordId'] : Null;
    } catch (e) {
      print(e);
      return 0;
    }
  }

  Future<List<Word>> getWordsListByTest(int testId) async {
    DBProvider.db.getDb();
    final db = await DBProvider.db.database;
    try {
      List<Map> results = await db.rawQuery("SELECT Word.wordId, Word.word "
          "FROM Word "
          "LEFT JOIN TestWords ON Word.wordId = TestWords.wordId "
          "WHERE TestWords.testId = ?", [testId]);
      List<Word> words = new List();
      results.forEach((result) {
        Word test = Word.fromMap(result);
        words.add(test);
      });
      return words.isNotEmpty ? words : null;
    } catch (e) {
      print(e);
      return null;
    }
  }

}
