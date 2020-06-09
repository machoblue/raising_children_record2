
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/model/chartLegend.dart';
import 'package:raisingchildrenrecord2/model/period.dart';
import 'package:raisingchildrenrecord2/view/baseState.dart';
import 'package:raisingchildrenrecord2/view/widget/simpleSegmentedControl.dart';
import 'package:raisingchildrenrecord2/viewmodel/chart/sleepChartViewModel.dart';

class SleepChartView extends StatefulWidget {
  @override
  _SleepChartViewState createState() => _SleepChartViewState();
}

class _SleepChartViewState extends BaseState<SleepChartView, SleepChartViewModel> {
  final _numberFormat = intl.NumberFormat('##0.0');
  final EdgeInsets chartMargin = EdgeInsets.fromLTRB(24, 12, 24, 24);
  final int minimumSleepMilliseconds = 0;
  final int maximumSleepMilliseconds = 1000 * 60 * 60 * 24;

  @override
  Widget build(BuildContext context) {
    L10n l10n = L10n.of(context);
    final chartLegend = ChartLegend(Colors.blue, l10n.sleepLabel, l10n.hours);
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
              painter: _SleepChartHorizontalScalePainter(
                chartMargin,
                snapshot.data,
              ),
              child: Container(),
            );
          }
        ),
        CustomPaint(
          painter: _SleepChartVerticalScalePainter(
            chartMargin,
            minimumSleepMilliseconds,
            maximumSleepMilliseconds,
            chartLegend,
          ),
          child: Container(),
        ),
        StreamBuilder(
          stream: viewModel.data,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }
            return CustomPaint(
              painter: _SleepChartPainter(
                chartMargin,
                snapshot.data.period,
                minimumSleepMilliseconds,
                maximumSleepMilliseconds,
                snapshot.data,
              ),
              child: Container(),
            );
          }
        )
      ],
    );
  }
}

class _SleepChartHorizontalScalePainter extends CustomPainter {

  final EdgeInsets chartMargin;
  final Period period;

  _SleepChartHorizontalScalePainter(this.chartMargin, this.period);

  @override
  void paint(Canvas canvas, Size size) {
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class _SleepChartVerticalScalePainter extends CustomPainter {

  final EdgeInsets chartMargin;
  final int minimumSleepMilliseconds;
  final int maximumSleepMilliseconds;
  final ChartLegend chartLegend;

  _SleepChartVerticalScalePainter(this.chartMargin, this.minimumSleepMilliseconds, this.maximumSleepMilliseconds, this.chartLegend);

  @override
  void paint(Canvas canvas, Size size) {
    _drawLegend(canvas, size);
    _drawXAxisAndYAxis(canvas, size);
    _drawHorizontalLines(canvas, size);
  }

  void _drawLegend(Canvas canvas, Size size) {
    final double fontSize = 12;
    final baseTextStyle = TextStyle(color: Colors.black, fontSize: fontSize);
    final textSpan = TextSpan(
      style: baseTextStyle,
      children: <TextSpan>[
        TextSpan(text: '●' ,style: TextStyle(color: chartLegend.color, fontSize: fontSize)),
        TextSpan(text: '${chartLegend.name}(${chartLegend.unit}) '),
      ],
    );

    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout(minWidth: 0, maxWidth: size.width);
    final double marginBottom = 6;
    textPainter.paint(canvas, Offset(chartMargin.left, chartMargin.top - fontSize - marginBottom));
  }

  void _drawXAxisAndYAxis(Canvas canvas, Size size) {
    final List<Point<double>> points = [
      Point(chartMargin.left, chartMargin.top),
      Point(chartMargin.left, size.height - chartMargin.bottom),
      Point(size.width - chartMargin.right, size.height - chartMargin.bottom),
      Point(size.width - chartMargin.right, chartMargin.top),
    ];

    Path path = Path();
    path.moveTo(points.first.x, points.first.y);
    for (int i = 1; i < points.length; i++) {
      final Point point = points[i];
      path.lineTo(point.x, point.y);
    }

    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawPath(path, paint);
  }

  void _drawHorizontalLines(Canvas canvas, Size size) {
    Path horizontalLinePath = Path();
    final double chartHeight = size.height - (chartMargin.top + chartMargin.bottom);
    double unitHeight = chartHeight / 24;
    for (int i = 0; i < 24; i++) {
      double y = chartMargin.top + i * unitHeight;
      horizontalLinePath.moveTo(chartMargin.left, y);
      horizontalLinePath.lineTo(size.width - chartMargin.right, y);
    }

    Paint horizontalLinePaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawPath(horizontalLinePath, horizontalLinePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _SleepChartPainter extends CustomPainter {

  final EdgeInsets chartMargin;
  final Period period;
  final int minimumSleepMilliseconds;
  final int maximumSleepMilliseconds;
  final SleepChartData data;

  _SleepChartPainter(this.chartMargin, this.period, this.minimumSleepMilliseconds, this.maximumSleepMilliseconds, this.data);

  @override
  void paint(Canvas canvas, Size size) {
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}