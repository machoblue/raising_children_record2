
import 'package:flutter/material.dart';

Future<DateTime> onDateTimeButtonPressed(BuildContext context, DateTime currentDateTime) async {
  DateTime selectedDate = await showDatePicker(
    context: context,
    initialDate: currentDateTime,
    firstDate: DateTime(2018),
    lastDate: DateTime(2030),
    builder: (BuildContext context, Widget child) {
      return child;
    },
  );

  if (selectedDate == null) {
    return null;
  }

  TimeOfDay selectedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(currentDateTime),
    builder: (BuildContext context, Widget child) {
      return child;
    },
  );

  if (selectedTime == null) {
    return null;
  }

  DateTime selectedDateTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute);
  return selectedDateTime;
}


Future<void> showSimpleDialog(BuildContext context, {
  String title,
  String content,
  String leftButtonTitle,
  void Function() onLeftButtonPressed,
  String rightButtonTitle,
  void Function() onRightButtonPressed,
}) {

  return showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          FlatButton(
            child: Text(leftButtonTitle),
            onPressed: onLeftButtonPressed,
          ),
          FlatButton(
            child: Text(rightButtonTitle),
            onPressed: onRightButtonPressed,
          ),
        ],
      );
    }
  );
}

Future<void> showSingleButtonDialog(BuildContext context, {
  String title,
  String content,
  String buttonTitle,
  void Function() onButtonPressed,
}) {
  return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            FlatButton(
              child: Text(buttonTitle),
              onPressed: onButtonPressed,
            ),
          ],
        );
      }
  );
}