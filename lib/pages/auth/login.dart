import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoginState();

}

class LoginState extends State<Login> {

  String email = '';
  String password = '';

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
          child: Column(
              children: <Widget>[
                SizedBox(height: 30.0),
                Text('E-mail'),
                TextFormField(
                  style: new TextStyle(color: Colors.black),
                  decoration: new InputDecoration(fillColor: Colors.black12, filled: true),
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
                        onPressed: () {

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
                      )
                    ],
                  ),
                )
              ]
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
