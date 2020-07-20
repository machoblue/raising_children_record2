
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raisingchildrenrecord2/data/recordRepository.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/period.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/viewmodel/baseViewModel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:raisingchildrenrecord2/shared/listExtension.dart';

class SleepChartViewModel with ViewModelErrorHandler, ViewModelInfoMessageHandler implements ViewModel {

  final Stream<Baby> babyStream;
  final RecordRepository recordRepository;

  StreamSubscription _currentIndexSubscription;
  StreamSubscription _babySubscription;
  StreamSubscription _dataSubscription;

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
    _currentIndexSubscription = _currentIndexBehaviorSubject.stream.listen((index) {
      _babySubscription?.cancel();
      _babySubscription = _getData(index).listen((data) {
        _dataStreamController.sink.add(data);
      });
      print("### _babySubscription: $_babySubscription");
    });

    _dataSubscription = _dataStreamController.stream.listen((data) {
      if (data == null) {
        return;
      }
      final double total = data.dateTimeToMilliseconds.entries.fold(0, (previousValue, entry) => previousValue + entry.value);
      final double totalHour = total / (1000 * 60 * 60);
      final double average = total / data.period.type.days;
      final double averageHour = average / (1000 * 60 * 60);
      _summaryStreamController.sink.add(SleepChartSummary(totalHour, averageHour));
    });
  }

  Stream<SleepChartData> _getData(int index) {
    final now = DateTime.now();
    final toDateTime = DateTime(now.year, now.month, now.day);
    final milkChartPeriod = PeriodTypeExtension.fromIndex(index);
    final fromDateTime = DateTime.fromMillisecondsSinceEpoch(toDateTime.millisecondsSinceEpoch - 1000 * 60 * 60 * 24 * milkChartPeriod.days);
    final period = Period(fromDateTime, toDateTime, milkChartPeriod);
    _periodStreamController.sink.add(period);

    return babyStream.asyncMap((baby) {
      return SharedPreferences.getInstance().then((sharedPreferences) {
        final String familyId = sharedPreferences.getString('familyId');
        return recordRepository.getRecords(familyId, baby.id, recordTypesIn: [RecordType.sleep, RecordType.awake], from: fromDateTime, to: toDateTime).then((records) {
          if (records == null || records.length == 0) {
            return SleepChartData(period, {}, Colors.blueAccent);
          }

          List<Record> sortedRecords = records.sorted((record1, record2) => record1.dateTime.compareTo(record2.dateTime));

          // Recordのリストを睡眠した期間のリストに変換
          List<SleepTime> sleepTimeList = [];
          DateTime sleepDateTime = sortedRecords.first.runtimeType == AwakeRecord ? fromDateTime : null;
          for (Record record in sortedRecords) {
            switch (record.runtimeType) {
              case SleepRecord:
                if (sleepDateTime == null) {
                  sleepDateTime = record.dateTime;
                }
                break;
              case AwakeRecord:
                if (sleepDateTime == null) {
                  continue;
                }
                sleepTimeList.add(SleepTime(sleepDateTime, record.dateTime));
                sleepDateTime = null;
                break;
            }
          }

          // 日を跨いだものはバラバラにする
          List<SleepTime> sleepTimeList2 = [];
          for (SleepTime sleepTime in sleepTimeList) {
            final DateTime from = sleepTime.from;
            final DateTime to = sleepTime.to;
            if (from.year == to.year && from.month == to.month && from.day == to.day) {
              sleepTimeList2.add(sleepTime);
              continue;
            }

            DateTime tempFrom = from;
            DateTime tempTo = DateTime(from.year, from.month, from.day + 1);
            while(tempTo.isBefore(to)) {
              sleepTimeList2.add(SleepTime(tempFrom, tempTo));
              tempFrom = tempTo;
              tempTo = tempTo.add(Duration(days: 1));
            }
            sleepTimeList2.add(SleepTime(tempFrom, to));
          }

          // 最後に日毎に合算する
          Map<DateTime, int> dateTimeToMilliseconds = {};
          for (SleepTime sleepTime in sleepTimeList2) {
            DateTime dateTime = DateTime(sleepTime.from.year, sleepTime.from.month, sleepTime.from.day);
            dateTimeToMilliseconds[dateTime] = (dateTimeToMilliseconds[dateTime] ?? 0) + (sleepTime.to.millisecondsSinceEpoch - sleepTime.from.millisecondsSinceEpoch);
          }

          return SleepChartData(period, dateTimeToMilliseconds, Colors.blueAccent);
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();

    _dataSubscription.cancel();
    _babySubscription.cancel();
    _currentIndexSubscription.cancel();

    _currentIndexBehaviorSubject.close();
    _dataStreamController.close();
    _periodStreamController.close();
    _summaryStreamController.close();
  }
}

class SleepChartData {
  final Period period;
  final Map<DateTime, int> dateTimeToMilliseconds;
  final Color color;
  SleepChartData(this.period, this.dateTimeToMilliseconds, this.color);
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