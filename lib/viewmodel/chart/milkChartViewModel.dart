
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raisingchildrenrecord2/data/recordRepository.dart';
import 'package:raisingchildrenrecord2/view/chart/milkChartView.dart';
import 'package:raisingchildrenrecord2/viewmodel/baseViewModel.dart';
import 'package:rxdart/rxdart.dart';

class MilkChartViewModel with ViewModelErrorHandler implements ViewModel {

  final RecordRepository recordRepository;

  BehaviorSubject<int> _currentIndexBehaviorSubject = BehaviorSubject.seeded(0);
  Stream<int> get currentIndex => _currentIndexBehaviorSubject.stream;
  StreamSink<int> get onSelected => _currentIndexBehaviorSubject.sink;

  BehaviorSubject<MilkChartData> _dataBehaviorSubject = BehaviorSubject.seeded(MilkChartData(MilkChartPeriod.oneWeek, MilkChartSubData('ミルク', Colors.yellow, {}), MilkChartSubData('母乳', Colors.pink, {})));
  Stream<MilkChartData> get data => _dataBehaviorSubject.stream;

  MilkChartViewModel(this.recordRepository) {
    _currentIndexBehaviorSubject.listen((index) {
      final yesterdayNow = DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch - 1000 * 60 * 60 * 24);
      final toDateTime = DateTime(yesterdayNow.year, yesterdayNow.month, yesterdayNow.hour);
      final milkChartPeriod = MilkChartPeriodExtension.fromIndex(index);
      final fromDateTime = DateTime.fromMillisecondsSinceEpoch(toDateTime.millisecondsSinceEpoch - 1000 * 60 * 60 * 24 * milkChartPeriod.days);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _currentIndexBehaviorSubject.close();
    _dataBehaviorSubject.close();
  }
}