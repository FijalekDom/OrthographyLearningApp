import 'package:flutter/material.dart';
import 'package:orthography_learning_app/domain/models/Word.dart';
import 'package:orthography_learning_app/repository/word_repository.dart';

class ExercisePage extends StatefulWidget {
  final int exerciseId;
  final String exerciseType;

  ExercisePage({@required this.exerciseId, @required this.exerciseType});

  @override
  State<StatefulWidget> createState() =>
      ExercisePageState(exerciseId: exerciseId, exerciseType: exerciseType);
}

class ExercisePageState extends State<ExercisePage> {
  int index = 0;
  bool isWaiting = false;
  List<Word> wordsList;
  String leftSign = '';
  String rightSign = '';
  int countCorrect = 0;
  int countIncorrect = 0;
  bool isAnswerGood;

  final int exerciseId;
  final String exerciseType;

  ExercisePageState({@required this.exerciseId, @required this.exerciseType});

  @override
  initState() {
    super.initState();
    setButtonSigns();
    setState(() => isWaiting = true);
    WordRepository().getWordsListByExercise(exerciseId).then((words) {
      setState(() => wordsList = words);
      setState(() => isWaiting = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nauka ortografii'),
        centerTitle: true,
        backgroundColor: Colors.lightGreen,
      ),
      body: isWaiting
          ? Center(
        child:
        CircularProgressIndicator(backgroundColor: Colors.lightGreen),
      )
          : Container(
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Text(
                      cutSignFromWord(wordsList[index].word),
                      style: TextStyle(
                        color: Colors.amber,
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
                            checkAnswer(
                                wordsList[index],
                                cutSignFromWord(wordsList[index].word),
                                'left');
                          },
                        ),
                        RaisedButton(
                          color: Colors.lightGreen[400],
                          child: Text(rightSign),
                          onPressed: () {
                            checkAnswer(
                                wordsList[index],
                                cutSignFromWord(wordsList[index].word),
                                'right');
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
                            : new IconButton(
                          icon: new Icon(Icons.close,
                              color: Colors.red),
                          onPressed: () async {},
                        )
                      ],
                    )
                        : Text(''),
                    isAnswerGood != null
                        ? Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        index < wordsList.length - 1
                            ? RaisedButton(
                          color: Colors.lightGreen[400],
                          child: Text('Następne słowo'),
                          onPressed: () {
                            setState(() => index = index + 1);
                            setState(
                                    () => isAnswerGood = null
                            );
                          },
                        )
                            : RaisedButton(
                          color: Colors.lightGreen[400],
                          child: Text('Zakończ nauke'),
                          onPressed: () async {
                            Navigator.pushNamedAndRemoveUntil(context, "/home", (r) => false);
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
    if (exerciseType != null) {
      if (exerciseType.startsWith('TYPE_O_U')) {
        String replaced = word.replaceFirst(RegExp(r'[ó|u]'), '_');
        return replaced;
      } else {
        if (exerciseType.startsWith('TYPE_Z_RZ')) {
          String replaced = word.replaceFirst(RegExp('ż|rz'), '_');
          return replaced;
        } else {
          if (exerciseType.startsWith('TYPE_H_CH')) {
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
    if (exerciseType != null) {
      switch (exerciseType) {
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

  void checkAnswer(Word word, String replacedString, String answerButton) {
    if (answerButton == 'left') {
      bool goodAnswer = compareWords(word.word, replacedString, leftSign);
      setState(() => isAnswerGood = goodAnswer);
      if (goodAnswer) {
        setState(() => countCorrect = countCorrect + 1);
      } else {
        setState(() => countIncorrect = countIncorrect + 1);
        wordsList.add(word);
      }
    } else {
      bool goodAnswer = compareWords(word.word, replacedString, rightSign);
      setState(() => isAnswerGood = goodAnswer);
      if (goodAnswer) {
        setState(() => countCorrect = countCorrect + 1);
      } else {
        setState(() => countIncorrect = countIncorrect + 1);
        wordsList.add(word);
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
}