import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/data/babyRepository.dart';
import 'package:raisingchildrenrecord2/data/userRepository.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/view/baseState.dart';
import 'package:raisingchildrenrecord2/view/mainView.dart';
import 'package:raisingchildrenrecord2/view/shared/utils.dart';
import 'package:raisingchildrenrecord2/viewmodel/loginViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/mainViewModel.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends BaseState<LoginView, LoginViewModel> {

  StreamSubscription _signInUserSubscription;
  StreamSubscription _messageSubscription;
  StreamSubscription _userNotExistsSubscription;

  @override
  void initState() {
    super.initState();

    viewModel.onLoginPageAppear.add(null);

    _signInUserSubscription = viewModel.signInUser.listen(_onSignedIn);
    _messageSubscription = viewModel.message.listen((String errorMessage) => Fluttertoast.showToast(msg: errorMessage));
    _userNotExistsSubscription = viewModel.userNotExists.listen((_) => _showUserNotExistsDialog());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.of(context).loginTitle)
      ),
      body: Stack(
        children: <Widget>[
          _buildLoginButton(),
          _buildIndicator(),
        ]
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();

    _signInUserSubscription.cancel();
    _messageSubscription.cancel();
    _userNotExistsSubscription.cancel();
  }

  Widget _buildLoginButton() {
    L10n l10n = L10n.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                  l10n.loginTitle,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blueGrey)
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(48, 0, 48, 0),
                  child: SizedBox(
                    width: double.infinity,
                    child: RaisedButton(
                      onPressed: () => _onLoginButtonTapped(),
                      child: Text(
                        L10n.of(context).loginButtonLabel,
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator() {
    return StreamBuilder(
      stream: viewModel.showIndicator,
      builder: (context, snapshot) {
        final showIndicator = snapshot.data ?? false;
        if (!showIndicator) {
          return Container();
        }
        return Positioned(
          child: Container(
            child: Center(
                child: CircularProgressIndicator()
            ),
          ),
        );
      }
    );
  }

  void _onLoginButtonTapped() {
    viewModel.onSignInButtonTapped.add(null);
  }

  void _showUserNotExistsDialog() {
    L10n l10n = L10n.of(context);
    showSingleButtonDialog(
        context,
        title: l10n.loginError,
        content: l10n.userNotExists,
        buttonTitle: l10n.ok,
        onButtonPressed: () => Navigator.pop(context),
    );
  }

  void _onSignedIn(String userId) {
    if (userId == null || userId.isEmpty) {
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Provider<MainViewModel>(
          create: (_) => MainViewModel(FirestoreUserRepository(), FirestoreBabyRepository()),
          child: MainView()
        )
      )
    );
  }
}
