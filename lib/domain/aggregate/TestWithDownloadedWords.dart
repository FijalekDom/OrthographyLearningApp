
import 'package:orthography_learning_app/domain/models/Test.dart';

class TestWithDownloadedWords extends Test {
  int count;

  TestWithDownloadedWords(int testId, int requiredPoints, String testType, int count)
    : super(testId: testId, requiredPoints: requiredPoints, testType: testType)
  {
    this.count = count;
  }

  factory TestWithDownloadedWords.fromMap(Map<String, dynamic> json) => new TestWithDownloadedWords(
      json["testId"],
      json["requiredPoints"],
      json["testType"],
      json["count"]
  );
}