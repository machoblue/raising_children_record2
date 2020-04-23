
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/viewmodel/recordViewModel.dart';
import 'package:intl/intl.dart';

class RecordView extends StatefulWidget {
  String recordType;
  Record record;

  RecordView({ Key key, this.recordType, this.record }): super(key: key);

  @override
  _RecordViewState createState() => _RecordViewState();
}

class _RecordViewState extends State<RecordView> {
  @override
  Widget build(BuildContext context) {
    return Provider<RecordViewModel>(
      create: (_) => RecordViewModel(),
      child: _RecordScaffold(recordType: widget.recordType, record: widget.record),
    );
  }
}

class _RecordScaffold extends StatefulWidget {
  String recordType;
  Record record;

  _RecordScaffold({ Key key, this.recordType, this.record }): super(key: key);

  @override
  _RecordScaffoldState createState() => _RecordScaffoldState();
}

class _RecordScaffoldState extends State<_RecordScaffold> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.record == null ? "新規追加" : "編集"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () => Provider.of<RecordViewModel>(context).onSaveButtonTapped.add(null),
            ),
          ]
      ),
      body: _RecordForm(),
    );
  }
}

class _RecordForm extends StatefulWidget {
  @override
  _RecordFormState createState() => _RecordFormState();
}

class _RecordFormState extends State<_RecordForm> {
  final _biggerFont = const TextStyle(color: Colors.blue, fontSize: 20.0);
  final _dateFormat = DateFormat().add_yMd().add_Hms();
  TextEditingController _noteController;

  RecordViewModel _recordViewModel;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    _recordViewModel = Provider.of<RecordViewModel>(context, listen: false);
    print("### recordviewmodel $_recordViewModel");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 36, 24, 36),
      child: Column(
        children: <Widget>[
          StreamBuilder(
            stream: _recordViewModel.dateTime,
            builder: (context, snapshot) {
              final dateTime = snapshot.data ?? DateTime.now();
              return FlatButton(
                child: Text(
                  _dateFormat.format(dateTime),
                  style: _biggerFont,
                ),
                onPressed: () => _onDateTimeButtonPressed(dateTime),
              );
            },
          ),
          Container(
            height: 24,
          ),
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'メモ',
            ),
            onSubmitted: (value) {
              print("### $value");
            },
          )
        ],
      ),
    );
  }

  void _onDateTimeButtonPressed(DateTime currentDateTime) async {
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
      return;
    }

    TimeOfDay selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentDateTime),
      builder: (BuildContext context, Widget child) {
        return child;
      },
    );

    if (selectedTime == null) {
      return;
    }

    DateTime selectedDateTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, selectedTime.hour, selectedTime.minute);
    _recordViewModel.onDateTimeSelected.add(selectedDateTime);
  }
}