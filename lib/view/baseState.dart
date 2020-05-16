
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/viewmodel/baseViewModel.dart';

class BaseState<W extends StatefulWidget, VM extends ViewModel> extends State<W> {

  VM viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<VM>(context, listen: false);
    viewModel.errorMessage.listen((ErrorMessage errorMessage) {
      _showErrorMessage(errorMessage);
    });
  }

  @override
  void dispose() {
    super.dispose();
    viewModel.dispose();
  }

  @override
  Widget build(BuildContext context) {
    throw 'This method must be implemented.';
  }

  void _showErrorMessage(ErrorMessage errorMessage) {
    showDialog(
      context: context,
      builder: (context) {
        L10n l10n = L10n.of(context);
        return AlertDialog(
          title: Text(errorMessage.title),
          content: Text(errorMessage.message),
          actions: <Widget>[
            FlatButton(
              child: Text(l10n.ok),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      }
    );
  }
}