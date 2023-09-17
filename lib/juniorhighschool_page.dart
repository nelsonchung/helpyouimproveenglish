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
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'exam.dart';
import 'exam_fill_word.dart';
import "juniorhighschool_data.dart"; 
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';


class JuniorHighSchoolPage extends StatefulWidget {
  const JuniorHighSchoolPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _JuniorHighSchoolPageState createState() => _JuniorHighSchoolPageState();
}

class _JuniorHighSchoolPageState extends State<JuniorHighSchoolPage> {
  final TextEditingController _englishWordController = TextEditingController();
  final TextEditingController _chineseWordController = TextEditingController();
  List<String> _unit = [];
  String? _selectedCategory = 'unit1';
  int? _categoryCount;  // To hold the category_count value from the settings table

  Database? _database_juniorhighschool;
  String _database_name = 'juniorhighschool_database.db';
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeJuniorHighSchoolDatabase().then((_) {
      _loadJuniorHighSchoolFromDatabase().then((_) {
          _integrateJuniorHighSchoolData();
      });
    });
  }

/*
  Future<void> _loadJuniorHighSchoolCountFromDatabase() async {
    if (_database_juniorhighschool == null) {
      final databasePath = await getDatabasesPath();
      final pathToDatabase = path.join(databasePath, 'juniorhighschool_database.db');

      _database_juniorhighschool = await openDatabase(
        pathToDatabase,
        version: 1,
      );
    }
    
    final settingsData = await _database_juniorhighschool!.query('settings');
    if (settingsData.isNotEmpty) {
      _categoryCount = settingsData.first['category_count'] as int?;
      if (_categoryCount == null) {
        print("Failed to load category_count from settings table");
        return;
      }
      print("_categoryCount is $_categoryCount");
    } else {
      print("Settings table returned empty data");
    }
  }
*/

Future<void> _integrateJuniorHighSchoolData() async {
    setState(() {
      _isLoading = true;  // Show loading indicator
    });

    if (_database_juniorhighschool == null || !_database_juniorhighschool!.isOpen) {
      await _initializeJuniorHighSchoolDatabase();
    }

Map<String, List<Junior_High_School_Word>> unitsData = {
  'unit1': unit1,
  'unit2': unit2,
  'unit3': unit3,
  'unit4': unit4,
  'unit5': unit5,
  'unit6': unit6,
  'unit7': unit7,
  'unit8': unit8,
};


for (var entry in unitsData.entries) {
  for (var unit in entry.value) {
    final existingWords = await _database_juniorhighschool!.query(
      'words',
      where: 'english_word = ? AND category = ?',
      whereArgs: [unit.english, entry.key],  // Accessing the `english` property directly
    );

    if (existingWords.isEmpty) {
      await _database_juniorhighschool!.insert('words', {
        'category': entry.key,
        'english_word': unit.english,   // Accessing the `english` property directly
        'chinese_word': unit.chinese,   // Accessing the `chinese` property directly
        'phrase': unit.phrase,
        'english_sentence': unit.english_sentence,
        'chinese_sentence': unit.chinese_sentence,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }
}


    setState(() {
      _isLoading = false;  // Hide loading indicator
    });
}


  Future<void> _loadJuniorHighSchoolFromDatabase() async {
      final databasePath = await getDatabasesPath();
      final pathToDatabase = path.join(databasePath, _database_name);

      _database_juniorhighschool = await openDatabase(
        pathToDatabase,
        version: 1,
      );

      List<Map<String, dynamic>> result;
      result = await _database_juniorhighschool!.query('words');

      List<String> informationFromDb = result.map((e) => e['category'] as String).toSet().toList();
      print("informationFromDb is $informationFromDb");

      setState(() {
          _unit = informationFromDb;
          if (_selectedCategory == null && _unit.isNotEmpty) {
              _selectedCategory = _unit.first;
          }
      });
  }


  Future<void> _initializeJuniorHighSchoolDatabase() async {
    final databasePath = await getDatabasesPath();
    final pathToDatabase = path.join(databasePath, _database_name);
    _database_juniorhighschool = await openDatabase(
      pathToDatabase,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          '''
          CREATE TABLE IF NOT EXISTS words(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              category TEXT,
              english_word TEXT UNIQUE,
              chinese_word TEXT,
              phrase TEXT,
              english_sentence TEXT,
              chinese_sentence TEXT
          )
          ''',
        );
      },
    );

  }

//word['english_word']
//word['chinese_word']
//https://firebasestorage.googleapis.com/v0/b/nelson-orderhotel.appspot.com/o/1.jpeg?alt=media&token=0180045c-af56-44b1-a819-c363f83bfd3a

void _showWordsOfSelectedCategory(BuildContext context) async {
  if (_database_juniorhighschool == null || !_database_juniorhighschool!.isOpen) {
    await _initializeJuniorHighSchoolDatabase();
  }

  final words = await _database_juniorhighschool!.query(
    'words',
    where: 'category = ?',
    whereArgs: [_selectedCategory],
  );

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Container(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.5,  // Adjust this value if needed
          child: PageView.builder(
            itemCount: words.length,
            itemBuilder: (context, index) {
              final word = words[index];
              return Column(
                children: [
                  // 1. Image
                  Container(
                    height: MediaQuery.of(context).size.height / 9,
                    width: MediaQuery.of(context).size.width / 12,
                    color: Colors.grey,
                    child: Image.asset(
                      'assets/junior/${(word['english_word'] as String).toLowerCase()}.jpeg',
                      fit: BoxFit.contain,
                      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                        // 图像加载失败时显示备用图像
                        return Image.asset(
                          'assets/junior/default.png', // 替换为您的备用图像路径
                          fit: BoxFit.contain,
                        );
                      },
                    ),
                  ),
                  // 2. English Word
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Text(
                          word['english_word'] as String,
                          style: GoogleFonts.sairaCondensed(
                            fontSize: 28.0,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 3. Chinese Word with Heart Icon
                  Row(
                    children: [
                      Icon(
                        Icons.favorite,  // Heart icon from material icons
                        color: Colors.red,
                      ),
                      SizedBox(width: 8.0),  // Provide some spacing between the word and the icon
                      Text(
                        word['chinese_word'] as String,
                        style: GoogleFonts.sairaCondensed(
                          fontSize: 20.0,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  /*
                  const SizedBox(height: 16.0),
                  // 4. Sentence
                  Text(
                    word['phrase'] as String,
                    style: TextStyle(fontSize: 24.0, color: Colors.black),
                  ),
                  */
                  const SizedBox(height: 16.0),
                  // 4. English Sentence
                  Text(
                    word['english_sentence'] as String,
                      style: GoogleFonts.sairaCondensed(
                        fontSize: 42.0,
                        color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // 5. Chinese Sentence
                  Text(
                    word['chinese_sentence'] as String,
                      style: GoogleFonts.sairaCondensed(
                        fontSize: 42.0,
                        color: Colors.black,
                    ),
                  ),

                ],
              );
            },
          ),
        ),
      );
    },
  );
}

  void _showAllWords(BuildContext context) async {
    if (_database_juniorhighschool == null || !_database_juniorhighschool!.isOpen) {
      await _initializeJuniorHighSchoolDatabase();
    }

    final words = await _database_juniorhighschool!.query('words');

    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('所有單字'),
          content: SingleChildScrollView(
            child: Column(
              children: words
                  .map(
                    (word) => ListTile(
                      title: Text(
                        word['english_word'] as String,
                        style: const TextStyle(fontSize: 18.0),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '分類: ${word['category'] as String}',
                            style: const TextStyle(fontSize: 18.0),
                          ),
                          Text(
                            '中文: ${word['chinese_word'] as String}',
                            style: const TextStyle(fontSize: 18.0),
                          ),
                        ],
                      ),
                      /*trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteWordFromDatabase(word['id'] as int);
                          Navigator.pop(context);
                          _showAllWords(context);
                        },
                      ),*/
                    ),
                  )
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('確定'),
            ),
          ],
        );
      },
    );
  }

  void _startWordTest(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExamPage(selectedCategory: _selectedCategory!, database_name: _database_name),
        //required this.selectedCategory, required this.database_name
      ),
    );
  }


  void _startWordFillTest(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ExamFillWordPage(selectedCategory: _selectedCategory!, database_name: _database_name),
      ),
    );
  }

  @override
  void dispose() {
    _database_juniorhighschool?.close();
    super.dispose();
  }

Future<void> _integratePhraseData() async {
    setState(() {
      _isLoading = true;  // Show loading indicator
    });

    if (_database_juniorhighschool == null || !_database_juniorhighschool!.isOpen) {
      await _initializeJuniorHighSchoolDatabase();
    }

    for (var unit in unit1) {
      final existingWords = await _database_juniorhighschool!.query(
        'words',
        where: 'english_word = ? AND category = ?',
        whereArgs: [unit.english, 'unit1'],
      );

      if (existingWords.isEmpty) {
        await _database_juniorhighschool!.insert('words', {
          'category': 'unit1',
          'english_word': unit.english,
          'chinese_word': unit.chinese,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    }

    setState(() {
      _isLoading = false;  // Hide loading indicator
    });
}


  @override
  Widget build(BuildContext context) {

        if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '2500 英文單字',
          style: TextStyle(fontSize: 20.0),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center( // Add this
                child: const Text(
                  '分類 Category',
                  style: TextStyle(fontSize: 40.0, color: Colors.white),
                ),
              ),
              Container(
                height: 200.0, // Adjust the height as needed
                child: CupertinoPicker(
                  backgroundColor: Color.fromARGB(255, 132, 227, 222),
                  itemExtent: 52.0, // Adjust the item height as needed
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      _selectedCategory = ['unit1', 'unit2', 'unit3', 'unit4', 'unit5', 'unit6', 'unit7', 'unit8'][index];
                    });
                  },
                  children: const [
                    Text('unit1', style: TextStyle(color: Colors.white, fontSize: 44.0)),
                    Text('unit2', style: TextStyle(color: Colors.white, fontSize: 44.0)),
                    Text('unit3', style: TextStyle(color: Colors.white, fontSize: 44.0)),
                    Text('unit4', style: TextStyle(color: Colors.white, fontSize: 44.0)),
                    Text('unit5', style: TextStyle(color: Colors.white, fontSize: 44.0)),
                    Text('unit6', style: TextStyle(color: Colors.white, fontSize: 44.0)),
                    Text('unit7', style: TextStyle(color: Colors.white, fontSize: 44.0)),
                    Text('unit8', style: TextStyle(color: Colors.white, fontSize: 44.0)),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              /*
              const Text(
                '英文單字 English vocabulary',
                style: TextStyle(fontSize: 18.0),
              ),
              TextField(
                controller: _englishWordController,
                style: const TextStyle(fontSize: 18.0),
              ),
              const SizedBox(height: 16.0),
              const Text(
                '中文單字 Chinese vocabulary',
                style: TextStyle(fontSize: 18.0),
              ),
              TextField(
                controller: _chineseWordController,
                style: const TextStyle(fontSize: 18.0),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _addWordToDatabase(context);
                },
                child: const Text(
                  '新增單字到資料庫',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
              const SizedBox(height: 16.0),
              */
              ElevatedButton(
                onPressed: () {
                  _showWordsOfSelectedCategory(context);
                },
                child: const Text(
                  '顯示當前分類單字',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _showAllWords(context);
                },
                child: const Text(
                  '顯示所有單字',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _startWordTest(context);
                },
                child: const Text(
                  '單字測試',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _startWordFillTest(context);
                },
                child: const Text(
                  '拼字測試',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
