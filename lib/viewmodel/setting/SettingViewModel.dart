
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingViewModel {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  final _onClearAllDataItemTappedStreamController = StreamController<void>();
  StreamSink<void> get onClearAllDataItemTapped => _onClearAllDataItemTappedStreamController.sink;

  final _loadingBehaviorSubject = BehaviorSubject.seeded(false);
  Stream<bool> get loading => _loadingBehaviorSubject.stream;

  final _logoutCompleteStreamController = StreamController<void>();
  Stream<void> get logoutComplete => _logoutCompleteStreamController.stream;

  SettingViewModel() {
    _onClearAllDataItemTappedStreamController.stream.listen((_) {
      _loadingBehaviorSubject.sink.add(true);
      _clearAllData().then((_) {
        _logout().then((_) {
          _loadingBehaviorSubject.sink.add(false);
          _logoutCompleteStreamController.sink.add(null);
        });
      });
    });
  }

  Future<void> _clearAllData() {
    return _clearFamilyInfo().then((_) {
      return _clearUserInfo();
    });
  }

  Future<void> _clearFamilyInfo() {

  }

  Future<void> _clearUserInfo() {
  }

  Future<void> _logout() {
    return firebaseAuth.signOut().then((_) {
      return googleSignIn.signOut().then((_) async {
        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        await sharedPreferences.remove('userId');
        await sharedPreferences.remove('familyId');
        await sharedPreferences.remove('selectedBabyId');
        return null;
      });
    });
  }

  void dispose() {
    _onClearAllDataItemTappedStreamController.close();
    _loadingBehaviorSubject.close();
    _logoutCompleteStreamController.close();
  }
}