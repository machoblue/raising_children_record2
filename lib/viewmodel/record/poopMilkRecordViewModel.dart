
import 'dart:async';
import 'package:raisingchildrenrecord2/data/recordRepository.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:raisingchildrenrecord2/viewmodel/record/baseRecordViewModel.dart';

class PoopRecordViewModel extends BaseRecordViewModel<PoopRecord> {

  // Input
  final StreamController<Hardness> _onHardnessSelectedStreamController = StreamController<Hardness>();
  StreamSink<Hardness> get onHardnessSelected => _onHardnessSelectedStreamController.sink;

  final StreamController<Amount> _onAmountSelectedStreamController = StreamController<Amount>();
  StreamSink<Amount> get onAmountSelected => _onAmountSelectedStreamController.sink;

  // Output
  Stream<Hardness> get hardness => recordBehaviorSubject.stream.map((record) => record.hardness);
  Stream<Amount> get amount => recordBehaviorSubject.stream.map((record) => record.amount);

  PoopRecordViewModel(Record record, User user, Baby baby, RecordRepository recordRepository): super(record, user, baby, recordRepository) {
    _onHardnessSelectedStreamController.stream.listen((hardness) {
      PoopRecord record = recordBehaviorSubject.value;
      record.hardness = hardness;
      recordBehaviorSubject.add(record);
    });

    _onAmountSelectedStreamController.stream.listen((amount) {
      PoopRecord record = recordBehaviorSubject.value;
      record.amount = amount;
      recordBehaviorSubject.add(record);
    });
  }

  void dispose() {
    _onHardnessSelectedStreamController.close();
    _onAmountSelectedStreamController.close();
  }
}