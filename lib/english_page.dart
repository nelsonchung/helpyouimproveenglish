import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'exam.dart';

class EnglishPage extends StatefulWidget {
  const EnglishPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _EnglishPageState createState() => _EnglishPageState();
}

class _EnglishPageState extends State<EnglishPage> {
  final TextEditingController _englishWordController = TextEditingController();
  final TextEditingController _chineseWordController = TextEditingController();
  final List<String> _categories = [
    'Unit 1',
    'Unit 2',
    'Unit 3',
    'Unit 4',
    'Unit 5',
  ];
  String? _selectedCategory;
  String _displayText = '';

  Database? _database;

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categories.first;
    _initializeDatabase();
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

    setState(() {
      _displayText = '單字已新增至資料庫';
    });

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

    _clearTextFields();
  }

  void _showAllWords(BuildContext context) async {
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

  void _clearTextFields() {
    _englishWordController.clear();
    _chineseWordController.clear();
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
        title: const Text(
          '英文單字',
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
                '分類',
                style: TextStyle(
                  fontSize: 18.0,
                ),
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
                '英文單字',
                style: TextStyle(fontSize: 18.0),
              ),
              TextField(
                controller: _englishWordController,
                style: const TextStyle(fontSize: 18.0),
              ),
              const SizedBox(height: 16.0),
              const Text(
                '中文單字',
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
                  '開始測試單字',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                _displayText,
                style: const TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
