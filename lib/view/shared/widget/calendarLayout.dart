

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class CalendarLayout extends StatelessWidget {
  final _titleFormat = DateFormat.yM();
  final _weekdayFormat = DateFormat.E();

  final _titleStyle = TextStyle(fontSize: 24);
  final _headerStyle = TextStyle(fontSize: 12, color: Colors.grey);
  final _dateStyle = TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.normal);
  final _dateStyleOtherMonth = TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.normal);

  final _cellBorder = BorderSide(color: Colors.grey, width: 0.25);

  final DateTime dateTime;
  final Widget Function() middleWidgetBuilder;
  final Widget Function(DateTime dateTime) dateCellBuilder;
  final void Function() onPrevPressed;
  final void Function() onNextPressed;
  final StartWeekday startWeekday;

  DateTime _firstDateOfCalendar;

  CalendarLayout(this.dateTime, { this.middleWidgetBuilder, this.dateCellBuilder, this.onPrevPressed, this.onNextPressed, this.startWeekday = StartWeekday.monday }) {
    final DateTime firstDateOfThisMonth = DateTime(dateTime.year, dateTime.month);
    final int offset = - (firstDateOfThisMonth.weekday % 7) + (startWeekday == StartWeekday.sunday ? 0 : 1);
    _firstDateOfCalendar = firstDateOfThisMonth.add(Duration(days: offset));
    print("### _firstDateOfCalendar: $_firstDateOfCalendar, ${_firstDateOfCalendar.weekday}");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildTitle(),
          _buildMiddle(),
          _buildCalendarHeader(),
          Expanded(
            child: _buildCalendarContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () => onPrevPressed(),
        ),
        Expanded(
          child: Container(),
        ),
        Text(
          _titleFormat.format(dateTime),
          style: _titleStyle,
        ),
        Expanded(
          child: Container(),
        ),
        IconButton(
          icon: Icon(Icons.chevron_right),
          onPressed: () => onNextPressed(),
        ),
      ],
    );
  }

  Widget _buildMiddle() {
    return middleWidgetBuilder == null ? Container() : middleWidgetBuilder();
  }

  Widget _buildCalendarHeader() {
    final double height = 36;
    return Container(
      height: height,
      child: Row(
        children: List.generate(7, (i) {
          final dateTime = _firstDateOfCalendar.add(Duration(days: i));
          final weekdayText = _weekdayFormat.format(dateTime);
          return Expanded(
            child: Text(
              weekdayText,
              style: _headerStyle,
              textAlign: TextAlign.center,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCalendarContent() {
    return Column(
      children: List<int>.generate(6, (i) => i).map((rowIndex) {
        return Expanded(
            flex: 1,
            child: Row(
              children: List<int>.generate(7, (i) => i).map((columnIndex) {
                return Expanded(
                  flex: 1,
                  child: _buildCalendarCell(rowIndex, columnIndex),
                );
              }).toList(),
            )
        );
      }).toList(),
    );
  }

  Widget _buildCalendarCell(int rowIndex, int columnIndex) {
    final DateTime cellDate = _firstDateOfCalendar.add(Duration(days: rowIndex * 7 + columnIndex));
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
              '${cellDate.day}',
              style: cellDate.month == dateTime.month ? _dateStyle : _dateStyleOtherMonth,
            ),
            dateCellBuilder(cellDate),
          ]
      ),
    );
  }
}

enum StartWeekday {
  sunday,
  monday,
}