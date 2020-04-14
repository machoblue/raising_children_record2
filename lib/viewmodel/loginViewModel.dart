import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class LoginViewModel {

  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  // input
  final _onLoginPageAppearStreamController = StreamController<void>();
  final _onSignInButtonTappedStreamController = StreamController<void>();
  StreamSink<void> get onLoginPageAppear => _onLoginPageAppearStreamController.sink;
  StreamSink<void> get onSignInButtonTapped => _onSignInButtonTappedStreamController.sink;

  // output
  final _signInUserStreamController = StreamController<String>();
  final _errorMessageStreamController = StreamController<String>();
  final _showIndicatorStreamController = StreamController<bool>();
  Stream<String> get signInUser => _signInUserStreamController.stream;
  Stream<String> get errorMessage => _errorMessageStreamController.stream;
  Stream<bool> get showIndicator => _showIndicatorStreamController.stream;

  LoginViewModel() {
    _bindInputAndOutput();
  }

  void _bindInputAndOutput() {
    _onLoginPageAppearStreamController.stream.listen(_getUserIdIfSignIn);
    _onSignInButtonTappedStreamController.stream.listen(_signIn);
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
    final GoogleSignInAccount account = await googleSignIn.signIn();
    final GoogleSignInAuthentication auth = await account.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(idToken: auth.idToken, accessToken: auth.accessToken);
    final user = (await firebaseAuth.signInWithCredential(credential)).user;
    if (user != null) {
      final QuerySnapshot querySnapshot = await Firestore.instance
          .collection('users')
          .where('id', isEqualTo: user.uid)
          .getDocuments();
      final List<DocumentSnapshot> snapshots = querySnapshot.documents;
      if (snapshots.length == 0) {

        final familyId = Uuid().v1();
        Firestore.instance.collection('users').document(user.uid).setData({
          'id': user.uid,
          'name': user.displayName,
          'photoUrl': user.photoUrl,
          'familyId': familyId,
        });

        final babyId = Uuid().v1();
        final defaultBabyIconUrl = 'https://firebasestorage.googleapis.com/v0/b/raisingchildrenrecord2.appspot.com/o/icon.png?alt=media&token=ce8d2ab5-98bf-42b3-9090-d3dc1459054a';
        Firestore.instance.collection('families').document(familyId).setData({
          'users': { user.uid : true, },
          'babies': {
            'id': babyId,
            'name': 'Baby',
            'photoUrl': defaultBabyIconUrl,
            'birthday': DateTime.now().millisecondsSinceEpoch,
          }
        });

        final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        await sharedPreferences.setString('id', user.uid);
        await sharedPreferences.setString('name', user.displayName);
        await sharedPreferences.setString('photoUrl', user.photoUrl);
        await sharedPreferences.setString('familyId', familyId);

        _signInUserStreamController.sink.add(user.uid);

      } else {
        final snapshot = snapshots[0];
        final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        await sharedPreferences.setString('id', snapshot['id']);
        await sharedPreferences.setString('name', snapshot['name']);
        await sharedPreferences.setString('photoUrl', snapshot['photoUrl']);
        await sharedPreferences.setString('familyId', snapshot['familyId']);

        _signInUserStreamController.sink.add(snapshot['id']);
      }

    } else {
      _signInUserStreamController.sink.add(null);
      _errorMessageStreamController.sink.add("Failed to sign in.");
    }

    _showIndicatorStreamController.sink.add(false);
  }

  void dispose() {
    _onLoginPageAppearStreamController.close();
    _onSignInButtonTappedStreamController.close();
    _signInUserStreamController.close();
    _errorMessageStreamController.close();
  }
}