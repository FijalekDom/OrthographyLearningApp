import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:orthography_learning_app/models/Test.dart';
import 'package:orthography_learning_app/models/UserTests.dart';
import 'package:orthography_learning_app/pages/auth/current_user.dart';
import 'package:orthography_learning_app/repository/test_repository.dart';
import 'package:orthography_learning_app/repository/user_tests_repository.dart';
import 'package:orthography_learning_app/services/api_conncection.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'dart:convert' as JSON;

class TestsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    int currentUserId = CurrentUser.currentUser.getCurrentUser().userId;
    int points = 0;
    UserTestsRepository().getUserPoints(currentUserId).then((pointsCount) {
      points = pointsCount;
    });

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: <Widget>[
            Text("Lista testów"),
            Text("Twoje zgromadzone punkty: " + points.toString(),
                style: TextStyle(fontSize: 15.0),
            )
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.lightGreen,
      ),
      body: FutureBuilder<List<Test>>(
        future: TestRepository().getAllTests(),
        builder: (BuildContext context, AsyncSnapshot<List<Test>> snapshot) {
          if(snapshot != null) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  Test item = snapshot.data[index];
                  print("wyswietlam");
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(child: Text(getTypeName(item.testType.toString()))),
                      Expanded(child: Text(item.requiredPoints.toString())),
                      Expanded(
                        child: RaisedButton(
                          color: Colors.lightGreen[400],
                          child: Text(
                                  'Wybierz'
                              ),
                          onPressed: () {
                            int userId = CurrentUser.currentUser.getCurrentUser().userId;
                            UserTests userTest = new UserTests(
                              idUserTest: 1,
                              points: 4,
                              date: new DateTime(2020, 5, 4, 15, 0, 0),
                              idUser: userId,
                              idTest: 1
                            );
                            UserTestsRepository().addUserTest(userTest);
                          },
                        ),
                      )
                    ],
                  );
                },
              );
            } else {
              print("kreci sie");
              ApiConnection().connectionTest().then((isConnection) {
                if(isConnection) {
                  print("pobieranie");
                  downloadTestsList().then((dataDownloaded) {
                    print("pobierano " + dataDownloaded.toString());
                    if(dataDownloaded) {
                        Navigator.pushNamed(context, "/tests");
                    } else {
                      return Alert(
                    context: context,
                    title: "Wystąpił błąd",
                    buttons: [
                      DialogButton(
                        child: Text("Powrót"), 
                        onPressed: () {
                                          
                        },
                      )
                    ]
                  ).show();
                    }
                  });
                } else {
                  return Alert(
                    context: context,
                    title: "Brak połączenia",
                    desc: "W celu pobrania listy testów wymagane jest połączenie z internetem",
                    buttons: [
                      DialogButton(
                        child: Text("Sprawdź ponownie"), 
                        onPressed: () {
                                          
                        },
                      )
                    ]
                  ).show();
                }
              });
            }
          } else {
            print("brak danych");
          }
        },
      ),
      backgroundColor: Colors.blue,
    );
  }

  String getTypeName(String typeName) {
    switch(typeName) {
      case 'ou' : return "U lub Ó - Łatwy";
      case 'ou' : return "U lub Ó - Trudny";
      case 'rz_z' : return "RZ lub Ż  - Łatwy";
      case 'rz_z' : return "RZ lub Ż  - Trudny";
      case 'ch_h' : return "CH lub H  - Łatwy";
      case 'ch_h' : return "CH lub H  - Trudny";
    }
  }

  Future<bool> downloadTestsList() async {
    Response downloadResponse = await ApiConnection().downloadTestListFromServer();
    print(downloadResponse.statusCode);
    if(downloadResponse.statusCode == 200) {
      List<dynamic> jsonData = JSON.jsonDecode(downloadResponse.body);

      bool result = addTestsToDatabase(jsonData);
      return result;
    } else {
      print("logowanie ponowne");
      if(downloadResponse.statusCode == 401) {
        Response loginResponse = await ApiConnection().loginToCurrentUser();
        print("logowanie " + loginResponse.statusCode.toString());
        if(loginResponse.statusCode == 200) {
          Map<String, dynamic> jsonData = JSON.jsonDecode(loginResponse.body);
          CurrentUser.currentUser.getCurrentUser().token = jsonData['token'];
          downloadResponse = await ApiConnection().downloadExercisesListFromServer();
          if(downloadResponse.statusCode == 200) {
              bool result = addTestsToDatabase(JSON.jsonDecode(downloadResponse.body));
              print("dodano");
              return result;
          } else {
            return false;
          }
        }
      } else {
        return false;
      }
    }
  }

  bool addTestsToDatabase(List<dynamic> jsonData) {
    try{
      Test test;
      print(jsonData);
      jsonData.forEach((data) {
        test = new Test(testId: data["id"], requiredPoints: data["requiredPoints"], testType: data["testType"]);
        TestRepository().addTest(test);
        return true;
      });
    } catch (e) {
      print(e);
      return false;
    }
  }
}
