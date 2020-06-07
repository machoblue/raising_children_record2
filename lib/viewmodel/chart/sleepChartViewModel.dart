
import 'dart:async';

import 'package:raisingchildrenrecord2/data/recordRepository.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/period.dart';
import 'package:raisingchildrenrecord2/viewmodel/baseViewModel.dart';
import 'package:rxdart/rxdart.dart';

class SleepChartViewModel with ViewModelErrorHandler implements ViewModel {

  final Stream<Baby> babyStream;
  final RecordRepository recordRepository;

  final _currentIndexBehaviorSubject = BehaviorSubject<int>.seeded(0);
  Stream<int> get currentIndex => _currentIndexBehaviorSubject.stream;
  StreamSink<int> get onSelected => _currentIndexBehaviorSubject.sink;

  final _dataStreamController = BehaviorSubject<SleepChartData>.seeded(null);
  Stream<SleepChartData> get data => _dataStreamController.stream;

  final _periodStreamController = StreamController<Period>();
  Stream<Period> get period => _periodStreamController.stream;

  final _summaryStreamController = BehaviorSubject<SleepChartSummary>.seeded(null);
  Stream<SleepChartSummary> get summary => _summaryStreamController.stream;

  SleepChartViewModel(this.babyStream, this.recordRepository) {
  }

  @override
  dispose() {
    super.dispose();
    _currentIndexBehaviorSubject.close();
    _dataStreamController.close();
    _periodStreamController.close();
    _summaryStreamController.close();
  }
}

class SleepChartData {
  final Period period;
  final Map<DateTime, int> dateTimeToMilliseconds;
  SleepChartData(this.period, this.dateTimeToMilliseconds);
}

class SleepTime {
  final DateTime from;
  final DateTime to;
  SleepTime(this.from, this.to);
}

class SleepChartSummary {
  final double totalHour;
  final double averageHour;
  SleepChartSummary(this.totalHour, this.averageHour);
}