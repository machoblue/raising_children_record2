
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/view/record/baseRecordView.dart';
import 'package:raisingchildrenrecord2/view/widget/simpleDropdownButton.dart';
import 'package:raisingchildrenrecord2/viewmodel/record/milkRecordViewModel.dart';

class MilkRecordView extends BaseRecordView<MilkRecordViewModel> {
  MilkRecordViewModel viewModel;

  MilkRecordView({ Key key, isNew, onComplete }): super(key: key, isNew: isNew, onComplete: onComplete);

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
              return SimpleDropdownButton<int>(
                value: snapshot.data ?? 0,
                items: List<int>.generate(36, (i) => i * 10),
                itemLabel: (value) => '$value',
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
