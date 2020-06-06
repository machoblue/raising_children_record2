
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raisingchildrenrecord2/data/recordRepository.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/view/chart/milkChartView.dart';
import 'package:raisingchildrenrecord2/viewmodel/baseViewModel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

class MilkChartViewModel with ViewModelErrorHandler implements ViewModel {

  final Stream<Baby> babyStream;
  final RecordRepository recordRepository;

  StreamSubscription _subscription;

  final _currentIndexBehaviorSubject = BehaviorSubject<int>.seeded(0);
  Stream<int> get currentIndex => _currentIndexBehaviorSubject.stream;
  StreamSink<int> get onSelected => _currentIndexBehaviorSubject.sink;

  final _dataStreamController = StreamController<MilkChartData>();
  Stream<MilkChartData> get data => _dataStreamController.stream;

  final _periodStreamController = StreamController<Period>();
  Stream<Period> get period => _periodStreamController.stream;

  MilkChartViewModel(this.babyStream, this.recordRepository) {
    _currentIndexBehaviorSubject.listen((index) {
      _getData(index).listen((data) {
        _dataStreamController.sink.add(data);
      });
    });
  }

  Stream<MilkChartData> _getData(int index) {
    final yesterdayNow = DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch - 1000 * 60 * 60 * 24);
    final toDateTime = DateTime(yesterdayNow.year, yesterdayNow.month, yesterdayNow.day);
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
              final newDateTime = DateTime(dateTime.year,dateTime.month, dateTime.day, 12);
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
                final newDateTime = DateTime(dateTime.year,dateTime.month, dateTime.day, 12);
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
    _currentIndexBehaviorSubject.close();
    _dataStreamController.close();
    _subscription?.cancel();
    _periodStreamController.close();
  }
}
