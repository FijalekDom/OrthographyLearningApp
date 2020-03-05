import 'dart:io';

import 'package:flutter/material.dart';
import 'package:orthography_learning_app/pages/auth/login.dart';
import 'package:orthography_learning_app/pages/auth/register.dart';
import 'package:orthography_learning_app/pages/exercises/exercises_list.dart';
import 'package:orthography_learning_app/pages/home.dart';
import 'package:orthography_learning_app/pages/loading_page.dart';
import 'package:orthography_learning_app/pages/test/tests_list.dart';

Future<void> main() async {
  String initialRoute = '/tests';

  bool connection = await connectionTest();
  if(!connection) {
    initialRoute = '/login';
  }
  
  
  runApp(MaterialApp(
    initialRoute: initialRoute,
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

Future<bool> connectionTest() async {
    try {
      final result = await InternetAddress.lookup('https://orthography-app.herokuapp.com/');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
    }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }