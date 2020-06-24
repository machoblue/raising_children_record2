
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/model/chartLegend.dart';
import 'package:raisingchildrenrecord2/model/period.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/view/baseState.dart';
import 'package:raisingchildrenrecord2/view/chart/milkChartView.dart';
import 'package:raisingchildrenrecord2/view/widget/circleImage.dart';
import 'package:raisingchildrenrecord2/view/widget/simpleSegmentedControl.dart';
import 'package:raisingchildrenrecord2/viewmodel/chart/sleepChartViewModel.dart';
import 'package:raisingchildrenrecord2/view/chart/canvasExtension.dart';

class SleepChartView extends StatefulWidget {
  @override
  _SleepChartViewState createState() => _SleepChartViewState();
}

class _SleepChartViewState extends BaseState<SleepChartView, SleepChartViewModel> {
  final _numberFormat = intl.NumberFormat('##0.0');
  final EdgeInsets chartMargin = EdgeInsets.fromLTRB(56, 36, 24, 24);
  final int minimumSleepMilliseconds = 0;
  final int maximumSleepMilliseconds = 1000 * 60 * 60 * 24;

  @override
  Widget build(BuildContext context) {
    L10n l10n = L10n.of(context);
    final chartLegend = ChartLegend(Colors.blue, l10n.sleepLabel, l10n.hours);
    return Column(
      children: <Widget>[
        Container(height: 12),
        StreamBuilder(
          stream: viewModel.currentIndex,
          builder: (context, snapshot) {
            return SimpleSegmentedControl(
              currentIndex: snapshot.data,
              labels: PeriodType.values.map((periodType) => periodType.getLabel(l10n)).toList(),
              onSelect: viewModel.onSelected.add,
            );
          }
        ),

        Container(
          padding: EdgeInsets.fromLTRB(48, 16, 8, 0),
          child: Row(
            children: <Widget>[
              CircleImage(
                AssetImage(RecordType.sleep.assetName),
                width: 24,
                height: 24,
              ),
              Container(height: 24, width: 4),
              Text(
                '${RecordType.sleep.localizedName}: ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              Container(height: 24, width: 8),
              Expanded(
                  child: StreamBuilder(
                      stream: viewModel.summary,
                      builder: (context, snapshot) {
                        return snapshot.hasData
                          ? CustomPaint(
                            painter: MilkChartSummaryTextPainter(
                              l10n.hours,
                              _numberFormat.format(snapshot.data.totalHour),
                              _numberFormat.format(snapshot.data.averageHour)
                            ),
                          )
                          : Container();
                      }
                  )
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: <Widget>[
              StreamBuilder(
                  stream: viewModel.period,
                  builder: (context, snapshot) {
                    return snapshot.hasData
                        ? CustomPaint(
                      painter: _SleepChartHorizontalScalePainter(
                        chartMargin,
                        snapshot.data,
                      ),
                      child: Container(),
                    )
                        : Container();
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
          ) ,
        ),

      ],
    );
  }
}

class _SleepChartHorizontalScalePainter extends CustomPainter {
  final _dateFormat = intl.DateFormat.Md();

  final EdgeInsets chartMargin;
  final Period period;

  _SleepChartHorizontalScalePainter(this.chartMargin, this.period);

  @override
  void paint(Canvas canvas, Size size) {
    final oddPaint = Paint()
      ..color = Color(0x0000000000);
    final evenPaint = Paint()
      ..color = Color(0x004400aaff);

    final fromDateTime = period.from;
    final toDateTime = period.to;
    final spanMilliseconds = toDateTime.millisecondsSinceEpoch - fromDateTime.millisecondsSinceEpoch;
    DateTime scaleLeftDateTime = fromDateTime;
    DateTime tempDateTime = fromDateTime.add(Duration(days: 1));
    Paint scalePaint = oddPaint;
    final double y0 = chartMargin.top;
    final double y1 = size.height - chartMargin.bottom;

    // configure label
    final chartWidth = size.width - (chartMargin.left + chartMargin.right);
    final double oneScaleWidth = chartWidth / (spanMilliseconds / (period.type.unitDays * 1000 * 60 * 60 * 24));
    final double fontSize = min(12.0, (oneScaleWidth * 0.8) / 5 * 2);
    final textStyle = TextStyle(fontSize: min(12, fontSize), color: Colors.black, );

    while (!tempDateTime.isAfter(toDateTime)) {
      if (period.type.isScaleBoundDay(tempDateTime) || tempDateTime == toDateTime) {
        final double x0 = chartMargin.left + chartWidth * ((scaleLeftDateTime.millisecondsSinceEpoch - fromDateTime.millisecondsSinceEpoch) / spanMilliseconds);
        final double x1 = chartMargin.left + chartWidth * ((tempDateTime.millisecondsSinceEpoch - fromDateTime.millisecondsSinceEpoch) / spanMilliseconds);
        canvas.drawRect(Rect.fromLTRB(x0, y0, x1, y1), scalePaint);

        canvas.drawText(
            _dateFormat.format(scaleLeftDateTime),
            textStyle,
            period.type == PeriodType.oneWeek ? TextAlign.center : TextAlign.start,
            Rect.fromLTRB(x0, size.height - chartMargin.bottom, x1, size.height)
        );

        // 値の更新
        scaleLeftDateTime = tempDateTime;
        scalePaint = scalePaint == oddPaint ? evenPaint : oddPaint;
      }

      tempDateTime = tempDateTime.add(Duration(days: 1));
    }
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
    _drawYAxisLabels(canvas, size);
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

  void _drawYAxisLabels(Canvas canvas, Size size) {
    final double fontSize = 12;
    final textStyle = TextStyle(color: Colors.black, fontSize: fontSize);
    final double chartHeight = size.height - (chartMargin.top + chartMargin.bottom);
    final double yO = size.height - chartMargin.bottom;
    final double rectLeftOffset = 4;
    double unitHeight = chartHeight / 24;
    for (int i = 0; i < 24; i++) {
      final double y = yO - unitHeight * i - fontSize / 2;
      canvas.drawText('$i', textStyle, TextAlign.end, Rect.fromLTRB(0, y, chartMargin.left - rectLeftOffset, y + unitHeight));
    }

    final double unitY = chartMargin.top - fontSize / 2;
    canvas.drawText('(${chartLegend.unit})', textStyle, TextAlign.end, Rect.fromLTRB(0, unitY , chartMargin.left - rectLeftOffset, unitY + unitHeight));
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
    _drawChart(canvas, size);
  }

  void _drawChart(Canvas canvas, Size size) {
    final Map<DateTime, int> dateTimeToMilliseconds = data.dateTimeToMilliseconds;
    if (dateTimeToMilliseconds == null || dateTimeToMilliseconds.length == 0) {
      return;
    }

    final int spanMilliseconds = period.to.millisecondsSinceEpoch - period.from.millisecondsSinceEpoch;
    final double chartWidth = size.width - (chartMargin.left + chartMargin.right);
    final double xOffset = (chartWidth / period.type.days) / 2;
    final double chartHeight = size.height - (chartMargin.top + chartMargin.bottom);
    List<Point<double>> points = dateTimeToMilliseconds.entries
        .map((entry) {
      final DateTime dateTime = entry.key;
      final int value = entry.value;
      final double x = chartMargin.left + chartWidth * ((dateTime.millisecondsSinceEpoch - period.from.millisecondsSinceEpoch) / spanMilliseconds) + xOffset;
      final double y = chartMargin.top + chartHeight * ((maximumSleepMilliseconds - value) / (maximumSleepMilliseconds - minimumSleepMilliseconds));
      return Point(x, y);
    })
        .toList();

    Paint pointPaint = Paint()
      ..color = data.color
      ..style = PaintingStyle.fill;

    Path chartPath = Path();
    chartPath.moveTo(points.first.x, points.first.y);

    canvas.drawCircle(Offset(points.first.x, points.first.y), 3.5, pointPaint);

    if (points.length > 1) {
      for (int i = 1; i < points.length; i++) {
        final point = points[i];
        chartPath.lineTo(point.x, point.y);
        canvas.drawCircle(Offset(point.x, point.y), 3.5, pointPaint);
      }
    }

    Paint chartPaint = Paint()
      ..color = data.color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawPath(chartPath, chartPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}