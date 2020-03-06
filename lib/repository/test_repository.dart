import 'package:orthography_learning_app/models/Test.dart';
import 'package:orthography_learning_app/services/database.dart';
import 'package:orthography_learning_app/models/User.dart';

class TestRepository {

  Future<List<Test>> getAllTests() async {
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
  }
}