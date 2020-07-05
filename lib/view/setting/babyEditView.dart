

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:intl/intl.dart';
import 'package:raisingchildrenrecord2/view/shared/utils.dart';
import 'package:raisingchildrenrecord2/view/baseState.dart';
import 'package:raisingchildrenrecord2/view/shared/widget/circleImage.dart';
import 'package:raisingchildrenrecord2/viewmodel/setting/babyEditViewModel.dart';

class BabyEditView extends StatefulWidget {
  Baby baby;

  BabyEditView(this.baby);

  @override
  _BabyEditViewState createState() => _BabyEditViewState();
}

class _BabyEditViewState extends BaseState<BabyEditView, BabyEditViewModel> {
  final _radioLabelFont = TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black);
  final _birthdayLabelFont = TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Color(0x0088000000));
  final _dateButtonFont = const TextStyle(color: Colors.blue, fontSize: 20.0);
  final _deleteButtonFont = const TextStyle(color: Colors.red, fontSize: 20.0);
  final _dateFormat = DateFormat().add_yMd().add_Hms();

  TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();

    StreamSubscription<String> subscription;
    subscription = viewModel.name.listen((name) {
      print("### initState name: $name");
      _nameController.text = name;
      subscription.cancel();
    });

    viewModel.onSaveComplete.listen((_) => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    L10n _l10n = L10n.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.baby == null
            ? _l10n.addBabyTitle
            : _l10n.editBabyTitle
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () => viewModel.onSaveButtonTapped.add(null),
          ),
        ]
      ),
      body: Stack(
        children: <Widget>[
          _body(),
          _indicator(),
        ],
      ),
    );
  }

  Widget _body() {
    L10n _l10n = L10n.of(context);
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.fromLTRB(24, 36, 24, 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            StreamBuilder(
              stream: viewModel.babyIconImageProvider,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }
                return GestureDetector(
                  onTap: _pickImage,
                  child: CircleImage(
                    snapshot.data,
                    width: 84,
                    height: 84,
                  ),
                );
              }
            ),
            Container(
              height: 36,
            ),
            TextField(
              controller: _nameController,
              onChanged: (text) => viewModel.onNameChanged.add(text),
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
              stream: viewModel.sex,
              builder: (context, snapshot) {
                final Sex currentSex = snapshot.data;
                return Row(
                    children: Sex.values.map((sex) {
                      return Container(
                        child: Row(
                          children: <Widget>[
                            Radio(
                              value: sex.string,
                              groupValue: currentSex.string,
                              onChanged: (sexString) => viewModel.onSexChanged.add(sexString),
                            ),
                            GestureDetector(
                              onTap: () => viewModel.onSexChanged.add(sex.string),
                              child: Text(
                                sex.localizedName,
                                style: _radioLabelFont,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList()
                );
              },
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
              stream: viewModel.birthday,
              builder: (context, snapshot) {
                final dateTime = snapshot.data ?? DateTime.now();
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
                      final DateTime selectedDateTime = await onDateTimeButtonPressed(context, dateTime);
                      if (selectedDateTime == null) {
                        return;
                      }
                      viewModel.onBirthdayChanged.add(selectedDateTime);
                    },
                  ),
                );
              },
            ),
            Container(
              height: 24,
            ),
            (widget.baby == null)
              ? Container()
              : Container(
                alignment: Alignment.center,
                child: FlatButton(
                  child: Text(
                    _l10n.recordDeleteButtonLabel,
                    style: _deleteButtonFont,
                  ),
                  onPressed: () => viewModel.onDeleteButtonTapped.add(null),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _indicator() {
    return StreamBuilder(
      stream: viewModel.isLoading,
      builder: (context, snapshot) {
        final bool isLoading = snapshot.data ?? false;
        return isLoading
          ? Center(
            child: CircularProgressIndicator()
          )
          : Container();
      }
    );
  }

  void _pickImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    viewModel.onImageSelected.add(image);
  }
}