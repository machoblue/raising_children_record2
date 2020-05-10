import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/data/BabyRepository.dart';
import 'package:raisingchildrenrecord2/data/UserRepository.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/view/invitationCodeReadView.dart';
import 'package:raisingchildrenrecord2/view/mainView.dart';
import 'package:raisingchildrenrecord2/viewmodel/invitationCodeReadViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/loginViewModel.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  Widget build(BuildContext context) {
    return Provider<LoginViewModel>(
      create: (_) => LoginViewModel(FirestoreUserRepository(), FirestoreBabyRepository()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(L10n.of(context).loginTitle)
        ),
        body: Stack(
          children: <Widget>[
            Center(
              child: LoginButton(),
            ),
            Builder(
              builder: (context) => StreamBuilder(
                stream: Provider.of<LoginViewModel>(context).showIndicator,
                builder: (context, snapshot) {
                  return Positioned(
                    child: (snapshot.hasData && snapshot.data) ? Container(
                      child: Center(
                        child: CircularProgressIndicator()
                      ),
                    ) : Container()
                  );
                }
              )
            )
          ]
        )
      ),
    );
  }
}

class LoginButton extends StatefulWidget {
  @override
  _LoginButtonState createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {

  LoginViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: _onLoginButtonTapped,
      child: Text(
          L10n.of(context).loginButtonLabel,
          style: TextStyle(fontSize: 16.0),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _viewModel = Provider.of<LoginViewModel>(context, listen: false);

    // この辺はLoginButtonではなく、LoginPageの方でやりたい。
    _viewModel.onLoginPageAppear.add(null);
    _viewModel.signInUser.listen((String signInUser) {
      print("### _viewModel.signInUser.listen: $signInUser");
      if (signInUser == null || signInUser.isEmpty) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainView()
        )
      );
    });
    _viewModel.message.listen((String errorMessage) {
      Fluttertoast.showToast(msg: errorMessage);
    });

    _viewModel.needConfirmInvitationCode.listen((_) => _showInvitationReadView());
  }

  @override
  void dispose() {
    super.dispose();
    print("### dispose()");
    _viewModel.dispose();
  }

  void _onLoginButtonTapped() {
    print("### _onLoginButtonTapped()");
    _viewModel.onSignInButtonTapped.add(null);
  }

  void _showInvitationReadView() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return Provider<InvitationCodeReadViewModel>(
            create: (_) => InvitationCodeReadViewModel(),
            child: InvitationCodeReadView(
              onInvitationCodeRead: _viewModel.onInvitationCodeRead.add,
            ),
          );
        }
      )
    );
  }
}