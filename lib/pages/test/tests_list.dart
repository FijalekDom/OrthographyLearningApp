import 'package:flutter/material.dart';
import 'package:orthography_learning_app/models/Test.dart';
import 'package:orthography_learning_app/repository/test_repository.dart';

class TestsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Testy'),
        centerTitle: true,
        backgroundColor: Colors.lightGreen,
      ),
      body: FutureBuilder<List<Test>>(
        future: TestRepository().getAllTests(),
        builder: (BuildContext context, AsyncSnapshot<List<Test>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                Test item = snapshot.data[index];
                return ListTile(
                  title: Text(item.requiredPoints.toString()),
                  leading: Text(item.testId.toString()),
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      backgroundColor: Colors.blue,
    );
  }
}
