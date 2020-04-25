
import 'dart:async';

import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
class HomeViewModel {
  Stream<User> userStream;
  Stream<Baby> babyStream;

  // INPUT
  final _addRecordStreamController = StreamController<String>();
  StreamSink<String> get addRecord => _addRecordStreamController.sink;

  // OUTPUT
  final _navigationToAddRecordStreamController = StreamController<Tuple3<String, User, Baby>>();
  Stream<Tuple3<String, User, Baby>> get navigationToAddRecord => _navigationToAddRecordStreamController.stream;

  HomeViewModel(this.userStream, this.babyStream) {
    _bindOutputAndOutput();
  }

  void _bindOutputAndOutput() {
    CombineLatestStream.combine3(
      userStream,
      babyStream,
      _addRecordStreamController.stream,
      (user, baby, recordType) => Tuple3<String, User, Baby>(recordType, user, baby))
    .listen(_navigateToAddRecords);
  }

  void _navigateToAddRecords(Tuple3<String, User, Baby> tuple3) {
    _navigationToAddRecordStreamController.sink.add(tuple3);
  }

  void dispose() {
    _addRecordStreamController.close();
    _navigationToAddRecordStreamController.close();
  }
}