
import 'dart:async';

import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
class HomeViewModel {
  Stream<User> userStream;
  Stream<Baby> babyStream;

  // INPUT
  final _addRecordStreamController = StreamController<RecordType>();
  StreamSink<RecordType> get addRecord => _addRecordStreamController.sink;

  // OUTPUT
  final _navigationToAddRecordStreamController = StreamController<Tuple3<RecordType, User, Baby>>();
  Stream<Tuple3<RecordType, User, Baby>> get navigationToAddRecord => _navigationToAddRecordStreamController.stream;

  HomeViewModel(this.userStream, this.babyStream) {
    _bindOutputAndOutput();
  }

  void _bindOutputAndOutput() {
    CombineLatestStream.combine3(
      userStream,
      babyStream,
      _addRecordStreamController.stream,
      (user, baby, recordType) => Tuple3<RecordType, User, Baby>(recordType, user, baby))
    .listen(_navigateToAddRecords);
  }

  void _navigateToAddRecords(Tuple3<RecordType, User, Baby> tuple3) {
    _navigationToAddRecordStreamController.sink.add(tuple3);
  }

  void dispose() {
    _addRecordStreamController.close();
    _navigationToAddRecordStreamController.close();
  }
}