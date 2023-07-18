import 'package:flutter/material.dart';
import 'english_page.dart';
import 'chemistry_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    EnglishPage(),
    ChemistryPage(),
    Text('Science Page'),
    Text('Lab Page'),
    Text('Profile Page'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*
      appBar: AppBar(
        title: const Text('Main Page'),
      ),
      */
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed, // 設置為 fixed 以顯示彩色圖示
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/directory_icon.png')),
            label: 'English',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/chemistry_icon.png')),
            label: 'Chemistry',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/science_icon.png')),
            label: 'Science',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/laboratory_icon.png')),
            label: 'Lab',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/personal_icon.png')),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
