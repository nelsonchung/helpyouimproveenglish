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
import 'package:flutter_svg/flutter_svg.dart';

class ChemistryPage extends StatelessWidget {
  const ChemistryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('元素週期表'),
      ),
      body: Center(
        child: SvgPicture.asset(
          'assets/Periodic_table_zh-tw.svg',
          width: MediaQuery.of(context).size.width, // 調整寬度以適應螢幕
          height: MediaQuery.of(context).size.height, // 調整高度以適應螢幕
        ),
      ),
    );
  }
}
