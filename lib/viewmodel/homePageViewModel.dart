
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
  BehaviorSubject<User> userStream;
  BehaviorSubject<Baby> babyStream;

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

  HomePageViewModel(this.dateTime, this.userStream, this.babyStream) {
    _bindInputAndOutput();
  }

  void _bindInputAndOutput() {
    CombineLatestStream.combine2(
      babyStream,
      _initStateStreamController.stream,
      (baby, _) => baby
    ).listen((baby) => _fetchRecords(baby));

    CombineLatestStream.combine3(
      userStream,
      babyStream,
      _editRecordStreamController.stream,
      (user, baby, record) => Tuple3<Record, User, Baby>(record, user, baby),
    ).listen(_navigateToEditRecord);
  }

  void _fetchRecords(Baby baby) async {
    if (baby == null) {
      return;
    }

    final sharedPreference = await SharedPreferences.getInstance();
    final familyId = sharedPreference.getString("familyId");
    final fromDateTime = DateTime(dateTime.year, dateTime.month, dateTime.day).millisecondsSinceEpoch;
    final toDateTime = fromDateTime + 1000 * 60 * 60 * 24;
    print(fromDateTime);
    print(toDateTime);

    final QuerySnapshot recordsQuerySnapshot = await Firestore.instance
        .collection('families')
        .document(familyId)
        .collection('babies')
        .document(baby.id)
        .collection('records')
        .where('dateTime', isGreaterThanOrEqualTo: fromDateTime, isLessThan: toDateTime)
        .getDocuments();


    final List<DocumentSnapshot> recordSnapshotList = recordsQuerySnapshot.documents;
    recordSnapshotList.forEach((snapshot) => print(snapshot['note']));
    final List<Record> records = recordSnapshotList.map((snapshot) => Record.fromSnapshot(snapshot)).toList();
    _recordsStreamController.sink.add(records);
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