
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/view/record/baseRecordView.dart';
import 'package:raisingchildrenrecord2/view/widget/simpleDropdownButton.dart';
import 'package:raisingchildrenrecord2/viewmodel/record/weightRecordViewModel.dart';

class WeightRecordView extends BaseRecordView<WeightRecordViewModel> {
  WeightRecordViewModel viewModel;

  WeightRecordView({ Key key, isNew, onComplete }): super(key: key, isNew: isNew, onComplete: onComplete);

  @override
  Widget buildContent(BuildContext context) {
    viewModel = Provider.of<WeightRecordViewModel>(context);
    return _amountDropDown(context);
  }

  Widget _amountDropDown(BuildContext context) {
    return Row(
      children: <Widget>[
        StreamBuilder(
            stream: viewModel.weight,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              return SimpleDropdownButton<double>(
                value: snapshot.data ?? 5.0,
                items: List<double>.generate(195, (i) => 0.5 + i * 0.1),
                itemLabel: (value) => '$value',
                onChanged: (double newValue) => viewModel.onWeightSelected.add(newValue),
              );
            }
        ),

        Container(width: 10),
        Text(
            L10n.of(context).kg,
            style: TextStyle(
              fontSize: 20,
            )
        ),
      ],
    );
  }
}
