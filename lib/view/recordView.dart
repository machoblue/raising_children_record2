
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:raisingchildrenrecord2/viewmodel/recordViewModel.dart';
import 'package:intl/intl.dart';

class RecordView extends StatefulWidget {
  Record record;
  User user;
  Baby baby;
  bool isNew;

  RecordView({ Key key, this.record, this.user, this.baby, this.isNew }): super(key: key);

  @override
  _RecordViewState createState() => _RecordViewState();
}

class _RecordViewState extends State<RecordView> {
  @override
  Widget build(BuildContext context) {
    return Provider<RecordViewModel>(
      create: (_) => RecordViewModel(widget.record, widget.user, widget.baby, L10n.of(context)),
      child: _RecordScaffold(record: widget.record, isNew: widget.isNew),
    );
  }
}

class _RecordScaffold extends StatefulWidget {
  Record record;
  bool isNew;

  _RecordScaffold({ Key key, this.record, this.isNew }): super(key: key);

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
          title: Text(widget.isNew ?? false ? "新規追加" : "編集"),
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
  final _recordTypeFont = const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold);
  final _dateButtonFont = const TextStyle(color: Colors.blue, fontSize: 20.0);
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
          Row(
            children: <Widget>[
              StreamBuilder(
                stream: _viewModel.assetName,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.fitHeight,
                        image: AssetImage(snapshot.data),
                      ),
                    ),
                    height: 48,
                    width: 48,
                  );
                }
              ),
              Expanded(
                child: StreamBuilder(
                  stream: _viewModel.title,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container();
                    }
                    return Container(
                      padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                      child: Text(
                        snapshot.data,
                        style: _recordTypeFont,
                      ),
                    );
                  },
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.start,
          ),
          Container(
            height: 36,
          ),
          StreamBuilder(
            stream: _viewModel.dateTime,
            builder: (context, snapshot) {
              final dateTime = snapshot.data ?? DateTime.now();
              return Container(
                alignment: Alignment.centerLeft,
                child: FlatButton(
                  child: Text(
                    _dateFormat.format(dateTime),
                    style: _dateButtonFont,
                  ),
                  onPressed: () => _onDateTimeButtonPressed(dateTime),
                )
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