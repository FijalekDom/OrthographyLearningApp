import 'package:flutter/material.dart';

class TestsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Testy'),
        centerTitle: true,
        backgroundColor: Colors.lightGreen,
      ),
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Ćmiłów",
              style: TextStyle(
                fontFamily: 'AmaticSC',
                fontSize: 37,
                fontWeight: FontWeight.bold,
              ),),
              Text("Ćmiłów",
                style: TextStyle(
                    fontFamily: 'Kalam',
                    fontSize: 37
                ),),
              Text("Ćmiłów",
                style: TextStyle(
                    fontFamily: 'PatrickHand',
                    fontSize: 37
                ),),
              Text("Ćmiłów"),
            ],
          ),
      ),
      backgroundColor: Colors.blue,
    );
  }
}
