import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/data/babyRepository.dart';
import 'package:raisingchildrenrecord2/data/userRepository.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/view/baseState.dart';
import 'package:raisingchildrenrecord2/view/invitationCodeReadView.dart';
import 'package:raisingchildrenrecord2/view/mainView.dart';
import 'package:raisingchildrenrecord2/viewmodel/invitationCodeReadViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/loginViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/mainViewModel.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends BaseState<LoginView, LoginViewModel> {

  StreamSubscription _signInUserSubscription;
  StreamSubscription _messageSubscription;
  StreamSubscription _needConfirmInvitationCodeSubscription;

  @override
  void initState() {
    super.initState();

    viewModel.onLoginPageAppear.add(null);

    _signInUserSubscription = viewModel.signInUser.listen(_onSignedIn);
    _messageSubscription = viewModel.message.listen((String errorMessage) => Fluttertoast.showToast(msg: errorMessage));
    _needConfirmInvitationCodeSubscription = viewModel.needConfirmInvitationCode.listen((_) => _showInvitationReadView());
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
    _needConfirmInvitationCodeSubscription.cancel();
  }

  Widget _buildLoginButton() {
    return Center(
      child: RaisedButton(
        onPressed: _onLoginButtonTapped,
        child: Text(
          L10n.of(context).loginButtonLabel,
          style: TextStyle(fontSize: 16.0),
        ),
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

  void _showInvitationReadView() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return Provider<InvitationCodeReadViewModel>(
            create: (_) => InvitationCodeReadViewModel(),
            child: InvitationCodeReadView(
              onInvitationCodeRead: viewModel.onInvitationCodeRead.add,
            ),
          );
        }
      )
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
