import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart' as path;
import 'dart:math';

class ExamPage extends StatefulWidget {
  final String selectedCategory;

  const ExamPage({Key? key, required this.selectedCategory}) : super(key: key);

  @override
  ExamPageState createState() => ExamPageState();
}

class ExamPageState extends State<ExamPage> {
  String? _englishWord;
  String? _correctChineseWord;
  List<String> _otherChineseWords = [];

  @override
  void initState() {
    super.initState();
    _loadWordsFromDatabase();
  }

  Future<void> _loadWordsFromDatabase() async {
    final databasePath = await sqflite.getDatabasesPath();
    final database = await sqflite.openDatabase(
      path.join(databasePath, 'word_database.db'),
      version: 1,
    );

    final selectedCategory = widget.selectedCategory;
    final words = await database
        .query('words', where: 'category = ?', whereArgs: [selectedCategory]);
    if (words.isNotEmpty) {
      final random = Random.secure();
      final randomIndex = random.nextInt(words.length);
      final randomWord = words[randomIndex];
      _englishWord = randomWord['english_word'] as String?;
      _correctChineseWord = randomWord['chinese_word'] as String?;

      final otherWords = List<String>.from(words
          .where((word) => word['chinese_word'] != _correctChineseWord)
          .map((word) => word['chinese_word'] as String));
      otherWords.shuffle(random);
      _otherChineseWords = otherWords.take(2).toList();
    } else {
      _englishWord = null;
      _correctChineseWord = null;
      _otherChineseWords.clear();
    }

    database.close();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _englishWord ?? '',
              style:
                  const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _showResultDialog(_correctChineseWord == _otherChineseWords[0]);
              },
              child: Text(
                  _otherChineseWords.isNotEmpty ? _otherChineseWords[0] : ''),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _showResultDialog(_correctChineseWord == _otherChineseWords[1]);
              },
              child: Text(
                  _otherChineseWords.length > 1 ? _otherChineseWords[1] : ''),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _showResultDialog(true);
              },
              child: Text(_correctChineseWord ?? ''),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showResultDialog(bool isCorrect) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isCorrect ? 'Correct!' : 'Incorrect'),
          content: Text(isCorrect
              ? 'Congratulations, you got it right!'
              : 'Sorry, better luck next time.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _loadWordsFromDatabase();
              },
              child: const Text('Next'),
            ),
          ],
        );
      },
    );
  }
}
