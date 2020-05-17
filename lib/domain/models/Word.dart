class Word {
  int idWord;
  String word;

  Word({this.idWord, this.word});

  factory Word.fromMap(Map<String, dynamic> json) => new Word(
      idWord: json["wordId"],
      word: json["word"]
  );

  Map<String, dynamic> toMap() => {
    'wordId': idWord,
    'word': word
  };
}