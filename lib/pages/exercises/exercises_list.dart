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
          print(snapshot);
          if(snapshot != null) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  Exercise item = snapshot.data[index];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(child: Text(getTypeName(item.exerciseType.toString()))),
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
              print("kreci sie");
              ApiConnection().connectionTest().then((isConnection) {
                print(isConnection);
                if(isConnection) {
                  print("pobieranie");
                  downloadExercisesListFromApi().then((dataDownloaded) {
                    print("pobierano " + dataDownloaded.toString());
                    if(dataDownloaded) {
                        Navigator.pushNamed(context, "/exercises");
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
                    desc: "W celu pobrania listy ćwiczeń wymagane jest połączenie z internetem",
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
    print(downloadResponse.statusCode);
    if(downloadResponse.statusCode == 200) {
      List<dynamic> jsonData = JSON.jsonDecode(downloadResponse.body);

      bool result = addExercisesToDatabase(jsonData);
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
              bool result = addExercisesToDatabase(JSON.jsonDecode(downloadResponse.body));
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

  bool addExercisesToDatabase(List<dynamic> jsonData) {
    try{
      Exercise exercise;
    jsonData.forEach((data) {
      exercise = new Exercise(exerciseId: data["id"], exerciseType: data["exerciseType"]);
      ExerciseRepository().addExercise(exercise);
      return true;
    });
    } catch (e) {
      print(e);
      return false;
    } 
  }
}
