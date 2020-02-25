import 'dart:io' show Directory;
import 'package:orthography_learning_app/models/Test.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {

  static final databaseName = "MyDatabase.orthographyApp";

  Future<Database> database;

  DatabaseHelper() {
    initDatabase();
  }

  initDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, databaseName);
    await deleteDatabase(path);
    this.database = (await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          // When creating the db, create the table
          await db.execute(
              '''CREATE TABLE IF NOT EXISTS Test (
      testId INTEGER PRIMARY KEY,
      requiredPoints INTEGER,
      testType TEXT)
      ''');
        })) as Future<Database>;
  }


  Future<Test> save(Test test) async {
    print("zapisuje");
    var dbClient = await this.database;
    test.testId = await dbClient.insert('Test', test.toMap());
    return test;
    // await dbClient.transaction((txn) async {

    // });
  }

  Future<List<Test>> getTestsList() async {
    var dbClient = await this.database;
    List<Map> maps = await dbClient.query('Test', columns: ['idTest', 'requiredPoints', 'testType']);
    List<Test> tests = [];
    if (maps.length > 0) {
      for(int i = 0; i < maps.length; i++) {
        tests.add(Test.fromMap(maps[i]));
      }
    }
    return tests;
  }
}