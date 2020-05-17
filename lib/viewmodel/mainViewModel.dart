import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:raisingchildrenrecord2/data/babyRepository.dart';
import 'package:raisingchildrenrecord2/data/userRepository.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:raisingchildrenrecord2/viewmodel/baseViewModel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainViewModel with ViewModelErrorHandler implements ViewModel {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  final UserRepository _userRepository;
  final BabyRepository _babyRepository;

  StreamSubscription<List<Baby>> _subscription;

  // INPUT
  final _onInitStateStreamController = StreamController<void>();
  StreamSink<void> get onInitState => _onInitStateStreamController.sink;

  final _onTabItemTappedStreamController = StreamController<int>();
  StreamSink<int> get onTabItemTapped => _onTabItemTappedStreamController.sink;

  final _onBabySelectedStreamController = StreamController<Baby>();
  StreamSink<Baby> get onBabySelected => _onBabySelectedStreamController.sink;

  // OUTPUT
  final _babiesBehaviorSubject = BehaviorSubject<List<Baby>>.seeded(null);
  Stream<List<Baby>> get babies => _babiesBehaviorSubject.stream;

  final babyBehaviorSubject = BehaviorSubject<Baby>.seeded(null);
  Stream<Baby> get baby => babyBehaviorSubject.stream;

  final _babyIconImageProvider = BehaviorSubject<ImageProvider>.seeded(AssetImage("assets/default_baby_icon.png"));
  Stream<ImageProvider> get babyIconImageProvider => _babyIconImageProvider.stream;

  final _selectedIndex = BehaviorSubject<int>.seeded(0);
  Stream<int> get selectedIndex => _selectedIndex.stream;

  final userBehaviorSubject = BehaviorSubject<User>.seeded(null);
  Stream<User> get user => userBehaviorSubject.stream;

  final _logoutCompleteStreamController = StreamController<void>();
  Stream<void> get logoutComplete => _logoutCompleteStreamController.stream;

  MainViewModel(this._userRepository, this._babyRepository) {
    bindInputAndOutput();
  }

  void bindInputAndOutput() {
    _onInitStateStreamController.stream.listen((_) {
      _getBabies()
        .then((babies) => _babiesBehaviorSubject.add(babies))
        .catchError(handleError);

      _observeBabies();

      _getUser();
    });

    babyBehaviorSubject.stream.listen((baby) {
      if (baby == null) {
        return;
      }
      _babyIconImageProvider.sink.add(CachedNetworkImageProvider(baby.photoUrl));
    });

    _onTabItemTappedStreamController.stream.listen((index) {
      _selectedIndex.sink.add(index);
    });

    _onBabySelectedStreamController.stream.listen((baby) async {
      babyBehaviorSubject.sink.add(baby);
      final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.setString('selectedBabyId', baby.id);
    });

    _babiesBehaviorSubject.stream.listen((babies) async {
      final Baby baby = await _pickSelectedBaby(babies);
      babyBehaviorSubject.sink.add(baby);
    });
  }

  Future<List<Baby>> _getBabies() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final String familyId = sharedPreferences.getString('familyId');
    return _babyRepository
      .getBabies(familyId)
      .then((babies) {
        if (babies.isEmpty) {
          Baby baby = Baby.newInstance();
          _babyRepository.createOrUpdateBaby(familyId, baby);
          return [baby];
        }

        return babies;
      });

  }

  void _observeBabies() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final String familyId = sharedPreferences.getString('familyId');
    _subscription = _babyRepository
      .observeBabies(familyId)
      .listen(_babiesBehaviorSubject.sink.add);
  }

  Future<Baby> _pickSelectedBaby(List<Baby> babies) async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final babyId = sharedPreferences.getString("selectedBabyId");

    if (babies == null) {
      return null;
    }

    if ((babies?.length ?? 0) == 0) {
      return null; // This line shouldn't be reached.
    }

    if (babyId == null) {
      final Baby newSelectedBaby = babies.first;
      sharedPreferences.setString('selectedBabyId', newSelectedBaby.id);
      return newSelectedBaby;
    }

    final selectedBabyList = babies.where((baby) => baby.id == babyId);
    if (selectedBabyList.length == 0) {
      final Baby newSelectedBaby = babies.first;
      sharedPreferences.setString('selectedBabyId', newSelectedBaby.id);
      return newSelectedBaby;
    }

    return selectedBabyList.first;
  }

  void _getUser() async {
    final sharedPreference = await SharedPreferences.getInstance();
    final userId = sharedPreference.getString("userId");

    _userRepository
      .getUser(userId)
      .then((user) {
        if (user == null) {
          _logout().then((_) => _logoutCompleteStreamController.sink.add(null));
          return;
        }

        userBehaviorSubject.sink.add(user);
      })
      .catchError(handleError);
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
    super.dispose();
    _onInitStateStreamController.close();
    _onTabItemTappedStreamController.close();
    _onBabySelectedStreamController.close();
    _babiesBehaviorSubject.close();
    babyBehaviorSubject.close();
    _babyIconImageProvider.close();
    _selectedIndex.close();
    userBehaviorSubject.close();
    _logoutCompleteStreamController.close();
    _subscription.cancel();
  }
}