

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:intl/intl.dart';
import 'package:raisingchildrenrecord2/shared/utils.dart';
import 'package:raisingchildrenrecord2/viewmodel/setting/babyEditViewModel.dart';

class BabyEditView extends StatefulWidget {
  Baby baby;

  BabyEditView(this.baby);

  @override
  _BabyEditViewState createState() => _BabyEditViewState();
}

class _BabyEditViewState extends State<BabyEditView> {
  final _birthdayLabelFont = TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Color(0x0088000000));
  final _dateButtonFont = const TextStyle(color: Colors.blue, fontSize: 20.0);
  final _deleteButtonFont = const TextStyle(color: Colors.red, fontSize: 20.0);
  final _dateFormat = DateFormat().add_yMd().add_Hms();

  BabyEditViewModel _viewModel;
  TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _viewModel = Provider.of<BabyEditViewModel>(context, listen: false);

    StreamSubscription<String> subscription;
    subscription = _viewModel.name.listen((name) {
      print("### initState name: $name");
      _nameController.text = name;
      subscription.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    L10n _l10n = L10n.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Baby")
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(24, 36, 24, 36),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              StreamBuilder(
                stream: _viewModel.babyIconImageProvider,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.fitHeight,
                        image: snapshot.data,
                      ),
                    ),
                    height: 84,
                    width: 84,
                  );
                }
              ),
              Container(
                height: 36,
              ),
              TextField(
                controller: _nameController,
                onChanged: (text) => _viewModel.onNameChanged.add(text),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: _l10n.nameLabel,
                ),
              ),
              Container(
                height: 36,
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  _l10n.birthdayLabel,
                  style: _birthdayLabelFont,
                ),
              ),
              StreamBuilder(
                stream: _viewModel.birthday,
                builder: (context, snapshot) {
                  final dateTime = snapshot.data ?? DateTime.now();
                  print("### dateTime: $dateTime");
                  return Container(
                    padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                    alignment: Alignment.centerLeft,
                    child: FlatButton(
                      child: Text(
                        _dateFormat.format(dateTime),
                        style: _dateButtonFont,
                      ),
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      onPressed: () async {
                        final DateTime selectedDateTime = await Utils.onDateTimeButtonPressed(context, dateTime);
                        if (selectedDateTime == null) {
                          return;
                        }
                        _viewModel.onBirthdayChanged.add(selectedDateTime);
                      },
                    ),
                  );
                },
              ),
              Container(
                height: 24,
              ),
              (widget.baby == null) ? Container() : Container(
                alignment: Alignment.center,
                child: FlatButton(
                  child: Text(
                    _l10n.recordDeleteButtonLabel,
                    style: _deleteButtonFont,
                  ),
  //                onPressed: () => _viewModel.onDeleteButtonTapped.add(null),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}