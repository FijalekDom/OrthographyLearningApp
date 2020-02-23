import 'package:flutter/material.dart';
import 'package:orthography_learning_app/models/TestType.dart';
import 'package:orthography_learning_app/pages/exercises/exercises_list.dart';
import 'package:orthography_learning_app/pages/home.dart';
import 'package:orthography_learning_app/pages/loading_page.dart';
import 'package:orthography_learning_app/pages/test/tests_list.dart';
import 'package:orthography_learning_app/services/database_helper.dart';
import 'package:orthography_learning_app/models/Test.dart';

void main() {
  DatabaseHelper db = DatabaseHelper.instance;
  Test test = new Test(1, 10, TestType.ou);
  db.save(test);

  print("start");
  runApp(MaterialApp(
    initialRoute: '/home',
    routes: {
      '/': (context) => LoadingPage(),
      '/home': (context) => Home(),
      '/exercises': (context) => ExercisesList(),
      '/tests': (context) => TestsList(),
    }
));
}