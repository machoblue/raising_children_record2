import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/view/home.dart';
import 'package:raisingchildrenrecord2/viewmodel/login_viewmodel.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Provider<LoginViewModel>(
      create: (_) => LoginViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Login')
        ),
        body: Center(
          child: LoginButton(),
        ),
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
    return FlatButton(
      onPressed: _onLoginButtonTapped,
      child: Text(
          'SIGN IN WITH GOOGLE',
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

      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return MyHomePage();
            }
          )
      );
    });
    _viewModel.errorMessage.listen((String errorMessage) {
      Fluttertoast.showToast(msg: errorMessage);
    });
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
}