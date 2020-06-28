
import 'dart:async';

import 'package:raisingchildrenrecord2/data/recordRepository.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/viewmodel/baseViewModel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExcretionChartViewModel with ViewModelErrorHandler implements ViewModel {

  Stream<Baby> babyStream;
  RecordRepository recordRepository;

  StreamSubscription _monthSubscription;
  StreamSubscription _dataSubscription;
  StreamSubscription _monthIncrementSubscription;
  StreamSubscription _monthDecrementSubscription;

  final _monthBehaviorSubject = BehaviorSubject<DateTime>.seeded(DateTime.now());
  Stream<DateTime> get month => _monthBehaviorSubject.stream;

  final _monthIncrementStreamController = StreamController<void>();
  StreamSink<void> get monthIncrement => _monthIncrementStreamController.sink;

  final _monthDecrementStreamController = StreamController<void>();
  StreamSink<void> get monthDecrement => _monthDecrementStreamController.sink;

  final _summaryStreamController = StreamController<ExcretionSummary>();
  Stream<ExcretionSummary> get summary => _summaryStreamController.stream;

  final _dataStreamController = StreamController<ExcretionChartData>();
  Stream<ExcretionChartData> get data => _dataStreamController.stream;

  ExcretionChartViewModel(this.babyStream, this.recordRepository) {
    _monthSubscription = _monthBehaviorSubject.stream.listen((dateTime) {
      final startOfThisMonth = DateTime(dateTime.year, dateTime.month, 1);

      _dataStreamController.sink.add(ExcretionChartData(startOfThisMonth, {}));

      final startOfThisWeek = startOfThisMonth.add(Duration(days: - startOfThisMonth.weekday + 1));
      final fromDateTime = startOfThisWeek;
      final toDateTime = fromDateTime.add(Duration(days: 42));
      
      _dataSubscription?.cancel();
      _dataSubscription = _getData(startOfThisMonth, fromDateTime, toDateTime).listen((data) {
        _dataStreamController.sink.add(data);
        _summaryStreamController.sink.add(_summarize(data));
      });
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

  Stream<ExcretionChartData> _getData(DateTime startOfThisMonth, DateTime from, DateTime to) {
    return babyStream.asyncMap((baby) {
      return SharedPreferences.getInstance().then((sharedPreferences) {
        final String familyId = sharedPreferences.getString('familyId');
        return recordRepository.getRecords(familyId, baby.id, recordTypesIn: [RecordType.poop, RecordType.pee], from: from, to: to).then((records) {
          Map<DateTime, ExcretionDailyData> dailyDataMap = {};
          records.forEach((record) {
            final recordDate = DateTime(record.dateTime.year, record.dateTime.month, record.dateTime.day);
            final ExcretionDailyData dailyData = dailyDataMap[recordDate];

            int poopCount = dailyData?.poopCount ?? 0;
            int diarrheaCount = dailyData?.diarrheaCount ?? 0;
            int peeCount = dailyData?.peeCount ?? 0;

            switch (record.runtimeType) {
              case PeeRecord:
                peeCount += 1;
                break;
              case PoopRecord:
                poopCount += 1;
                if ((record as PoopRecord).hardness == Hardness.diarrhea) {
                  diarrheaCount += 1;
                }
                break;
              default:
                throw 'This line should not be reached.';
            }
            dailyDataMap[recordDate] = ExcretionDailyData(poopCount, diarrheaCount, peeCount);
          });
          return ExcretionChartData(startOfThisMonth, dailyDataMap);
        });
      });
    });
  }

  ExcretionSummary _summarize(ExcretionChartData data) {
    final int dataCount = data.dailyDataMap.length;
    if (dataCount == 0) {
      return ExcretionSummary(0, 0);
    }

    int poopTotalCount = 0;
    int peeTotalCount = 0;
    for (MapEntry<DateTime, ExcretionDailyData> entry in data.dailyDataMap.entries) {
      poopTotalCount += entry.value.poopCount;
      peeTotalCount += entry.value.peeCount;
    }
    return ExcretionSummary(poopTotalCount / dataCount, peeTotalCount / dataCount);
  }

  @override
  void dispose() {
    super.dispose();

    _monthSubscription.cancel();
    _dataSubscription?.cancel();
    _monthIncrementSubscription.cancel();
    _monthDecrementSubscription.cancel();

    _monthBehaviorSubject.close();
    _summaryStreamController.close();
    _dataStreamController.close();
    _monthIncrementStreamController.close();
    _monthDecrementStreamController.close();
  }
}

class ExcretionSummary {
  final double poopAverage;
  final double peeAverage;
  ExcretionSummary(this.poopAverage, this.peeAverage);
}

class ExcretionChartData {
  final DateTime month;
  final Map<DateTime, ExcretionDailyData> dailyDataMap;
  ExcretionChartData(this.month, this.dailyDataMap);
}

class ExcretionDailyData {
  int poopCount;
  int diarrheaCount;
  int peeCount;
  ExcretionDailyData(this.poopCount, this.diarrheaCount, this.peeCount);
}