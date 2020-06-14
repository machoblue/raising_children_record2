
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/view/baseState.dart';
import 'package:raisingchildrenrecord2/view/widget/circleImage.dart';
import 'package:raisingchildrenrecord2/viewmodel/chart/excretionChartViewModel.dart';
import 'package:intl/intl.dart';

class ExcretionChartView extends StatefulWidget {
  @override
  _ExcretionChartViewState createState() => _ExcretionChartViewState();
}

class _ExcretionChartViewState extends BaseState<ExcretionChartView, ExcretionChartViewModel> {
  final _calendarTitleFormat = DateFormat.yM();

  final _calendarTitleStyle = TextStyle(fontSize: 24);
  final _summaryLabelStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black);
  final _summaryValueLargeStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black);
  final _summaryValueSmallStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.black);
  final _calendarHeaderStyle = TextStyle(fontSize: 12, color: Colors.grey);
  final _legendBaseStyle = TextStyle(fontSize: 12, color: Colors.black);
  final _legendPoopStyle = TextStyle(fontSize: 12, color: Colors.brown);
  final _legendPeeStyle = TextStyle(fontSize: 12, color: Colors.lightBlue);
  final _dayStyle = TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.normal);
  final _dayOfOtherMonthStyle = TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.normal);
  final _dayContentBaseStyle = TextStyle(fontSize: 12, color: Colors.black);
  final _dayContentPoopStyle = TextStyle(fontSize: 12, color: Colors.brown);
  final _dayContentDiarrheaStyle = TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold);
  final _dayContentPeeStyle = TextStyle(fontSize: 12, color: Colors.lightBlue);

  final _summaryValueFormat = NumberFormat('##0.0');

  final _cellBorder = BorderSide(color: Colors.grey, width: 0.25);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 12, 12, 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          StreamBuilder(
            stream: viewModel.month,
            builder: (context, snapshot) {
              return snapshot.hasData
                ? Text(
                  _calendarTitleFormat.format(snapshot.data),
                  style: _calendarTitleStyle,
                )
                : Container();
            }
          ),
          Container(height: 12),
          StreamBuilder(
            stream: viewModel.summary,
            builder: (context, snapshot) {
              return _buildExcretionSummary(
                snapshot.data?.poopAverage,
                snapshot.data?.peeAverage
              );
            },
          ),
          Container(height: 8),
          _buildCalendarHeader(),
          Expanded(
            child: _buildCalendarContent(),
          ),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildExcretionSummary(double poopAverage, double peeAverage) {
    return Column(
      children: <Widget>[
        _buildExcretionSummaryRow(RecordType.poop, poopAverage),
        Container(height: 8),
        _buildExcretionSummaryRow(RecordType.pee, peeAverage),
      ],
    );
  }

  Widget _buildExcretionSummaryRow(RecordType recordType, double value) {
    L10n l10n = L10n.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(width: 8),
        CircleImage(
          AssetImage(recordType.assetName),
          width: 24,
          height: 24,
        ),
        Container(height: 24, width: 4),
        Text(
          '${recordType.localizedName}: ',
          style: _summaryLabelStyle,
        ),
        Container(height: 24, width: 8),
        RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(text: '${l10n.average} ', style: _summaryValueSmallStyle,),
              TextSpan(text: '${value == null ? '' : _summaryValueFormat.format(value)}', style: _summaryValueLargeStyle,),
              TextSpan(text: ' ${l10n.times}', style: _summaryValueSmallStyle,),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarHeader() {
    return StreamBuilder(
      stream: viewModel.calendarHeader,
      builder: (context, snapshot) {
        final double headerHeight = 36;
        return snapshot.hasData
          ? Container(
            height: headerHeight,
            child: Row(
              children: (snapshot.data as List<String>).map((dayText) {
                return Expanded(
                  flex: 1,
                  child: Text(
                    dayText,
                    style: _calendarHeaderStyle,
                    textAlign: TextAlign.center,
                  ),
                );
              }).toList(),
            ),
          )
          : Container(height: headerHeight);
      },
    );
  }

  Widget _buildCalendarContent() {
    return StreamBuilder(
      stream: viewModel.data,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        final ExcretionChartData data = snapshot.data;

        return Column(
          children: List<int>.generate(6, (i) => i).map((rowIndex) {
            return Expanded(
              flex: 1,
              child: Row(
                children: List<int>.generate(7, (i) => i).map((columnIndex) {
                  return Expanded(
                    flex: 1,
                    child: _buildCalendarCell(data, rowIndex, columnIndex),
                  );
                }).toList(),
              )
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCalendarCell(ExcretionChartData data, int rowIndex, int columnIndex) {
    final ExcretionDailyData dailyData = data.dailyDataList[rowIndex * 7 + columnIndex];
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: rowIndex == 5 ? BorderSide.none : _cellBorder,
          right: (columnIndex % 7) == 6 ? BorderSide.none : _cellBorder,
        ),
      ),
      child: Column(
        children: <Widget>[
          Text(
            '${dailyData.dateTime.day}',
            style: dailyData.isMainMonth ? _dayStyle : _dayOfOtherMonthStyle,
          ),
          Container(
            padding: EdgeInsets.fromLTRB(4, 0, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                dailyData.poopCount == 0
                  ? Container()
                  : RichText(
                    text: TextSpan(
                      style: _dayContentBaseStyle,
                      children: <TextSpan>[
                        TextSpan(text: '● ', style: _dayContentPoopStyle,),
                        TextSpan(text: '${dailyData.poopCount}',),
                        TextSpan(text: ' ('),
                        TextSpan(text: '${dailyData.diarrheaCount}', style: dailyData.diarrheaCount > 0 ? _dayContentDiarrheaStyle : _dayContentBaseStyle,),
                        TextSpan(text: ')'),
                      ],
                    ),
                  ),
                dailyData.peeCount == 0
                  ? Container()
                  : RichText(
                    text: TextSpan(
                      style: _dayContentBaseStyle,
                      children: <TextSpan>[
                        TextSpan(text: '● ', style: _dayContentPeeStyle,),
                        TextSpan(text: '${dailyData.peeCount}',),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ]

      ),
    );
  }

  Widget _buildLegend() {
    L10n l10n = L10n.of(context);
    return RichText(
      text: TextSpan(
        style: _legendBaseStyle,
        children: <TextSpan>[
          TextSpan(text: '●', style: _legendPoopStyle),
          TextSpan(text: '${l10n.poopLegend}, '),
          TextSpan(text: '●', style: _legendPeeStyle),
          TextSpan(text: '${l10n.peeLegend}'),
        ],
      ),
    );
  }
}