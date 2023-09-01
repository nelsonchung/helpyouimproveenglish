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
  int _selectedCategoryCount = 3;
  Database? _database;
  FixedExtentScrollController? _pickerController;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
    _loadCategoriesFromDatabase();
    
    _loadCategoryCountFromDatabase().then((_) {
      _pickerController = FixedExtentScrollController(initialItem: _selectedCategoryCount - 1);
    });
    
  }

  @override
  void didChangeDependencies() {
    print("Enter didChangeDependencies");
    super.didChangeDependencies();
    _loadCategoryCountFromDatabase();
  }



  Future<void> _initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    final pathToDatabase = path.join(databasePath, 'categories_database.db');

    _database = await openDatabase(
      pathToDatabase,
      version: 2,
      onCreate: (db, version) {
        db.execute(
            "CREATE TABLE categories(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT UNIQUE);");
        db.execute(
            "CREATE TABLE settings(id INTEGER PRIMARY KEY, category_count INTEGER);");
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 2) {
          db.execute(
              "CREATE TABLE IF NOT EXISTS settings(id INTEGER PRIMARY KEY, category_count INTEGER);");
        }
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

        print("Enter _loadCategoryCountFromDatabase");

        final settingsData = await _database!.query('settings');
        if (settingsData.isNotEmpty) {
            setState(() {
                _selectedCategoryCount = settingsData.first['category_count'] as int;
                _pickerController = FixedExtentScrollController(initialItem: _selectedCategoryCount - 1);
            });
            print("_selectedCategoryCount: $_selectedCategoryCount");
        }
    }


  Future<void> _updateCategoryCountInDatabase(int newCount) async {

    print("newCount is $newCount");
    if (_database == null || !_database!.isOpen) {
      await _initializeDatabase();
    }

    final existingSettings = await _database!.query('settings');
    if (existingSettings.isEmpty) {
      await _database!.insert(
        'settings',
        {'category_count': newCount},
      );
    } else {
      await _database!.update(
        'settings',
        {'category_count': newCount},
        where: 'id = ?',
        whereArgs: [existingSettings.first['id']],
      );
    }

    setState(() {
      _selectedCategoryCount = newCount;
      print("_selectedCategoryCount: $_selectedCategoryCount");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '個人設定',
          style: TextStyle(fontSize: 20.0),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 200,
            child: Column(
              children: [
                Text(
                  "分類數量: $_selectedCategoryCount",
                  style: TextStyle(fontSize: 20),
                ),
                CupertinoPicker(
                  scrollController: _pickerController ??= FixedExtentScrollController(initialItem: _selectedCategoryCount - 1),
                  itemExtent: 32.0,
                  useMagnifier: true,
                  magnification: 1.2,
                  diameterRatio: 0.8,
                  onSelectedItemChanged: (int value) {
                    _updateCategoryCountInDatabase(value + 1);
                    setState(() {
                      _selectedCategoryCount = value + 1;
                    });
                  },
                  children: List.generate(50, (index) {
                    return Center(child: Text('${index + 1}'));
                  }),
                ),
              ],
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

  Future<void> _editCategory(BuildContext context, int index) async {
    final controller = TextEditingController(text: _categories[index]);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Category'),
          content: SingleChildScrollView(
            child: TextField(controller: controller),
          ),
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
