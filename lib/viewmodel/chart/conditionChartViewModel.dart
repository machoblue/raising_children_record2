
import 'dart:async';
import 'dart:math';

import 'package:raisingchildrenrecord2/data/recordRepository.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/viewmodel/baseViewModel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    _monthSubscription = _monthBehaviorSubject.stream.listen((dateTime) {
      _dataBehaviorSubject.add(ConditionChartData(dateTime, {}));
      final startOfThisMonth = DateTime(dateTime.year, dateTime.month, 1);
      final isMondayStart = true;
      final startOfThisWeek = startOfThisMonth.add(Duration(days: isMondayStart ? (- startOfThisMonth.weekday + 1) : (- startOfThisMonth.weekday % 7)));
      final fromDateTime = startOfThisWeek;
      final toDateTime = fromDateTime.add(Duration(days: 42));
      _dataSubscription = _getData(dateTime, fromDateTime, toDateTime).listen((data) {
        _dataBehaviorSubject.add(data);
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

  Stream<ConditionChartData> _getData(DateTime month, DateTime from, DateTime to) {
    return babyStream.asyncMap((baby) {
      return SharedPreferences.getInstance().then((sharedPreferences) {
        final String familyId = sharedPreferences.getString('familyId');
        final List<RecordType> recordTypes = [RecordType.bodyTemperature, RecordType.cough, RecordType.rash, RecordType.vomit, RecordType.poop];
        return recordRepository.getRecords(familyId, baby.id, recordTypesIn: recordTypes, from: from, to: to).then((records) {
          Map<DateTime, ConditionDailyData> dailyDataMap = {};
          records.forEach((record) {
            final recordDate = DateTime(record.dateTime.year, record.dateTime.month, record.dateTime.day);
            final ConditionDailyData dailyData = dailyDataMap[recordDate];

            double bodyTemperature = dailyData?.bodyTemperature ?? 0.0;
            int vomitCount = dailyData?.vomitCount ?? 0;
            int coughCount = dailyData?.coughCount ?? 0;
            int diarrheaCount = dailyData?.diarrheaCount ?? 0;
            int rashCount = dailyData?.rashCount ?? 0;

            switch (record.runtimeType) {
              case BodyTemperatureRecord:
                bodyTemperature = max(bodyTemperature, (record as BodyTemperatureRecord).temperature);
                break;
              case CoughRecord:
                coughCount += 1;
                break;
              case RashRecord:
                rashCount += 1;
                break;
              case VomitRecord:
                vomitCount += 1;
                break;
              case PoopRecord:
                if ((record as PoopRecord).hardness == Hardness.diarrhea) {
                  diarrheaCount += 1;
                }
                break;
              default:
                throw 'This line should not be reached.';
            }
            dailyDataMap[recordDate] = ConditionDailyData(bodyTemperature, vomitCount, coughCount, rashCount, diarrheaCount);
          });
          return ConditionChartData(month, dailyDataMap);
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();

    _monthSubscription.cancel();
    _dataSubscription?.cancel();
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
  final int vomitCount;
  final int coughCount;
  final int rashCount;
  final int diarrheaCount;
  ConditionDailyData(this.bodyTemperature, this.vomitCount, this.coughCount, this.rashCount, this.diarrheaCount);
}