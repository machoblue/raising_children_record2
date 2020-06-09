
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/model/period.dart';
import 'package:raisingchildrenrecord2/view/baseState.dart';
import 'package:raisingchildrenrecord2/view/widget/simpleSegmentedControl.dart';
import 'package:raisingchildrenrecord2/viewmodel/chart/sleepChartViewModel.dart';

class SleepChartView extends StatefulWidget {
  @override
  _SleepChartViewState createState() => _SleepChartViewState();
}

class _SleepChartViewState extends BaseState<SleepChartView, SleepChartViewModel> {
  final NumberFormat _numberFormat = NumberFormat('##0.0');

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
              labels: PeriodType.values.map((periodType) => periodType.getLabel(l10n)),
              onSelect: viewModel.onSelected.add,
            );
          }
        ),
        StreamBuilder(
          stream: viewModel.period,
          builder: (context, snapshot) {
            return CustomPaint(
              painter: _SleepChartHorizontalScalePainter(),
              child: Container(),
            );
          }
        ),
        CustomPaint(
          painter: _SleepChartVerticalScalePainter(),
          child: Container(),
        ),
        StreamBuilder(
          stream: viewModel.data,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }
            return CustomPaint(
              painter: _SleepChartPainter(),
              child: Container(),
            );
          }
        )
      ],
    );
  }
}

class _SleepChartHorizontalScalePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class _SleepChartVerticalScalePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _SleepChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}