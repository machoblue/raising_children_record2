
import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:raisingchildrenrecord2/data/userRepository.dart';
import 'package:raisingchildrenrecord2/shared/authenticator.dart';
import 'package:raisingchildrenrecord2/viewmodel/baseViewModel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class RegisterViewModel with ViewModelErrorHandler implements ViewModel {

  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  final Authenticator googleAuthenticator;
  final Authenticator guestAuthenticator;
  final UserRepository userRepository;

  // Input
  final _onAppearStream = StreamController<void>();
  StreamSink get onAppear => _onAppearStream.sink;

  final _onGoogleButtonTappedStream = StreamController<void>();
  StreamSink get onGoogleButtonTapped => _onGoogleButtonTappedStream.sink;

  final _onAnonymousButtonTappedStream = StreamController<void>();
  StreamSink get onAnonymousButtonTapped => _onAnonymousButtonTappedStream.sink;

  final _onDialogSignInButtonTappedStream = StreamController<void>();
  StreamSink get onDialogSignInButtonTapped => _onDialogSignInButtonTappedStream.sink;

  // Output
  final _onSignInStreamController = StreamController<void>();
  Stream get onSignIn => _onSignInStreamController.stream;

  final _needConfirmInvitationCode = StreamController<void>();
  Stream<void> get needConfirmInvitationCode => _needConfirmInvitationCode.stream;

  final _alreadyRegisteredStreamController = StreamController<void>();
  Stream get alreadyRegistered => _alreadyRegisteredStreamController.stream;

  final _showIndicatorStreamController = BehaviorSubject.seeded(false);
  Stream<bool> get showIndicator => _showIndicatorStreamController.stream;

  StreamSubscription _onAppearSubscription;
  StreamSubscription _onGoogleButtonTappedSubscription;

  RegisterViewModel(this.googleAuthenticator, this.guestAuthenticator, this.userRepository) {
    _onAppearSubscription = _onAppearStream.stream.listen((_) {
      _showIndicatorStreamController.sink.add(true);

      _isSignIn()
        .then((isSignIn) {
          if (isSignIn) {
            _onSignInStreamController.sink.add(null);
          }
          _showIndicatorStreamController.sink.add(false);
        })
        .catchError(_handleError);
    });

    _onGoogleButtonTappedSubscription = _onGoogleButtonTappedStream.stream.listen((_) {
      _showIndicatorStreamController.sink.add(true);

      googleAuthenticator.authenticate().then((authenticatedUser) {
        userRepository.getUser(authenticatedUser.id).then((user) async {
          if (user == null) {
            _needConfirmInvitationCode.sink.add(null);
            return;
          }

          _saveUserIdAndFamilyId(user.id, user.familyId);
          _alreadyRegisteredStreamController.sink.add(null);
        });
      })
      .catchError(_handleError)
      .whenComplete(() => _showIndicatorStreamController.sink.add(false));
    });
  }

  Future<bool> _isSignIn() {
    /*
    return googleSignIn.isSignedIn().then((isSignIn) {
      if (!isSignIn) {
        return false;
      }

      return SharedPreferences.getInstance().then((sharedPreferences) {
        final userId = sharedPreferences.getString("userId");
        return userId?.isNotEmpty ?? false;
      });
    });
     */
//    final FirebaseUser firebaseUser = firebaseAuth.currentUser();
    return firebaseAuth.currentUser().then((firebaseUser) {
      if (firebaseUser == null) {
        return false;
      }

      return SharedPreferences.getInstance().then((sharedPreferences) {
        final userId = sharedPreferences.getString("userId");
        return userId?.isNotEmpty ?? false;
      });
    });
  }

  Future<void> _saveUserIdAndFamilyId(String userId, String familyId) {
    SharedPreferences.getInstance().then((sharedPreferences) async {
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
        message = Intl.message('Cannot access data. This operation is unexpected. Please tell us what did you do.', name: 'permissionError');
        errorMessageStreamController.sink.add(ErrorMessage(title, message));
        return;
      case AuthenticateFailedException:
        message = Intl.message('Cannot access data. This operation is unexpected. Please tell us what did you do.', name: 'permissionError');
        errorMessageStreamController.sink.add(ErrorMessage(title, message));
        return;
      default:
        handleError(error);
    }
  }

  @override
  void dispose() {
    super.dispose();

    _onAppearSubscription.cancel();
    _onGoogleButtonTappedSubscription.cancel();

    _onAppearStream.close();
    _onGoogleButtonTappedStream.close();
    _onAnonymousButtonTappedStream.close();
    _onDialogSignInButtonTappedStream.close();
    _onSignInStreamController.close();
    _needConfirmInvitationCode.close();
    _alreadyRegisteredStreamController.close();
    _showIndicatorStreamController.close();
  }
}