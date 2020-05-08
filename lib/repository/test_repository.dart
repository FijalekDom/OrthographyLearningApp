import 'package:orthography_learning_app/models/Test.dart';
import 'package:orthography_learning_app/services/database.dart';

class TestRepository {

  Future<List<Test>> getAllTests() async {
    try {
      final db = DBProvider.db.getDb();
      List<Map> results = await db.query(
          "Test", columns: Test.columns,
      );
      List<Test> tests = new List();
      results.forEach((result) {
        Test test = Test.fromMap(result);
        tests.add(test);
      });
      return tests;
    } catch(e) {
      return null;
    }
  }

  Future<bool> addTest(Test test) async {
    DBProvider.db.getDb();
    final db = await DBProvider.db.database;
    try {
      await db.rawQuery("INSERT INTO Test ('testId', 'requiredPoints', 'testType') "
                  "values (?, ?, ?)",
              [test.testId, test.requiredPoints, test.testType]);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}