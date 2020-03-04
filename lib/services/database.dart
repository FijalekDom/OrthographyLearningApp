import 'dart:io' show Directory;
import 'package:orthography_learning_app/models/Test.dart';
import 'package:orthography_learning_app/models/User.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();
  static Database _database;

  Future<Database> get database async {
    if (_database != null)
      return _database;
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await
    getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "OrthographyLearningDB.db");
    return openDatabase(
        path, version: 1,
        onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await db.execute("CREATE TABLE IF NOT EXISTS Test ("
              "testId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
              "requiredPoints INTEGER NOT NULL,"
              "testType TEXT NOT NULL)"
          );

          await db.execute("CREATE TABLE IF NOT EXISTS User ("
              "userId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
              "name TEXT NOT NULL,"
              "email TEXT NOT NULL,"
              "password TEXT NOT NULL,"
              "token TEXT NOT NULL)"
          );

          await db.execute("CREATE TABLE IF NOT EXISTS Word ("
              "wordId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
              "exerciseType TEXT NOT NULL)"
          );

          await db.execute("CREATE TABLE IF NOT EXISTS Exercise ("
              "exercisedId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
              "word TEXT NOT NULL)"
          );

          await db.execute("CREATE TABLE IF NOT EXISTS UserTests ("
              "userTestId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
              "points INTEGER NOT NULL,"
              "date TEXT NOT NULL,"
              "userId INTEGER NOT NULL,"
              "testId INTEGER NOT NULL,"
              "FOREIGN KEY (userId) REFERENCES Users (userId)"
              "FOREIGN KEY (testId) REFERENCES Test (testId)"
              ")"
          );

          await db.execute("CREATE TABLE IF NOT EXISTS UserExercises ("
              "userTestId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
              "userId INTEGER NOT NULL,"
              "exercisedId INTEGER NOT NULL,"
              "FOREIGN KEY (userId) REFERENCES Users (userId)"
              "FOREIGN KEY (exercisedId) REFERENCES Exercise (exercisedId)"
              ")"
          );

          await db.execute("CREATE TABLE IF NOT EXISTS TestWords ("
              "exercisedId INTEGER NOT NULL,"
              "testId INTEGER NOT NULL,"
              "FOREIGN KEY (exercisedId) REFERENCES Exercise (exercisedId)"
              "FOREIGN KEY (testId) REFERENCES Test (testId)"
              ")"
          );

          await db.execute("CREATE TABLE IF NOT EXISTS ExerciseWords ("
              "exercisedId INTEGER NOT NULL,"
              "wordId INTEGER NOT NULL,"
              "FOREIGN KEY (exercisedId) REFERENCES Exercise (exercisedId)"
              "FOREIGN KEY (wordId) REFERENCES Word (wordId)"
              ")"
          );

          await db.execute(
              "INSERT INTO Test ('testId', 'requiredPoints', 'testType')"
              "values (?, ?, ?)",
              [1, 10, "ou"]
          );
          await db.execute(
              "INSERT INTO Test ('testId', 'requiredPoints', 'testType')"
                  "values (?, ?, ?)",
              [2, 10, "rz_z"]
          );

          await db.execute(
              "INSERT INTO User ('userId', 'name', 'email', password, token)"
                  "values (?, ?, ?, ?, ?)",
              [1, 'user1', 'aa@bb.pl', "aaaaa", "aaabbb"]
          );
        }
    );
  }

  Future<List<Test>> getAllTests() async {
    final db = await database;
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