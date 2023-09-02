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
import 'main_page.dart';

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';



  Future<void> _deleteDatabase(BuildContext context) async {
    final databasePath = await getDatabasesPath();
    final pathToDatabase = path.join(databasePath, 'categories_database.db');
    await deleteDatabase(pathToDatabase);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Database Deleted!')));
  }

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '助英台',
      theme: ThemeData(
        canvasColor: Colors.white,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor:
            const Color.fromARGB(255, 132, 227, 222), //type 1&2
        //scaffoldBackgroundColor: const Color(0xFF009FB8), //type 3
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 21, 200, 191), //type 1&2
          //backgroundColor: Color(0xFFF9BE00), //type 3
          titleTextStyle: TextStyle(fontSize: 18), // 調整字型大小為 18
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            //backgroundColor: const Color(0xFFFF7043), //type 1
            //backgroundColor: const Color.fromARGB(255, 21, 200, 191), //type 2
            backgroundColor: const Color(0xFFF9BE00), //type 3
            textStyle: const TextStyle(fontSize: 18), // 調整字型大小為 18
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        '/mainPage': (context) => const MainPage(),
      },
      home: const MyHomePage(title: '助英台'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontSize: 18), // 調整字型大小為 18
        ),
      ),
      body: Stack(
        children: [
          // Your main content
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/mainPage');
              },
              child: const Text('進入主畫面'),
            ),
          ),

          // Positioning the delete button at the bottom left
          Positioned(
            bottom: 10,  // Adjust these values as needed
            left: 10,
            child: ElevatedButton(
              onPressed: () {
                _deleteDatabase(context);
              },
              child: const Text('刪除資料庫'),
            ),
          ),
        ],
      ),
    );
  }
}
