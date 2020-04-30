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
      _getBaby();
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
  }

  void _getBabies() async {
    final sharedPreference = await SharedPreferences.getInstance();
    final familyId = sharedPreference.getString("familyId");
    final QuerySnapshot babiesQuerySnapshot = await Firestore.instance
      .collection('families')
      .document(familyId)
      .collection('babies')
      .getDocuments();
    final List<DocumentSnapshot> babySnapshots = babiesQuerySnapshot.documents;
    if (babySnapshots.length == 0) {
      // TODO: create baby
    } else {
      _babiesBehaviorSubject.sink.add(babySnapshots
          .map((snapshot) => Baby.fromSnapshot(snapshot))
          .where((baby) => baby != null)
          .toList());
    }
  }

  void _getBaby() async {
    final sharedPreference = await SharedPreferences.getInstance();
    final userId = sharedPreference.getString("userId");
    final familyId = sharedPreference.getString("familyId");
    final babyId = sharedPreference.getString("selectedBabyId");
    print("### userId:$userId, familyId:$familyId, babyId:$babyId");
    final CollectionReference babiesCollectionReference = await Firestore.instance
        .collection('families')
        .document(familyId)
        .collection('babies');

    if (babyId != null) {
      final DocumentSnapshot babySnapshot = await babiesCollectionReference.document(babyId).get();
      if (babySnapshot?.exists ?? false) {
        babyBehaviorSubject.sink.add(Baby.fromSnapshot(babySnapshot));
      } else {
        _createNewBabyAndSink(babiesCollectionReference);
      }

    } else {
      final QuerySnapshot babiesQuerySnapshot = await babiesCollectionReference.getDocuments();
      final List<DocumentSnapshot> babySnapshots = babiesQuerySnapshot.documents;
      if (babySnapshots.length == 0) {
        _createNewBabyAndSink(babiesCollectionReference);
      } else {
        babyBehaviorSubject.sink.add(Baby.fromSnapshot(babySnapshots.first));
        final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        await sharedPreferences.setString('selectedBabyId', babyId);
        await sharedPreferences.setStringList('babyIds', babySnapshots.map((snapshot) => snapshot['id'] as String).where((id) => id != null).toList());
      }
    }
  }

  void _createNewBabyAndSink(CollectionReference babiesCollectionReference) async {
    final String babyId = Uuid().v1();
    final Baby baby = Baby(babyId, "Baby", DateTime.now(), 'https://firebasestorage.googleapis.com/v0/b/raisingchildrenrecord2.appspot.com/o/icon.png?alt=media&token=ce8d2ab5-98bf-42b3-9090-d3dc1459054a');
    babiesCollectionReference.document(babyId).setData(baby.map);
    babyBehaviorSubject.sink.add(baby);
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString('selectedBabyId', babyId);
    await sharedPreferences.setStringList('babyIds', [babyId]);
  }

  void _getUser() async {
    final sharedPreference = await SharedPreferences.getInstance();
    final userId = sharedPreference.getString("userId");
    final DocumentSnapshot userSnapshot = await Firestore.instance.collection('users').document(userId).get();

    if (userSnapshot?.exists ?? false) {
      final user = User.fromSnapshot(userSnapshot);
      print("### user: ${user.id}");
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