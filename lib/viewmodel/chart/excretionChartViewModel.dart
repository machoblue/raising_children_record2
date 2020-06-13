
import 'dart:async';

import 'package:raisingchildrenrecord2/data/recordRepository.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/viewmodel/baseViewModel.dart';
import 'package:rxdart/rxdart.dart';

class ExcretionChartViewModel with ViewModelErrorHandler implements ViewModel {

  Stream<Baby> babyStream;
  RecordRepository recordRepository;

  final _monthBehaviorSubject = BehaviorSubject<DateTime>.seeded(DateTime.now());
  Stream<DateTime> get month => _monthBehaviorSubject.stream;

  final _summaryStreamController = StreamController<ExcretionSummary>();
  Stream<ExcretionSummary> get summary => _summaryStreamController.stream;

  final _calendarHeaderStreamController = StreamController<List<String>>();
  Stream<List<String>> get calendarHeader => _calendarHeaderStreamController.stream;

  final _dataStreamController = StreamController<ExcretionChartData>();
  Stream<ExcretionChartData> get data => _dataStreamController.stream;

  ExcretionChartViewModel(this.babyStream, this.recordRepository) {
  }

  @override
  void dispose() {
    super.dispose();
    _monthBehaviorSubject.close();
    _summaryStreamController.close();
    _calendarHeaderStreamController.close();
    _dataStreamController.close();
  }
}

class ExcretionSummary {
  final double poopAverage;
  final double peeAverage;
  ExcretionSummary(this.poopAverage, this.peeAverage);
}

class ExcretionChartData {
  final List<ExcretionDailyData> dailyDataList;
  ExcretionChartData(this.dailyDataList);
}

class ExcretionDailyData {
  final DateTime dateTime;
  final int poopCount;
  final int diarrheaCount;
  final int peeCount;
  ExcretionDailyData(this.dateTime, this.poopCount, this.diarrheaCount, this.peeCount);
}