
import 'package:flutter/cupertino.dart';
import 'package:raisingchildrenrecord2/view/baseState.dart';
import 'package:raisingchildrenrecord2/view/widget/calendarLayout.dart';
import 'package:raisingchildrenrecord2/viewmodel/chart/conditionChartViewModel.dart';

class ConditionChartView extends StatefulWidget {
  @override
  _ConditionChartViewState createState() => _ConditionChartViewState();
}

class _ConditionChartViewState extends BaseState<ConditionChartView, ConditionChartViewModel> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        children: <Widget>[
          StreamBuilder(
            stream: viewModel.data,
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return Container();
              }
              final ConditionChartData data = snapshot.data;
              return Expanded(
                child: CalendarLayout(
                  data.month,
                  onPrevPressed: () => viewModel.monthDecrement.add(null),
                  onNextPressed: () => viewModel.monthIncrement.add(null),
                  dateCellBuilder: (dateTime) {
                    return Container();
                  },
                ),
              );
            },
          )
        ],
      ),
    );
  }
}