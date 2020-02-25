class Test {
  int testId;
  int requiredPoints;
  String testType;
  static final columns = ["testId", "requiredPoints", "testType"];

  Test({this.testId, this.requiredPoints, this.testType});

  factory Test.fromMap(Map<String, dynamic> json) => new Test(
    testId: json["testId"],
    requiredPoints: json["requiredPoints"],
    testType: json["testType"]
  );

  Map<String, dynamic> toMap() => {
    'testId': testId,
    'requiredPoints': requiredPoints,
    'testType': testType,
  };
}

