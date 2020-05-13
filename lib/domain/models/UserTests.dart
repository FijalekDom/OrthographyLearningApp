class UserTests {
  int idUserTest;
  int points;
  DateTime date;
  int idUser;
  int idTest;

  UserTests({
    this.idUserTest,
    this.points,
    this.date,
    this.idUser,
    this.idTest
  });

  factory UserTests.fromMap(Map<String, dynamic> json) => new UserTests(
      idUserTest: json["idUserTest"],
      points: json["points"],
      date: DateTime.parse(json["date"]),
      idUser: json["userId"],
      idTest: json["testId"]
  );

  Map<String, dynamic> toMap() => {
    'idUserTest': idUserTest,
    'points': points,
    'date': date,
    'idUser': idUser,
    'idTest': idTest
  };
}