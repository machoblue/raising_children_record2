
import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserEditViewModel {

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

  UserEditViewModel(User user) {
    _userBehaviorSubject.add(user);
    _bindInputAndOutput();
  }

  void _bindInputAndOutput() {
    CombineLatestStream.combine2(
      _userBehaviorSubject,
      _imageBehaviorSubject,
      (user, image) => image == null ? CachedNetworkImageProvider(user.photoUrl) : FileImage(image),
    )
    .listen((imageProvider) => _userIconImageProviderStreamController.sink.add(imageProvider));

    _onNameChangedStreamController.stream.listen((name) {
      User user = _userBehaviorSubject.value;
      user.name = name;
      _userBehaviorSubject.add(user);
    });

    CombineLatestStream.combine3(
      _onSaveButtonTappedStreamController.stream,
      _userBehaviorSubject,
      _imageBehaviorSubject,
      (_, user, imageFile) => Tuple2<User, File>(user, imageFile),
    )
    .listen(_save);
  }

  void _save(Tuple2<User, File> tuple2) async {
    if (_isLoadingBehaviorSubject.value) {
      return;
    }

    _isLoadingBehaviorSubject.sink.add(true);

    final User user = tuple2.item1;
    final File imageFile = tuple2.item2;

    if (imageFile == null) {
      await _saveUser(user);
      _isLoadingBehaviorSubject.sink.add(false);
      _onSaveCompleteStreamController.sink.add(null);
      return;
    }

    final String userId = user.id;
    StorageReference reference = FirebaseStorage.instance.ref().child(userId);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
//    StorageTaskSnapshot storageTaskSnapshot;
    uploadTask.onComplete.then((storageTaskSnapshot) {
      if (storageTaskSnapshot.error != null) {
        // TODO: error handling
        _isLoadingBehaviorSubject.sink.add(false);
        return;
      }

      storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) async {
        user.photoUrl = downloadUrl;
        await _saveUser(user);
        _isLoadingBehaviorSubject.sink.add(false);
        _onSaveCompleteStreamController.sink.add(null);
      });
    });

  }

  void _saveUser(User user) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await Firestore.instance
      .collection('users')
      .document(user.id)
      .setData(user.map);
    return;
  }

  void dispose() {
    _userIconImageProviderStreamController.close();
    _userBehaviorSubject.close();
    _onSaveCompleteStreamController.close();
    _imageBehaviorSubject.close();
    _onNameChangedStreamController.close();
    _onSaveButtonTappedStreamController.close();
    _isLoadingBehaviorSubject.close();
  }
}