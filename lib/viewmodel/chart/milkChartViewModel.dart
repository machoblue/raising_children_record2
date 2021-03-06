
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raisingchildrenrecord2/data/recordRepository.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/period.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/view/chart/milkChartView.dart';
import 'package:raisingchildrenrecord2/viewmodel/baseViewModel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

class MilkChartViewModel with ViewModelErrorHandler, ViewModelInfoMessageHandler implements ViewModel {

  final Stream<Baby> babyStream;
  final RecordRepository recordRepository;

  StreamSubscription _currentIndexSubscription;
  StreamSubscription _babySubscription;
  StreamSubscription _dataSubscription;

  final _currentIndexBehaviorSubject = BehaviorSubject<int>.seeded(0);
  Stream<int> get currentIndex => _currentIndexBehaviorSubject.stream;
  StreamSink<int> get onSelected => _currentIndexBehaviorSubject.sink;

  final _dataStreamController = BehaviorSubject<MilkChartData>.seeded(null);
  Stream<MilkChartData> get data => _dataStreamController.stream;

  final _periodStreamController = StreamController<Period>();
  Stream<Period> get period => _periodStreamController.stream;

  final _milkChartSummaryStreamController = BehaviorSubject<MilkChartSummary>.seeded(null);
  Stream<MilkChartSummary> get milkChartSummary => _milkChartSummaryStreamController.stream;

  MilkChartViewModel(this.babyStream, this.recordRepository) {
    _currentIndexSubscription = _currentIndexBehaviorSubject.listen((index) {
      _babySubscription?.cancel();
      _babySubscription = _getData(index).listen((data) {
        _dataStreamController.sink.add(data);
      });
    });

    _dataSubscription = _dataStreamController.stream.listen((data) {
      if (data == null) {
        return;
      }
      final int milkSum = data.data1.dateToValue.entries.fold<int>(0, (previousValue, entry) => previousValue + entry.value);
      final int milkAverage = (milkSum / data.period.type.days).round();
      final int mothersMilkSumMilliseconds = data.data2.dateToValue.entries.fold<int>(0, (previousValue, entry) => previousValue + entry.value);
      final double mothersMilkSum = mothersMilkSumMilliseconds / (1000 * 60 * 60);
      final double mothersMilkAverage = mothersMilkSum / data.period.type.days;
      _milkChartSummaryStreamController.sink.add(MilkChartSummary(milkSum, milkAverage, mothersMilkSum, mothersMilkAverage));
    });
  }

  Stream<MilkChartData> _getData(int index) {
    final now = DateTime.now();
    final toDateTime = DateTime(now.year, now.month, now.day);
    final milkChartPeriod = PeriodTypeExtension.fromIndex(index);
    final fromDateTime = DateTime.fromMillisecondsSinceEpoch(toDateTime.millisecondsSinceEpoch - 1000 * 60 * 60 * 24 * milkChartPeriod.days);
    final period = Period(fromDateTime, toDateTime, milkChartPeriod);
    _periodStreamController.sink.add(period);

    return babyStream.asyncMap((baby) {
      return SharedPreferences.getInstance().then((sharedPreferences) {
        final familyId = sharedPreferences.getString('familyId');

        return recordRepository.getRecords(familyId, baby.id, recordTypesIn: [RecordType.milk, RecordType.mothersMilk], from: fromDateTime, to: toDateTime).then((records) {
          final List<Tuple2<DateTime, int>> milkTuples = records
            .where((record) => record.runtimeType == MilkRecord)
            .map((record) => record as MilkRecord)
            .map((milkRecord) {
              final dateTime = milkRecord.dateTime;
              final newDateTime = DateTime(dateTime.year,dateTime.month, dateTime.day);
              return Tuple2(newDateTime, milkRecord.amount);
            })
            .toList();
          Map<DateTime, int> milkMap = Map();
          for (var tuple in milkTuples) {
            milkMap[tuple.item1] = (milkMap[tuple.item1] ?? 0) + tuple.item2;
          }
          final MilkChartSubData milkSubData = MilkChartSubData(
            RecordType.milk.localizedName,
            Colors.yellow,
            milkMap,
          );

          final List<Tuple2<DateTime, int>> mothersMilkTuples= records
              .where((record) => record.runtimeType == MothersMilkRecord)
              .map((record) => record as MothersMilkRecord)
              .map((mothersMilkRecord) {
                final dateTime = mothersMilkRecord.dateTime;
                final newDateTime = DateTime(dateTime.year,dateTime.month, dateTime.day);
                return Tuple2(newDateTime, (mothersMilkRecord.leftMilliseconds ?? 0) + (mothersMilkRecord.rightMilliseconds ?? 0));
              })
              .toList();
          Map<DateTime, int> mothersMilkMap = Map();
          for (var tuple in mothersMilkTuples) {
            mothersMilkMap[tuple.item1] = (mothersMilkMap[tuple.item1] ?? 0) + tuple.item2;
          }
          final MilkChartSubData mothersMilkSubData = MilkChartSubData(
            RecordType.mothersMilk.localizedName,
            Colors.pink,
            mothersMilkMap,
          );

          return MilkChartData(period, milkSubData, mothersMilkSubData);
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();

    _babySubscription.cancel();
    _currentIndexSubscription.cancel();
    _dataSubscription.cancel();

    _currentIndexBehaviorSubject.close();
    _dataStreamController.close();
    _periodStreamController.close();
    _milkChartSummaryStreamController.close();
  }
}
