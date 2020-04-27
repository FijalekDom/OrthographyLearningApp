
import 'package:orthography_learning_app/services/database.dart';

class UserTestsRepository {
  Future<int> getUserPoints(int userId) async {
    DBProvider.db.getDb();
    final db = await DBProvider.db.database;
    try {
      var result = await db.rawQuery("SELECT COUNT(points) as points FROM UserTests "
                  "WHERE userId = ?",
                  [userId]);
      return result.isNotEmpty ? result.first["points"] : 0;
    } catch (e) {
      print(e);
      return 0;
    }
  }
}