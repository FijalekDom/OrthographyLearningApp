import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:orthography_learning_app/domain/models/UserTests.dart';
import 'package:orthography_learning_app/domain/models/Word.dart';
import 'package:orthography_learning_app/pages/auth/current_user.dart';
import 'package:orthography_learning_app/repository/user_tests_repository.dart';
import 'package:orthography_learning_app/repository/word_repository.dart';
import 'package:orthography_learning_app/services/api_conncection.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class TestPage extends StatefulWidget {
  final int testId;
  final String testType;

  TestPage({@required this.testId, @required this.testType});

  @override
  State<StatefulWidget> createState() =>
      TestPageState(testId: testId, testType: testType);
}

class TestPageState extends State<TestPage> {
  int points = 0;
  int index = 0;
  bool isWaiting = false;
  List<Word> wordsList;
  String leftSign = '';
  String rightSign = '';
  int countCorrect = 0;
  int countIncorrect = 0;
  bool isAnswerGood;

  final int testId;
  final String testType;

  TestPageState({@required this.testId, @required this.testType});

  @override
  initState() {
    super.initState();
    setButtonSigns();
    setState(() => isWaiting = true);
    WordRepository().getWordsListByTest(testId).then((words) {
      setState(() => wordsList = words);
      setState(() => isWaiting = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test'),
        centerTitle: true,
        backgroundColor: Colors.lightGreen,
      ),
      body: isWaiting
          ? Center(
              child:
                  CircularProgressIndicator(backgroundColor: Colors.lightGreen),
            )
          : Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/background.png"), fit: BoxFit.cover)),
              child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text('Poprawne odpowiedzi: ' +
                                  countCorrect.toString()),
                              Text('Błędne odpowiedzi: ' +
                                  countIncorrect.toString())
                            ],
                          ),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Text(
                            cutSignFromWord(wordsList[index].word),
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                              fontFamily: 'Kalam',
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              RaisedButton(
                                color: Colors.lightGreen[400],
                                child: Text(leftSign),
                                onPressed: () {
                                  if(isAnswerGood == null) {
                                    checkAnswer(
                                        wordsList[index].word,
                                        cutSignFromWord(wordsList[index].word),
                                        'left');
                                  }
                                },
                              ),
                              RaisedButton(
                                color: Colors.lightGreen[400],
                                child: Text(rightSign),
                                onPressed: () {
                                  if(isAnswerGood == null) {
                                    checkAnswer(
                                        wordsList[index].word,
                                        cutSignFromWord(wordsList[index].word),
                                        'right');
                                  }
                                },
                              )
                            ],
                          ),
                          isAnswerGood != null
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    isAnswerGood
                                        ? Container(
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color(0xFFe0f2f1)),
                                            child: new IconButton(
                                              icon: new Icon(
                                                Icons.check,
                                                color: Colors.green,
                                              ),
                                              onPressed: () {},
                                            ))
                                        : Container(
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color(0xFFe0f2f1)),
                                            child: new IconButton(
                                              icon: new Icon(Icons.close,
                                                  color: Colors.red),
                                              onPressed: () async {},
                                            ))
                                  ],
                                )
                              : Text(''),
                          isAnswerGood != null
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    index < 19
                                        ? RaisedButton(
                                            color: Colors.lightGreen[400],
                                            child: Text('Następne pytanie'),
                                            onPressed: () {
                                              setState(() => index = index + 1);
                                              setState(
                                                  () => isAnswerGood = null);
                                            },
                                          )
                                        : RaisedButton(
                                            color: Colors.lightGreen[400],
                                            child: Text('Zakończ test'),
                                            onPressed: () async {
                                              setState(() => isWaiting = true);
                                              bool dataSaved =
                                                  await saveTestData();
                                              if (dataSaved) {
                                                setState(
                                                    () => isWaiting = false);
                                                dataSavedAlert();
                                              } else {
                                                setState(
                                                    () => isWaiting = false);
                                                errorDataSaveAlert();
                                              }
                                            },
                                          )
                                  ],
                                )
                              : Text(''),
                        ],
                      ),
                    ]),
              ),
            ),
      backgroundColor: Colors.blue,
    );
  }

  String cutSignFromWord(String word) {
    if (testType != null) {
      if (testType.startsWith('TYPE_O_U')) {
        String replaced = word.replaceFirst(RegExp(r'[ó|u]'), '_');
        return replaced;
      } else {
        if (testType.startsWith('TYPE_Z_RZ')) {
          String replaced = word.replaceFirst(RegExp('ż|rz'), '_');
          return replaced;
        } else {
          if (testType.startsWith('TYPE_H_CH')) {
            String replaced = word.replaceFirst(RegExp('h|ch'), '_');
            return replaced;
          } else {
            return '';
          }
        }
      }
    } else {
      return '';
    }
  }

  setButtonSigns() {
    if (testType != null) {
      switch (testType) {
        case 'TYPE_O_U_LEVEL_1':
        case 'TYPE_O_U_LEVEL_2':
          {
            setState(() => leftSign = 'ó');
            setState(() => rightSign = 'u');
            break;
          }
        case 'TYPE_Z_RZ_LEVEL_1':
        case 'TYPE_Z_RZ_LEVEL_2':
          {
            setState(() => leftSign = 'ż');
            setState(() => rightSign = 'rz');
            break;
          }
        case 'TYPE_H_CH_LEVEL_1':
        case 'TYPE_H_CH_LEVEL_2':
          {
            setState(() => leftSign = 'h');
            setState(() => rightSign = 'ch');
            break;
          }
        default:
          break;
      }
    }
  }

  void checkAnswer(String word, String replacedString, String answerButton) {
    if (answerButton == 'left') {
      bool goodAnswer = compareWords(word, replacedString, leftSign);
      setState(() => isAnswerGood = goodAnswer);
      if (goodAnswer) {
        setState(() => countCorrect = countCorrect + 1);
      } else {
        setState(() => countIncorrect = countIncorrect + 1);
      }
    } else {
      bool goodAnswer = compareWords(word, replacedString, rightSign);
      setState(() => isAnswerGood = goodAnswer);
      if (goodAnswer) {
        setState(() => countCorrect = countCorrect + 1);
      } else {
        setState(() => countIncorrect = countIncorrect + 1);
      }
    }
  }

  bool compareWords(String word, String replacedString, String sign) {
    String wordFromAnswer = replacedString.replaceFirst(RegExp('_'), sign);

    if (word == wordFromAnswer) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> saveTestData() async {
    int userId = CurrentUser.currentUser.getCurrentUser().userId;
    UserTests test = new UserTests(
        idUserTest: 0,
        points: this.countCorrect,
        date: new DateTime.now(),
        idUser: userId,
        idTest: testId);
    bool dataAdded = await UserTestsRepository().addUserTest(test);
    ApiConnection().connectionTest().then((isInternetConnection) async {
      List<UserTests> tests = new List();
      tests.add(test);
      Response response = await ApiConnection().sendTestResult(tests);
      if (response.statusCode == 400) {
        Response loginResponse = await ApiConnection().loginToCurrentUser();

        if (loginResponse.statusCode == 200) {
          Response response = await ApiConnection().sendTestResult(tests);
        }
      }
    });
    return dataAdded;
  }

  void dataSavedAlert() {
    Alert(
        context: context,
        title: "Brawo!!!",
        content: Text("Test został zakończony, dane testu zostały zapisane."),
        buttons: [
          DialogButton(
            child: Text("Testy"),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, "/tests", (r) => false);
            },
          ),
          DialogButton(
            child: Text("Menu"),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, "/home", (r) => false);
            },
          )
        ]).show();
  }

  void errorDataSaveAlert() {
    Alert(context: context, title: "Wystąpił błąd podczas zapisu", buttons: [
      DialogButton(
        child: Text("Powrót do menu"),
        onPressed: () {
          Navigator.pushNamedAndRemoveUntil(context, "/home", (r) => false);
        },
      )
    ]).show();
  }
}
