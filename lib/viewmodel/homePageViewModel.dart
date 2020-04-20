
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePageViewModel {
  DateTime dateTime;
  BehaviorSubject<Baby> baby;

  // Input
  final StreamController _initStateStreamController = StreamController<void>();
  StreamSink<void> get initState => _initStateStreamController.sink;

  // Output
  final StreamController _recordsStreamController = BehaviorSubject<List<Record>>.seeded([]);
  Stream<List<Record>> get records => _recordsStreamController.stream;

  HomePageViewModel(this.dateTime, this.baby) {
    _bindInputAndOutput();
  }

  void _bindInputAndOutput() {
//    baby.mergeWith([_initStateStreamController.stream]).listen((baby) {
//    baby.withLatestFrom(_initStateStreamController.stream, (baby, _) {
//    _initStateStreamController.stream.withLatestFrom(baby, (_, baby) {
//    CombineLatestStream.combine2(baby, _initStateStreamController.stream, (baby, _) {
    baby.listen((baby) {
      print("### baby.mergeWith");
      _fetchRecords(baby);
    });
  }

  void _fetchRecords(Baby baby) async {
    if (baby == null) {
      return;
    }

    final sharedPreference = await SharedPreferences.getInstance();
//    final userId = sharedPreference.getString("userId");
    final familyId = sharedPreference.getString("familyId");
//    final babyId = sharedPreference.getString("selectedBabyId");
//    print("### userId:$userId, familyId:$familyId, babyId:$babyId");
    final QuerySnapshot recordsQuerySnapshot = await Firestore.instance
        .collection('families')
        .document(familyId)
        .collection('babies')
        .document(baby.id)
        .collection('records')
        .where('dateTime', isGreaterThanOrEqualTo: 0, isLessThan: DateTime.now().millisecondsSinceEpoch + 1000 * 60 * 60 * 24)
        .getDocuments();

    final List<DocumentSnapshot> recordSnapshotList = recordsQuerySnapshot.documents;
    recordSnapshotList.forEach((snapshot) => print(snapshot['note']));
    final List<Record> records = recordSnapshotList.map((snapshot) => Record.fromSnapshot(snapshot)).toList();
    print("### ");
    print(records.length);
    print(records[0].note);
    print(records[0].type);
    _recordsStreamController.sink.add(records);
  }

  void dispose() {
    _initStateStreamController.close();
    _recordsStreamController.close();
  }
}