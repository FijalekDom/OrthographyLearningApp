import 'package:encrypt/encrypt.dart';
import 'package:orthography_learning_app/services/database.dart';
import 'package:orthography_learning_app/models/User.dart';
import 'package:password/password.dart';

class UserRepository {

  Future<User> getUserWithToken()
  async {
    DBProvider.db.getDb();
    final db = await DBProvider.db.database;
    try {
      var result = await db.rawQuery('SELECT * FROM User WHERE token IS NOT NULL');
      return result.isNotEmpty ? User.fromMap(result.first) : Null;
    } catch (e) {
      return null;
    }
  }

  Future<User> getUserByEmail(String email)
  async {
    DBProvider.db.getDb();
    final db = await DBProvider.db.database;
    try {
      var result = await db.rawQuery('SELECT * FROM User WHERE email = ?', [email]);
      return result.isNotEmpty ? User.fromMap(result.first) : Null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> addUser(User user) async {
    DBProvider.db.getDb();

    final db = await DBProvider.db.database;
    try {
      await db.rawQuery("INSERT INTO User ('userId', 'name', 'email', 'password', 'token') "
                  "values (?, ?, ?, ?, ?)",
              [user.userId, user.name, user.email, user.password, user.token]);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> deleteUserToken(User user) async {
    DBProvider.db.getDb();
    final db = await DBProvider.db.database;
    try {
      await db.rawQuery("UPDATE User SET token = null "
                  "WHERE email = ?", [user.email]);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> setUserToken(User user) async {
    DBProvider.db.getDb();
    final db = await DBProvider.db.database;
    try {
      await db.rawQuery("UPDATE User SET token = ? "
                  "WHERE email=?", [user.token, user.email]);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}