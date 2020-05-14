import 'package:orthography_learning_app/domain/aggregate/TestWithDownloadedWords.dart';
import 'package:orthography_learning_app/domain/models/Test.dart';
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

  Future<List<TestWithDownloadedWords>> getAllTestsWithDownloadWordsInfo() async {
    DBProvider.db.getDb();
    final db = await DBProvider.db.database;
    try {
      List<Map> results = await db.rawQuery('SELECT Test.testId, Test.requiredPoints, Test.testType, COUNT(wordId) as count '
          'FROM Test '
          'LEFT JOIN TestWords ON Test.testId = TestWords.testId '
          'GROUP BY Test.testId');
      List<TestWithDownloadedWords> tests = new List();
      results.forEach((result) {
        Test test = TestWithDownloadedWords.fromMap(result);
        tests.add(test);
      });
      return tests;
    } catch (e) {
      print(e);
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