
import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:raisingchildrenrecord2/data/babyRepository.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/storage/storageUtil.dart';
import 'package:raisingchildrenrecord2/viewmodel/baseViewModel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

class BabyEditViewModel with ViewModelErrorHandler implements ViewModel {

  final BabyRepository babyRepository;
  final StorageUtil storageUtil;

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

  BabyEditViewModel(Baby baby, this.babyRepository, this.storageUtil) {
    _babyBehaviorSubject.add(baby ?? Baby.newInstance());
    _bindInputAndOutput();
  }

  void _bindInputAndOutput() {
    CombineLatestStream.combine2(
      _babyBehaviorSubject,
      _imageBehaviorSubject,
      (baby, image) => image == null ? CachedNetworkImageProvider(baby.photoUrl) : FileImage(image),
    )
    .listen((imageProvider) => _babyIconImageProviderStreamController.sink.add(imageProvider));

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
    .listen((tuple2) {
      _isLoadingBehaviorSubject.sink.add(true);
      _save(tuple2).then((_) {
        _isLoadingBehaviorSubject.sink.add(false);
        _onSaveCompleteStreamController.sink.add(null);
      });
    });

    _onDeleteButtonTappedStreamController.stream.listen((_) {
      _isLoadingBehaviorSubject.add(true);
      _delete(_babyBehaviorSubject.value).then((_) {
        _isLoadingBehaviorSubject.add(false);
        _onSaveCompleteStreamController.sink.add(null);
      });
    });
  }

  Future<void> _save(Tuple2<Baby, File> tuple2) async {
    if (_isLoadingBehaviorSubject.value) {
      return;
    }

    final Baby baby = tuple2.item1;
    final File imageFile = tuple2.item2;

    if (imageFile == null) {
      return _saveBaby(baby);
    }

    final String babyId = baby.id;
    return storageUtil
      .uploadFile(imageFile, babyId)
      .then((imageFileUrl) {
        baby.photoUrl = imageFileUrl;
        return _saveBaby(baby);
      })
      .catchError(_handleError);
  }

  Future<void>_saveBaby(Baby baby) async {
    return SharedPreferences.getInstance().then((sharedPreferences) {
      final String familyId = sharedPreferences.get('familyId');
      return babyRepository
        .createOrUpdateBaby(familyId, baby)
        .catchError(_handleError);
    });
  }

  Future<void> _delete(Baby baby) async {
    if (_isLoadingBehaviorSubject.value) {
      return;
    }

    return SharedPreferences.getInstance().then((sharedPreferences) {
      final String familyId = sharedPreferences.get('familyId');
      return babyRepository
        .deleteBaby(familyId, baby.id)
        .catchError(_handleError);
    });
  }

  void _handleError(Object error) {
    _isLoadingBehaviorSubject.add(false);
    handleError(error);
  }

  void dispose() {
    super.dispose();
    _babyIconImageProviderStreamController.close();
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