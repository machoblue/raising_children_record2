
import 'dart:math';
import 'package:intl/intl.dart' as intl;
import 'package:flutter/material.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/model/chartLegend.dart';
import 'package:raisingchildrenrecord2/model/period.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/view/baseState.dart';
import 'package:raisingchildrenrecord2/view/shared/widget/circleImage.dart';
import 'package:raisingchildrenrecord2/view/shared/widget/simpleSegmentedControl.dart';
import 'package:raisingchildrenrecord2/viewmodel/chart/milkChartViewModel.dart';
import 'package:raisingchildrenrecord2/view/shared/canvasExtension.dart';

class MilkChartView extends StatefulWidget {
  @override
  _MilkChartViewState createState() => _MilkChartViewState();
}

class _MilkChartViewState extends BaseState<MilkChartView, MilkChartViewModel> {
  final _numberFormat = intl.NumberFormat('##0.0');

  @override
  Widget build(BuildContext context) {
    L10n l10n = L10n.of(context);
    final milkLegend = ChartLegend(Colors.yellow, l10n.milkLabel, l10n.ml);
    final mothersMilkLegend = ChartLegend(Colors.pink, l10n.mothersMilkLabel, l10n.hours);
    return Column(
      children: <Widget>[
        Container(height: 12),
        StreamBuilder(
          stream: viewModel.currentIndex,
          builder: (context, snapshot) {
            return SimpleSegmentedControl(
              currentIndex: snapshot.data,
              labels: PeriodType.values.map((item) => item.getLabel(l10n)).toList(),
              onSelect: viewModel.onSelected.add,
            );
          },
        ),
        Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(32, 8, 8, 0),
              child: Row(
                children: <Widget>[
                  CircleImage(
                    AssetImage(RecordType.milk.assetName),
                    width: 24,
                    height: 24,
                  ),
                  Container(height: 24, width: 4),
                  Text(
                    '${RecordType.milk.localizedName}: ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  Container(height: 24, width: 8),
                  Expanded(
                      child: StreamBuilder(
                          stream: viewModel.milkChartSummary,
                          builder: (context, snapshot) {
                            return snapshot.hasData
                                ? CustomPaint(
                              painter: MilkChartSummaryTextPainter(l10n.ml, snapshot.data.milkSum.toString(), snapshot.data.milkAverage.toString()),
                            )
                                : Container();
                          }
                      )
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(32, 16, 8, 0),
              child: Row(
                children: <Widget>[
                  CircleImage(
                    AssetImage(RecordType.mothersMilk.assetName),
                    width: 24,
                    height: 24,
                  ),
                  Container(height: 24, width: 4),
                  Text(
                    '${RecordType.mothersMilk.localizedName}: ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  Container(height: 24, width: 8),
                  Expanded(
                    child: StreamBuilder(
                      stream: viewModel.milkChartSummary,
                      builder: (context, snapshot) {
                        return snapshot.hasData
                          ? CustomPaint(
                            painter: MilkChartSummaryTextPainter(l10n.hours, _numberFormat.format(snapshot.data.mothersMilkSum), _numberFormat.format(snapshot.data.mothersMilkAverage)),
                          )
                          : Container();
                      }
                    )
                  ),
                ],
              ),
            ),
          ],
        ),
        Expanded(
          child: Container(
            child: Stack(
              children: <Widget>[
                StreamBuilder(
                  stream: viewModel.period,
                  builder: (context, snapshot) {
                    return snapshot.hasData
                      ? CustomPaint(
                        painter: MilkChartHorizontalScalePainter(snapshot.data),
                        child: Container(),
                      )
                      : Container();
                  }
                ),
                CustomPaint(
                  painter: MilkChartFramePainter(milkLegend, mothersMilkLegend),
                  child: Container(),
                ),
                StreamBuilder(
                  stream: viewModel.data,
                  builder: (context, snapshot) {
                    return snapshot.hasData
                      ? CustomPaint(
                        painter: MilkChartPainter(snapshot.data),
                        child: Container(),
                      )
                      : Container();
                  }
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MilkChartFramePainter extends CustomPainter {
  final ChartLegend legend1;
  final ChartLegend legend2;

  MilkChartFramePainter(this.legend1, this.legend2);

  @override
  void paint(Canvas canvas, Size size) {
    final double margin = min(size.width * 0.1, size.height * 0.1);

    final double fontSize = 12;
    final baseTextStyle = TextStyle(color: Colors.black, fontSize: fontSize);
    final textSpan = TextSpan(
      style: baseTextStyle,
      children: <TextSpan>[
        TextSpan(text: '●' ,style: TextStyle(color: legend1.color, fontSize: fontSize)),
        TextSpan(text: '${legend1.name}(${legend1.unit}) '),
        TextSpan(text: '●' ,style: TextStyle(color: legend2.color, fontSize: fontSize)),
        TextSpan(text: '${legend2.name}(${legend2.unit}) '),
      ],
    );

    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout(minWidth: 0, maxWidth: size.width);
    final double marginBottom = 6;
    textPainter.paint(canvas, Offset(margin, margin - fontSize - marginBottom));

    Path path = Path();
    double x0 = margin;
    double y0 = margin;
    double x1 = x0;
    double y1 = size.height - margin;
    double x2 = size.width - margin;
    double y2 = y1;
    double x3 = x2;
    double y3 = y0;
    path.moveTo(x0, y0);
    path.lineTo(x1, y1);
    path.lineTo(x2, y2);
    path.lineTo(x3, y3);

    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawPath(path, paint);

    Path horizontalLinePath = Path();
    double unitHeight = (size.height - margin * 2) / 32;
    for (int i = 0; i < 32; i++) {
      double y = margin + i * unitHeight;
      horizontalLinePath.moveTo(x0, y);
      horizontalLinePath.lineTo(x2, y);
    }

    Paint horizontalLinePaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawPath(horizontalLinePath, horizontalLinePaint);

    for (int i = 0; i < 7; i++) {
      final textSpan = TextSpan(style: baseTextStyle, text: (500 * i).toString());
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr, textAlign: TextAlign.right);
      textPainter.layout(minWidth: margin - 2.5, maxWidth: size.width);
      textPainter.paint(canvas, Offset(0, size.height - margin - fontSize / 2 - unitHeight * 5 * i));
    }

    final unitTextSpan = TextSpan(style: baseTextStyle, text: '(${legend1.unit})');
    final unitTextPainter = TextPainter(text: unitTextSpan, textDirection: TextDirection.ltr, textAlign: TextAlign.right);
    unitTextPainter.layout(minWidth: margin - 2.5, maxWidth: size.width);
    unitTextPainter.paint(canvas, Offset(0, margin - fontSize / 2));

    for (int i = 0; i < 16; i++) {
      final textSpan = TextSpan(style: baseTextStyle, text: (0.5 * i).toString());
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      textPainter.layout(minWidth: 0, maxWidth: size.width);
      textPainter.paint(canvas, Offset(size.width - margin + 2.5, size.height - margin - fontSize / 2 - unitHeight * 2 * i));
    }

    final unitTextSpan2 = TextSpan(style: baseTextStyle, text: '(${legend2.unit})');
    final unitTextPainter2 = TextPainter(text: unitTextSpan2, textDirection: TextDirection.ltr);
    unitTextPainter2.layout(minWidth: 0, maxWidth: size.width);
    unitTextPainter2.paint(canvas, Offset(size.width - margin + 2.5, margin - fontSize / 2));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class MilkChartHorizontalScalePainter extends CustomPainter {
  final dateFormat = intl.DateFormat.Md();

  final Period period;

  MilkChartHorizontalScalePainter(this.period);

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  void _drawBackground(Canvas canvas, Size size) {
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
    final double margin = min(size.width * 0.1, size.height * 0.1);
    final double y0 = margin;
    final double y1 = size.height - margin;
    final double oneScaleWidth = (size.width - margin * 2) / (spanMilliseconds / (period.type.unitDays * 1000 * 60 * 60 * 24));
    final double fontSize = min(12.0, (oneScaleWidth * 0.8) / 5 * 2);
    final textStyle = TextStyle(fontSize: min(12, fontSize), color: Colors.black, );
    while (true) {
      if (tempDateTime.isAfter(toDateTime)) {
        break;
      }

      if (period.type.isScaleBoundDay(tempDateTime) || tempDateTime == toDateTime) {
        final double x0 = margin + (size.width - margin * 2) * ((scaleLeftDateTime.millisecondsSinceEpoch - fromDateTime.millisecondsSinceEpoch) / spanMilliseconds);
        final double x1 = margin + (size.width - margin * 2) * ((tempDateTime.millisecondsSinceEpoch - fromDateTime.millisecondsSinceEpoch) / spanMilliseconds);
        canvas.drawRect(Rect.fromLTRB(x0, y0, x1, y1), scalePaint);

        canvas.drawText(
          dateFormat.format(scaleLeftDateTime),
          textStyle,
          period.type == PeriodType.oneWeek ? TextAlign.center : TextAlign.start,
          Rect.fromLTRB(x0, size.height - margin, x1, size.height)
        );

        // 値の更新
        scaleLeftDateTime = tempDateTime;
        scalePaint = scalePaint == oddPaint ? evenPaint : oddPaint;
      }

      tempDateTime = tempDateTime.add(Duration(days: 1));
    }
  }
}

class MilkChartPainter extends CustomPainter {

  final MilkChartData data;

  MilkChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    _drawChart(canvas, size, data.period, data.data1, 0, 3200);
    _drawChart(canvas, size, data.period, data.data2, 0, 1000 * 60 * 60 * 8);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  void _drawChart(Canvas canvas, Size size, Period period, MilkChartSubData subData, int minY, int maxY) {
    final Map<DateTime, int> dateToValue = subData.dateToValue;
    if (dateToValue == null || dateToValue.length == 0) {
      return;
    }

    final double margin = min(size.width * 0.1, size.height * 0.1);

    final int spanMilliseconds = period.to.millisecondsSinceEpoch - period.from.millisecondsSinceEpoch;
    final double chartWidth = size.width - margin * 2;
    final double xOffset = chartWidth / period.type.days / 2;
    final double chartHeight = size.height - margin * 2;
    List<Point<double>> points = dateToValue.entries
      .map((entry) {
        final DateTime dateTime = entry.key;
        final int value = entry.value;
        final double x = margin + chartWidth * ((dateTime.millisecondsSinceEpoch - period.from.millisecondsSinceEpoch) / spanMilliseconds) + xOffset;
        final double y = margin + chartHeight * ((maxY - value) / (maxY - minY));
        return Point(x, y);
      })
      .toList();

    canvas.drawLines(points, subData.color, pointRadius: 2.5, strokeWidth: 1.5);
  }
}

class MilkChartSummaryTextPainter extends CustomPainter {
  final String unit;
  final String sumText;
  final String averageText;

  MilkChartSummaryTextPainter(this.unit, this.sumText, this.averageText);

  @override
  void paint(Canvas canvas, Size size) {
    final smallTextStyle = TextStyle(color: Colors.black, fontSize: 12);
    final mediumTextStyle = TextStyle(color: Colors.black, fontSize: 16);
    final largeTextStyle = TextStyle(color: Colors.black, fontSize: 20);
    final textSpan = TextSpan(
      style: mediumTextStyle,
      children: <TextSpan> [
        TextSpan(text: '${intl.Intl.message('Total', name: 'total')} ', style: smallTextStyle),
        TextSpan(text: '$sumText', style: largeTextStyle),
        TextSpan(text: ' $unit', style: smallTextStyle),
        TextSpan(text: ' (${intl.Intl.message('Average', name: 'average')} ', style: smallTextStyle),
        TextSpan(text: '$averageText', style: mediumTextStyle),
        TextSpan(text: ' $unit)', style: smallTextStyle),
      ],
    );
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout(minWidth: 0, maxWidth: size.width);
    textPainter.paint(canvas, Offset(0, -12));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class MilkChartData {
  final Period period;
  final MilkChartSubData data1;
  final MilkChartSubData data2;
  MilkChartData(this.period, this.data1, this.data2);
}

class MilkChartSubData {
  final String name;
  final Color color;
  final Map<DateTime, int> dateToValue;
  MilkChartSubData(this.name, this.color, this.dateToValue);
}

class MilkChartSummary {
  final int milkSum;
  final int milkAverage;
  final double mothersMilkSum;
  final double mothersMilkAverage;
  MilkChartSummary(this.milkSum, this.milkAverage, this.mothersMilkSum, this.mothersMilkAverage);
}