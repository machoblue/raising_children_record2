
import 'dart:async';

import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:raisingchildrenrecord2/viewmodel/baseViewModel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';
class HomeViewModel with ViewModelErrorHandler implements ViewModel {
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
      final tuple3 = Tuple3<RecordType, User, Baby>(recordType, userBehaviorSubject.value, babyBehaviorSubject.value);
      _navigationToAddRecordStreamController.sink.add(tuple3);
    });

    _getRecordTypes().then((recordTypes) {
      _recordTypesBehaviorSubject.add(recordTypes);
    });
  }

  Future<List<RecordType>> _getRecordTypes() {
    return SharedPreferences.getInstance().then((sharedPreferences) {
      final List<String> orderedRecordTypeStrings = sharedPreferences.getStringList('recordButtonOrder');
      if (orderedRecordTypeStrings == null) {
        return RecordType.values;
      }

      final List<RecordType> notOrderedRecordType = RecordType.values
          .where((recordType) => !orderedRecordTypeStrings.contains(recordType.string))
          .toList();

      final List<RecordType> orderedRecordType = orderedRecordTypeStrings
        .map((recordTypeString) => RecordTypeExtension.fromString(recordTypeString))
        .toList();

      return orderedRecordType + notOrderedRecordType;
    });
  }

  void dispose() {
    super.dispose();
    _addRecordStreamController.close();
    _navigationToAddRecordStreamController.close();
    _recordTypesBehaviorSubject.close();
  }
}