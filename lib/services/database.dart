import 'dart:io' show Directory;
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
              "token TEXT)"
          );

          await db.execute("CREATE TABLE IF NOT EXISTS Word ("
              "wordId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
              "word TEXT NOT NULL UNIQUE)"
          );

          await db.execute("CREATE TABLE IF NOT EXISTS Exercise ("
              "exerciseId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
              "exerciseType TEXT NOT NULL)"
          );

          await db.execute("CREATE TABLE IF NOT EXISTS UserTests ("
              "userTestId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
              "points INTEGER NOT NULL,"
              "date DATETIME NOT NULL,"
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
              "testId INTEGER NOT NULL,"
              "wordId INTEGER NOT NULL,"
              "FOREIGN KEY (testId) REFERENCES Test (testId)"
              "FOREIGN KEY (wordId) REFERENCES Word (wordId)"
              ")"
          );

          await db.execute("CREATE TABLE IF NOT EXISTS ExerciseWords ("
              "exerciseId INTEGER NOT NULL,"
              "wordId INTEGER NOT NULL,"
              "FOREIGN KEY (exerciseId) REFERENCES Exercise (exerciseId)"
              "FOREIGN KEY (wordId) REFERENCES Word (wordId)"
              ")"
          );

        }
    );
  }

  Database getDb() {
    return _database;
  }
}