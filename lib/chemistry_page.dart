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
