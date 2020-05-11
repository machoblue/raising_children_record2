import 'dart:async';

import 'package:raisingchildrenrecord2/data/BabyRepository.dart';
import 'package:raisingchildrenrecord2/data/UserRepository.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/invitationCode.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class LoginViewModel {

  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseUser firebaseUser;

  final UserRepository userRepository;
  final BabyRepository babyRepository;

  // input
  final _onLoginPageAppearStreamController = StreamController<void>();
  final _onSignInButtonTappedStreamController = StreamController<void>();
  StreamSink<void> get onLoginPageAppear => _onLoginPageAppearStreamController.sink;
  StreamSink<void> get onSignInButtonTapped => _onSignInButtonTappedStreamController.sink;

  final _onInvitationCodeReadStreamController = StreamController<InvitationCode>();
  StreamSink<InvitationCode> get onInvitationCodeRead => _onInvitationCodeReadStreamController.sink;

  // output
  final _signInUserStreamController = StreamController<String>();
  final _messageStreamController = StreamController<String>();
  final _showIndicatorStreamController = StreamController<bool>();
  Stream<String> get signInUser => _signInUserStreamController.stream;
  Stream<String> get message => _messageStreamController.stream;
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
      _messageStreamController.sink.add(Intl.message('Failed to sign in.', name: 'failedToSignIn'));
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
      });
  }

  void _handleInvitationCode(InvitationCode invitationCode) async {
    _showIndicatorStreamController.sink.add(true);
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (invitationCode == null) {
      final familyId = Uuid().v1();
      await sharedPreferences.setString('familyId', familyId);

      User user = User.fromFirebaseUser(firebaseUser, familyId);
      await userRepository.createOrUpdateUser(user);
      await userRepository.createOrJoinFamily(familyId, user);
      await sharedPreferences.setString('userId', user.id);

      final Baby baby = Baby.newInstance();
      await babyRepository.createOrUpdateBaby(familyId, baby);
      await sharedPreferences.setString('selectedBabyId', baby.id);

      _signInUserStreamController.sink.add(user.id);

    } else {
      User user = User.fromFirebaseUserAndInvitationCode(firebaseUser, invitationCode);
      await userRepository.createOrUpdateUser(user);
      String familyId = invitationCode.familyId;
      await userRepository.createOrJoinFamily(familyId, user);
      await sharedPreferences.setString('familyId', familyId);
      sharedPreferences.setString('userId', user.id);

      Baby selectedBaby;
      List<Baby> babies = await babyRepository.getBabies(familyId);
      if (babies.isEmpty) {
        selectedBaby = Baby.newInstance();
        babyRepository.createOrUpdateBaby(familyId, selectedBaby);
      } else {
        selectedBaby = babies.first;
      }
      sharedPreferences.setString('selectedBabyId', selectedBaby.id);

      _messageStreamController.sink.add(Intl.message('Finished configuration to share data.', name: 'dataShareComplete'));
      _signInUserStreamController.sink.add(user.id);
    }

    _showIndicatorStreamController.sink.add(false);
  }

  void dispose() {
    _onLoginPageAppearStreamController.close();
    _onSignInButtonTappedStreamController.close();
    _signInUserStreamController.close();
    _messageStreamController.close();
    _showIndicatorStreamController.close();
    _needConfirmInvitationCode.close();
    _onInvitationCodeReadStreamController.close();
  }
}