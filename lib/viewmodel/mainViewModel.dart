import 'dart:async';
import 'dart:ui';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';

class MainViewModel {

  // INPUT
  final _onTabItemTappedStreamController = StreamController<int>();
  StreamSink<int> get onTabItemTapped => _onTabItemTappedStreamController.sink;

  final _onBabyButtonTappedStreamController = StreamController<void>();
  StreamSink<void> get onBabyButtonTapped => _onBabyButtonTappedStreamController.sink;

  // OUTPUT
  final _babyIconImageProvider = BehaviorSubject<ImageProvider>.seeded(AssetImage("assets/default_baby_icon.png"));
  Stream<ImageProvider> get babyIconImageProvider => _babyIconImageProvider.stream;

  final _selectedIndex = BehaviorSubject<int>.seeded(0);
  Stream<int> get selectedIndex => _selectedIndex.stream;

  MainViewModel() {
    _onTabItemTappedStreamController.stream.listen((index) {
      _selectedIndex.sink.add(index);
    });

    _onBabyButtonTappedStreamController.stream.listen((_) {
      print("### onTap");
    });
  }

  dispose() {
    _onTabItemTappedStreamController.close();
    _onBabyButtonTappedStreamController.close();
    _babyIconImageProvider.close();
    _selectedIndex.close();
  }
}