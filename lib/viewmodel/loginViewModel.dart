import 'dart:async';

import 'package:raisingchildrenrecord2/data/babyRepository.dart';
import 'package:raisingchildrenrecord2/data/userRepository.dart';
import 'package:raisingchildrenrecord2/shared/authenticator.dart';
import 'package:raisingchildrenrecord2/viewmodel/baseViewModel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';

class LoginViewModel with ViewModelErrorHandler, ViewModelInfoMessageHandler implements ViewModel {

  final GoogleSignIn googleSignIn = GoogleSignIn();

  final Authenticator googleAuthenticator;

  final UserRepository userRepository;
  final BabyRepository babyRepository;

  StreamSubscription _onLoginPageAppearStreamSubscription;
  StreamSubscription _onSignInButtonTappedStreamSubscription;

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

  LoginViewModel(this.googleAuthenticator, this.userRepository, this.babyRepository) {
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

  Future<void> _signIn(_) async {
    if (_showIndicatorStreamController.value) {
      return;
    }

    _showIndicatorStreamController.sink.add(true);

    return googleAuthenticator.authenticate().then((authenticatedUser) {
      return userRepository.getUser(authenticatedUser.id).then((user) async {
        if (user == null) {
          _userNotExistsStreamController.sink.add(null);
          return;
        }

        _saveUserIdAndFamilyId(user.id, user.familyId);
        _signInUserStreamController.sink.add(user.id);
      });
    })
    .catchError(_handleError)
    .whenComplete(() => _showIndicatorStreamController.sink.add(false));
  }

  Future<void> _saveUserIdAndFamilyId(String userId, String familyId) {
    return SharedPreferences.getInstance().then((sharedPreferences) async {
      await sharedPreferences.setString('userId', userId);
      await sharedPreferences.setString('familyId', familyId);
      return;
    });
  }

  void _handleError(Object error) {
    _showIndicatorStreamController.sink.add(false);

    String title = Intl.message('Error', name: 'error');
    String message = "";

    switch (error.runtimeType) {
      case AuthenticateCancelledException:
        message = Intl.message('Authentication was canceled.', name: 'authenticationCanceled');
        errorMessageSink.add(ErrorMessage(title, message));
        return;
      case AuthenticateFailedException:
        message = Intl.message('Authentication was failed.', name: 'authenticationFailed');
        errorMessageSink.add(ErrorMessage(title, message));
        return;
      default:
        handleError(error);
    }
  }

  void dispose() {
    super.dispose();
    _onLoginPageAppearStreamSubscription.cancel();
    _onSignInButtonTappedStreamSubscription.cancel();

    _onLoginPageAppearStreamController.close();
    _onSignInButtonTappedStreamController.close();
    _signInUserStreamController.close();
    _messageStreamController.close();
    _showIndicatorStreamController.close();
    _userNotExistsStreamController.close();
  }
}