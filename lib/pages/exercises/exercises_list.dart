import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:orthography_learning_app/models/Exercise.dart';
import 'package:orthography_learning_app/pages/auth/current_user.dart';
import 'package:orthography_learning_app/repository/exercise_repository.dart';
import 'package:orthography_learning_app/services/api_conncection.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'dart:convert' as JSON;

class ExercisesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: <Widget>[
            Text("Lista ćwiczeń"),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.lightGreen,
      ),
      body: FutureBuilder<List<Exercise>>(
        future: ExerciseRepository().getAllExercises(),
        builder: (BuildContext context, AsyncSnapshot<List<Exercise>> snapshot) {
          if (snapshot.hasData) {
            if(snapshot.data.length != 0) {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  Exercise item = snapshot.data[index];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(child: Text(getTypeName(item.exerciseType
                          .toString()))),
                      Expanded(
                        child: RaisedButton(
                          color: Colors.lightGreen[400],
                          child: Text(
                              'Wybierz'
                          ),
                          onPressed: () {

                          },
                        ),
                      )
                    ],
                  );
                },
              );
            } else {
              ApiConnection().connectionTest().then((isConnection) {
                if (isConnection) {
                  downloadExercisesListFromApi().then((dataDownloaded) {
                    if (dataDownloaded) {
                      Navigator.pushNamed(context, "/exercises");
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
                  });
                } else {
                  Alert(
                      context: context,
                      title: "Brak połączenia",
                      desc: "W celu pobrania listy ćwiczeń wymagane jest połączenie z internetem",
                      buttons: [
                        DialogButton(
                          child: Text("Sprawdź ponownie"),
                          onPressed: () {
                            Navigator.pushNamed(context, "/exercises");
                          },
                        )
                      ]
                  ).show();
                }
              });
            }
          } else if (snapshot.hasError) {
            Alert(
                context: context,
                title: "Brak połączenia",
                desc: "W celu pobrania listy ćwiczeń wymagane jest połączenie z internetem",
                buttons: [
                  DialogButton(
                    child: Text("Sprawdź ponownie"),
                    onPressed: () {
                      Navigator.pushNamed(context, "/home");
                    },
                  )
                ]
            ).show();
          } else {
            return ListView(
              children: <Widget>[
                SizedBox(
                  child: CircularProgressIndicator(),
                  width: 60,
                  height: 60,
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text('Awaiting result...'),
                )
              ],
            );
          }
          return ListView();
        }
      ),
      backgroundColor: Colors.blue,
    );
  }

  String getTypeName(String typeName) {
    switch(typeName) {
      case 'TYPE_O_U_LEVEL_1' : return "U lub Ó - Łatwy";
      case 'TYPE_O_U_LEVEL_2' : return "U lub Ó - Trudny";
      case 'TYPE_Z_RZ_LEVEL_1' : return "RZ lub Ż  - Łatwy";
      case 'TYPE_Z_RZ_LEVEL_2' : return "RZ lub Ż  - Trudny";
      case 'TYPE_H_CH_LEVEL_1' : return "CH lub H  - Łatwy";
      case 'TYPE_H_CH_LEVEL_2' : return "CH lub H  - Trudny";
    }
  }

  Future<bool> downloadExercisesListFromApi() async {
    Response downloadResponse = await ApiConnection().downloadExercisesListFromServer();
    if(downloadResponse.statusCode == 200) {
      List<dynamic> jsonData = JSON.jsonDecode(downloadResponse.body);

      bool result = await addExercisesToDatabase(jsonData);
      return result;
    } else {
      if(downloadResponse.statusCode == 401) {
        Response loginResponse = await ApiConnection().loginToCurrentUser();
        if(loginResponse.statusCode == 200) {
          Map<String, dynamic> jsonData = JSON.jsonDecode(loginResponse.body);
          CurrentUser.currentUser.getCurrentUser().token = jsonData['token'];
          downloadResponse = await ApiConnection().downloadExercisesListFromServer();
          if(downloadResponse.statusCode == 200) {
              bool result = await addExercisesToDatabase(JSON.jsonDecode(downloadResponse.body));
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

  Future<bool> addExercisesToDatabase(List<dynamic> jsonData) async {
    bool added = false;
    try{
      Exercise exercise;
      jsonData.forEach((data) async {
        exercise = new Exercise(exerciseId: data["id"], exerciseType: data["exerciseType"]);
        added = await ExerciseRepository().addExercise(exercise);
      });
      return added;
    } catch (e) {
      print(e);
      return false;
    } 
  }
}
