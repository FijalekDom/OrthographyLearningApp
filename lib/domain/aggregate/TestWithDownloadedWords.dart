
import 'package:orthography_learning_app/domain/models/Test.dart';

class TestWithDownloadedWords extends Test {
  bool isDownloaded;

  TestWithDownloadedWords(int testId, int requiredPoints, String testType, bool isDownloaded)
    : super(testId: testId, requiredPoints: requiredPoints, testType: testType)
  {
    this.isDownloaded = isDownloaded;
  }

  factory TestWithDownloadedWords.fromMap(Map<String, dynamic> json) => new TestWithDownloadedWords(
      json["testId"],
      json["requiredPoints"],
      json["testType"],
      json["isDownloaded"]
  );
}