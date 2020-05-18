
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:raisingchildrenrecord2/data/babyRepository.dart';
import 'package:raisingchildrenrecord2/data/familyRepository.dart';
import 'package:raisingchildrenrecord2/data/userRepository.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:raisingchildrenrecord2/viewmodel/baseViewModel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsViewModel with ViewModelErrorHandler implements ViewModel {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final User user;
  final UserRepository userRepository;
  final BabyRepository babyRepository;
  final FamilyRepository familyRepository;

  final _onClearAllDataItemTappedStreamController = StreamController<void>();
  StreamSink<void> get onClearAllDataItemTapped => _onClearAllDataItemTappedStreamController.sink;

  final _onLogoutButtonTappedStreamController = StreamController<void>();
  StreamSink<void> get onLogoutButtonTapped => _onLogoutButtonTappedStreamController.sink;

  final _isLoadingBehaviorSubject = BehaviorSubject.seeded(false);
  Stream<bool> get isLoading => _isLoadingBehaviorSubject.stream;

  final _logoutCompleteStreamController = StreamController<void>();
  Stream<void> get logoutComplete => _logoutCompleteStreamController.stream;

  SettingsViewModel(this.user, this.userRepository, this.babyRepository, this.familyRepository) {
    _onClearAllDataItemTappedStreamController.stream.listen((_) {
      _isLoadingBehaviorSubject.sink.add(true);
      _clearAllData().then((_) {
        _logout().then((_) {
          _isLoadingBehaviorSubject.sink.add(false);
          _logoutCompleteStreamController.sink.add(null);
        });
      })
      .catchError(_handleError);
    });

    _onLogoutButtonTappedStreamController.stream.listen((_) {
      _isLoadingBehaviorSubject.sink.add(true);
      _logout().then((_) {
        _isLoadingBehaviorSubject.sink.add(false);
        _logoutCompleteStreamController.sink.add(null);
      })
      .catchError(_handleError);
    });
  }

  Future<void> _clearAllData() {
    return _clearFamilyInfo().then((_) {
      return userRepository.deleteUser(user.id);
    });
  }

  Future<void> _clearFamilyInfo() async {
    final String familyId = user.familyId;
    return familyRepository
      .getMembers(familyId)
      .then((users) {
        final bool isFamilyContainsOnlyMe = users.length == 1 && users.first.id == user.id;
        if (!isFamilyContainsOnlyMe) {
          return userRepository
            .exitFamily(user.familyId, user.id);

        } else {
          return familyRepository
            .deleteFamily(user.familyId);
        }
      });
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

  void _handleError(Object error) {
    _isLoadingBehaviorSubject.sink.add(false);
    handleError(error);
  }

  void dispose() {
    super.dispose();
    _onClearAllDataItemTappedStreamController.close();
    _onLogoutButtonTappedStreamController.close();
    _isLoadingBehaviorSubject.close();
    _logoutCompleteStreamController.close();
  }
}