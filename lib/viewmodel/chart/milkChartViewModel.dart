
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raisingchildrenrecord2/data/recordRepository.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/view/chart/milkChartView.dart';
import 'package:raisingchildrenrecord2/viewmodel/baseViewModel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MilkChartViewModel with ViewModelErrorHandler implements ViewModel {

  final Stream<Baby> babyStream;
  final RecordRepository recordRepository;

  StreamSubscription _subscription;

  BehaviorSubject<int> _currentIndexBehaviorSubject = BehaviorSubject.seeded(0);
  Stream<int> get currentIndex => _currentIndexBehaviorSubject.stream;
  StreamSink<int> get onSelected => _currentIndexBehaviorSubject.sink;

  BehaviorSubject<MilkChartData> _dataBehaviorSubject = BehaviorSubject.seeded(MilkChartData(MilkChartPeriod.oneWeek, MilkChartSubData('ミルク', Colors.yellow, {}), MilkChartSubData('母乳', Colors.pink, {})));
  Stream<MilkChartData> get data => _dataBehaviorSubject.stream;

  MilkChartViewModel(this.babyStream, this.recordRepository) {
    _currentIndexBehaviorSubject.listen((index) {
      _getData(index).then((data) {
        _dataBehaviorSubject.sink.add(data);
      });
    });
  }

  Future<MilkChartData> _getData(int index) {
    SharedPreferences.getInstance().then((sharedPreferences) {
      final String familyId = sharedPreferences.getString("familyId");

      _subscription = babyStream.listen((baby) {
        final yesterdayNow = DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch - 1000 * 60 * 60 * 24);
        final toDateTime = DateTime(yesterdayNow.year, yesterdayNow.month, yesterdayNow.hour);
        final milkChartPeriod = MilkChartPeriodExtension.fromIndex(index);
        final fromDateTime = DateTime.fromMillisecondsSinceEpoch(toDateTime.millisecondsSinceEpoch - 1000 * 60 * 60 * 24 * milkChartPeriod.days);
        recordRepository.getRecords(familyId, baby.id, recordTypesIn: [RecordType.milk, RecordType.mothersMilk], from: fromDateTime, to: toDateTime).then((records) {
          final List<MilkRecord> milkRecords = records.where((record) => record.runtimeType == MilkRecord).toList();
          final MilkChartSubData milkSubData = MilkChartSubData(
            RecordType.milk.localizedName,
            Colors.yellow,
            Map.fromIterable(milkRecords, key: (record) => record.dateTime, value: (record) => record.amount),
          );
        }).catchError(handleError);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _currentIndexBehaviorSubject.close();
    _dataBehaviorSubject.close();
    _subscription.cancel();
  }
}