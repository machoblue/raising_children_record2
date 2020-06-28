
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/view/home/record/baseRecordView.dart';
import 'package:raisingchildrenrecord2/view/shared/widget/simpleDropdownButton.dart';
import 'package:raisingchildrenrecord2/viewmodel/home/record/bodyTemperatureRecordViewModel.dart';
import 'package:intl/intl.dart';

class BodyTemperatureRecordView extends BaseRecordView<BodyTemperatureRecordViewModel> {
  final _numberFormat = NumberFormat('###.0');
  BodyTemperatureRecordViewModel viewModel;

  BodyTemperatureRecordView({ Key key, isNew, onComplete }): super(key: key, isNew: isNew, onComplete: onComplete);

  @override
  Widget buildContent(BuildContext context) {
    viewModel = Provider.of<BodyTemperatureRecordViewModel>(context);
    return _amountDropDown(context);
  }

  Widget _amountDropDown(BuildContext context) {
    return Row(
      children: <Widget>[
        StreamBuilder(
            stream: viewModel.bodyTemperature,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              return SimpleDropdownButton<double>(
                value: snapshot.data ?? 36.5,
                items: List<double>.generate(80, (i) => 34.0 + i * 0.1),
                itemLabel: (value) => _numberFormat.format(value),
                onChanged: (double newValue) => viewModel.onBodyTemperatureSelected.add(newValue),
              );
            }
        ),

        Container(width: 10),
        Text(
            L10n.of(context).degreesCelsius,
            style: TextStyle(
              fontSize: 20,
            )
        ),
      ],
    );
  }
}
