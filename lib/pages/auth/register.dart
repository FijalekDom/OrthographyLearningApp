import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => RegisterState();

}

class RegisterState extends State<Register> {

  String login = '';
  String email = '';
  String password = '';
  String confirmPassword = '';

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logowanie'),
        centerTitle: true,
        backgroundColor: Colors.lightGreen,
      ),
      body: SingleChildScrollView(
              child: Container(
          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
          child: Form(
            key: formKey,
            child: Column(
                children: <Widget>[
                  SizedBox(height: 30.0),
                  Text('Login'),
                  TextFormField(
                    style: new TextStyle(color: Colors.black),
                    decoration: new InputDecoration(fillColor: Colors.black12, filled: true),
                    validator: (val) => val.length > 4 ? null : 'Login musi mieć co najmniej 4 znaki.',
                    onChanged: (val) {
                      setState(() => login = val);
                    },
                  ),
                  SizedBox(height: 30.0),
                  Text('E-mail'),
                  TextFormField(
                    style: new TextStyle(color: Colors.black),
                    decoration: new InputDecoration(fillColor: Colors.black12, filled: true),
                    validator: (val) => EmailValidator.validate(val) ? null : 'Podaj poprawny email.',
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
                    validator: (val) => val.length < 5 ? 'Hasło musi miec co najmniej 5 znaków.' : null,
                    onChanged: (val) {
                      setState(() => password = val);
                    },
                  ),
                  SizedBox(height: 30.0),
                  Text('Hasło'),
                  TextFormField(
                    style: new TextStyle(color: Colors.black),
                    decoration: new InputDecoration(fillColor: Colors.black12, filled: true),
                    obscureText: true,
                    validator: (val) => val.length < 5 ? 'Hasło musi miec co najmniej 5 znaków.' : null,
                    onChanged: (val) {
                      setState(() => confirmPassword = val);
                    },
                  ),
                  Container(
                    child: Row(
                      children: <Widget>[
                        SizedBox(height: 30.0),
                        RaisedButton(
                          color: Colors.lightGreen[400],
                          child: Text(
                              'Zarejestruj się'
                          ),
                          onPressed: () async {
                            if(formKey.currentState.validate()) {
                              print(email);
                            }
                          },
                        ),
                      ],
                    ),
                  )
                ]
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}

