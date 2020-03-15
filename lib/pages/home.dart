import 'package:flutter/material.dart';
import 'package:orthography_learning_app/models/User.dart';
import 'package:orthography_learning_app/pages/auth/current_user.dart';
import 'package:orthography_learning_app/repository/user_repository.dart';

class Home extends StatelessWidget {
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
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget> [
              Text("Witaj " + CurrentUser.currentUser.getCurrentUser().name),
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
      backgroundColor: Colors.blue,
    );
  }
}

