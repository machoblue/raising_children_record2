
import 'dart:async';
import 'package:raisingchildrenrecord2/data/recordRepository.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:raisingchildrenrecord2/viewmodel/home/record/baseRecordViewModel.dart';

class BodyTemperatureRecordViewModel extends BaseRecordViewModel<BodyTemperatureRecord> {

  Stream<double> get bodyTemperature => recordBehaviorSubject.stream.map((record) => record.temperature ?? 0);
  final StreamController<double> _onBodyTemperatureSelectedStreamController = StreamController<double>();
  StreamSink<double> get onBodyTemperatureSelected => _onBodyTemperatureSelectedStreamController.sink;

  BodyTemperatureRecordViewModel(Record record, User user, Baby baby, RecordRepository recordRepository): super(record, user, baby, recordRepository) {

    _onBodyTemperatureSelectedStreamController.stream.listen((temperature) {
      BodyTemperatureRecord record = recordBehaviorSubject.value;
      record.temperature = temperature;
      recordBehaviorSubject.add(record);
    });
  }

  void dispose() {
    _onBodyTemperatureSelectedStreamController.close();
  }
}