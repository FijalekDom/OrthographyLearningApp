import 'package:orthography_learning_app/models/TestType.dart';

class Test {
  int testId;
  int requiredPoints;
  TestType testType;

  Test(int testId, int requiredPoints, TestType testType) {
    this.testId = testId;
    this.requiredPoints = requiredPoints;
    this.testType = testType;
  }

  Map<String, dynamic> toMap() {
    return {
      'testId': testId,
      'requiredPoints': requiredPoints,
      'testType': testType,
    };
  }

  Test.fromMap(Map<String, dynamic> map) {
    testId = map['testId'];
    requiredPoints = map['requiredPoints'];
    testType = map['testType'];
  }
}

