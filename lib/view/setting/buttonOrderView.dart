
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
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
    return StreamBuilder(
      stream: _viewModel.recordTypes,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        final List<RecordType> recordTypes = snapshot.data;
        return ReorderableListView(
          onReorder: (oldOrder, newOrder) => _onReorder(oldOrder, newOrder, recordTypes),
          children: <Widget>[
            for (RecordType recordType in recordTypes)
              _buildListTile(recordType),
          ],
        );
      },
    );
  }

  Widget _buildListTile(RecordType recordType) {
    return Container(
      key: Key(recordType.string),
      padding: EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.fitHeight,
                image: AssetImage(recordType.assetName),
              )
            ),
          ),
          Container(
            height: 36,
            width: 8
          ),
          Expanded(
            child: Text(
              recordType.localizedName,
            ),
          ),
          Icon(
            Icons.reorder,
            size: 24,
            color: Colors.grey,
          )
        ],
      )
    );
  }

  void _onReorder(int oldIndex, int newIndex, List<RecordType> recordTypes) {
    recordTypes.insert(newIndex, recordTypes.removeAt(oldIndex));
    _viewModel.onButtonOrderChanged.add(recordTypes.map((recordType) => recordType.string).toList());
  }
}