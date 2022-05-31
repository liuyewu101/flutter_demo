import 'package:flutter/material.dart';
import '../Modal/langauge.dart';
import 'language_page.dart';

// ignore: must_be_immutable
class HomePage extends StatelessWidget {
  String currentText = "主页";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            new Text('主页'),
            new IconButton(
                icon: Icon(Icons.language),
                onPressed: () async {
                  // Navigator.push(context, MaterialPageRoute(builder: (context) {
                  //   return languagePage();
                  // }, settings: RouteSettings(
                  //   arguments: Language('zh-CN', '中文')
                  // )));
                  var result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) {
                            return languagePage();
                          },
                          settings: RouteSettings(
                              arguments: Language('zh-CN', '中文'))));
                  Language language = result as Language;
                  /*弹窗显示返回的数据*/
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(
                            "返回的结果",
                            textAlign: TextAlign.center,
                          ),
                          content: Text(
                            "${language.code},${language.displayName}",
                            textAlign: TextAlign.center,
                          ),
                          actions: <Widget>[
                            CloseButton(
                              color: Colors.red,
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("确定")),
                          ],
                        );
                      });
                }),
          ],
        ),
      ),
    );
  }
}
