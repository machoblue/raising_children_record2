
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:raisingchildrenrecord2/data/UserRepository.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingViewModel {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final User user;
  final UserRepository userRepository;

  final _onClearAllDataItemTappedStreamController = StreamController<void>();
  StreamSink<void> get onClearAllDataItemTapped => _onClearAllDataItemTappedStreamController.sink;

  final _isLoadingBehaviorSubject = BehaviorSubject.seeded(false);
  Stream<bool> get isLoading => _isLoadingBehaviorSubject.stream;

  final _logoutCompleteStreamController = StreamController<void>();
  Stream<void> get logoutComplete => _logoutCompleteStreamController.stream;

  SettingViewModel(this.user, this.userRepository) {
    _onClearAllDataItemTappedStreamController.stream.listen((_) {
      _isLoadingBehaviorSubject.sink.add(true);
      print("### before _clearAllData()");
      _clearAllData().then((_) {
        print("### after  _clearAllData()");
        _logout().then((_) {
          _isLoadingBehaviorSubject.sink.add(false);
          _logoutCompleteStreamController.sink.add(null);
        });
      });
    });
  }

  Future<void> _clearAllData() {
    print("### before _clearFamilyInfo()");
    return _clearFamilyInfo().then((_) {
      print("### after  _clearFamilyInfo()");
      return _clearUserInfo();
    });
  }

  Future<void> _clearFamilyInfo() async {
    QuerySnapshot familyUsersQuerySnapshot = await Firestore.instance
      .collection('families')
      .document(user.familyId)
      .collection('users')
      .getDocuments();
    List<DocumentSnapshot> familyUserSnapshots = familyUsersQuerySnapshot.documents;
    final bool isFamilyContainsOnlyMe = familyUserSnapshots.length == 1 && familyUserSnapshots.first['id'] == user.id;
    if (isFamilyContainsOnlyMe) {
      return Firestore.instance
          .collection('families')
          .document(user.familyId)
          .delete();

    } else {
      return userRepository.exitFamily(user.familyId, user.id);
    }
  }

  Future<void> _clearUserInfo() {
    return userRepository.deleteUser(user.id);
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
    _isLoadingBehaviorSubject.close();
    _logoutCompleteStreamController.close();
  }
}