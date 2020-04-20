import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainViewModel {

  // INPUT
  final _onInitStateStreamController = StreamController<void>();
  StreamSink<void> get onInitState => _onInitStateStreamController.sink;

  final _onTabItemTappedStreamController = StreamController<int>();
  StreamSink<int> get onTabItemTapped => _onTabItemTappedStreamController.sink;

  final _onBabyButtonTappedStreamController = StreamController<void>();
  StreamSink<void> get onBabyButtonTapped => _onBabyButtonTappedStreamController.sink;

  // OUTPUT
  final _babyStreamController = StreamController<Baby>();
  Stream<Baby> get baby => _babyStreamController.stream;

  final _babyIconImageProvider = BehaviorSubject<ImageProvider>.seeded(AssetImage("assets/default_baby_icon.png"));
  Stream<ImageProvider> get babyIconImageProvider => _babyIconImageProvider.stream;

  final _selectedIndex = BehaviorSubject<int>.seeded(0);
  Stream<int> get selectedIndex => _selectedIndex.stream;

  MainViewModel() {
    bindInputAndOutput();
  }

  void bindInputAndOutput() {
    _onInitStateStreamController.stream.listen((_) {
      _getBaby();
    });

    _babyStreamController.stream.listen((baby) => _babyIconImageProvider.sink.add(CachedNetworkImageProvider(baby.photoUrl)));

    _onTabItemTappedStreamController.stream.listen((index) {
      _selectedIndex.sink.add(index);
    });

    _onBabyButtonTappedStreamController.stream.listen((_) {
      print("### onTap");
    });
  }

  void _getBaby() async {
    final sharedPreference = await SharedPreferences.getInstance();
    final userId = sharedPreference.getString("userId");
    final familyId = sharedPreference.getString("familyId");
    final babyId = sharedPreference.getString("selectedBabyId");
    print("### userId:$userId, familyId:$familyId, babyId:$babyId");
    final DocumentSnapshot babySnapshot = await Firestore.instance.collection('families').document(familyId).collection('babies').document(babyId).get();

    if (babySnapshot?.exists ?? false) {
      final baby = Baby.fromSnapshot(babySnapshot);
      _babyStreamController.sink.add(baby);
    }
  }

  dispose() {
    _onInitStateStreamController.close();
    _onTabItemTappedStreamController.close();
    _babyStreamController.close();
    _onBabyButtonTappedStreamController.close();
    _babyIconImageProvider.close();
    _selectedIndex.close();
  }
}