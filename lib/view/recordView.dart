
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:raisingchildrenrecord2/viewmodel/recordViewModel.dart';
import 'package:intl/intl.dart';

class RecordView extends StatefulWidget {
  Record record;
  User user;
  Baby baby;

  RecordView({ Key key, this.record, this.user, this.baby }): super(key: key);

  @override
  _RecordViewState createState() => _RecordViewState();
}

class _RecordViewState extends State<RecordView> {
  @override
  Widget build(BuildContext context) {
    return Provider<RecordViewModel>(
      create: (_) => RecordViewModel(widget.record, widget.user, widget.baby),
      child: _RecordScaffold(record: widget.record),
    );
  }
}

class _RecordScaffold extends StatefulWidget {
  Record record;

  _RecordScaffold({ Key key, this.record }): super(key: key);

  @override
  _RecordScaffoldState createState() => _RecordScaffoldState();
}

class _RecordScaffoldState extends State<_RecordScaffold> {

  RecordViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<RecordViewModel>(context, listen: false);
    _viewModel.onSaveComplete.listen((_) => _pop());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.record == null ? "新規追加" : "編集"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () => _viewModel.onSaveButtonTapped.add(null),
            ),
          ]
      ),
      body: _RecordForm(),
    );
  }

  void _pop() {
    Navigator.pop(context);
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
  RecordViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    _viewModel = Provider.of<RecordViewModel>(context, listen: false);
    _viewModel.note.listen((note) {
      _noteController.text = note;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 36, 24, 36),
      child: Column(
        children: <Widget>[
          StreamBuilder(
            stream: _viewModel.dateTime,
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
            onChanged: (text) => _viewModel.onNoteChanged.add(text),
            controller: _noteController,
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
    _viewModel.onDateTimeSelected.add(selectedDateTime);
  }
}