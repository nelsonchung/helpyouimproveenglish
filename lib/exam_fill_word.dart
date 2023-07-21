import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class ExamFillWordPage extends StatefulWidget {
  final String selectedCategory;

  const ExamFillWordPage({Key? key, required this.selectedCategory})
      : super(key: key);

  @override
  ExamFillWordPageState createState() => ExamFillWordPageState();
}

class ExamFillWordPageState extends State<ExamFillWordPage> {
  final TextEditingController _chineseWordController = TextEditingController();
  String? _chineseWord;

  Database? _database;

  @override
  void initState() {
    super.initState();
    _loadRandomWordFromDatabase();
  }

  Future<void> _loadRandomWordFromDatabase() async {
    final databasePath = await getDatabasesPath();
    final pathToDatabase = path.join(databasePath, 'word_database.db');

    _database = await openDatabase(
      pathToDatabase,
      version: 1,
    );

    final selectedCategory = widget.selectedCategory;
    final words = await _database!
        .query('words', where: 'category = ?', whereArgs: [selectedCategory]);
    if (words.isNotEmpty) {
      final randomIndex = _getRandomIndex(words.length);
      final randomWord = words[randomIndex];
      _chineseWord = randomWord['chinese_word'] as String?;
    } else {
      _chineseWord = null;
    }

    setState(() {});
  }

  int _getRandomIndex(int length) {
    final random = Random();
    return random.nextInt(length);
  }

  Future<void> _checkAnswer(BuildContext context) async {
    final enteredEnglishWord = _chineseWordController.text;

    if (_chineseWord == null || enteredEnglishWord.isEmpty) {
      return;
    }

    final word = await _database!.query(
      'words',
      where: 'category = ? AND chinese_word = ? AND english_word = ?',
      whereArgs: [widget.selectedCategory, _chineseWord, enteredEnglishWord],
    );

    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(word.isNotEmpty ? '正確' : '錯誤'),
          content: Text(word.isNotEmpty ? '答案正確!' : '答案錯誤!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _loadRandomWordFromDatabase();
                _chineseWordController.clear();
              },
              child: const Text('下一題'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _database?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('填充單字測試 - 分類: ${widget.selectedCategory}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _chineseWord ?? '',
              style:
                  const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _chineseWordController,
              style: const TextStyle(fontSize: 18.0),
              decoration: const InputDecoration(
                labelText: '請輸入此單字的英文',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _checkAnswer(context);
              },
              child: const Text('確認答案'),
            ),
          ],
        ),
      ),
    );
  }
}
