import 'package:flutter/material.dart';

import '../Modal/langauge.dart';

// ignore: camel_case_types
class languagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Language? language = ModalRoute.of(context)?.settings.arguments as Language?;

    return Scaffold(
      appBar: AppBar(
        title: Text('语言列表'),
        actions: [
          IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.of(context).pop(Language('en-US', '英语'));
              }),
        ],
      ),
      body: Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('语言码：${language?.code}\n名称：${language?.displayName}'),
          ],
        ),
      ),
    );
  }
}
