
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:raisingchildrenrecord2/data/BabyRepository.dart';
import 'package:raisingchildrenrecord2/data/UserRepository.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:raisingchildrenrecord2/shared/collectionReferenceExtension.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsViewModel {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final User user;
  final UserRepository userRepository;
  final BabyRepository babyRepository;

  final _onClearAllDataItemTappedStreamController = StreamController<void>();
  StreamSink<void> get onClearAllDataItemTapped => _onClearAllDataItemTappedStreamController.sink;

  final _onLogoutButtonTappedStreamController = StreamController<void>();
  StreamSink<void> get onLogoutButtonTapped => _onLogoutButtonTappedStreamController.sink;

  final _isLoadingBehaviorSubject = BehaviorSubject.seeded(false);
  Stream<bool> get isLoading => _isLoadingBehaviorSubject.stream;

  final _logoutCompleteStreamController = StreamController<void>();
  Stream<void> get logoutComplete => _logoutCompleteStreamController.stream;

  SettingsViewModel(this.user, this.userRepository, this.babyRepository) {
    _onClearAllDataItemTappedStreamController.stream.listen((_) {
      _isLoadingBehaviorSubject.sink.add(true);
      _clearAllData().then((_) {
        _logout().then((_) {
          _isLoadingBehaviorSubject.sink.add(false);
          _logoutCompleteStreamController.sink.add(null);
        });
      });
    });

    _onLogoutButtonTappedStreamController.stream.listen((_) {
      print("##### _onLogoutButtonTappedStreamController.stream.listen");
      _isLoadingBehaviorSubject.sink.add(true);
      _logout().then((_) {
        print("##### _logout.then");
        _isLoadingBehaviorSubject.sink.add(false);
        _logoutCompleteStreamController.sink.add(null);
      });
    });
  }

  Future<void> _clearAllData() {
    return _clearFamilyInfo().then((_) {
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
      DocumentReference familyReference = Firestore.instance
        .collection('families')
        .document(user.familyId);

      await familyReference.collection('invitationCodes').deleteAll();
      await babyRepository.deleteAllBabies(user.familyId);
      await familyReference.collection('users').deleteAll();
      return;

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
        return;
      });
    });
  }

  void dispose() {
    _onClearAllDataItemTappedStreamController.close();
    _onLogoutButtonTappedStreamController.close();
    _isLoadingBehaviorSubject.close();
    _logoutCompleteStreamController.close();
  }
}