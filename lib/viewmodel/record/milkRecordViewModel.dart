
import 'dart:async';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/viewmodel/record/plainRecordViewModel.dart';

class MilkRecordViewModel extends PlainRecordViewModel {

  Stream<int> get amount => recordBehaviorSubject.stream.map((record) => (record as MilkRecord)?.amount ?? 0);
  final StreamController<int> _onAmountSelectedStreamController = StreamController<int>();
  StreamSink<int> get onAmountSelected => _onAmountSelectedStreamController.sink;

  MilkRecordViewModel(record, user, baby): super(record, user, baby) {

    _onAmountSelectedStreamController.stream.listen((amount) {
      Record record = recordBehaviorSubject.value;
      (record as MilkRecord)?.amount = amount;
      recordBehaviorSubject.add(record);
    });
  }

  void dispose() {
    _onAmountSelectedStreamController.close();
  }
}