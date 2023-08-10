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
    /*
    Text('Science Page'),
    Text('Lab Page'),
    Text('Profile Page'),
    */
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
          /*
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
          */
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
