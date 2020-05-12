
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/viewmodel/setting/buttonOrderViewModel.dart';

class ButtonOrderView extends StatefulWidget {
  @override
  _ButtonOrderViewState createState() => _ButtonOrderViewState();
}

class _ButtonOrderViewState extends State<ButtonOrderView> {

  ButtonOrderViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<ButtonOrderViewModel>(context, listen: false);
  }

  @override
  void dispose() {
    super.dispose();
    _viewModel.dispose();
  }

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