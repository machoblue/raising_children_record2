
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/data/babyRepository.dart';
import 'package:raisingchildrenrecord2/data/userRepository.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/view/baseState.dart';
import 'package:raisingchildrenrecord2/view/loginView.dart';
import 'package:raisingchildrenrecord2/viewmodel/loginViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/registerViewModel.dart';

class RegisterView extends StatefulWidget {
  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends BaseState<RegisterView, RegisterViewModel>{
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            RaisedButton(
              onPressed: () => viewModel.onGoogleButtonTapped.add(null),
              child: Text(
                L10n.of(context).loginButtonLabel,
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            RaisedButton(
              onPressed: () => viewModel.onGuestButtonTapped.add(null),
              child: Text(
                L10n.of(context).loginButtonLabel,
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            FlatButton(
              onPressed: () => _showLoginView(),
              child: Text(
                L10n.of(context).loginButtonLabel,
                style: TextStyle(fontSize: 16.0),
              ),
            )
          ]
        ),
        Center(
          child: StreamBuilder(
            stream: viewModel.showIndicator,
            builder: (context, snapshot) {
              return (snapshot.hasData && snapshot.data)
                ? CircularProgressIndicator()
                : Container();
            },
          ),
        )
      ],
    );
  }

  void _showLoginView() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) {
              return Provider(
                create: (_) => LoginViewModel(FirestoreUserRepository(), FirestoreBabyRepository()),
                child: LoginView(),
              );
            }
        )
    );
  }
}