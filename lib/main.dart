import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/data/babyRepository.dart';
import 'package:raisingchildrenrecord2/data/userRepository.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/shared/authenticator.dart';
import 'package:raisingchildrenrecord2/view/loginView.dart';
import 'package:raisingchildrenrecord2/view/registerView.dart';
import 'package:raisingchildrenrecord2/viewmodel/loginViewModel.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:raisingchildrenrecord2/viewmodel/registerViewModel.dart';

void main() {
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
//      home: Provider(
//        create: (_) => LoginViewModel(FirestoreUserRepository(), FirestoreBabyRepository()),
//        child: LoginView(),
//      ),
      home: Provider(
        create: (_) => RegisterViewModel(GoogleAuthenticator(), GuestAuthenticator(), FirestoreUserRepository(), FirestoreBabyRepository()),
        child: RegisterView(),
      ),
      localizationsDelegates: [
        L10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja'),
        Locale('en'),
      ],
    );
  }
}