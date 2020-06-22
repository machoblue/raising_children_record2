
import 'package:flutter/cupertino.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/view/baseState.dart';
import 'package:raisingchildrenrecord2/view/widget/simpleSegmentedControl.dart';
import 'package:raisingchildrenrecord2/viewmodel/chart/growthChartViewModel.dart';

class GrowthChartView extends StatefulWidget {
  @override
  _GrowthChartViewState createState() => _GrowthChartViewState();
}

class _GrowthChartViewState extends BaseState<GrowthChartView, GrowthChartViewModel> {
  @override
  Widget build(BuildContext context) {
    L10n l10n = L10n.of(context);
    return Column(
      children: <Widget>[
        StreamBuilder(
          stream: viewModel.currentIndex,
          builder: (context, snapshot) {
            return SimpleSegmentedControl(
              currentIndex: snapshot.data,
              labels: GrowthPeriodType.values.map((periodType) => periodType.getLabel(l10n)).toList(),
              onSelect: viewModel.onSelected.add,
            );
          },
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(12),
            child: Stack(
              children: <Widget>[
                StreamBuilder(
                  stream: viewModel.period,
                  builder: (context, snapshot) {
                    return snapshot.hasData
                        ? CustomPaint(
                      painter: _GrowthChartFramePainter(snapshot.data),
                      child: Container(),
                    )
                        : Container();
                  },
                ),
                StreamBuilder(
                  stream: viewModel.statisticsData,
                  builder: (context, snapshot) {
                    return snapshot.hasData
                      ? CustomPaint(
                        painter: _GrowthStatisticsPainter(snapshot.data),
                        child: Container(),
                      )
                      : Container();
                  },
                ),
                StreamBuilder(
                  stream: viewModel.growthChartData,
                  builder: (context, snapshot) {
                    return snapshot.hasData
                      ? CustomPaint(
                        painter: _GrowthChartPainter(snapshot.data),
                        child: Container(),
                      )
                      : Container();
                  },
                ),
              ],
            ),
          )
        ),
      ],
    );
  }
}

class _GrowthChartFramePainter extends CustomPainter {
  final GrowthPeriodType periodType;

  _GrowthChartFramePainter(this.periodType);

  @override
  void paint(Canvas canvas, Size size) {
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class _GrowthStatisticsPainter extends CustomPainter {
  final GrowthStatisticsData statisticsData;

  _GrowthStatisticsPainter(this.statisticsData);

  @override
  void paint(Canvas canvas, Size size) {
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class _GrowthChartPainter extends CustomPainter {
  final GrowthChartData chartData;

  _GrowthChartPainter(this.chartData);

  @override
  void paint(Canvas canvas, Size size) {
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}