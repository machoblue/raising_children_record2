
import 'package:flutter/cupertino.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/view/baseState.dart';
import 'package:raisingchildrenrecord2/view/widget/simpleSegmentedControl.dart';
import 'package:raisingchildrenrecord2/viewmodel/chart/milkChartViewModel.dart';

class MilkChartView extends StatefulWidget {
  @override
  _MilkChartViewState createState() => _MilkChartViewState();
}

class _MilkChartViewState extends BaseState<MilkChartView, MilkChartViewModel> {

  @override
  Widget build(BuildContext context) {
    L10n l10n = L10n.of(context);
    return Column(
      children: <Widget>[
        Container(height: 12),
        StreamBuilder(
          stream: viewModel.currentIndex,
          builder: (context, snapshot) {
            return SimpleSegmentedControl(
              currentIndex: snapshot.data,
              labels: MilkViewTabItem.values.map((item) => item.getLabel(l10n)).toList(),
              onSelect: viewModel.onSelected.add,
            );
          },
        ),
        Container(),
      ],
    );
  }
}

enum MilkViewTabItem {
  oneWeek, threeWeeks, threeMonths,
}

extension MilkViewTabItemExtension on MilkViewTabItem {
  String getLabel(L10n l10n) {
    switch (this) {
      case MilkViewTabItem.oneWeek: return l10n.oneWeek;
      case MilkViewTabItem.threeWeeks: return l10n.threeWeeks;
      case MilkViewTabItem.threeMonths: return l10n.threeMonths;
    }
  }
}