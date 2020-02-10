import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ortografia'),
        centerTitle: true,
        backgroundColor: Colors.lightGreen,
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget> [
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

