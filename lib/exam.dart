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
 * Creation Date: Oct 10, 2023
 */

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart' as path;
import 'dart:math';

class ExamPage extends StatefulWidget {
  final String selectedCategory;
  final String database_name;

  const ExamPage({Key? key, required this.selectedCategory, required this.database_name}) : super(key: key);

  @override
  ExamPageState createState() => ExamPageState();
}

class ExamPageState extends State<ExamPage> {
  String? _englishWord;
  String? _correctChineseWord;
  List<String> _otherChineseWords = [];
  List<String> _shuffledOptions = []; // 新增的狀態變量
  String? _selectedOption;
  String? _correctOption;

  @override
  void initState() {
    super.initState();
    _loadWordsFromDatabase();
  }

  Future<void> _loadWordsFromDatabase() async {
    final databasename = widget.database_name;
    final databasePath = await sqflite.getDatabasesPath();
    final database = await sqflite.openDatabase(
      path.join(databasePath, databasename),
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

    if (_correctChineseWord != null) {
      _shuffledOptions = List.from(_otherChineseWords)..add(_correctChineseWord!);
      _shuffledOptions.shuffle();
    } else {
      _shuffledOptions.clear();
    }
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final options = List<String>.from(_otherChineseWords);
    options.add(_correctChineseWord ?? '');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                _englishWord ?? '',
                style: const TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 48.0),
            _buildOptionButton(_shuffledOptions, 0),
            const SizedBox(height: 32.0),
            _buildOptionButton(_shuffledOptions, 1),
            const SizedBox(height: 32.0),
            _buildOptionButton(_shuffledOptions, 2),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(List<String> options, int index) {
    Color? backgroundColor;
    if (_selectedOption == options[index]) {
      //backgroundColor = Colors.deepOrange;
      backgroundColor = Colors.red[400];
    }
    if (_correctOption == options[index]) {
      //backgroundColor = Colors.yellow;
      backgroundColor = Colors.lightGreen;
    }

    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedOption = options[index];
          _correctOption = _correctChineseWord;

          if (_selectedOption == _correctOption) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("恭喜你答對囉，準備下一題"),
                duration: Duration(seconds: 3),
              ),
            );
            Future.delayed(Duration(seconds: 3), () {
              _loadWordsFromDatabase();
            });
          }
        });
      },
      child: Text(options.length > index ? options[index] : ''),
      style: ElevatedButton.styleFrom(
        primary: backgroundColor,
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
    );
  }
}
