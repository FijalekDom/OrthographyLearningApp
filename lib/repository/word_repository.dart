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

}
