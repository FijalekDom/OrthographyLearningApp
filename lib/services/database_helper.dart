import 'dart:io' show Directory;
import 'package:orthography_learning_app/models/Test.dart';
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart' show getApplicationDocumentsDirectory;

class DatabaseHelper {

  static final _databaseName = "MyDatabase.orthographyApp";

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Future<Database> _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    print("tworzenie");
    await db.execute('''CREATE TABLE IF NOT EXISTS Test (
      idTest INTEGER PRIMARY KEY,
      requiredPoints INTEGER,
      testType TEXT)
      ''');
  }

  Future<Test> save(Test test) async {
    print("zapisuje");
    var dbClient = await _database;
    test.testId = await dbClient.insert('Test', test.toMap());
    return test;
    // await dbClient.transaction((txn) async {

    // });
  }

  Future<List<Test>> getTestsList() async {
    var dbClient = await _database;
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