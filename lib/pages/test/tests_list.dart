import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:orthography_learning_app/domain/aggregate/TestWithDownloadedWords.dart';
import 'package:orthography_learning_app/domain/models/Test.dart';
import 'package:orthography_learning_app/pages/auth/current_user.dart';
import 'package:orthography_learning_app/repository/test_words_repository.dart';
import 'package:orthography_learning_app/repository/test_repository.dart';
import 'package:orthography_learning_app/repository/user_tests_repository.dart';
import 'package:orthography_learning_app/repository/word_repository.dart';
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
  bool isDownloading = false;

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
          : FutureBuilder<List<TestWithDownloadedWords>>(
          future: TestRepository().getAllTestsWithDownloadWordsInfo(),
          builder: (BuildContext context, AsyncSnapshot<List<TestWithDownloadedWords>> snapshot) {
            if (snapshot.hasData) {
              if(snapshot.data.length != 0) {
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    TestWithDownloadedWords item = snapshot.data[index];
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
                          : item.count > 0
                              ? RaisedButton(
                                color: Colors.lightGreen[400],
                                child: Text(
                                    'Wybierz'
                                ),
                                onPressed: () {

                                },
                              )
                              : RaisedButton(
                                color: Colors.lightGreen[400],
                                child: isDownloading
                                ? CircularProgressIndicator()
                                : Text(
                                    'Pobierz słowa'
                                ),
                                onPressed: () {
                                  setState(() => isDownloading = true);
                                  downloadWordsListByTest(item.testId).then((isAdded) {
                                    setState(() => isDownloading = false);
                                    if(isAdded) {
                                      Navigator.pushNamed(context, "/tests");
                                    }
                                  });
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

  Future<bool> downloadWordsListByTest(int testId) async {
    Response response = await ApiConnection().downloadWordsByTest(testId);
    if(response.statusCode == 200) {
      List<dynamic> words = JSON.jsonDecode(response.body);
      bool wordsAdded = await addWordsToDatabase(words, testId);

      return wordsAdded;
    } else {
      if(response.statusCode == 401) {
        Response loginResponse = await ApiConnection().loginToCurrentUser();
        if(loginResponse.statusCode == 200) {
          Response response = await ApiConnection().downloadWordsByTest(testId);
          if(response.statusCode == 200) {
            List<dynamic> words = JSON.jsonDecode(response.body);
            bool wordsAdded = await addWordsToDatabase(words, testId);

            return wordsAdded;
          } else {
            showErrorAlert();
          }
        } else {
          showErrorAlert();
        }
      } else {
        showErrorAlert();
      }
    }
    return false;
   }


  Future<bool> addWordsToDatabase(List<dynamic> words, int testId) async {
    try {
      for(String word in words) {
        WordRepository().addWord(word);
        int id = await WordRepository().getWordIdByName(word);
        TestWordsRepository().addTestWordsFromList(testId, id);
      }
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  void showErrorAlert() {
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
}
