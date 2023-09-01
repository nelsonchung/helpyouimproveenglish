import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<String> _categories = List.generate(50, (index) => '梁 ${index + 1} 伯');
  int _selectedCategoryCount = 5;
  Database? _database;
  
  @override
  void initState() {
    super.initState();
    _initializeDatabase();
    _loadCategoriesFromDatabase();
    _loadCategoryCountFromDatabase();
  }
  
  Future<void> _initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    final pathToDatabase = path.join(databasePath, 'categories_database.db');

    _database = await openDatabase(
      pathToDatabase,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          '''
          CREATE TABLE IF NOT EXISTS categories(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT UNIQUE
          )
          ''',
        );
      },
    );
  }

  Future<void> _loadCategoriesFromDatabase() async {
    if (_database == null || !_database!.isOpen) {
      await _initializeDatabase();
    }

    final categoryData = await _database!.query('categories');

    if (categoryData.isEmpty) {
      for (var category in _categories) {
        await _database!.insert('categories', {'name': category});
      }
    } else {
      _categories = categoryData.map((e) => e['name'] as String).toList();
    }
    setState(() {});
  }

  Future<void> _loadCategoryCountFromDatabase() async {
    if (_database == null || !_database!.isOpen) {
      await _initializeDatabase();
    }

    final settingsData = await _database!.query('settings');
    if (settingsData.isNotEmpty) {
      _selectedCategoryCount = settingsData.first['category_count'] as int;
    }
    setState(() {});
  }

    Future<void> _updateCategoryCountInDatabase(int newCount) async {
    if (_database == null || !_database!.isOpen) {
      await _initializeDatabase();
    }

    await _database!.insert(
      'settings',
      {'category_count': newCount},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    setState(() {
      _selectedCategoryCount = newCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('個人設定'),
      ),
      body: Column(
        children: [
          Container(
            height: 200,
            child: CupertinoPicker(
              itemExtent: 32.0,
              onSelectedItemChanged: (int index) {
                _updateCategoryCountInDatabase(index + 1);
              },
              children: List.generate(50, (index) {
                return Center(child: Text('${index + 1}'));
              }),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _selectedCategoryCount,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_categories[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      await _editCategory(context, index);
                      _loadCategoriesFromDatabase();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCategoryCountPicker(BuildContext context) {
    return showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: CupertinoPicker(
            itemExtent: 32.0,
            onSelectedItemChanged: (int index) {
              _updateCategoryCountInDatabase(index + 1);
            },
            children: List.generate(50, (index) {
              return Center(child: Text('${index + 1}'));
            }),
          ),
        );
      },
    );
  }

    Future<void> _editCategory(BuildContext context, int index) async {
        final controller = TextEditingController(text: _categories[index]);
        await showDialog(
        context: context,
        builder: (context) {
            return AlertDialog(
            title: Text('Edit Category'),
            content: SingleChildScrollView(  // Add this line
                child: TextField(controller: controller),
            ),  // and this line
            actions: [
                TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                child: const Text('Save'),
                onPressed: () async {
                    final newName = controller.text;
                    if (newName.isNotEmpty) {
                    await _database!.update(
                        'categories',
                        {'name': newName},
                        where: 'name = ?',
                        whereArgs: [_categories[index]],
                    );
                    }
                    Navigator.pop(context);
                },
                ),
            ],
            );
        },
        );
    }
}
