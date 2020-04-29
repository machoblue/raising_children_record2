
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/view/record/baseRecordView.dart';
import 'package:raisingchildrenrecord2/view/record/plainRecordView.dart';
import 'package:raisingchildrenrecord2/viewmodel/record/milkRecordViewModel.dart';

class MilkRecordView extends BaseRecordView<MilkRecordViewModel> {
  final _listItemFont = const TextStyle(fontSize: 20.0);
  MilkRecordViewModel viewModel;

  MilkRecordView({ Key key, isNew }): super(key: key, isNew: isNew);

  @override
  Widget buildContent(BuildContext context) {
    viewModel = Provider.of<MilkRecordViewModel>(context);
    return _amountDropDown();
  }

  Widget _amountDropDown() {
    return Row(
      children: <Widget>[
        StreamBuilder(
            stream: viewModel.amount,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              return DropdownButton<int>(
                value: snapshot.data ?? 0,
                items: List<int>.generate(36, (i) => i * 10).map((value) {
                  return DropdownMenuItem<int>(
                      value: value,
                      child: Container(
                          padding: EdgeInsets.fromLTRB(20, 0, 12, 0),
                          child: Text(
                            "$value",
                            style: _listItemFont,
                          )
                      )
                  );
                }).toList(),
                icon: Icon(Icons.expand_more),
                iconSize: 24,
                elevation: 16,
                underline: Container(
                  height: 2,
                  color: Colors.black54,
                ),
                onChanged: (int newValue) => viewModel.onAmountSelected.add(newValue),
              );
            }
        ),

        Container(width: 10),
        Text(
            "ml",
            style: TextStyle(
              fontSize: 20,
            )
        ),
      ],
    );
  }
}
