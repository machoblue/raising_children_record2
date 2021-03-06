
import 'dart:async';

import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/viewmodel/baseViewModel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ButtonOrderViewModel with ViewModelErrorHandler, ViewModelInfoMessageHandler implements ViewModel {
  final _onButtonOrderChangedStreamController = StreamController<List<String>>();
  StreamSink<List<String>> get onButtonOrderChanged => _onButtonOrderChangedStreamController.sink;

  final _buttonOrderBehaviorSubject = BehaviorSubject.seeded(List<String>());
  Stream<List<String>> get buttonOrder => _buttonOrderBehaviorSubject.stream;

  final _recordTypesBehaviorSubject = BehaviorSubject.seeded(List<RecordType>());
  Stream<List<RecordType>> get recordTypes => _recordTypesBehaviorSubject.stream;

  ButtonOrderViewModel() {
    SharedPreferences.getInstance().then((sharedPreferences) {
      List<String> orderedRecordTypeStrings = sharedPreferences.getStringList('recordButtonOrder');
      List<String> allRecordTypeStrings = RecordType.values.map((recordType) => recordType.string).toList();
      if (orderedRecordTypeStrings == null) {
        _buttonOrderBehaviorSubject.sink.add(allRecordTypeStrings);
        return;
      }

      List<String> notContainedRecordTypeStrings = allRecordTypeStrings.where((recordTypeString) => !orderedRecordTypeStrings.contains(recordTypeString)).toList();
      _buttonOrderBehaviorSubject.sink.add(orderedRecordTypeStrings + notContainedRecordTypeStrings);
    });

    _onButtonOrderChangedStreamController.stream.listen((buttonOrder) {
      _buttonOrderBehaviorSubject.add(buttonOrder);
      SharedPreferences.getInstance().then((sharedPreferences) {
        sharedPreferences.setStringList('recordButtonOrder', buttonOrder);
      });
    });

    _buttonOrderBehaviorSubject.stream.listen((buttonOrder) {
      List<RecordType> recordTypes = buttonOrder
          .map((recordTypeString) => RecordTypeExtension.fromString(recordTypeString))
          .toList();
      _recordTypesBehaviorSubject.add(recordTypes);
    });
  }

  void dispose() {
    super.dispose();
    _onButtonOrderChangedStreamController.close();
    _buttonOrderBehaviorSubject.close();
    _recordTypesBehaviorSubject.close();
  }
}