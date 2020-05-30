
import 'dart:async';
import 'package:raisingchildrenrecord2/data/recordRepository.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:raisingchildrenrecord2/viewmodel/record/baseRecordViewModel.dart';

class WeightRecordViewModel extends BaseRecordViewModel<WeightRecord> {

  Stream<double> get weight => recordBehaviorSubject.stream.map((record) => record.weight ?? 0);
  final StreamController<double> _onWeightSelectedStreamController = StreamController<double>();
  StreamSink<double> get onWeightSelected => _onWeightSelectedStreamController.sink;

  WeightRecordViewModel(Record record, User user, Baby baby, RecordRepository recordRepository): super(record, user, baby, recordRepository) {

    _onWeightSelectedStreamController.stream.listen((weight) {
      WeightRecord record = recordBehaviorSubject.value;
      record.weight = weight;
      recordBehaviorSubject.add(record);
    });
  }

  void dispose() {
    _onWeightSelectedStreamController.close();
  }
}