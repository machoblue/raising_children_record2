
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:raisingchildrenrecord2/viewmodel/record/milkRecordViewModel.dart';
import 'package:intl/intl.dart';

class MilkRecordView extends StatefulWidget {
  Record record;
  User user;
  Baby baby;
  bool isNew;

  MilkRecordView({ Key key, this.record, this.user, this.baby, this.isNew }): super(key: key);

  @override
  _MilkRecordViewState createState() => _MilkRecordViewState();
}

class _MilkRecordViewState extends State<MilkRecordView> {
  @override
  Widget build(BuildContext context) {
    return Provider<MilkRecordViewModel>(
      create: (_) => MilkRecordViewModel(widget.record, widget.user, widget.baby),
      child: _MilkRecordScaffold(record: widget.record, isNew: widget.isNew),
    );
  }
}

class _MilkRecordScaffold extends StatefulWidget {
  Record record;
  bool isNew;

  _MilkRecordScaffold({ Key key, this.record, this.isNew }): super(key: key);

  @override
  _MilkRecordScaffoldState createState() => _MilkRecordScaffoldState();
}

class _MilkRecordScaffoldState extends State<_MilkRecordScaffold> {

  MilkRecordViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<MilkRecordViewModel>(context, listen: false);
    _viewModel.onSaveComplete.listen((_) => _pop());
  }

  @override
  Widget build(BuildContext context) {
    L10n l10n = L10n.of(context);
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.isNew ?? false ? l10n.recordTitleNew : l10n.recordTitleEdit),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () => _viewModel.onSaveButtonTapped.add(null),
            ),
          ]
      ),
      body: _MilkRecordForm(isNew: widget.isNew),
    );
  }

  void _pop() {
    Navigator.pop(context);
  }
}

class _MilkRecordForm extends StatefulWidget {
  bool isNew;

  _MilkRecordForm({ Key key, this.isNew }): super(key: key);
  @override
  _MilkRecordFormState createState() => _MilkRecordFormState();
}

class _MilkRecordFormState extends State<_MilkRecordForm> {
  final _recordTypeFont = const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold);
  final _dateButtonFont = const TextStyle(color: Colors.blue, fontSize: 20.0);
  final _deleteButtonFont = const TextStyle(color: Colors.red, fontSize: 20.0);
  final _listItemFont = const TextStyle(fontSize: 20.0);
  final _dateFormat = DateFormat().add_yMd().add_Hms();

  TextEditingController _noteController;
  MilkRecordViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    _viewModel = Provider.of<MilkRecordViewModel>(context, listen: false);
    StreamSubscription subscription;
    subscription = _viewModel.note.listen((note) {
      _noteController.text = note;
      subscription.cancel(); // listen only first time
    });
  }

  @override
  void dispose() {
    super.dispose();
    _viewModel.dispose();
    _noteController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    L10n l10n = L10n.of(context);
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
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  onPressed: () => _onDateTimeButtonPressed(dateTime),
                ),
              );
            },
          ),
          Container(
            height: 14,
          ),
          Row(
            children: <Widget>[
              StreamBuilder(
                stream: _viewModel.amount,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }
                  return DropdownButton<int>(
                    value: snapshot.data ?? 0,
                    items: List<int>.generate(36, (i) => i * 10).map((value) {
                      return DropdownMenuItem<int>(
                          value: value,
                          child: Container(
                              padding: EdgeInsets.fromLTRB(20, 0, 12, 0),
                              child: Text(
                                "$value",
                                style: _listItemFont,
                              )
                          )
                      );
                    }).toList(),
                    icon: Icon(Icons.expand_more),
                    iconSize: 24,
                    elevation: 16,
                    underline: Container(
                      height: 2,
                      color: Colors.black54,
                    ),
                    onChanged: (int newValue) => _viewModel.onAmountSelected.add(newValue),
                  );
                }
              ),

              Container(width: 10),
              Text(
                "ml",
                style: TextStyle(
                  fontSize: 20,
                )
              ),
            ],
          ),
          Container(
            height: 24,
          ),
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: l10n.recordLabelNote,
            ),
            onChanged: (text) => _viewModel.onNoteChanged.add(text),
            controller: _noteController,
          ),
          Container(
            height: 24,
          ),
          !(widget.isNew ?? false) ? FlatButton(
            child: Text(
              l10n.recordDeleteButtonLabel,
              style: _deleteButtonFont,
            ),
            onPressed: () => _viewModel.onDeleteButtonTapped.add(null),
          ) : Container()
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