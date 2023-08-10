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
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sqflite;

class CreateNewWordPage extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const CreateNewWordPage();

  @override
  CreateNewWordPageState createState() => CreateNewWordPageState();
}

class CreateNewWordPageState extends State<CreateNewWordPage> {
  final TextEditingController _englishWordController = TextEditingController();
  final TextEditingController _chineseWordController = TextEditingController();

  Future<void> _addWordToDatabase(BuildContext context) async {
    final databasePath = await sqflite.getDatabasesPath();
    final database = await sqflite.openDatabase(
      path.join(databasePath, 'words_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE words(id INTEGER PRIMARY KEY AUTOINCREMENT, englishWord TEXT, chineseWord TEXT)',
        );
      },
      version: 1,
    );

    await database.transaction((txn) async {
      await txn.rawInsert(
        'INSERT INTO words(englishWord, chineseWord) VALUES(?, ?)',
        [_englishWordController.text, _chineseWordController.text],
      );
    });

    database.close();

    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Word'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _englishWordController,
              decoration: const InputDecoration(
                labelText: '英文單字',
              ),
              onChanged: (value) {
                // 在這裡處理輸入的英文單字
              },
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _chineseWordController,
              decoration: const InputDecoration(
                labelText: '中文單字',
              ),
              onChanged: (value) {
                // 在這裡處理輸入的中文單字
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _addWordToDatabase(context),
              child: const Text('Add Word'),
            ),
          ],
        ),
      ),
    );
  }
}
