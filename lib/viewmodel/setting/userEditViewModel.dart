
import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:raisingchildrenrecord2/data/userRepository.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:raisingchildrenrecord2/storage/storageUtil.dart';
import 'package:raisingchildrenrecord2/viewmodel/baseViewModel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

class UserEditViewModel with ViewModelErrorHandler, ViewModelInfoMessageHandler implements ViewModel {

  final UserRepository userRepository;
  final StorageUtil storageUtil;

  StreamSubscription _userAndImageSubscription;
  StreamSubscription _onNameChangedSubscription;
  StreamSubscription _onSaveButtonTappedSubscription;

  final _userBehaviorSubject = BehaviorSubject<User>.seeded(null);

  final StreamController<ImageProvider> _userIconImageProviderStreamController = StreamController<ImageProvider>();
  Stream<ImageProvider> get userIconImageProvider => _userIconImageProviderStreamController.stream;

  Stream<String> get name => _userBehaviorSubject.stream.map((user) => user?.name ?? '');

  final StreamController<void> _onSaveCompleteStreamController = StreamController<void>();
  Stream<void> get onSaveComplete => _onSaveCompleteStreamController.stream;

  final _imageBehaviorSubject = BehaviorSubject<File>.seeded(null);
  StreamSink<File> get onImageSelected => _imageBehaviorSubject.sink;

  final _onNameChangedStreamController = StreamController<String>();
  StreamSink<String> get onNameChanged => _onNameChangedStreamController.sink;

  final _onSaveButtonTappedStreamController = StreamController<void>();
  StreamSink<void> get onSaveButtonTapped => _onSaveButtonTappedStreamController.sink;

  final _isLoadingBehaviorSubject = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get isLoading => _isLoadingBehaviorSubject.stream;

  UserEditViewModel(User user, this.userRepository, this.storageUtil) {
    _userBehaviorSubject.add(user);
    _bindInputAndOutput();
  }

  void _bindInputAndOutput() {
    _userAndImageSubscription = CombineLatestStream.combine2(
      _userBehaviorSubject,
      _imageBehaviorSubject,
      (user, image) => image != null
          ? FileImage(image)
          : user.photoUrl != null
            ? CachedNetworkImageProvider(user.photoUrl)
            : AssetImage("assets/default_baby_icon.png"),
    )
    .listen((imageProvider) => _userIconImageProviderStreamController.sink.add(imageProvider));

    _onNameChangedSubscription = _onNameChangedStreamController.stream.listen((name) {
      User user = _userBehaviorSubject.value;
      user.name = name;
      _userBehaviorSubject.add(user);
    });

    _onSaveButtonTappedSubscription = CombineLatestStream.combine3(
      _onSaveButtonTappedStreamController.stream,
      _userBehaviorSubject,
      _imageBehaviorSubject,
      (_, user, imageFile) => Tuple2<User, File>(user, imageFile),
    )
    .listen((tuple2) {
      if (_isLoadingBehaviorSubject.value) {
        return;
      }

      _isLoadingBehaviorSubject.sink.add(true);
      _save(tuple2).then((_) {
        _isLoadingBehaviorSubject.sink.add(false);
        _onSaveCompleteStreamController.sink.add(null);
      });
    });
  }

  Future<void>_save(Tuple2<User, File> tuple2) async {
    final User user = tuple2.item1;
    final File imageFile = tuple2.item2;

    if (imageFile == null) {
      return _saveUser(user);
    }

    final String userId = user.id;
    return storageUtil
      .uploadFile(imageFile, userId)
      .then((imageFileUrl) {
        user.photoUrl = imageFileUrl;
        return _saveUser(user);
      });
  }

  Future<void>_saveUser(User user) async {
    return userRepository
      .createOrUpdateUser(user)
      .catchError(_handleError);
  }

  void _handleError(Object error) {
    _isLoadingBehaviorSubject.sink.add(false);
    handleError(error);
  }

  void dispose() {
    super.dispose();

    _userAndImageSubscription.cancel();
    _onNameChangedSubscription.cancel();
    _onSaveButtonTappedSubscription.cancel();

    _userIconImageProviderStreamController.close();
    _userBehaviorSubject.close();
    _onSaveCompleteStreamController.close();
    _imageBehaviorSubject.close();
    _onNameChangedStreamController.close();
    _onSaveButtonTappedStreamController.close();
    _isLoadingBehaviorSubject.close();
  }
}