import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:orthography_learning_app/domain/models/UserTests.dart';
import 'package:orthography_learning_app/pages/auth/current_user.dart';
import 'package:orthography_learning_app/repository/user_repository.dart';
import 'package:orthography_learning_app/repository/user_tests_repository.dart';
import 'package:orthography_learning_app/services/api_conncection.dart';
import 'dart:convert' as JSON;

class Home extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => HomeState();
}

class HomeState extends State<Home> {

  String info;
  bool isWaiting = true;

  @override
  initState() {
    setState(() => info = 'Brak danych o synchronizacji');
    setState(() => isWaiting = true);
    super.initState();
    ApiConnection().connectionTest().then((isInternetConnection) {
      if(!isInternetConnection) {
        setState(() => info = "Synchronizacja nie powiodła się - Brak połączenia z siecią");
        setState(() => isWaiting = false);
      } else {
        synchronizeDataAction();
        setState(() => isWaiting = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ortografia'),
        actions: <Widget>[
          new IconButton(icon: new Icon(Icons.power_settings_new),
            onPressed: () async {
              UserRepository().deleteUserToken(CurrentUser.currentUser.getCurrentUser()).then((isDeleted) {
                if(isDeleted) {
                  CurrentUser.currentUser.deleteCurrentUser();
                  Navigator.pushNamedAndRemoveUntil(context, "/login", (r) => false);
                }
              });
            },
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.lightGreen,
      ),
      body: isWaiting
          ? Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightGreen
            ),
          )
          :Container(
        child: Center(
          child:  Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget> [
                Text(
                  info,
                  style: TextStyle(color: Colors.amber),
                ),
                SizedBox(height: 60.0),
                Text("Witaj " + CurrentUser.currentUser.getCurrentUser().name,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                Text("Wybierz ację",
                    style: TextStyle(fontSize: 15)),
                RaisedButton(
                  child: Text("Ćwiczenia"),
                  onPressed: () {
                    Navigator.pushNamed(context, '/exercises');
                  },
                ),
                RaisedButton(
                  child: Text("Test"),
                  onPressed: () {
                    Navigator.pushNamed(context, '/tests');
                  },
                )
              ]
          ),
        ),
      ),
      backgroundColor: Colors.blue,
    );
  }

  Future<bool> synchronizeDataAction() async {
    String infoString = ' ';
    DateTime date = await UserTestsRepository().getLatestUserTestDate();

    if(date != null) {
      Response response = await ApiConnection().checkLastTestDate(date);
      infoString = await checkSynchronizationResponse(response);
      setState(() => info = infoString);
    } else {
      setState(() => info = 'Brak dat do synchronizacji');
    }
  }

  Future<String> checkSynchronizationResponse(Response response) async {
    print(response.statusCode);
    switch(response.statusCode) {
      case 200: return checkResponseBody(response.body); break;
      case 204: return "Dane aktualne"; break;
      case 401: return loginAgain(); break;
      case 400: return "Wystąpił błąd podczas synchronizacji"; break;
      case 500: return "Wystąpił błąd podczas synchronizacji"; break;
      default: return "Wystąpił błąd podczas synchronizacji"; break;
    }
  }

  Future<String> loginAgain() async {
    Response loginResponse = await ApiConnection().loginToCurrentUser();

    if(loginResponse.statusCode == 200) {
      Map<String, dynamic> jsonData = JSON.jsonDecode(loginResponse.body);
      CurrentUser.currentUser.getCurrentUser().token = jsonData['token'];

      DateTime date = await UserTestsRepository().getLatestUserTestDate();
      Response synchronizationResponse = await ApiConnection().checkLastTestDate(date);
      return checkSynchronizationResponseAfterLogin(synchronizationResponse);
    } else {
      print("błąd logowania");
      return "Wystąpił błąd podczas synchronizacji";
    }
  }

  Future<String> checkSynchronizationResponseAfterLogin(Response response) async {
    print(response.statusCode);
    switch(response.statusCode) {
      case 200: return checkResponseBody(response.body); break;
      case 204: return "Dane aktualne"; break;
      case 401: return "Wystąpił błąd podczas synchronizacji"; break;
      case 400: return "Wystąpił błąd podczas synchronizacji"; break;
      case 500: return "Wystąpił błąd podczas synchronizacji"; break;
      default: return "Wystąpił błąd podczas synchronizacji"; break;
    }
  }

  Future<String> checkResponseBody(String body) async {
    List<dynamic> decodedJSON;
    try {
      decodedJSON = JSON.jsonDecode(body);
      bool dataAdded = await addRecordsToDatabase(decodedJSON);
      print(dataAdded);
      if(dataAdded == true) {
        return "Synchronizacja zakończona powodzeniem";
      } else {
        return "Wystąpił błąd podczas synchronizacji";
      }
    } catch (err) {
      bool dataSent = await sendDataToApi(body);
      print(dataSent);
      if(dataSent == true) {
        return "Synchronizacja zakończona powodzeniem";
      } else {
        print("błąd wysyłania");
        return "Wystąpił błąd podczas synchronizacji";
      }
    }
  }

  Future<bool> addRecordsToDatabase(List<dynamic> data) async {
    bool dataAdded = false;
    try{
      UserTests test;
      int userId = CurrentUser.currentUser.getCurrentUser().userId;
      for(dynamic dataChunk in data) {
        String replaced = dataChunk["date"].replaceFirst(RegExp('T'), ' ');
        test = new UserTests(idUserTest: 0, points: dataChunk["points"], date: DateTime.parse(replaced), idUser: userId, idTest: dataChunk["testId"]);
        dataAdded = await UserTestsRepository().addUserTest(test);
      }
      return dataAdded;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> sendDataToApi(String dateString) async {
    dateString = dateString.replaceFirst(RegExp('T'), ' ');
    dateString = dateString.replaceAll(RegExp('"'), '');
    DateTime date = DateTime.parse(dateString);
    bool allAdded = false;

    List<UserTests> userTests = await UserTestsRepository().getUserTestsNeverThanDate(date.toString());

    if(userTests != null) {
      Response response = await ApiConnection().sendTestResult(userTests);
      if(response.statusCode == 201) {
        allAdded = true;
      } else {
        allAdded = false;
      }

    }

    return allAdded;
  }
}

