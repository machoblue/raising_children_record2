
import 'dart:math';
import 'package:intl/intl.dart' as intl;
import 'package:flutter/material.dart';
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
              labels: MilkChartPeriod.values.map((item) => item.getLabel(l10n)).toList(),
              onSelect: viewModel.onSelected.add,
            );
          },
        ),
        Expanded(
          child: Container(
            child: Stack(
              children: <Widget>[
                CustomPaint(
                  painter: MilkChartFramePainter(),
                  child: Container(),
                ),
                Container(

                child: StreamBuilder(
                  stream: viewModel.data,
                  builder: (context, snapshot) {
                    print("### streamBuilder START");
                    if (!snapshot.hasData) {
                      return Container();
                    }
                    print("### streamBuilder from: ${snapshot.data.fromDateTime}");
                    print("### streamBuilder to  : ${snapshot.data.toDateTime}");
                    return CustomPaint(
                      painter: MilkChartPainter(snapshot.data),
                      child: Container(),
                    );
                  }
                ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

enum MilkChartPeriod {
  oneWeek, threeWeeks, threeMonths,
}

extension MilkChartPeriodExtension on MilkChartPeriod {
  String getLabel(L10n l10n) {
    switch (this) {
      case MilkChartPeriod.oneWeek: return l10n.oneWeek;
      case MilkChartPeriod.threeWeeks: return l10n.threeWeeks;
      case MilkChartPeriod.threeMonths: return l10n.threeMonths;
      default: throw 'This line shouldn\'t be reached';
    }
  }

  int get days {
    switch (this) {
      case MilkChartPeriod.oneWeek: return 7;
      case MilkChartPeriod.threeWeeks: return 21;
      case MilkChartPeriod.threeMonths: return 90;
      default: throw 'This line shouldn\'t be reached';
    }
  }

  bool isScaleBoundDay(DateTime dateTime) {
    switch (this) {
      case MilkChartPeriod.oneWeek: return dateTime.hour == 0 && dateTime.minute == 0;
      case MilkChartPeriod.threeWeeks: return dateTime.weekday == DateTime.monday;
      case MilkChartPeriod.threeMonths: return dateTime.weekday == DateTime.monday;
      default: throw 'This line shouldn\'t be reached';
    }
  }

  static MilkChartPeriod fromIndex(int index) {
    switch (index) {
      case 0: return MilkChartPeriod.oneWeek;
      case 1: return MilkChartPeriod.threeWeeks;
      case 2: return MilkChartPeriod.threeMonths;
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

class MilkChartPainter extends CustomPainter {
  final dateFormat = intl.DateFormat.Md();

  final MilkChartData data;

  MilkChartPainter(this.data);

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

    final fromDateTime = data.fromDateTime;
    final toDateTime = data.toDateTime;
    final spanMilliseconds = data.toDateTime.millisecondsSinceEpoch - fromDateTime.millisecondsSinceEpoch;
    DateTime scaleLeftDateTime = fromDateTime;
    DateTime tempDateTime = fromDateTime.add(Duration(days: 1));
    Paint scalePaint = oddPaint;
    final double margin = min(size.width * 0.1, size.height * 0.1);
    final double y0 = margin;
    final double y1 = size.height - margin;
    while (true) {
      if (tempDateTime.isAfter(toDateTime)) {
        break;
      }

      if (data.period.isScaleBoundDay(tempDateTime) || tempDateTime == toDateTime) {
        final double x0 = margin + (size.width - margin * 2) * ((scaleLeftDateTime.millisecondsSinceEpoch - fromDateTime.millisecondsSinceEpoch) / spanMilliseconds);
        final double x1 = margin + (size.width - margin * 2) * ((tempDateTime.millisecondsSinceEpoch - fromDateTime.millisecondsSinceEpoch) / spanMilliseconds);
        canvas.drawRect(Rect.fromLTRB(x0, y0, x1, y1), scalePaint);

        // 値の更新
        scaleLeftDateTime = tempDateTime;
        scalePaint = scalePaint == oddPaint ? evenPaint : oddPaint;
      }

      tempDateTime = tempDateTime.add(Duration(days: 1));
    }
  }

  DateTime _getStartDateTime() {
    switch (data.period) {
      case MilkChartPeriod.oneWeek:
        return DateTime.fromMillisecondsSinceEpoch(data.fromDateTime.millisecondsSinceEpoch + 1000 * 60 * 60 * 24);
      case MilkChartPeriod.threeWeeks:
      case MilkChartPeriod.threeMonths:
        DateTime tempDateTime = data.fromDateTime;
        while(true) {
          tempDateTime = DateTime.fromMillisecondsSinceEpoch(tempDateTime.millisecondsSinceEpoch + 1000 * 60 * 60 * 24);
          if (tempDateTime.weekday != DateTime.monday) {
            continue;
          }
          return tempDateTime;
        }
    }
  }
}

class MilkChartData {
  final MilkChartPeriod period;
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