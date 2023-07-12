import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class EnglishPage extends StatefulWidget {
  const EnglishPage({Key? key}) : super(key: key);

  @override
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

  late Database _database;

  @override
  void initState() {
    super.initState();
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

  void _addWordToDatabase(BuildContext context) async {
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

    final word = {
      'category': _selectedCategory,
      'english_word': englishWord,
      'chinese_word': chineseWord,
    };

    await _database.insert('words', word);

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
    final words = await _database.query('words');

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
                      title: Text(word['english_word'] as String),
                      subtitle: Text(word['chinese_word'] as String),
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

  void _clearTextFields() {
    _englishWordController.clear();
    _chineseWordController.clear();
  }

  @override
  void dispose() {
    _database.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('英文單字'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('分類'),
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
                    child: Text(category),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16.0),
              const Text('英文單字'),
              TextField(controller: _englishWordController),
              const SizedBox(height: 16.0),
              const Text('中文單字'),
              TextField(controller: _chineseWordController),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _addWordToDatabase(context);
                },
                child: const Text('新增單字到資料庫'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _showAllWords(context);
                },
                child: const Text('顯示所有單字'),
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
