import 'package:orthography_learning_app/models/TestType.dart';

class Test {
  int testId;
  int requiredPoints;
  TestType testType;

  Test({this.testType, this.requiredPoints, this.testId});
}