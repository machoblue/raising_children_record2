import 'dart:async';

import 'package:raisingchildrenrecord2/data/BabyRepository.dart';
import 'package:raisingchildrenrecord2/data/UserRepository.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/invitationCode.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:raisingchildrenrecord2/viewmodel/baseViewModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class LoginViewModel with ViewModelErrorHandler implements ViewModel {

  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseUser firebaseUser;

  final UserRepository userRepository;
  final BabyRepository babyRepository;

  // input
  final _onLoginPageAppearStreamController = StreamController<void>();
  StreamSink<void> get onLoginPageAppear => _onLoginPageAppearStreamController.sink;

  final _onSignInButtonTappedStreamController = StreamController<void>();
  StreamSink<void> get onSignInButtonTapped => _onSignInButtonTappedStreamController.sink;

  final _onInvitationCodeReadStreamController = StreamController<InvitationCode>();
  StreamSink<InvitationCode> get onInvitationCodeRead => _onInvitationCodeReadStreamController.sink;

  // output
  final _signInUserStreamController = StreamController<String>();
  Stream<String> get signInUser => _signInUserStreamController.stream;

  final _messageStreamController = StreamController<String>();
  Stream<String> get message => _messageStreamController.stream;

  final _showIndicatorStreamController = StreamController<bool>();
  Stream<bool> get showIndicator => _showIndicatorStreamController.stream;

  final _needConfirmInvitationCode = StreamController<void>();
  Stream<void> get needConfirmInvitationCode => _needConfirmInvitationCode.stream;

  LoginViewModel(this.userRepository, this.babyRepository) {
    _bindInputAndOutput();
  }

  void _bindInputAndOutput() {
    _onLoginPageAppearStreamController.stream.listen(_getUserIdIfSignIn);
    _onSignInButtonTappedStreamController.stream.listen(_signIn);
    _onInvitationCodeReadStreamController.stream.listen((invitationCode) {
      _handleInvitationCode(invitationCode);
    });
  }

  void _getUserIdIfSignIn(_) async {
    print("### getUserIdIfSignIn");
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
    print("### _signIn()");
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
      errorMessageStreamController.sink.add(ErrorMessage(Intl.message('Error', name: 'error'),
                                                          Intl.message('Failed to sign in.', name: 'failedToSignIn')));
      _showIndicatorStreamController.sink.add(false);
      return;
    }

    userRepository
      .getUser(firebaseUser.uid)
      .then((user) async {
        if (user == null) {
          _needConfirmInvitationCode.sink.add(null);
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

  void _handleInvitationCode(InvitationCode invitationCode) async {
    _showIndicatorStreamController.sink.add(true);
    if (invitationCode == null) {
      _createUserAndFamily()
        .then((userId) {
          _showIndicatorStreamController.sink.add(false);
          _signInUserStreamController.sink.add(userId);
        })
        .catchError(_handleError);

    } else {
      _createUserAndJoinFamily(invitationCode)
        .then((userId) {
          _showIndicatorStreamController.sink.add(false);
          _signInUserStreamController.sink.add(userId);
          _messageStreamController.sink.add(Intl.message('Finished configuration to share data.', name: 'dataShareComplete'));
        })
        .catchError(_handleError);
    }
  }

  Future<String> _createUserAndFamily() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final familyId = Uuid().v1();
    User user = User.fromFirebaseUser(firebaseUser, familyId);
    return userRepository.createOrUpdateUser(user).then((_) {
      return userRepository.createOrJoinFamily(familyId, user).then((_) {
        sharedPreferences.setString('userId', user.id);
        sharedPreferences.setString('familyId', familyId);

        final baby = Baby.newInstance();
        return babyRepository.createOrUpdateBaby(familyId, baby).then((_) {
          sharedPreferences.setString('selectedBabyId', baby.id);
          return user.id;
        });
      });
    });
  }

  Future<String> _createUserAndJoinFamily(InvitationCode invitationCode) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final User user = User.fromFirebaseUserAndInvitationCode(firebaseUser, invitationCode);
    return userRepository.createOrUpdateUser(user).then((_) {
      String familyId = invitationCode.familyId;
      return userRepository.createOrJoinFamily(familyId, user).then((_) {
        sharedPreferences.setString('familyId', familyId);
        sharedPreferences.setString('userId', user.id);

        return babyRepository.getBabies(familyId).then((babies) {
          if (babies.isNotEmpty) {
            sharedPreferences.setString('selectedBabyId', babies.first.id);
            return user.id;
          }

          final baby = Baby.newInstance();
          return babyRepository.createOrUpdateBaby(familyId, baby).then((_) {
            sharedPreferences.setString('selectedBabyId', baby.id);
            return user.id;
          });
        });
      });
    });
  }

  void _handleError(Object error) {
    _showIndicatorStreamController.sink.add(false);
    super.handleError(error);
  }

  void dispose() {
    super.dispose();
    _onLoginPageAppearStreamController.close();
    _onSignInButtonTappedStreamController.close();
    _signInUserStreamController.close();
    _messageStreamController.close();
    _showIndicatorStreamController.close();
    _needConfirmInvitationCode.close();
    _onInvitationCodeReadStreamController.close();
  }
}