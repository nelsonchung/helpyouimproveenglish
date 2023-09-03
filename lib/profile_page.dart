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
 * Creation Date: September 3, 2023
 */
 
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
	List<String> _addInfoOneList = List.generate(50, (index) => '');
	int _selectedCategoryCount = 1;
	Database? _database;
	FixedExtentScrollController? _pickerController;

    late Future<void> _loadDataFuture;  // 1. 增加一個 Future 成員變數

	@override
		void initState() {
			super.initState();
            _loadDataFuture = _loadData();  // 2. 在 initState() 中初始化這個 Future
		}

	Future<void> _loadData() async {
		await _initializeDatabase();
		await _loadCategoriesFromDatabase();
		await _loadCategoryCountFromDatabase();
		_pickerController = FixedExtentScrollController(initialItem: _selectedCategoryCount - 1);
		if (_pickerController != null && _pickerController!.hasClients) {
			print('[_pickerController]Initial item: ${_pickerController!.initialItem}');
			print('[_pickerController]Current offset: ${_pickerController!.offset}');
		}
	}
	@override
		void didChangeDependencies() {
			super.didChangeDependencies();
			//_loadCategoryCountFromDatabase();
		}

	Future<void> _initializeDatabase() async {
		final databasePath = await getDatabasesPath();
		final pathToDatabase = path.join(databasePath, 'categories_database.db');

		_database = await openDatabase(
				pathToDatabase,
				version: 2,
				onCreate: (db, version) {
				db.execute("CREATE TABLE categories(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT UNIQUE);");
				db.execute("CREATE TABLE settings(id INTEGER PRIMARY KEY, category_count INTEGER);");
				db.execute("ALTER TABLE categories ADD COLUMN addInfoOne TEXT DEFAULT '';");
				},
onUpgrade: (db, oldVersion, newVersion) async {
if (oldVersion < 2) {
db.execute("CREATE TABLE IF NOT EXISTS settings(id INTEGER PRIMARY KEY, category_count INTEGER);");
// Check if the addInfoOne column exists
var columns = await db.rawQuery('PRAGMA table_info(categories)');
var addInfoOneExists = columns.indexWhere((map) => map['name'] == 'addInfoOne') != -1;
if (!addInfoOneExists) {
await db.execute("ALTER TABLE categories ADD COLUMN addInfoOne TEXT DEFAULT '';");
}
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
			await _database!.insert('categories', {'name': category, 'addInfoOne': ''});
		}
	} else {
		_categories = categoryData.map((e) => e['name'] as String).toList();
		_addInfoOneList = categoryData.map((e) => (e['addInfoOne'] ?? '').toString()).toList();
		print('the length of _categories is $_categories.length');
		print('the length of _addInfoOneList is $_addInfoOneList.length');
	}
	setState(() {
			_selectedCategoryCount = _categories.length;  // Ensure the count matches the actual number of categories
			print('set the parameter of _selectedCategoryCount is $_selectedCategoryCount');
			});
}

Future<void> _loadCategoryCountFromDatabase() async {
	if (_database == null || !_database!.isOpen) {
		await _initializeDatabase();
	}

	final settingsData = await _database!.query('settings');
	if (settingsData.isNotEmpty) {
		int countFromDatabase = settingsData.first['category_count'] as int;
		print('The parameter of countFromDatabase is $countFromDatabase');
		if (_selectedCategoryCount != countFromDatabase) {
			setState(() {
					_selectedCategoryCount = countFromDatabase;
					_pickerController = FixedExtentScrollController(initialItem: _selectedCategoryCount - 1);
					if (_pickerController != null && _pickerController!.hasClients) {
					print('[_pickerController]Initial item: ${_pickerController!.initialItem}');
					print('[_pickerController]Current offset: ${_pickerController!.offset}');
					}
					});
		}
	}
}

Future<void> _updateCategoryCountInDatabase(int newCount) async {
	if (_database == null || !_database!.isOpen) {
		await _initializeDatabase();
	}

	final existingSettings = await _database!.query('settings');
	if (existingSettings.isEmpty) {
		await _database!.insert('settings', {'category_count': newCount});
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
			print('set the parameter of _selectedCategoryCount to $_selectedCategoryCount');
			});
}

@override
Widget build(BuildContext context) {
	return Scaffold(
			appBar: AppBar(
				title: const Text('個人設定', style: TextStyle(fontSize: 20.0)),
				),
			body: FutureBuilder(
				future: _loadDataFuture,  // 3. 在 FutureBuilder 中使用這個 Future 變數
				builder: (context, snapshot) {
				if (snapshot.connectionState == ConnectionState.done) {
				return Column(
						children: [
						Container(
							height: 100,
							child: Column(
								children: [
								Text("分類數量: $_selectedCategoryCount", style: TextStyle(fontSize: 20)),
								CupertinoPicker(
									scrollController: _pickerController,
									itemExtent: 32.0,
									useMagnifier: true,
									magnification: 1.2,
									diameterRatio: 0.8,
									onSelectedItemChanged: (int value) {
									_updateCategoryCountInDatabase(value + 1);
									},
children: List.generate(50, (index) => Center(child: Text('${index + 1}'))),
),
								],
								),
							),
				Expanded(
						child: ListView.builder(
							itemCount: _selectedCategoryCount + 1,  // +1 for the header
							itemBuilder: (context, index) {
							if (index == 0) {
							// This is the header row
							return Padding(
									padding: const EdgeInsets.all(8.0),
									child: Row(
										mainAxisAlignment: MainAxisAlignment.spaceBetween,
										children: [
										Text('分類 Category', style: TextStyle(fontWeight: FontWeight.bold)),
										Text('功能', style: TextStyle(fontWeight: FontWeight.bold)),
										Text('編輯', style: TextStyle(fontWeight: FontWeight.bold)),
										//Icon(Icons.edit, color: Colors.transparent),  // Invisible icon for alignment
										],
										),
								      );
							}
							index = index - 1;  // Adjust index for actual data
							return ListTile(
									title: Row(
										mainAxisAlignment: MainAxisAlignment.spaceBetween,
										children: [
										Expanded(child: Text(index < _categories.length ? _categories[index] : 'Unknown Category')),
										Expanded(child: Text(index < _addInfoOneList.length ? _addInfoOneList[index] : '')),
										IconButton(
											icon: const Icon(Icons.edit),
											onPressed: () async {
											await _editCategory(context, index);
											_loadCategoriesFromDatabase();
											},
											),
										],
										),
								       );
							},
							),
							),
							],
							);
				} else {
					return Center(child: CircularProgressIndicator()); // 顯示加載指示器
				}
				},
				),
				);
}


Future<void> _editCategory(BuildContext context, int index) async {
	final controller = TextEditingController(text: _addInfoOneList[index]);
	await showDialog(
			context: context,
			builder: (context) {
			return AlertDialog(
					title: Text('修改"功能"資訊'),
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
								{'addInfoOne': newName},
                                where: 'id = ?',
                                whereArgs: [index + 1],  // Adjusted to match the database id
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
