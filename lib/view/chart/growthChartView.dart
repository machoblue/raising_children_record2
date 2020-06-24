
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/model/chartLegend.dart';
import 'package:raisingchildrenrecord2/view/baseState.dart';
import 'package:raisingchildrenrecord2/view/widget/simpleSegmentedControl.dart';
import 'package:raisingchildrenrecord2/viewmodel/chart/growthChartViewModel.dart';
import 'package:raisingchildrenrecord2/view/chart/canvasExtension.dart';

class GrowthChartView extends StatefulWidget {
  @override
  _GrowthChartViewState createState() => _GrowthChartViewState();
}

class _GrowthChartViewState extends BaseState<GrowthChartView, GrowthChartViewModel> {
  final EdgeInsets chartAreaMargin = EdgeInsets.fromLTRB(24, 24, 24, 24);
  @override
  Widget build(BuildContext context) {
    L10n l10n = L10n.of(context);
    final List<ChartLegend> legends = [
      ChartLegend(Colors.yellow, l10n.heightLabel, l10n.cm),
      ChartLegend(Colors.orange, l10n.weightLabel, l10n.kg),
    ];
    return Column(
      children: <Widget>[
        Container(height: 12),
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
                      painter: _GrowthChartFramePainter(legends, snapshot.data, chartAreaMargin),
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
                        painter: _GrowthStatisticsPainter(snapshot.data, chartAreaMargin),
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
                        painter: _GrowthChartPainter(snapshot.data, chartAreaMargin),
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
  final labelStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.black);
  final unitStyle = TextStyle(fontSize: 9, fontWeight: FontWeight.normal, color: Colors.black);

  final List<ChartLegend> legends;
  final GrowthPeriodType periodType;
  final EdgeInsets margin;

  _GrowthChartFramePainter(this.legends, this.periodType, this.margin);

  @override
  void paint(Canvas canvas, Size size) {
    _drawLegend(canvas, size);
    _drawXAxisAndYAxis(canvas, size);
    _drawHorizontalLines(canvas, size);
    _drawYAxisLabels(canvas, size);
    _drawVerticalLines(canvas, size);
    _drawXAxisLabels(canvas, size);
  }

  void _drawLegend(Canvas canvas, Size size) {
    final double fontSize = 12;
    final textSpan = TextSpan(
      style: TextStyle(color: Colors.black, fontSize: fontSize),
      children: legends.map((legend) {
        return <TextSpan>[
          TextSpan(text: '●', style: TextStyle(color: legend.color, fontSize: fontSize)),
          TextSpan(text: '${legend.name}(${legend.unit}) '),
        ];
      })
      .expand((textSpanList) => textSpanList)
      .toList(),
    );
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout(minWidth: 0, maxWidth: size.width);
    final double legendMarginBottom = 6;
    textPainter.paint(canvas, Offset(margin.left, margin.top - fontSize - legendMarginBottom));
  }

  void _drawXAxisAndYAxis(Canvas canvas, Size size) {
    final List<Point<double>> points = [
      Point(margin.left, margin.top),
      Point(margin.left, size.height - margin.bottom),
      Point(size.width - margin.right, size.height - margin.bottom),
      Point(size.width - margin.right, margin.top),
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
    Path path = Path();
    final double x0 = margin.left;
    final double x1 = size.width - margin.right;
    final int diff = (periodType.weightRange.max - periodType.weightRange.min).toInt();
    final double unitHeight = (size.height - (margin.top + margin.bottom)) / diff;
    for (int i = 0; i < diff; i++) {
      final double y = size.height - margin.bottom - unitHeight * (i + 1);
      path.moveTo(x0, y);
      path.lineTo(x1, y);
    }

    Paint paint = Paint()
      ..color = Colors.grey
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    canvas.drawPath(path, paint);
  }

  void _drawYAxisLabels(Canvas canvas, Size size) {
    final int diff = (periodType.weightRange.max - periodType.weightRange.min).toInt();
    final double unitHeight = (size.height - (margin.top + margin.bottom)) / diff;
    final double heightPerOneScale = (periodType.heightRange.max - periodType.heightRange.min) / diff;
    final double weightPerOneScale = (periodType.weightRange.max - periodType.weightRange.min) / diff;
    final double fontSizeHalf = 6;
    final double spanX = 2;
    for (int i = 0; i < diff - 1; i++) {
      final double y = size.height - margin.bottom - unitHeight * (i + 1);
      final heightLabelValue = (periodType.heightRange.min + heightPerOneScale * i).toInt();
      canvas.drawText('$heightLabelValue', labelStyle, TextAlign.end, Rect.fromLTRB(0, y - fontSizeHalf, margin.left - spanX, y + fontSizeHalf));
      final weightLabelValue = (periodType.weightRange.min + weightPerOneScale * i).toInt();
      canvas.drawText('$weightLabelValue', labelStyle, TextAlign.start, Rect.fromLTRB(size.width - margin.right + spanX, y - fontSizeHalf, size.width, y + fontSizeHalf));
    }

    canvas.drawText('(cm)', unitStyle, TextAlign.end, Rect.fromLTRB(0, margin.top - fontSizeHalf, margin.left - spanX, margin.top + fontSizeHalf));
    canvas.drawText('(kg)', unitStyle, TextAlign.start, Rect.fromLTRB(size.width - margin.right + spanX, margin.top - fontSizeHalf, size.width, margin.top + fontSizeHalf));
  }

  void _drawVerticalLines(Canvas canvas, Size size) {
    final double y0 = margin.top;
    final double y1 = size.height - margin.bottom;
    final double unitWidth = (size.width - (margin.left + margin.right)) / (periodType.months / periodType.monthsPerOneScale);
    Path path = Path();
    for (int i = 0; i < (periodType.months / periodType.monthsPerOneScale) - 1; i++) {
      final double x = margin.left + unitWidth * (i + 1);
      path.moveTo(x, y0);
      path.lineTo(x, y1);
    }

    Paint paint = Paint()
      ..color = Colors.grey
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    canvas.drawPath(path, paint);
  }

  void _drawXAxisLabels(Canvas canvas, Size size) {

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class _GrowthStatisticsPainter extends CustomPainter {
  final GrowthStatisticsData statisticsData;
  final EdgeInsets margin;

  _GrowthStatisticsPainter(this.statisticsData, this.margin);

  @override
  void paint(Canvas canvas, Size size) {
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class _GrowthChartPainter extends CustomPainter {
  final GrowthChartData chartData;
  final EdgeInsets margin;

  _GrowthChartPainter(this.chartData, this.margin);

  @override
  void paint(Canvas canvas, Size size) {
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}