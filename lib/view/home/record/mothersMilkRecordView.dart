
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/view/home/record/baseRecordView.dart';
import 'package:raisingchildrenrecord2/view/widget/simpleDropdownButton.dart';
import 'package:raisingchildrenrecord2/viewmodel/home/record/mothersMilkRecordViewModel.dart';
import 'package:intl/intl.dart';

class MothersMilkRecordView extends BaseRecordView<MothersMilkRecordViewModel> {
  MothersMilkRecordViewModel viewModel;

  MothersMilkRecordView({ Key key, isNew, onComplete }): super(key: key, isNew: isNew, onComplete: onComplete);

  @override
  Widget buildContent(BuildContext context) {
    viewModel = Provider.of<MothersMilkRecordViewModel>(context);
    return _amountDropDown(context);
  }

  Widget _amountDropDown(BuildContext context) {
    L10n l10n = L10n.of(context);
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
                l10n.left,
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
                l10n.minutes,
                style: TextStyle(
                  fontSize: 20,
                )
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Text(
                l10n.right,
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
                l10n.minutes,
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
