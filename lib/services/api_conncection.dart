import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:http/http.dart';
import 'package:orthography_learning_app/domain/models/Test.dart';
import 'package:orthography_learning_app/domain/models/UserTests.dart';
import 'package:orthography_learning_app/pages/auth/current_user.dart';

class ApiConnection {
    Future<bool> connectionTest() async {
    try {
      final result = await InternetAddress.lookup('www.google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }

  Future<Response> downloadExercisesListFromServer() async {
    String url = 'https://orthography-app.herokuapp.com/rest/exercise/gettypes';
    Map<String, String> headers = {"Content-type": "application/json"};
    String token = CurrentUser.currentUser.getCurrentUser().token;
    String json = '{ "token": "'+ token + '"}';
    Response response = await post(url, headers: headers, body: json);
    
    return response;
  }

  Future<Response> loginToCurrentUser() async {
    String url = 'https://orthography-app.herokuapp.com/rest/login';
    Map<String, String> headers = {"Content-type": "application/json"};
    print("logowanie do: " + CurrentUser.currentUser.getCurrentUser().email + " " + CurrentUser.currentUser.getCurrentUser().password);
    String json = '{ "email": "'+ CurrentUser.currentUser.getCurrentUser().email + '",' + '"password": "'+ CurrentUser.currentUser.getCurrentUser().password + '"}';
    Response response = await post(url, headers: headers, body: json);

    return response;
  }

  Future<Response> downloadTestListFromServer() async {
    String url = 'https://orthography-app.herokuapp.com/rest/test/get';
    Map<String, String> headers = {"Content-type": "application/json"};
    String token = CurrentUser.currentUser.getCurrentUser().token;
    String json = '{ "token": "'+ token + '"}';
    Response response = await post(url, headers: headers, body: json);
    
    return response;
  }

    Future<Response> checkLastTestDate(DateTime date) async {

      String url = 'https://orthography-app.herokuapp.com/rest/synchronization/synchronize';
      Map<String, String> headers = {"Content-type": "application/json"};
      String token = CurrentUser.currentUser.getCurrentUser().token;
      String json = '{ "token": "'+ token + '", ' +
          '"date": "'+ parseDateToApiDate(date) +
          '"}';
      Response response = await post(url, headers: headers, body: json);
      return response;
    }

  Future<Response> sendTestResult(List<UserTests> testResults) async {

    String url = 'https://orthography-app.herokuapp.com/rest/test/saveresults';
    Map<String, String> headers = {"Content-type": "application/json"};
    String token = CurrentUser.currentUser.getCurrentUser().token;

    String json = '{ "token": "'+ token + '", ' +
                  '"testResults" : [';

    testResults.forEach((test) {
      json += '{ ' +
          '"testId": "'+ test.idTest.toString() + '", ' +
          '"date": "'+ parseDateToApiDate(test.date) + '", ' +
          '"gainedPoints": "'+ test.points.toString() +
          '"},';
    });
    json = json.substring(0, json.length - 1);

    json += ']}';

    Response response = await post(url, headers: headers, body: json);

    return response;
  }

  Future<Response> downloadWordsByTest(int testId) async {
    String url = 'https://orthography-app.herokuapp.com/rest/test/getwords';
    Map<String, String> headers = {"Content-type": "application/json"};
    String token = CurrentUser.currentUser.getCurrentUser().token;
    String json = '{ "token": "'+ token + '", ' +
        '"testId": "'+ testId.toString() +
        '"}';
    Response response = await post(url, headers: headers, body: json);
    return response;
  }

  String parseDateToApiDate(DateTime date) {
    String formattedDate = date.toIso8601String();

    return formattedDate;
  }
}