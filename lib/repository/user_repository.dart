import 'package:orthography_learning_app/services/database.dart';
import 'package:orthography_learning_app/models/User.dart';

class UserRepository {

  Future<User> getUser(String login, String password)
  async {
    final db = await DBProvider.db.database;
    var result = await db.rawQuery('SELECT * FROM User WHERE login = ? AND password = ?', [login, password]);
    return result.isNotEmpty ? User.fromMap(result.first) : Null;
  }
}