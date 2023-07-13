import 'package:flutter/material.dart';
//import 'create_new_word.dart';
//import 'exam.dart';
import 'main_page.dart';

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
          primarySwatch: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF41D62D), // 調整背景顏色
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFD4D117), // 調整標題背景顏色
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3FB827), // 調整按鈕背景顏色
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        '/mainPage': (context) => const MainPage(),
        //'/createNewWord': (context) => const CreateNewWordPage(),
        //'/exam': (context) => const ExamPage(),
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
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/mainPage');
              },
              child: const Text('進入主畫面'),
            ),
          ],
        ),
      ),
    );
  }
}
