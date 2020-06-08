
import 'package:orthography_learning_app/domain/models/UserTests.dart';
import 'package:orthography_learning_app/pages/auth/current_user.dart';
import 'package:orthography_learning_app/services/database.dart';

class UserTestsRepository {

  Future<bool> addUserTest(UserTests testResult) async {
    DBProvider.db.getDb();
    final db = await DBProvider.db.database;
    try {
      await db.rawQuery("INSERT INTO UserTests ('points', 'date', 'userId', 'testId') "
          "values (?, ?, ?, ?)",
          [testResult.points, testResult.date.toString(), testResult.idUser, testResult.idTest]);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<int> getUserPoints(int userId) async {
    DBProvider.db.getDb();
    final db = await DBProvider.db.database;

    try {
      var result = await db.rawQuery("SELECT SUM(points) as points FROM UserTests "
                  "WHERE userId = ?",
                  [userId]);
      print(result);
      return result.isNotEmpty ? result.first["points"] : 0;

    } catch (e) {
      print(e);
      return 0;
    }
  }

  Future<DateTime> getLatestUserTestDate() async {
    DBProvider.db.getDb();
    final db = await DBProvider.db.database;

    try {
      int userId = CurrentUser.currentUser.getCurrentUser().userId;
      var result = await db.rawQuery('SELECT date FROM UserTests WHERE userId = ? ORDER BY date DESC LIMIT 1', [userId]);
      return result.isNotEmpty ? DateTime.parse(result.first["date"]) : null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<UserTests>> getUserTestsNeverThanDate(String date) async {
    final db = await DBProvider.db.database;

    try {
      int userId = CurrentUser.currentUser.getCurrentUser().userId;
      List<Map> results = await db.rawQuery('SELECT * FROM UserTests WHERE date > ? AND userId = ? ORDER BY date DESC', [date, userId]);
      if(!results.isEmpty) {
        List<UserTests> tests = new List();
        results.forEach((result) {
          print(result);
          UserTests test = UserTests.fromMap(result);
          tests.add(test);
        });
        return tests;
      } else {
        return null;
      }

    } catch (e) {
      print(e);
      return null;
    }
  }
}