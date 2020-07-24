import 'dart:async';

import 'package:raisingchildrenrecord2/data/babyRepository.dart';
import 'package:raisingchildrenrecord2/data/userRepository.dart';
import 'package:raisingchildrenrecord2/viewmodel/baseViewModel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class LoginViewModel with ViewModelErrorHandler, ViewModelInfoMessageHandler implements ViewModel {

  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseUser firebaseUser;

  final UserRepository userRepository;
  final BabyRepository babyRepository;

  StreamSubscription _onLoginPageAppearStreamSubscription;
  StreamSubscription _onSignInButtonTappedStreamSubscription;
  StreamSubscription _onInvitationCodeReadStreamSubscription;

  // input
  final _onLoginPageAppearStreamController = StreamController<void>();
  StreamSink<void> get onLoginPageAppear => _onLoginPageAppearStreamController.sink;

  final _onSignInButtonTappedStreamController = StreamController<void>();
  StreamSink<void> get onSignInButtonTapped => _onSignInButtonTappedStreamController.sink;

  // output
  final _signInUserStreamController = StreamController<String>();
  Stream<String> get signInUser => _signInUserStreamController.stream;

  final _messageStreamController = StreamController<String>();
  Stream<String> get message => _messageStreamController.stream;

  final _showIndicatorStreamController = BehaviorSubject.seeded(false);
  Stream<bool> get showIndicator => _showIndicatorStreamController.stream;

  final _userNotExistsStreamController = StreamController<void>();
  Stream<void> get userNotExists => _userNotExistsStreamController.stream;

  LoginViewModel(this.userRepository, this.babyRepository) {
    _bindInputAndOutput();
  }

  void _bindInputAndOutput() {
    _onLoginPageAppearStreamSubscription = _onLoginPageAppearStreamController.stream.listen(_getUserIdIfSignIn);
    _onSignInButtonTappedStreamSubscription = _onSignInButtonTappedStreamController.stream.listen(_signIn);
  }

  void _getUserIdIfSignIn(_) async {
    _showIndicatorStreamController.sink.add(true);
    bool isSignIn = await googleSignIn.isSignedIn();
    if (isSignIn) {
      final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      _signInUserStreamController.sink.add(sharedPreferences.getString("userId"));

    } else {
      _signInUserStreamController.sink.add(null);
    }
    _showIndicatorStreamController.sink.add(false);
  }

  void _signIn(_) async {
    if (_showIndicatorStreamController.value) {
      return;
    }

    _showIndicatorStreamController.sink.add(true);

    firebaseUser = await googleSignIn.signIn().then((GoogleSignInAccount account) {
      if (account == null) {
        _showIndicatorStreamController.sink.add(false);
        return null;
      }

      return account.authentication.then((GoogleSignInAuthentication auth) async {
        final AuthCredential credential = GoogleAuthProvider.getCredential(idToken: auth.idToken, accessToken: auth.accessToken);
        return firebaseAuth.signInWithCredential(credential).then((AuthResult result) {
          return result.user;
        });
      });
    });

    if (firebaseUser == null) {
      _signInUserStreamController.sink.add(null);
      errorMessageSink.add(ErrorMessage(Intl.message('Error', name: 'error'),
                                                          Intl.message('Failed to sign in.', name: 'failedToSignIn')));
      _showIndicatorStreamController.sink.add(false);
      return;
    }

    userRepository
      .getUser(firebaseUser.uid)
      .then((user) async {
        if (user == null) {
          _userNotExistsStreamController.sink.add(null);
          _showIndicatorStreamController.sink.add(false);
          return;
        }

        final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        await sharedPreferences.setString('userId', user.id);
        await sharedPreferences.setString('familyId', user.familyId);

        _signInUserStreamController.sink.add(user.id);
        _showIndicatorStreamController.sink.add(false);
      })
      .catchError(_handleError);
  }

  void _handleError(Object error) {
    _showIndicatorStreamController.sink.add(false);
    super.handleError(error);
  }

  void dispose() {
    super.dispose();
    _onLoginPageAppearStreamSubscription.cancel();
    _onSignInButtonTappedStreamSubscription.cancel();
    _onInvitationCodeReadStreamSubscription.cancel();

    _onLoginPageAppearStreamController.close();
    _onSignInButtonTappedStreamController.close();
    _signInUserStreamController.close();
    _messageStreamController.close();
    _showIndicatorStreamController.close();
    _userNotExistsStreamController.close();
  }
}