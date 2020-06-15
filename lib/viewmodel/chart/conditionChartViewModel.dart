
import 'dart:async';

import 'package:raisingchildrenrecord2/data/recordRepository.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/viewmodel/baseViewModel.dart';
import 'package:rxdart/rxdart.dart';

class ConditionChartViewModel with ViewModelErrorHandler implements ViewModel {

  final Stream<Baby> babyStream;
  final RecordRepository recordRepository;

  StreamSubscription _monthSubscription;
  StreamSubscription _dataSubscription;
  StreamSubscription _monthIncrementSubscription;
  StreamSubscription _monthDecrementSubscription;

  final _monthBehaviorSubject = BehaviorSubject<DateTime>.seeded(DateTime.now());
  Stream<DateTime> get month => _monthBehaviorSubject.stream;

  final _dataBehaviorSubject = BehaviorSubject<ConditionChartData>.seeded(ConditionChartData(DateTime.now(), {}));
  Stream<ConditionChartData> get data => _dataBehaviorSubject.stream;

  final _monthIncrementStreamController = StreamController<void>();
  StreamSink<void> get monthIncrement => _monthIncrementStreamController.sink;

  final _monthDecrementStreamController = StreamController<void>();
  StreamSink<void> get monthDecrement => _monthDecrementStreamController.sink;

  ConditionChartViewModel(this.babyStream, this.recordRepository) {
    _monthSubscription = _monthBehaviorSubject.stream.listen((month) {
      _dataBehaviorSubject.add(ConditionChartData(month, {})); // TODO: impl
    });

    _monthDecrementSubscription = _monthDecrementStreamController.stream.listen((_) {
      final DateTime currentMonth = _monthBehaviorSubject.value;
      _monthBehaviorSubject.add(DateTime(currentMonth.year, currentMonth.month - 1));
    });

    _monthIncrementSubscription = _monthIncrementStreamController.stream.listen((_) {
      final DateTime currentMonth = _monthBehaviorSubject.value;
      _monthBehaviorSubject.add(DateTime(currentMonth.year, currentMonth.month + 1));
    });
  }

  @override
  void dispose() {
    super.dispose();

    _monthSubscription.cancel();
    _dataSubscription.cancel();
    _monthIncrementSubscription.cancel();
    _monthDecrementSubscription.cancel();

    _monthBehaviorSubject.close();
    _dataBehaviorSubject.close();
    _monthIncrementStreamController.close();
    _monthDecrementStreamController.close();
  }
}

class ConditionChartData {
  final DateTime month;
  final Map<DateTime, ConditionDailyData> dailyDataMap;
  ConditionChartData(this.month, this.dailyDataMap);
}

class ConditionDailyData {
  final double bodyTemperature;
  final bool hasVomited;
  final bool hasCoughed;
  final bool hasRashCameOut;
  final bool hasDiarrhea;
  ConditionDailyData(this.bodyTemperature, this.hasVomited, this.hasCoughed, this.hasRashCameOut, this.hasDiarrhea);
}