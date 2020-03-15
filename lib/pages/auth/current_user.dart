import 'package:orthography_learning_app/models/User.dart';

class CurrentUser {
  CurrentUser._();
  static final CurrentUser currentUser = CurrentUser._();
  static User _user;

  Future<User> get database async {
    if (_user != null) {
      return _user;
    } else {
      return null;
    }
  }

  void setCurrentUser(User user) {
    _user = user;
  }

  User getCurrentUser() {
    return _user;
  }

  void deleteCurrentUser() {
    _user = null;
  }
}