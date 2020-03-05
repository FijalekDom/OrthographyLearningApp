import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:orthography_learning_app/models/User.dart';
import 'package:orthography_learning_app/repository/user_repository.dart';

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
                          if(formKey.currentState.validate()) {
                            User user = await UserRepository().getUser(email, password);
                            String loginErrorMessage = loginActionValidator(user);
                            if(loginErrorMessage == "") {
                              Navigator.pushNamed(context, '/home');
                            } else {
                              setState(() => error = loginErrorMessage);
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

  String loginActionValidator(User user) {
    if(user != null) {
      if(user.token != '') {
        return "";
      } else {
        return "Błąd logowania";
      }
    } else {
      return "Niepoprawny login lub hasło";
    }
  }
  
}
