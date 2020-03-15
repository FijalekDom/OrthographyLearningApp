import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart';
import 'dart:convert' as JSON;
import 'package:orthography_learning_app/models/User.dart';
import 'package:orthography_learning_app/pages/auth/current_user.dart';
import 'package:orthography_learning_app/repository/user_repository.dart';
import 'package:orthography_learning_app/services/api_conncection.dart';

class Login extends StatefulWidget {


  @override
  State<StatefulWidget> createState() => LoginState();
}

class LoginState extends State<Login> {

  String email = '';
  String password = '';
  String error = '';
  final formKey = GlobalKey<FormState>();

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
                            print("loguje");
                            String loginErrorMessage = await loginAction();
                            if(loginErrorMessage == "") {
                              Navigator.pushNamedAndRemoveUntil(context, "/home", (r) => false);
                            } else {
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
        name: jsonData['user'], 
        email: email,
        password: password,
        token: jsonData['token']);
      loginUser = await setUserStatus(loginUser);
      if(loginUser != null) {
        CurrentUser.currentUser.setCurrentUser(loginUser);
        print("usawtiono usera na:");
        print(loginUser.toString());
        return "";
      } else {
        return "Wystąpił błąd podczas zapisu !!!";
      }
    } else {
      if(response.statusCode == 500) {
        return "Wystąpił błąd !!!";
      } else {
        return "Nieprawidłowy login/hasło";
      }
    }
  }

  Future<User> setUserStatus(User user) async {
    User loginUser = await UserRepository().getUserByEmail(user.email);
    print(user.email);
    if(loginUser  == null) {
      UserRepository().addUser(user).then((isSet) async {
        print("dodaje usera");
        if(isSet) {
          return await UserRepository().getUserByEmail(user.email);
        } else {
          return null;
        }
      });
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
