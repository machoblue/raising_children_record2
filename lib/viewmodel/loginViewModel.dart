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

    if (user == null) {
      _signInUserStreamController.sink.add(null);
      _errorMessageStreamController.sink.add("Failed to sign in.");
      _showIndicatorStreamController.sink.add(false);
      return;
    }

    final userSnapshot = await Firestore.instance.collection('users').document(user.uid).get();
    if (userSnapshot.exists ?? false) {
      final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.setString('userId', userSnapshot['id']);
      await sharedPreferences.setString('userName', userSnapshot['name']);
      await sharedPreferences.setString('userPhotoUrl', userSnapshot['photoUrl']);
      await sharedPreferences.setString('familyId', userSnapshot['familyId']);

      _signInUserStreamController.sink.add(user.uid);
      _showIndicatorStreamController.sink.add(false);

      return;
    }

    final familyId = Uuid().v1();
    Firestore.instance.collection('users').document(user.uid).setData({
      'id': user.uid,
      'name': user.displayName,
      'photoUrl': user.photoUrl,
      'familyId': familyId,
    });

    final babyId = Uuid().v1();
    final defaultBabyIconUrl = 'https://firebasestorage.googleapis.com/v0/b/raisingchildrenrecord2.appspot.com/o/icon.png?alt=media&token=ce8d2ab5-98bf-42b3-9090-d3dc1459054a';
    
    final familyDocumentReference = Firestore.instance.collection('families').document(familyId);
//    familyDocumentReference.updateData({'users': FieldValue.arrayUnion('some user id'));
    familyDocumentReference.setData({
      'userIds': [user.uid],
    });
    familyDocumentReference.collection('babies').document(babyId).setData({
      'id': babyId,
      'name': 'Baby',
      'photoUrl': defaultBabyIconUrl,
      'birthday': DateTime.now().millisecondsSinceEpoch,
    });

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString('userId', user.uid);
    await sharedPreferences.setString('userName', user.displayName);
    await sharedPreferences.setString('userPhotoUrl', user.photoUrl);
    await sharedPreferences.setString('familyId', familyId);
    await sharedPreferences.setStringList('babyIds', [babyId]);
    await sharedPreferences.setString('selectedBabyId', babyId);

    _signInUserStreamController.sink.add(user.uid);
    _showIndicatorStreamController.sink.add(false);
  }

  void dispose() {
    _onLoginPageAppearStreamController.close();
    _onSignInButtonTappedStreamController.close();
    _signInUserStreamController.close();
    _errorMessageStreamController.close();
    _showIndicatorStreamController.close();
  }
}