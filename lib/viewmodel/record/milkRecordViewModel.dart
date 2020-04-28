
import 'dart:async';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/viewmodel/record/plainRecordViewModel.dart';

class MilkRecordViewModel extends PlainRecordViewModel<MilkRecord> {

  Stream<int> get amount => recordBehaviorSubject.stream.map((record) => record.amount ?? 0);
  final StreamController<int> _onAmountSelectedStreamController = StreamController<int>();
  StreamSink<int> get onAmountSelected => _onAmountSelectedStreamController.sink;

  MilkRecordViewModel(record, user, baby): super(record, user, baby) {

    _onAmountSelectedStreamController.stream.listen((amount) {
      MilkRecord record = recordBehaviorSubject.value;
      record.amount = amount;
      recordBehaviorSubject.add(record);
    });
  }

  void dispose() {
    _onAmountSelectedStreamController.close();
  }
}