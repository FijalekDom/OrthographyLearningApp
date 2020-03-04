class User {
  int userId;
  String name;
  String email;
  String password;
  String token;

  User({this.userId, this.name, this.email, this.password, this.token});

  factory User.fromMap(Map<String, dynamic> json) => new User(
      userId: json["testId"],
      name: json["name"],
      email: json["email"],
      password: json["password"],
      token: json["token"]
  );

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'name': name,
    'email': email,
    'password': password,
    'token': token,
  };


}
