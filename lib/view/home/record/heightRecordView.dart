
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/view/home/record/baseRecordView.dart';
import 'package:raisingchildrenrecord2/view/widget/simpleDropdownButton.dart';
import 'package:raisingchildrenrecord2/viewmodel/home/record/heightRecordViewModel.dart';
import 'package:intl/intl.dart';

class HeightRecordView extends BaseRecordView<HeightRecordViewModel> {
  final _numberFormat = NumberFormat('###.0');
  HeightRecordViewModel viewModel;

  HeightRecordView({ Key key, isNew, onComplete }): super(key: key, isNew: isNew, onComplete: onComplete);

  @override
  Widget buildContent(BuildContext context) {
    viewModel = Provider.of<HeightRecordViewModel>(context);
    return _amountDropDown(context);
  }

  Widget _amountDropDown(BuildContext context) {
    return Row(
      children: <Widget>[
        StreamBuilder(
            stream: viewModel.height,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              return SimpleDropdownButton<double>(
                value: snapshot.data ?? 50.0,
                items: List<double>.generate(800, (i) => 20.0 + i * 0.1),
                itemLabel: (value) => _numberFormat.format(value),
                onChanged: (double newValue) => viewModel.onHeightSelected.add(newValue),
              );
            }
        ),

        Container(width: 10),
        Text(
            L10n.of(context).cm,
            style: TextStyle(
              fontSize: 20,
            )
        ),
      ],
    );
  }
}
