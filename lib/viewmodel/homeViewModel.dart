
import 'dart:async';

import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';
class HomeViewModel {
  BehaviorSubject<User> userBehaviorSubject;
  BehaviorSubject<Baby> babyBehaviorSubject;

  // INPUT
  final _addRecordStreamController = StreamController<RecordType>();
  StreamSink<RecordType> get addRecord => _addRecordStreamController.sink;

  // OUTPUT
  final _navigationToAddRecordStreamController = StreamController<Tuple3<RecordType, User, Baby>>();
  Stream<Tuple3<RecordType, User, Baby>> get navigationToAddRecord => _navigationToAddRecordStreamController.stream;

  final _recordTypesBehaviorSubject = BehaviorSubject.seeded(List<RecordType>());
  Stream<List<RecordType>> get recordTypes => _recordTypesBehaviorSubject.stream;

  HomeViewModel(this.userBehaviorSubject, this.babyBehaviorSubject) {
    _bindOutputAndOutput();
  }

  void _bindOutputAndOutput() {
    _addRecordStreamController.stream.listen((recordType) {
      _navigateToAddRecords(Tuple3<RecordType, User, Baby>(recordType, userBehaviorSubject.value, babyBehaviorSubject.value));
    });

    print("#### bindOutputAndOutput");
    SharedPreferences.getInstance().then((sharedPreferences) {
      print("#### bindOutputAndOutput2");
      final List<RecordType> recordTypes = sharedPreferences.getStringList('recordButtonOrder')?.map((recordTypeString) {
          return RecordTypeExtension.fromString(recordTypeString);
        })?.toList() ?? RecordType.values;
      print("### recordButtonOrder:${sharedPreferences.getStringList('recordButtonOrder')}");
      _recordTypesBehaviorSubject.add(recordTypes);
    });
  }

  void _navigateToAddRecords(Tuple3<RecordType, User, Baby> tuple3) {
    _navigationToAddRecordStreamController.sink.add(tuple3);
  }

  void dispose() {
    _addRecordStreamController.close();
    _navigationToAddRecordStreamController.close();
    _recordTypesBehaviorSubject.close();
  }
}