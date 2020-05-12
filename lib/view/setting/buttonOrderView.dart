
import 'package:flutter/material.dart';

class ButtonOrderView extends StatefulWidget {
  @override
  _ButtonOrderViewState createState() => _ButtonOrderViewState();
}

class _ButtonOrderViewState extends State<ButtonOrderView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ボタンの順番を変更する')
      ),
      body: _body(),
    );
  }

  Widget _body() {
    List<String> items = ['Alice', 'Bob', 'Charlie', 'D'];
    return ReorderableListView(

      onReorder: (oldIndex, newIndex) {

        print("#### $oldIndex $newIndex");
      },
      children: <Widget>[
        for (String item in items)
          ListTile(
            key: ValueKey(item),
            title: Text(item),
          ),
      ]
    );
  }
}