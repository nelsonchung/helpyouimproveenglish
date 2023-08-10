/*
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * Author: Nelson Chung
 * Creation Date: August 10, 2023
 */
 
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
    // 將正確答案添加到選項列表中
    final options = List<String>.from(_otherChineseWords);
    options.add(_correctChineseWord ?? '');

    // 隨機排序選項列表
    options.shuffle();

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
                _showResultDialog(options[0] == _correctChineseWord);
              },
              child: Text(options.isNotEmpty ? options[0] : ''),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _showResultDialog(options[1] == _correctChineseWord);
              },
              child: Text(options.length > 1 ? options[1] : ''),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _showResultDialog(options[2] == _correctChineseWord);
              },
              child: Text(options.length > 2 ? options[2] : ''),
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
          title: Text(isCorrect ? '正確!' : '錯誤'),
          content: Text(isCorrect ? '恭喜，答對了！' : '很抱歉，再接再厲！'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _loadWordsFromDatabase();
              },
              child: const Text('下一題'),
            ),
          ],
        );
      },
    );
  }
}
