
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/data/babyRepository.dart';
import 'package:raisingchildrenrecord2/data/userRepository.dart';
import 'package:raisingchildrenrecord2/view/baseState.dart';
import 'package:raisingchildrenrecord2/view/invitationCodeReadView.dart';
import 'package:raisingchildrenrecord2/view/loginView.dart';
import 'package:raisingchildrenrecord2/view/mainView.dart';
import 'package:raisingchildrenrecord2/view/shared/utils.dart';
import 'package:raisingchildrenrecord2/viewmodel/invitationCodeReadViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/loginViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/mainViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/registerViewModel.dart';

class RegisterView extends StatefulWidget {
  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends BaseState<RegisterView, RegisterViewModel>{

  StreamSubscription _signInStreamSubscription;
  StreamSubscription _needConfirmInvitationStreamSubscription;
  StreamSubscription _alreadyRegisteredStreamSubscription;

  @override
  void initState() {
    super.initState();

    viewModel.onAppear.add(null);

    _signInStreamSubscription = viewModel.onSignIn.listen((_) => _showMainView());
    _needConfirmInvitationStreamSubscription = viewModel.needConfirmInvitationCode.listen((_) => _showInvitationReadView());
    _alreadyRegisteredStreamSubscription = viewModel.alreadyRegistered.listen((_) => _showAlreadyRegisteredDialog());
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
          title: Text("ユーザー登録")
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text(
                          "赤ちゃん日記2",
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
                              onPressed: () => viewModel.onGoogleButtonTapped.add(null),
                              child: Text(
                                "Googleで登録する",
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(48, 0, 48, 0),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlineButton(
                              color: Colors.white,
                              textColor: Colors.black,
                              onPressed: () => viewModel.onGuestButtonTapped.add(null),
                              child: Text(
                                "ゲストとして利用する",
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(48, 0, 48, 0),
                          child: SizedBox(
                            width: double.infinity,
                            child: FlatButton(
                              onPressed: () => _showLoginView(),
                              child: Text(
                                "登録済みのアカウントにログインする",
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
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _signInStreamSubscription.cancel();
    _needConfirmInvitationStreamSubscription.cancel();
    _alreadyRegisteredStreamSubscription.cancel();
  }

  void _showMainView() {
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

  void _showInvitationReadView() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Provider<InvitationCodeReadViewModel>(
          create: (_) => InvitationCodeReadViewModel(),
          child: InvitationCodeReadView(onInvitationCodeRead: viewModel.onInvitationCodeRead.add,),
        )
      )
    );
  }

  void _showAlreadyRegisteredDialog() {
    showSimpleDialog(
      context,
      title: "確認",
      content: "すでに登録済みです。ログインしますか？",
      leftButtonTitle: "キャンセル",
      rightButtonTitle: "OK",
      onLeftButtonPressed: null,
      onRightButtonPressed: () => _showMainView(),
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