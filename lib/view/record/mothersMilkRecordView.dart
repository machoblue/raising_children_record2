
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/view/record/baseRecordView.dart';
import 'package:raisingchildrenrecord2/view/widget/simpleDropdownButton.dart';
import 'package:raisingchildrenrecord2/viewmodel/record/mothersMilkRecordViewModel.dart';
import 'package:intl/intl.dart';

class MothersMilkRecordView extends BaseRecordView<MothersMilkRecordViewModel> {
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
                  return SimpleDropdownButton<int>(
                    value: snapshot.data ?? 0,
                    items: List<int>.generate(60, (i) => i),
                    itemLabel: (value) => '$value',
                    onChanged: (newValue) => viewModel.onLeftMinutesSelected.add(newValue),
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
                  return SimpleDropdownButton<int>(
                    value: snapshot.data ?? 0,
                    items: List<int>.generate(60, (i) => i),
                    itemLabel: (value) => '$value',
                    onChanged: (newValue) => viewModel.onRightMinutesSelected.add(newValue),
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
