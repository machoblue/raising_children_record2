
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

class HomePageViewModel {
  DateTime dateTime;
  BehaviorSubject<User> userBehaviorSubject;
  BehaviorSubject<Baby> babyBehaviorSubject;

  // Input
  final StreamController _initStateStreamController = StreamController<void>();
  StreamSink<void> get initState => _initStateStreamController.sink;

  final _editRecordStreamController = StreamController<Record>();
  StreamSink<Record> get editRecord => _editRecordStreamController.sink;

  // Output
  final StreamController _recordsStreamController = BehaviorSubject<List<Record>>.seeded([]);
  Stream<List<Record>> get records => _recordsStreamController.stream;

  final _navigationToEditRecordStreamController = StreamController<Tuple3<Record, User, Baby>>();
  Stream<Tuple3<Record, User, Baby>> get navigationToEditRecord => _navigationToEditRecordStreamController.stream;

  HomePageViewModel(this.dateTime, this.userBehaviorSubject, this.babyBehaviorSubject) {
    _bindInputAndOutput();
  }

  void _bindInputAndOutput() {
    CombineLatestStream.combine2(
      babyBehaviorSubject,
      _initStateStreamController.stream,
      (baby, _) => baby
    ).listen((baby) => _fetchRecords(baby));

    _editRecordStreamController.stream.listen((record) {
      _navigateToEditRecord(Tuple3<Record, User, Baby>(record, userBehaviorSubject.value, babyBehaviorSubject.value));
    });
  }

  void _fetchRecords(Baby baby) async {
    if (baby == null) {
      return;
    }

    final sharedPreference = await SharedPreferences.getInstance();
    final familyId = sharedPreference.getString("familyId");
    final fromDateTime = Timestamp.fromMillisecondsSinceEpoch(DateTime(dateTime.year, dateTime.month, dateTime.day).millisecondsSinceEpoch);
    final toDateTime = Timestamp.fromMillisecondsSinceEpoch(fromDateTime.millisecondsSinceEpoch + 1000 * 60 * 60 * 24);
    print(fromDateTime);
    print(toDateTime);

    Firestore.instance
      .collection('families')
      .document(familyId)
      .collection('babies')
      .document(baby.id)
      .collection('records')
      .where('dateTime', isGreaterThanOrEqualTo: fromDateTime, isLessThan: toDateTime)
      .snapshots()
      .listen((recordsQuerySnapshot) {
        final List<DocumentSnapshot> recordSnapshotList = recordsQuerySnapshot.documents;
        recordSnapshotList.forEach((snapshot) => print(snapshot['note']));
        final List<Record> records = recordSnapshotList
            .map((snapshot) => Record.fromSnapshot(snapshot))
            .where((record) => record != null)
            .toList();
        _recordsStreamController.sink.add(records);
      });
  }

  void _navigateToEditRecord(Tuple3<Record, User, Baby> tuple3) {
    _navigationToEditRecordStreamController.sink.add(tuple3);
  }

  void dispose() {
    _initStateStreamController.close();
    _recordsStreamController.close();
    _editRecordStreamController.close();
    _navigationToEditRecordStreamController.close();
  }
}