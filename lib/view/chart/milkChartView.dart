
import 'package:flutter/cupertino.dart';
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
    return Column(
      children: <Widget>[
        Container(height: 12),
        StreamBuilder(
          stream: viewModel.currentIndex,
          builder: (context, snapshot) {
            return SimpleSegmentedControl(
              currentIndex: snapshot.data,
              labels: ['1週間', '3週間', '1ヶ月'],
              onSelect: (selectedIndex) {
                viewModel.onSelected.add(selectedIndex);
              },
            );
          },
        ),
        Container(),
      ],
    );
  }
}