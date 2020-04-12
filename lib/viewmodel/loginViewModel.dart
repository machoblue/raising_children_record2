import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  Stream<String> get signInUser => _signInUserStreamController.stream;
  Stream<String> get errorMessage => _errorMessageStreamController.stream;

  LoginViewModel() {
    _bindInputAndOutput();
  }

  void _bindInputAndOutput() {
    _onLoginPageAppearStreamController.stream.listen(_getUserIdIfSignIn);
    _onSignInButtonTappedStreamController.stream.listen(_signIn);
  }

  void _getUserIdIfSignIn(_) async {
    print("### getUserIdIfSignIn");
    bool isSignIn = await googleSignIn.isSignedIn();
    if (isSignIn) {
      final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      _signInUserStreamController.sink.add(sharedPreferences.getString("userId"));

    } else {
      _signInUserStreamController.sink.add(null);
    }
  }

  void _signIn(_) async {
    print("### _signIn()");
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
        Firestore.instance.collection('users').document(user.uid).setData({
          'id': user.uid,
          'name': user.displayName,
          'photoUrl': user.photoUrl,
        });

        final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        await sharedPreferences.setString('id', user.uid);
        await sharedPreferences.setString('name', user.displayName);
        await sharedPreferences.setString('photoUrl', user.photoUrl);

        _signInUserStreamController.sink.add(user.uid);

      } else {
        final snapshot = snapshots[0];
        final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        await sharedPreferences.setString('id', snapshot['id']);
        await sharedPreferences.setString('name', snapshot['name']);
        await sharedPreferences.setString('photoUrl', snapshot['photoUrl']);

        _signInUserStreamController.sink.add(snapshot['id']);
      }

    } else {
      _signInUserStreamController.sink.add(null);
      _errorMessageStreamController.sink.add("Failed to sign in.");
    }
  }

  void dispose() {
    _onLoginPageAppearStreamController.close();
    _onSignInButtonTappedStreamController.close();
    _signInUserStreamController.close();
    _errorMessageStreamController.close();
  }
}