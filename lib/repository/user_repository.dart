import 'package:orthography_learning_app/services/database.dart';
import 'package:orthography_learning_app/models/User.dart';

class UserRepository {

  Future<User> getUser(String login, String password)
  async {
    await DBProvider.db.initDB();
    final db = await DBProvider.db.database;
    try {
      var result = await db.rawQuery('SELECT * FROM User WHERE email = ? AND password = ?', [login, password]);
      return result.isNotEmpty ? User.fromMap(result.first) : Null;
    } catch (e) {
      print(e);
    }
    return null;
  }
}