
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/view/baseState.dart';
import 'package:raisingchildrenrecord2/viewmodel/setting/buttonOrderViewModel.dart';

class ButtonOrderView extends StatefulWidget {
  @override
  _ButtonOrderViewState createState() => _ButtonOrderViewState();
}

class _ButtonOrderViewState extends BaseState<ButtonOrderView, ButtonOrderViewModel> {

  @override
  Widget build(BuildContext context) {
    Fluttertoast.showToast(msg: L10n.of(context).editRecordButtonsOrderMessage, toastLength: Toast.LENGTH_LONG);
    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.of(context).editRecordButtonsOrder),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return StreamBuilder(
      stream: viewModel.recordTypes,
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
    RecordType movedRecordType = recordTypes.removeAt(oldIndex);
    newIndex -= newIndex > oldIndex ? 1 : 0;
    recordTypes.insert(newIndex, movedRecordType);
    viewModel.onButtonOrderChanged.add(recordTypes.map((recordType) => recordType.string).toList());
  }
}