
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:raisingchildrenrecord2/viewmodel/record/plainRecordViewModel.dart';
import 'package:intl/intl.dart';

class PlainRecordView extends StatefulWidget {
  Record record;
  User user;
  Baby baby;
  bool isNew;

  PlainRecordView({ Key key, this.record, this.user, this.baby, this.isNew }): super(key: key);

  @override
  _PlainRecordViewState createState() => _PlainRecordViewState();
}

class _PlainRecordViewState extends State<PlainRecordView> {
  @override
  Widget build(BuildContext context) {
    return Provider<PlainRecordViewModel>(
      create: (_) => PlainRecordViewModel(widget.record, widget.user, widget.baby),
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

  PlainRecordViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<PlainRecordViewModel>(context, listen: false);
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
      body: _RecordForm(isNew: widget.isNew),
    );
  }

  void _pop() {
    Navigator.pop(context);
  }
}

class _RecordForm extends StatefulWidget {
  bool isNew;

  _RecordForm({ Key key, this.isNew }): super(key: key);
  @override
  _RecordFormState createState() => _RecordFormState();
}

class _RecordFormState extends State<_RecordForm> {
  final _recordTypeFont = const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold);
  final _dateButtonFont = const TextStyle(color: Colors.blue, fontSize: 20.0);
  final _deleteButtonFont = const TextStyle(color: Colors.red, fontSize: 20.0);
  final _listItemFont = const TextStyle(fontSize: 20.0);
  final _dateFormat = DateFormat().add_yMd().add_Hms();

  TextEditingController _noteController;
  PlainRecordViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    _viewModel = Provider.of<PlainRecordViewModel>(context, listen: false);
    _viewModel.note.listen((note) {
      _noteController.text = note;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _viewModel.dispose();
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