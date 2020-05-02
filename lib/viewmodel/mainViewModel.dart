import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class MainViewModel {

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

  MainViewModel() {
    bindInputAndOutput();
  }

  void bindInputAndOutput() {
    _onInitStateStreamController.stream.listen((_) {
      _getBabies();
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

  void _getBabies() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final familyId = sharedPreferences.getString("familyId");
    final QuerySnapshot babiesQuerySnapshot = await Firestore.instance
      .collection('families')
      .document(familyId)
      .collection('babies')
      .getDocuments();
    final List<DocumentSnapshot> babySnapshots = babiesQuerySnapshot.documents;

    if (babySnapshots.length == 0) {
      final String babyId = Uuid().v1();
      final Baby baby = Baby(babyId, "Baby", DateTime.now(),
          'https://firebasestorage.googleapis.com/v0/b/raisingchildrenrecord2.appspot.com/o/icon.png?alt=media&token=ce8d2ab5-98bf-42b3-9090-d3dc1459054a');
      Firestore.instance
          .collection('families')
          .document(familyId)
          .collection('babies')
          .document(babyId)
          .setData(baby.map);
      _babiesBehaviorSubject.sink.add([baby]);
      sharedPreferences.setStringList('babyIds', [babyId]);
      return;
    }

    _babiesBehaviorSubject.sink.add(babySnapshots
        .map((snapshot) => Baby.fromSnapshot(snapshot))
        .where((baby) => baby != null)
        .toList());
  }

  Future<Baby> _pickSelectedBaby(List<Baby> babies) async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final familyId = sharedPreferences.getString("familyId");
    final babyId = sharedPreferences.getString("selectedBabyId");

    if (babies == null) {
      return null;
    }

    if ((babies?.length ?? 0) == 0) {
      final String babyId = Uuid().v1();
      final Baby baby = Baby(babyId, "Baby", DateTime.now(), 'https://firebasestorage.googleapis.com/v0/b/raisingchildrenrecord2.appspot.com/o/icon.png?alt=media&token=ce8d2ab5-98bf-42b3-9090-d3dc1459054a');
      Firestore.instance
          .collection('families')
          .document(familyId)
          .collection('babies')
          .document(babyId)
          .setData(baby.map);
      sharedPreferences.setString('selectedBabyId', babyId);
      sharedPreferences.setStringList('babyIds', [babyId]);
      return baby;
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
    final DocumentSnapshot userSnapshot = await Firestore.instance.collection('users').document(userId).get();

    if (userSnapshot?.exists ?? false) {
      final user = User.fromSnapshot(userSnapshot);
      userBehaviorSubject.sink.add(user);
    }
  }

  dispose() {
    _onInitStateStreamController.close();
    _onTabItemTappedStreamController.close();
    _onBabySelectedStreamController.close();
    _babiesBehaviorSubject.close();
    babyBehaviorSubject.close();
    _babyIconImageProvider.close();
    _selectedIndex.close();
    userBehaviorSubject.close();
  }
}