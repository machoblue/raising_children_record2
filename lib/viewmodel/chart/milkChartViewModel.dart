
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

  final _currentIndexBehaviorSubject = BehaviorSubject<int>.seeded(0);
  Stream<int> get currentIndex => _currentIndexBehaviorSubject.stream;
  StreamSink<int> get onSelected => _currentIndexBehaviorSubject.sink;

  final _dataStreamController = StreamController<MilkChartData>();
  Stream<MilkChartData> get data => _dataStreamController.stream;

  MilkChartViewModel(this.babyStream, this.recordRepository) {
    _currentIndexBehaviorSubject.listen((index) {
      print("### ${_currentIndexBehaviorSubject.value}");
      _getData(index).listen((data) {
        _dataStreamController.sink.add(data);
      });
    });
  }

  Stream<MilkChartData> _getData(int index) {
    return babyStream.asyncMap((baby) {
      return SharedPreferences.getInstance().then((sharedPreferences) {
        final familyId = sharedPreferences.getString('familyId');

        final yesterdayNow = DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch - 1000 * 60 * 60 * 24);
        final toDateTime = DateTime(yesterdayNow.year, yesterdayNow.month, yesterdayNow.day);
        final milkChartPeriod = MilkChartPeriodExtension.fromIndex(index);
        final fromDateTime = DateTime.fromMillisecondsSinceEpoch(toDateTime.millisecondsSinceEpoch - 1000 * 60 * 60 * 24 * milkChartPeriod.days);

        return recordRepository.getRecords(familyId, baby.id, recordTypesIn: [RecordType.milk, RecordType.mothersMilk], from: fromDateTime, to: toDateTime).then((records) {
          final List<MilkRecord> milkRecords = records.where((record) => record.runtimeType == MilkRecord).map((record) => record as MilkRecord).toList();
          final MilkChartSubData milkSubData = MilkChartSubData(
            RecordType.milk.localizedName,
            Colors.yellow,
            Map.fromIterable(milkRecords, key: (record) => record.dateTime, value: (record) => record.amount),
          );

          final List<MothersMilkRecord> mothersMilkRecords = records.where((record) => record.runtimeType == MothersMilkRecord).map((record) => record as MothersMilkRecord).toList();
          final MilkChartSubData mothersMilkSubData = MilkChartSubData(
            RecordType.mothersMilk.localizedName,
            Colors.pink,
            Map.fromIterable(mothersMilkRecords, key: (record) => record.dateTime, value: (record) => (record.leftMilliseconds ?? 0) + (record.rightMilliseconds ?? 0))
          );

          return MilkChartData(milkChartPeriod, fromDateTime, toDateTime, milkSubData, mothersMilkSubData);
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _currentIndexBehaviorSubject.close();
    _dataStreamController.close();
    _subscription?.cancel();
  }
}