import 'package:flutter/material.dart';
import 'package:orthography_learning_app/models/TestType.dart';
import 'package:orthography_learning_app/pages/auth/login.dart';
import 'package:orthography_learning_app/pages/auth/register.dart';
import 'package:orthography_learning_app/pages/exercises/exercises_list.dart';
import 'package:orthography_learning_app/pages/home.dart';
import 'package:orthography_learning_app/pages/loading_page.dart';
import 'package:orthography_learning_app/pages/test/tests_list.dart';
import 'package:orthography_learning_app/services/database.dart';
import 'package:orthography_learning_app/models/Test.dart';

void main() {
  DBProvider.db.initDB();
  runApp(MaterialApp(
    initialRoute: '/login',
    routes: {
      '/': (context) => LoadingPage(),
      '/home': (context) => Home(),
      '/login': (context) => Login(),
      '/register': (context) => Register(),
      '/exercises': (context) => ExercisesList(),
      '/tests': (context) => TestsList(),
    }
));
}