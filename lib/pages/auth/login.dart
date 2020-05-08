import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart';
import 'dart:convert' as JSON;
import 'package:orthography_learning_app/models/User.dart';
import 'package:orthography_learning_app/pages/auth/current_user.dart';
import 'package:orthography_learning_app/repository/user_repository.dart';
import 'package:orthography_learning_app/services/api_conncection.dart';
import 'package:progress_dialog/progress_dialog.dart';

class Login extends StatefulWidget {


  @override
  State<StatefulWidget> createState() => LoginState();
}

class LoginState extends State<Login> {

  String email = '';
  String password = '';
  String error = '';
  final formKey = GlobalKey<FormState>();
  bool isWaiting = false;
  ProgressDialog pr;
  
  @override
  initState() {
    super.initState();
    UserRepository().getUserWithToken().then((user) {
      if(user != null) {
        CurrentUser.currentUser.setCurrentUser(user);
        Navigator.pushNamedAndRemoveUntil(context, "/home", (r) => false);
      }
      setState(() {});
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logowanie'),
        centerTitle: true,
        backgroundColor: Colors.lightGreen,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
        child: Form(
          key: formKey,
          child: isWaiting 
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(height: 30.0),
                  Text('E-mail'),
                  TextFormField(
                    style: new TextStyle(color: Colors.black),
                    decoration: new InputDecoration(fillColor: Colors.black12, filled: true),
                    validator: (val) => EmailValidator.validate(val) ? null : 'Podaj poprawny email !!!',
                    onChanged: (val) {
                      setState(() => email = val);
                    },
                  ),
                  SizedBox(height: 30.0),
                  Text('Hasło'),
                  TextFormField(
                    style: new TextStyle(color: Colors.black),
                    decoration: new InputDecoration(fillColor: Colors.black12, filled: true),
                    obscureText: true,
                    validator: (val) => val.length < 5 ? 'Hasło musi miec co najmniej 5 znaków !!!' : null,
                    onChanged: (val) {
                      setState(() => password = val);
                    },
                  ),
                  Container(
                    child: Row(
                      children: <Widget>[
                        SizedBox(height: 30.0),
                        RaisedButton(
                          color: Colors.lightGreen[400],
                          child: Text(
                              'Zaloguj się'
                          ),
                          onPressed: () async {
                            bool isInternetConnection = await ApiConnection().connectionTest();
                            if(!isInternetConnection) {
                              setState(() => error = "Brak połączenia z siecią");
                            } else {
                              setState(() => error = "");
                              if(formKey.currentState.validate()) {
                                setState(() => isWaiting = true);
                                String loginErrorMessage = await loginAction();
                                if(loginErrorMessage == "") {
                                  setState(() => isWaiting = false);
                                  Navigator.pushNamedAndRemoveUntil(context, "/home", (r) => false);
                                } else {
                                  setState(() => isWaiting = false);
                                  setState(() => error = loginErrorMessage);
                                }
                              }
                            }
                          },
                        ),
                        SizedBox(height: 30.0),
                        RaisedButton(
                          color: Colors.lightGreen[400],
                          child: Text(
                              'Rejestracja'
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30.0),
                        Text(
                          error,
                          style: TextStyle(color: Colors.red),
                        )
                ]
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Future<String> loginAction() async {
    String url = 'https://orthography-app.herokuapp.com/rest/login';
    Map<String, String> headers = {"Content-type": "application/json"};
    String json = '{ "email": "'+ email + '",' + '"password": "'+ password + '"}';
    Response response = await post(url, headers: headers, body: json);
    if(response.statusCode == 200) {
      Map<String, dynamic> jsonData = JSON.jsonDecode(response.body);
      
      User loginUser = new User(
        userId: jsonData['id'],
        name: jsonData['userName'], 
        email: email,
        password: password,
        token: jsonData['token']);
      User addedUser = await setUserStatus(loginUser);
      print(addedUser);
      if(addedUser != null) {
        CurrentUser.currentUser.setCurrentUser(addedUser);
        return "";
      } else {
        return "Wystąpił błąd podczas zapisu !!!";
      }
    } else {
      if(response.statusCode == 500 || response.statusCode == 503) {
        return "Wystąpił błąd !!!";
      } else {
        return "Nieprawidłowy login/hasło";
      }
    }
  }

  Future<User> setUserStatus(User user) async {
    User loginUser = await UserRepository().getUserByEmail(user.email);
    if(loginUser  == null) {
      bool added = await UserRepository().addUser(user);
      if(added) {
        return user;
      } else {
        return null;
      }
    } else {
      print("ustawiam token");
      bool tokenChnaged = await UserRepository().setUserToken(user);
        if(tokenChnaged) {
          return await UserRepository().getUserByEmail(user.email);
        } else {
          return null;
        }
    }
  }
}
