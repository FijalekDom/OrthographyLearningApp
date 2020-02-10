import 'package:flutter/material.dart';
import 'package:orthography_learning_app/pages/exercises/exercises_list.dart';
import 'package:orthography_learning_app/pages/home.dart';
import 'package:orthography_learning_app/pages/loading_page.dart';
import 'package:orthography_learning_app/pages/test/tests_list.dart';

void main() => runApp(MaterialApp(
    initialRoute: '/home',
    routes: {
      '/': (context) => LoadingPage(),
      '/home': (context) => Home(),
      '/exercises': (context) => ExercisesList(),
      '/tests': (context) => TestsList(),
    }
));