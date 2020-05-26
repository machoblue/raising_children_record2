
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/view/record/baseRecordView.dart';
import 'package:raisingchildrenrecord2/viewmodel/record/mothersMilkRecordViewModel.dart';
import 'package:intl/intl.dart';

class MothersMilkRecordView extends BaseRecordView<MothersMilkRecordViewModel> {
  final _listItemFont = const TextStyle(fontSize: 20.0);
  MothersMilkRecordViewModel viewModel;

  MothersMilkRecordView({ Key key, isNew, onComplete }): super(key: key, isNew: isNew, onComplete: onComplete);

  @override
  Widget buildContent(BuildContext context) {
    viewModel = Provider.of<MothersMilkRecordViewModel>(context);
    return _amountDropDown();
  }

  Widget _amountDropDown() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
                '${Intl.message('Left', name: 'left')}:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )
            ),
            Container(width: 10),
            StreamBuilder(
                stream: viewModel.leftMinutes,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }
                  return DropdownButton<int>(
                    value: snapshot.data ?? 0,
                    items: List<int>.generate(60, (i) => i).map((value) {
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
                    onChanged: (int newValue) => viewModel.onLeftMinutesSelected.add(newValue),
                  );
                }
            ),

            Container(width: 10),
            Text(
                Intl.message('minutes', name: 'minutes'),
                style: TextStyle(
                  fontSize: 20,
                )
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Text(
                '${Intl.message('Right', name: 'right')}:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )
            ),
            Container(width: 10),
            StreamBuilder(
                stream: viewModel.rightMinutes,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    print("### !snapshot.hasData");
                    return Container();
                  }
                  return DropdownButton<int>(
                    value: snapshot.data ?? 0,
                    items: List<int>.generate(60, (i) => i).map((value) {
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
                    onChanged: (int newValue) => viewModel.onRightMinutesSelected.add(newValue),
                  );
                }
            ),

            Container(width: 10),
            Text(
                Intl.message('minutes', name: 'minutes'),
                style: TextStyle(
                  fontSize: 20,
                )
            ),
          ],
        ),
      ],
    );
  }
}
