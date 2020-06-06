
import 'dart:math';
import 'package:intl/intl.dart' as intl;
import 'package:flutter/material.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/view/baseState.dart';
import 'package:raisingchildrenrecord2/view/widget/simpleSegmentedControl.dart';
import 'package:raisingchildrenrecord2/viewmodel/chart/milkChartViewModel.dart';
import 'package:raisingchildrenrecord2/view/chart/canvasExtension.dart';

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
              labels: PeriodType.values.map((item) => item.getLabel(l10n)).toList(),
              onSelect: viewModel.onSelected.add,
            );
          },
        ),
        Expanded(
          child: Container(
            child: Stack(
              children: <Widget>[
                Container(
                  child: StreamBuilder(
                    stream: viewModel.period,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Container();
                      }
                      return CustomPaint(
                        painter: MilkChartHorizontalScalePainter(snapshot.data),
                        child: Container(),
                      );
                    }
                  ),
                ),
                CustomPaint(
                  painter: MilkChartFramePainter(),
                  child: Container(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

enum PeriodType {
  oneWeek, threeWeeks, threeMonths,
}

extension PeriodTypeExtension on PeriodType {
  String getLabel(L10n l10n) {
    switch (this) {
      case PeriodType.oneWeek: return l10n.oneWeek;
      case PeriodType.threeWeeks: return l10n.threeWeeks;
      case PeriodType.threeMonths: return l10n.threeMonths;
      default: throw 'This line shouldn\'t be reached';
    }
  }

  int get days {
    switch (this) {
      case PeriodType.oneWeek: return 7;
      case PeriodType.threeWeeks: return 21;
      case PeriodType.threeMonths: return 90;
      default: throw 'This line shouldn\'t be reached';
    }
  }

  int get unitDays {
    switch (this) {
      case PeriodType.oneWeek: return 1;
      case PeriodType.threeWeeks: return 7;
      case PeriodType.threeMonths: return 7;
      default: throw 'This line shouldn\'t be reached';
    }
  }

  bool isScaleBoundDay(DateTime dateTime) {
    switch (this) {
      case PeriodType.oneWeek: return dateTime.hour == 0 && dateTime.minute == 0;
      case PeriodType.threeWeeks: return dateTime.weekday == DateTime.monday;
      case PeriodType.threeMonths: return dateTime.weekday == DateTime.monday;
      default: throw 'This line shouldn\'t be reached';
    }
  }

  static PeriodType fromIndex(int index) {
    switch (index) {
      case 0: return PeriodType.oneWeek;
      case 1: return PeriodType.threeWeeks;
      case 2: return PeriodType.threeMonths;
      default: throw 'This line shouldn\'t be reached';
    }
  }
}

class MilkChartFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double margin = min(size.width * 0.1, size.height * 0.1);

    final double fontSize = 12;
    final baseTextStyle = TextStyle(color: Colors.black, fontSize: fontSize);
    final textSpan = TextSpan(
      style: baseTextStyle,
      children: <TextSpan>[
        TextSpan(text: '●' ,style: TextStyle(color: Colors.yellow, fontSize: fontSize)),
        TextSpan(text: 'ミルク(ml) '),
        TextSpan(text: '●' ,style: TextStyle(color: Colors.pink, fontSize: fontSize)),
        TextSpan(text: '母乳(時間)'),
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

    final unitTextSpan = TextSpan(style: baseTextStyle, text: '(ml)');
    final unitTextPainter = TextPainter(text: unitTextSpan, textDirection: TextDirection.ltr, textAlign: TextAlign.right);
    unitTextPainter.layout(minWidth: margin - 2.5, maxWidth: size.width);
    unitTextPainter.paint(canvas, Offset(0, margin - fontSize / 2));

    for (int i = 0; i < 16; i++) {
      final textSpan = TextSpan(style: baseTextStyle, text: (0.5 * i).toString());
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      textPainter.layout(minWidth: 0, maxWidth: size.width);
      textPainter.paint(canvas, Offset(size.width - margin + 2.5, size.height - margin - fontSize / 2 - unitHeight * 2 * i));
    }

    final unitTextSpan2 = TextSpan(style: baseTextStyle, text: '(時間)');
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

class MilkChartData {
  final PeriodType period;
  final DateTime fromDateTime;
  final DateTime toDateTime;
  final MilkChartSubData data1;
  final MilkChartSubData data2;
  MilkChartData(this.period, this.fromDateTime, this.toDateTime, this.data1, this.data2);
}

class MilkChartSubData {
  final String name;
  final Color color;
  final Map<DateTime, int> dateToValue;
  MilkChartSubData(this.name, this.color, this.dateToValue);
}

class Period {
  final DateTime from;
  final DateTime to;
  final PeriodType type;
  Period(this.from, this.to, this.type);
}