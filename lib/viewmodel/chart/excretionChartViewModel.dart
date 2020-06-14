
import 'dart:async';

import 'package:raisingchildrenrecord2/data/recordRepository.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/viewmodel/baseViewModel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExcretionChartViewModel with ViewModelErrorHandler implements ViewModel {

  final _dateFormat = DateFormat.E();

  Stream<Baby> babyStream;
  RecordRepository recordRepository;

  StreamSubscription _monthSubscription;
  StreamSubscription _dataSubscription;

  final _monthBehaviorSubject = BehaviorSubject<DateTime>.seeded(DateTime.now());
  Stream<DateTime> get month => _monthBehaviorSubject.stream;

  final _summaryStreamController = StreamController<ExcretionSummary>();
  Stream<ExcretionSummary> get summary => _summaryStreamController.stream;

  final _calendarHeaderStreamController = StreamController<List<String>>();
  Stream<List<String>> get calendarHeader => _calendarHeaderStreamController.stream;

  final _dataStreamController = StreamController<ExcretionChartData>();
  Stream<ExcretionChartData> get data => _dataStreamController.stream;

  ExcretionChartViewModel(this.babyStream, this.recordRepository) {
    _monthSubscription = _monthBehaviorSubject.stream.listen((dateTime) {
      final startOfThisMonth = DateTime(dateTime.year, dateTime.month, 1);
      final startOfThisWeek = startOfThisMonth.add(Duration(days: - startOfThisMonth.weekday + 1));
      final fromDateTime = startOfThisWeek;
      final toDateTime = fromDateTime.add(Duration(days: 42));
      
      _calendarHeaderStreamController.sink.add(_createCalendarHeader(fromDateTime));

      _dataSubscription?.cancel();
      _dataSubscription = _getData(startOfThisMonth, fromDateTime, toDateTime).listen((data) {
        _dataStreamController.sink.add(data);
        _summaryStreamController.sink.add(_summarize(data));
      });
    });
  }

  Stream<ExcretionChartData> _getData(DateTime startOfThisMonth, DateTime from, DateTime to) {
    return babyStream.asyncMap((baby) {
      return SharedPreferences.getInstance().then((sharedPreferences) {
        final String familyId = sharedPreferences.getString('familyId');
        return recordRepository.getRecords(familyId, baby.id, recordTypesIn: [RecordType.poop, RecordType.pee], from: from, to: to).then((records) {
          List<ExcretionDailyData> dailyDataList = _createEmptyDailyDataList(startOfThisMonth, from, to);
          records.forEach((record) {
            final int index = record.dateTime.difference(from).inDays;
            print("### record.dateTime: ${record.dateTime}, from: $from, index: $index");
            if (!(index >= 0 && index <= 42)) {
              return;
            }

            switch (record.runtimeType) {
              case PeeRecord:
                dailyDataList[index].peeCount += 1;
                break;
              case PoopRecord:
                dailyDataList[index].poopCount += 1;
                if ((record as PoopRecord).hardness == Hardness.diarrhea) {
                  dailyDataList[index].diarrheaCount += 1;
                }
                break;
              default:
                throw 'This line should not be reached.';
            }
          });
          return ExcretionChartData(dailyDataList);
        });
      });
    });
  }

  List<ExcretionDailyData> _createEmptyDailyDataList(DateTime startOfThisMonth, DateTime from, DateTime to) {
    List<ExcretionDailyData> dailyDataList = [];
    DateTime tempDateTime = from;
    while (!(tempDateTime.isAfter(to))) {
      dailyDataList.add(ExcretionDailyData(tempDateTime, 0, 0, 0, tempDateTime.month == startOfThisMonth.month));
      tempDateTime = tempDateTime.add(Duration(days: 1));
    }
    return dailyDataList;
  }

  List<String> _createCalendarHeader(DateTime calendarStartDateTime) {
    List<String> header = [];
    DateTime dateTime = calendarStartDateTime;
    for (int i = 0; i < 7; i++) {
      header.add(_dateFormat.format(dateTime));
      dateTime = dateTime.add(Duration(days: 1));
    }
    return header;
  }

  ExcretionSummary _summarize(ExcretionChartData data) {
    int poopTotalCount = 0;
    int peeTotalCount = 0;
    for (ExcretionDailyData dailyData in data.dailyDataList) {
      poopTotalCount += dailyData.poopCount;
      peeTotalCount += dailyData.peeCount;
    }
    int dataCount = data.dailyDataList.length;
    return ExcretionSummary(poopTotalCount / dataCount, peeTotalCount / dataCount);
  }

  @override
  void dispose() {
    super.dispose();
    _monthSubscription.cancel();

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
  int poopCount;
  int diarrheaCount;
  int peeCount;
  final bool isMainMonth;
  ExcretionDailyData(this.dateTime, this.poopCount, this.diarrheaCount, this.peeCount, this.isMainMonth);
}