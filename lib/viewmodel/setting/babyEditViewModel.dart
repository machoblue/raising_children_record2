
import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';
import 'package:firebase_storage/firebase_storage.dart';

class BabyEditViewModel {

  final _babyBehaviorSubject = BehaviorSubject<Baby>.seeded(null);

  final StreamController<ImageProvider> _babyIconImageProviderStreamController = StreamController<ImageProvider>();
  Stream<ImageProvider> get babyIconImageProvider => _babyIconImageProviderStreamController.stream;

  Stream<String> get name => _babyBehaviorSubject.stream.map((baby) => baby?.name ?? '');

  Stream<DateTime> get birthday => _babyBehaviorSubject.stream.map((baby) => baby?.birthday ?? DateTime.now());

  final StreamController<void> _onSaveCompleteStreamController = StreamController<void>();
  Stream<void> get onSaveComplete => _onSaveCompleteStreamController.stream;

  final _imageBehaviorSubject = BehaviorSubject<File>.seeded(null);
  StreamSink<File> get onImageSelected => _imageBehaviorSubject.sink;

  final _onNameChangedStreamController = StreamController<String>();
  StreamSink<String> get onNameChanged => _onNameChangedStreamController.sink;

  final _onBirthdayChangedStreamController = StreamController<DateTime>();
  StreamSink<DateTime> get onBirthdayChanged => _onBirthdayChangedStreamController.sink;

  final _onSaveButtonTappedStreamController = StreamController<void>();
  StreamSink<void> get onSaveButtonTapped => _onSaveButtonTappedStreamController.sink;

  final _onDeleteButtonTappedStreamController = StreamController<void>();
  StreamSink<void> get onDeleteButtonTapped => _onDeleteButtonTappedStreamController.sink;

  final _isLoadingBehaviorSubject = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get isLoading => _isLoadingBehaviorSubject.stream;

  BabyEditViewModel(Baby baby) {
    _babyBehaviorSubject.add(baby);
    _bindInputAndOutput();
  }

  void _bindInputAndOutput() {
    _babyBehaviorSubject.listen((baby) => _babyIconImageProviderStreamController.sink.add(CachedNetworkImageProvider(baby.photoUrl)));

    _imageBehaviorSubject.listen((imageFile) => _babyIconImageProviderStreamController.sink.add(FileImage(imageFile)));

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

    CombineLatestStream.combine3(
      _onSaveButtonTappedStreamController.stream,
      _babyBehaviorSubject,
      _imageBehaviorSubject,
      (_, baby, imageFile) => Tuple2<Baby, File>(baby, imageFile),
    )
    .listen(_save);

    _onDeleteButtonTappedStreamController.stream.listen((_) => _delete(_babyBehaviorSubject.value));
  }

  void _save(Tuple2<Baby, File> tuple2) async {
    if (_isLoadingBehaviorSubject.value) {
      return;
    }

    _isLoadingBehaviorSubject.sink.add(true);

    final Baby baby = tuple2.item1;
    final File imageFile = tuple2.item2;

    if (imageFile == null) {
      await _saveBaby(baby);
      _isLoadingBehaviorSubject.sink.add(false);
      _onSaveCompleteStreamController.sink.add(null);
      return;
    }

    final String babyId = baby.id;
    StorageReference reference = FirebaseStorage.instance.ref().child(babyId);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
//    StorageTaskSnapshot storageTaskSnapshot;
    uploadTask.onComplete.then((storageTaskSnapshot) {
      if (storageTaskSnapshot.error != null) {
        // TODO: error handling
        _isLoadingBehaviorSubject.sink.add(false);
        return;
      }

      storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) async {
        baby.photoUrl = downloadUrl;
        await _saveBaby(baby);
        _isLoadingBehaviorSubject.sink.add(false);
        _onSaveCompleteStreamController.sink.add(null);
      });
    });

  }

  void _saveBaby(Baby baby) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final String familyId = sharedPreferences.get('familyId');
    await Firestore.instance
      .collection('families')
      .document(familyId)
      .collection("babies")
      .document(baby.id)
      .setData(baby.map);
    return;
  }

  void _delete(Baby baby) async {
    if (_isLoadingBehaviorSubject.value) {
      return;
    }

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
    _imageBehaviorSubject.close();
    _onNameChangedStreamController.close();
    _onBirthdayChangedStreamController.close();
    _onSaveButtonTappedStreamController.close();
    _onDeleteButtonTappedStreamController.close();
    _isLoadingBehaviorSubject.close();
  }
}