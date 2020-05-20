

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:raisingchildrenrecord2/view/baseState.dart';
import 'package:raisingchildrenrecord2/view/widget/circleImage.dart';
import 'package:raisingchildrenrecord2/viewmodel/setting/userEditViewModel.dart';

class UserEditView extends StatefulWidget {
  User user;

  UserEditView(this.user);

  @override
  _UserEditViewState createState() => _UserEditViewState();
}

class _UserEditViewState extends BaseState<UserEditView, UserEditViewModel> {

  UserEditViewModel _viewModel;
  TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _viewModel = Provider.of<UserEditViewModel>(context, listen: false);

    StreamSubscription<String> subscription;
    subscription = _viewModel.name.listen((name) {
      _nameController.text = name;
      subscription.cancel();
    });

    _viewModel.onSaveComplete.listen((_) => Navigator.pop(context));
  }

  @override
  void dispose() {
    super.dispose();
    _viewModel.dispose();
  }

  @override
  Widget build(BuildContext context) {
    L10n _l10n = L10n.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_l10n.editUserTitle),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () => _viewModel.onSaveButtonTapped.add(null),
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
              stream: _viewModel.userIconImageProvider,
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
              onChanged: (text) => _viewModel.onNameChanged.add(text),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: _l10n.nameLabel,
              ),
            ),
            Container(
              height: 36,
            ),
          ],
        ),
      ),
    );
  }

  Widget _indicator() {
    return StreamBuilder(
      stream: _viewModel.isLoading,
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
    _viewModel.onImageSelected.add(image);
  }
}