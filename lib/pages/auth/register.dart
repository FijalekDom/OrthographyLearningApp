import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Register extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => RegisterState();

}

class RegisterState extends State<Register> {

  String login = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  String error ='';
  bool isWaiting = false;

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logowanie'),
        centerTitle: true,
        backgroundColor: Colors.lightGreen,
      ),
      body: isWaiting 
          ? Center(
              child: CircularProgressIndicator(),
            )
      :SingleChildScrollView(
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
                    validator: (val) => val.length >= 4 ? null : 'Login musi mieć co najmniej 4 znaki.',
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
                            if(formKey.currentState.validate() && validateTheSamePasswords()) {
                                setState(() => isWaiting = true);
                                String errorMessage = await registerAction();
                                setState(() => isWaiting = false);
                                if(errorMessage == '') {
                                  print("zrobione");
                                  return Alert(
                                    context: context,
                                    title: "Udało się !!!",
                                    desc: "Brawo " + login + " twoje konto zostało utworzone, zaloguj się aby użyć aplikacji.",
                                    buttons: [
                                      DialogButton(child: Text("Przejdź do logowania"), 
                                        onPressed: () {
                                          Navigator.pushNamed(context, '/login');
                                        },
                                      )
                                    ]
                                  ).show();
                                } else {
                                  setState(() => error = errorMessage);
                                }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30.0),
                      Text(
                        error,
                        style: TextStyle(color: Colors.red),
                      ),

                ]
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  bool validateTheSamePasswords() {
    if(password == confirmPassword) {
      return true;
    } else {
      setState(() => error = "Hasła powinny być takie same");
      return false;
    }
  }
 
  Future<String> registerAction() async {
    try {
      String url = 'https://orthography-app.herokuapp.com/rest/register';
      Map<String, String> headers = {"Content-type": "application/json"};
      String json = '{ "userName": "'+ login + '", ' +
                    '"email": "'+ email + '", ' +
                    '"password": "'+ password + '"}';
      Response response = await post(url, headers: headers, body: json);
      switch(response.statusCode) {
        case 201: return ''; break;
        case 400: return 'Podany adres e-mail posiada już konto !!!'; break;
        case 500: return 'Błąd serwera'; break;
        case 503: return 'Błąd połączenia'; break;
        default: return 'Nieznany błąd'; break;
      }
    } catch (e) {
      return 'Wystąpił błąd !!!';
    }
  }

}

