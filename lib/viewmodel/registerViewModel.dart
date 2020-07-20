
import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:raisingchildrenrecord2/data/babyRepository.dart';
import 'package:raisingchildrenrecord2/data/firestoreErrorHandler.dart';
import 'package:raisingchildrenrecord2/data/userRepository.dart';
import 'package:raisingchildrenrecord2/model/authenticatedUser.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/invitationCode.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:raisingchildrenrecord2/shared/authenticator.dart';
import 'package:raisingchildrenrecord2/viewmodel/baseViewModel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class RegisterViewModel with ViewModelErrorHandler, ViewModelInfoMessageHandler implements ViewModel {

  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  final Authenticator googleAuthenticator;
  final Authenticator guestAuthenticator;
  final UserRepository userRepository;
  final BabyRepository babyRepository;

  AuthenticatedUser _authenticatedUser;

  // Input
  final _onAppearStream = StreamController<void>();
  StreamSink get onAppear => _onAppearStream.sink;

  final _onGoogleButtonTappedStream = StreamController<void>();
  StreamSink get onGoogleButtonTapped => _onGoogleButtonTappedStream.sink;

  final _onGuestButtonTappedStream = StreamController<void>();
  StreamSink get onGuestButtonTapped => _onGuestButtonTappedStream.sink;

  final _onDialogSignInButtonTappedStream = StreamController<void>();
  StreamSink get onDialogSignInButtonTapped => _onDialogSignInButtonTappedStream.sink;

  final _onInvitationCodeReadStreamController = StreamController<InvitationCode>();
  StreamSink<InvitationCode> get onInvitationCodeRead => _onInvitationCodeReadStreamController.sink;

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
  StreamSubscription _onGuestButtonTappedSubscription;
  StreamSubscription _onDialogSignInButtonTappedSubscription;
  StreamSubscription _onInvitationCodeReadSubscription;

  RegisterViewModel(this.googleAuthenticator, this.guestAuthenticator, this.userRepository, this.babyRepository) {
    _onAppearSubscription = _onAppearStream.stream.listen((_) {
      _showIndicatorStreamController.sink.add(true);

      _isSignIn()
        .then((isSignIn) {
          if (isSignIn) {
            _onSignInStreamController.sink.add(null);
          }
        })
        .catchError(_handleError)
        .whenComplete(() => _showIndicatorStreamController.sink.add(false));
    });

    _onGoogleButtonTappedSubscription = _onGoogleButtonTappedStream.stream.listen((_) {
      _showIndicatorStreamController.sink.add(true);

      googleAuthenticator.authenticate().then((authenticatedUser) {
        userRepository.getUser(authenticatedUser.id).then((user) async {
          if (user == null) {
            _authenticatedUser = authenticatedUser;
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

    _onGuestButtonTappedSubscription = _onGuestButtonTappedStream.stream.listen((_) {
      _showIndicatorStreamController.sink.add(true);

      guestAuthenticator.authenticate().then((authenticatedUser) {
        userRepository.getUser(authenticatedUser.id).then((user) async {
          if (user == null) {
            _authenticatedUser = authenticatedUser;
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

    _onDialogSignInButtonTappedSubscription = _onDialogSignInButtonTappedStream.stream.listen((_) {
      _onSignInStreamController.sink.add(null);
    });

    _onInvitationCodeReadSubscription = _onInvitationCodeReadStreamController.stream.listen((invitationCode) {
      _showIndicatorStreamController.sink.add(true);
      _handleInvitationCode(invitationCode)
        .then((_) {
          _onSignInStreamController.sink.add(null);
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
    return SharedPreferences.getInstance().then((sharedPreferences) async {
      await sharedPreferences.setString('userId', userId);
      await sharedPreferences.setString('familyId', familyId);
      return;
    });
  }

  Future<void> _saveSelectedBabyId(String selectedBabyId) {
    return SharedPreferences.getInstance().then((sharedPreferences) async {
      return sharedPreferences.setString('selectedBabyId', selectedBabyId);
    });
  }

  Future<void> _handleInvitationCode(InvitationCode invitationCode) {
    if (invitationCode == null) {
      return _createUserAndFamily();

    } else {
      return _createUserAndJoinFamily(invitationCode)
        .then((_) {
          infoMessageSink.add(Intl.message('Finished configuration to share data.', name: 'dataShareComplete'));
        })
        .catchError((error) {
          final title = Intl.message('Error', name: 'error');
          final message = Intl.message('This invitation code isn\'t valid. This may be expired. Please recreate invitation code and read again.', name: 'invitationCodeInvalid');
          errorMessageSink.add(ErrorMessage(title, message));
        }, test: (error) => error is PermissionException);
    }
  }

  Future<void> _createUserAndFamily() async {
    final familyId = Uuid().v1();
    final user = User.fromAuthenticatedUser(_authenticatedUser, familyId);
    return userRepository.createOrUpdateUser(user).then((_) {
      return userRepository.createFamily(familyId, user).then((_) {
        return _saveUserIdAndFamilyId(user.id, familyId).then((_) {
          final baby = Baby.newInstance();
          return babyRepository.createOrUpdateBaby(familyId, baby).then((_) {
            return _saveSelectedBabyId(baby.id);
          });
        });
      });
    });
  }

  Future<void> _createUserAndJoinFamily(InvitationCode invitationCode) async {
    final user = User.fromAuthenticatedUserAndInvitationCode(_authenticatedUser, invitationCode);
    return userRepository.createOrUpdateUser(user).then((_) {
      final String familyId = invitationCode.familyId;
      return userRepository.joinFamily(familyId, user).then((_) {
        _saveUserIdAndFamilyId(user.id, familyId).then((_) {
          return babyRepository.getBabies(familyId).then((babies) {
            if (babies.isNotEmpty) {
              return _saveSelectedBabyId(babies.first.id);
            }

            final baby = Baby.newInstance();
            return babyRepository.createOrUpdateBaby(familyId, baby).then((_) {
              return _saveSelectedBabyId(baby.id);
            });
          });
        });
      });
    });
  }

  void _handleError(Object error) {
    String title = Intl.message('Error', name: 'error');
    String message = "";

    switch (error.runtimeType) {
      case AuthenticateCancelledException:
        message = Intl.message('Cannot access data. This operation is unexpected. Please tell us what did you do.', name: 'permissionError');
        errorMessageSink.add(ErrorMessage(title, message));
        return;
      case AuthenticateFailedException:
        message = Intl.message('Cannot access data. This operation is unexpected. Please tell us what did you do.', name: 'permissionError');
        errorMessageSink.add(ErrorMessage(title, message));
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
    _onGuestButtonTappedSubscription.cancel();
    _onDialogSignInButtonTappedSubscription.cancel();
    _onInvitationCodeReadSubscription.cancel();

    _onAppearStream.close();
    _onGoogleButtonTappedStream.close();
    _onGuestButtonTappedStream.close();
    _onDialogSignInButtonTappedStream.close();
    _onSignInStreamController.close();
    _onInvitationCodeReadStreamController.close();
    _needConfirmInvitationCode.close();
    _alreadyRegisteredStreamController.close();
    _showIndicatorStreamController.close();
  }
}