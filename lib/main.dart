import 'package:flutter/material.dart';
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
