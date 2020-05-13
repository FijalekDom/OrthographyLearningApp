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

class TestsList extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => TestsListState();
}

class TestsListState extends State<TestsList> {

  int points = 0;
  bool isWaiting = true;

  @override
  initState() {
    super.initState();
    setState(() => isWaiting = true);
    int currentUserId = CurrentUser.currentUser.getCurrentUser().userId;
    UserTestsRepository().getUserPoints(currentUserId).then((pointsCount) {
      setState(() => points = pointsCount);
    });

    TestRepository().getAllTests().then((tests) {
      if(tests.length == 0) {
        downloadTests();
      } else {
        setState(() => isWaiting = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {

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
      body: isWaiting
          ? Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightGreen,
            ),
          )
          : FutureBuilder<List<Test>>(
          future: TestRepository().getAllTests(),
          builder: (BuildContext context, AsyncSnapshot<List<Test>> snapshot) {
            if (snapshot.hasData) {
              if(snapshot.data.length != 0) {
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    Test item = snapshot.data[index];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(child: Text(getTypeName(item.testType.toString()))),
                        Expanded(child: Text('Potrzeba ' + item.requiredPoints.toString() + ' pkt.')),
                        Expanded(
                          child: points < item.requiredPoints
                          ? IconButton(
                            icon: Icon(Icons.lock),
                            color: Colors.white,
                            onPressed: () {},
                            )
                          : RaisedButton(
                            color: Colors.lightGreen[400],
                            child: Text(
                                 'Wybierz'
                            ),
                            onPressed: () {
                              int userId = CurrentUser.currentUser
                                  .getCurrentUser()
                                  .userId;
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
                Center(
                  child: Text(
                    'Brak danych'
                  )
                );
              }
            } else if (snapshot.hasError) {
              Alert(
                  context: context,
                  title: "Wystąpił błąd",
                  buttons: [
                    DialogButton(
                      child: Text("Powrót do menu"),
                      onPressed: () {
                        Navigator.pushNamed(context, "/home");
                      },
                    )
                  ]
              ).show();
            } else {
              return Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.lightGreen,
                ),
              );
            }
            return ListView();
          }
      ),
      backgroundColor: Colors.blue,
    );
  }

  Future downloadTests() async {
    print("pobieram");
    bool isConnection = await ApiConnection().connectionTest();
    if (isConnection) {
      bool dataDownloaded = await downloadTestsList();
      if (dataDownloaded) {
        setState(() => isWaiting = false);
      } else {
        Alert(
          context: context,
          title: "Wystąpił błąd",
          buttons: [
            DialogButton(
              child: Text("Powrót do menu"),
              onPressed: () {
                Navigator.pushNamed(context, "/home");
              },
            )
          ]
        ).show();
      }
    } else {
      Alert(
        context: context,
        title: "Brak połączenia",
        desc: "W celu pobrania listy testów wymagane jest połączenie z internetem",
        buttons: [
          DialogButton(
            child: Text("Sprawdź ponownie"),
            onPressed: () {
              Navigator.pushNamed(context, "/tests");
            },
          )
        ]
      ).show();
    }
  }


  String getTypeName(String typeName) {
    switch(typeName) {
      case 'TYPE_O_U_LEVEL_1' : return "U lub Ó - Łatwy";
      case 'TYPE_O_U_LEVEL_2' : return "U lub Ó - Trudny";
      case 'TYPE_Z_RZ_LEVEL_1' : return "RZ lub Ż  - Łatwy";
      case 'TYPE_Z_RZ_LEVEL_2' : return "RZ lub Ż  - Trudny";
      case 'TYPE_H_CH_LEVEL_1' : return "CH lub H  - Łatwy";
      case 'TYPE_H_CH_LEVEL_2' : return "CH lub H  - Trudny";
      default: return 'nieznany'; break;
    }
  }

  Future<bool> downloadTestsList() async {
    Response downloadResponse = await ApiConnection().downloadTestListFromServer();
    if(downloadResponse.statusCode == 200) {
      List<dynamic> jsonData = JSON.jsonDecode(downloadResponse.body);

      bool result = await addTestsToDatabase(jsonData);
      return result;
    } else {
      if(downloadResponse.statusCode == 401) {
        Response loginResponse = await ApiConnection().loginToCurrentUser();
        if(loginResponse.statusCode == 200) {
          Map<String, dynamic> jsonData = JSON.jsonDecode(loginResponse.body);
          CurrentUser.currentUser.getCurrentUser().token = jsonData['token'];
          downloadResponse = await ApiConnection().downloadTestListFromServer();
          if(downloadResponse.statusCode == 200) {
            bool result = await addTestsToDatabase(JSON.jsonDecode(downloadResponse.body));
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

  Future<bool> addTestsToDatabase(List<dynamic> jsonData) async {
    print("dodaje");
    bool isAdded = false;
    try{
      Test test;
      for(dynamic data in jsonData) {
        test = new Test(testId: data["id"], requiredPoints: data["requiredPoints"], testType: data["testType"]);
        isAdded = await TestRepository().addTest(test);
      }

      return isAdded;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
