
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BabyEditViewModel {

  final _babyBehaviorSubject = BehaviorSubject<Baby>.seeded(null);

  Stream<ImageProvider> get babyIconImageProvider => _babyBehaviorSubject.stream.map((baby) {
    return baby == null ? AssetImage('asset/default_baby_icon.png') : CachedNetworkImageProvider(baby.photoUrl);
  });

  Stream<String> get name => _babyBehaviorSubject.stream.map((baby) => baby?.name ?? '');

  Stream<DateTime> get birthday => _babyBehaviorSubject.stream.map((baby) => baby?.birthday ?? DateTime.now());

  final StreamController<void> _onSaveCompleteStreamController = StreamController<void>();
  Stream<void> get onSaveComplete => _onSaveCompleteStreamController.stream;

  final _onNameChangedStreamController = StreamController<String>();
  StreamSink<String> get onNameChanged => _onNameChangedStreamController.sink;

  final _onBirthdayChangedStreamController = StreamController<DateTime>();
  StreamSink<DateTime> get onBirthdayChanged => _onBirthdayChangedStreamController.sink;

  final _onSaveButtonTappedStreamController = StreamController<void>();
  StreamSink<void> get onSaveButtonTapped => _onSaveButtonTappedStreamController.sink;

  final _onDeleteButtonTappedStreamController = StreamController<void>();
  StreamSink<void> get onDeleteButtonTapped => _onDeleteButtonTappedStreamController.sink;

  BabyEditViewModel(Baby baby) {
    _babyBehaviorSubject.add(baby);
    _bindInputAndOutput();
  }

  void _bindInputAndOutput() {
    _onNameChangedStreamController.stream.listen((name) {
      Baby baby = _babyBehaviorSubject.value;
      baby.name = name;
      _babyBehaviorSubject.add(baby);
    });

    _onBirthdayChangedStreamController.stream.listen((birthday) {
      Baby baby = _babyBehaviorSubject.value;
      baby.birthday = birthday;
      _babyBehaviorSubject.add(baby);
    });

    _onSaveButtonTappedStreamController.stream.listen((_) => _save(_babyBehaviorSubject.value));
    _onDeleteButtonTappedStreamController.stream.listen((_) => _delete(_babyBehaviorSubject.value));
  }

  void _save(Baby baby) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final String familyId = sharedPreferences.get('familyId');
    Firestore.instance
        .collection('families')
        .document(familyId)
        .collection("babies")
        .document(baby.id)
        .setData(baby.map);

    _onSaveCompleteStreamController.sink.add(null);
  }

  void _delete(Baby baby) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final String familyId = sharedPreferences.get('familyId');
    Firestore.instance
        .collection('families')
        .document(familyId)
        .collection("babies")
        .document(baby.id)
        .delete();

    _onSaveCompleteStreamController.sink.add(null);
  }

  void dispose() {
    _babyBehaviorSubject.close();
    _onSaveCompleteStreamController.close();
    _onNameChangedStreamController.close();
    _onBirthdayChangedStreamController.close();
    _onSaveButtonTappedStreamController.close();
    _onDeleteButtonTappedStreamController.close();
  }
}