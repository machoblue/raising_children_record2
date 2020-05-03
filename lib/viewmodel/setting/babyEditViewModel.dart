
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:rxdart/rxdart.dart';

class BabyEditViewModel {

  final _babyBehaviorSubject = BehaviorSubject<Baby>.seeded(null);

  Stream<ImageProvider> get babyIconImageProvider => _babyBehaviorSubject.stream.map((baby) {
    return baby == null ? AssetImage('asset/default_baby_icon.png') : CachedNetworkImageProvider(baby.photoUrl);
  });

  Stream<String> get name => _babyBehaviorSubject.stream.map((baby) => baby?.name ?? '');

  Stream<DateTime> get birthday => _babyBehaviorSubject.stream.map((baby) => baby?.birthday ?? DateTime.now());

  final _onNameChangedStreamController = StreamController<String>();
  StreamSink<String> get onNameChanged => _onNameChangedStreamController.sink;

  final _onBirthdayChangedStreamController = StreamController<DateTime>();
  StreamSink<DateTime> get onBirthdayChanged => _onBirthdayChangedStreamController.sink;

  final _onSaveButtonTappedStreamController = StreamController<void>();
  StreamSink<void> get onSaveButtonTapped => _onSaveButtonTappedStreamController.sink;

  final _onDeleteButtonTappedStreamController = StreamController<void>();
  StreamSink<void> get onDeleteButtonTapped => _onDeleteButtonTappedStreamController.sink;

  BabyEditViewModel(Baby baby) {
    print("### BabyEditViewModel baby.name: ${baby.name}");
    _babyBehaviorSubject.add(baby);
  }

  void dispose() {
    _babyBehaviorSubject.close();
    _onNameChangedStreamController.close();
    _onBirthdayChangedStreamController.close();
    _onSaveButtonTappedStreamController.close();
    _onDeleteButtonTappedStreamController.close();
  }
}