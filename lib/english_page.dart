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

class EnglishPage extends StatefulWidget {
  const EnglishPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _EnglishPageState createState() => _EnglishPageState();
}

class _EnglishPageState extends State<EnglishPage> {
  final TextEditingController _englishWordController = TextEditingController();
  final TextEditingController _chineseWordController = TextEditingController();
  List<String> _categories = [];
  String? _selectedCategory;
  int? _categoryCount;  // To hold the category_count value from the settings table

  Database? _database;
  Database? _database_categories; //for 分類數量，跟分類名稱

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
    _initializeCategoriesDatabase().then((_) {
      _loadCategoryCountFromDatabase().then((_) {
        _loadCategoriesFromDatabase();
      });
    });
  }


  Future<void> _loadCategoryCountFromDatabase() async {
    if (_database_categories == null) {
      final databasePath = await getDatabasesPath();
      final pathToDatabase = path.join(databasePath, 'categories_database.db');

      _database_categories = await openDatabase(
        pathToDatabase,
        version: 1,
      );
    }
    
    final settingsData = await _database_categories!.query('settings');
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


  Future<void> _loadCategoriesFromDatabase() async {
    final databasePath = await getDatabasesPath();
    final pathToDatabase = path.join(databasePath, 'categories_database.db');

    _database_categories = await openDatabase(
      pathToDatabase,
      version: 1,  // Assuming this is the version
      // ... Other parameters ...
    );

    List<Map<String, dynamic>> result;
    if (_categoryCount != null) {
      result = await _database_categories!.query(
        'categories',
        limit: _categoryCount,
      );
    } else {
      result = await _database_categories!.query('categories');
    }

    List<String> categoriesFromDb = result.map((e) => e['name'] as String).toList();
    print("categoriesFromDb is $categoriesFromDb");

    setState(() {
      _categories = categoriesFromDb;
      _selectedCategory = _categories.first;
    });
  }

  Future<void> _initializeCategoriesDatabase() async {
    final databasePath = await getDatabasesPath();
    final pathToDatabase = path.join(databasePath, 'categories_database.db');

    _database = await openDatabase(
      pathToDatabase,
      version: 1,
      onCreate: (db, version) async {
        // 如果数据库是新创建的，我们还需要设置类别表
        await db.execute(
          '''
          CREATE TABLE IF NOT EXISTS categories(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT UNIQUE
          )
          ''',
        );
        await db.execute(
          '''
          CREATE TABLE IF NOT EXISTS settings(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category_count INTEGER
          )
          ''',
        );
        // 初始化 category_count 的值
        await db.insert('settings', {'category_count': 3});

        // Now, we'll add 50 default categories
        List<String> defaultCategories = [];
        for (int i = 1; i <= 50; i++) {
          defaultCategories.add('梁 $i 伯');
        }
        for (String category in defaultCategories) {
          await db.insert('categories', {'name': category});
        }
      },
    );

    // 由于我们可能已经创建了新的数据库和类别，所以我们需要重新加载类别和类别计数
    await _loadCategoryCountFromDatabase();
    await _loadCategoriesFromDatabase();
  }

  Future<void> _initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    final pathToDatabase = path.join(databasePath, 'word_database.db');

    _database = await openDatabase(
      pathToDatabase,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          '''
          CREATE TABLE IF NOT EXISTS words(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category TEXT,
            english_word TEXT UNIQUE,
            chinese_word TEXT
          )
          ''',
        );
      },
    );
  }

  Future<void> _addWordToDatabase(BuildContext context) async {
    final englishWord = _englishWordController.text;
    final chineseWord = _chineseWordController.text;

    if (englishWord.isEmpty || chineseWord.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('錯誤'),
            content: const Text('請輸入英文單字和中文單字'),
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
      return;
    }

    if (_database == null || !_database!.isOpen) {
      await _initializeDatabase();
    }

    final word = {
      'category': _selectedCategory,
      'english_word': englishWord,
      'chinese_word': chineseWord,
    };

    await _database!.insert('words', word);

    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('成功'),
          content: const Text('單字已新增至資料庫'),
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

    _englishWordController.clear();
    _chineseWordController.clear();
  }

  void _showWordsOfSelectedCategory(BuildContext context) async {
    if (_database == null || !_database!.isOpen) {
      await _initializeDatabase();
    }

    final words = await _database!.query(
      'words',
      where: 'category = ?',
      whereArgs: [_selectedCategory],
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('分類：$_selectedCategory'),
          content: SingleChildScrollView(
            child: Column(
              children: words.map((word) {
                return ListTile(
                  title: Text(
                    word['english_word'] as String,
                    style: const TextStyle(fontSize: 18.0),
                  ),
                  subtitle: Text(
                    '中文: ${word['chinese_word'] as String}',
                    style: const TextStyle(fontSize: 18.0),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _deleteWordFromDatabase(word['id'] as int);
                      Navigator.pop(context);
                      _showAllWords(context);
                    },
                  ),
                );
              }).toList(),
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

  void _showAllWords(BuildContext context) async {
    if (_database == null || !_database!.isOpen) {
      await _initializeDatabase();
    }

    final words = await _database!.query('words');

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
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteWordFromDatabase(word['id'] as int);
                          Navigator.pop(context);
                          _showAllWords(context);
                        },
                      ),
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

  void _deleteWordFromDatabase(int id) async {
    if (_database == null || !_database!.isOpen) {
      await _initializeDatabase();
    }

    await _database!.delete(
      'words',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  void _startWordTest(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExamPage(selectedCategory: _selectedCategory!),
      ),
    );
  }

  void _startWordFillTest(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ExamFillWordPage(selectedCategory: _selectedCategory!),
      ),
    );
  }

  @override
  void dispose() {
    _database?.close();
    _database_categories?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '英文單字 English term',
          style: TextStyle(fontSize: 20.0),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '分類 Category',
                style: TextStyle(fontSize: 18.0),
              ),
              DropdownButton<String>(
                value: _selectedCategory,
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(
                      category,
                      style: const TextStyle(fontSize: 18.0),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16.0),
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
