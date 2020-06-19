
import 'dart:async';

import 'package:raisingchildrenrecord2/data/recordRepository.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/viewmodel/baseViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/chart/growthStatisticsScheme.dart';
import 'package:rxdart/rxdart.dart';

class GrowthChartViewModel with ViewModelErrorHandler implements ViewModel {

  Stream<Baby> babyStream;
  RecordRepository recordRepository;

  StreamSubscription _currentIndexSubscription;
  StreamSubscription _babySubscription;

  final _currentIndexBehaviorSubject = BehaviorSubject<int>.seeded(0);
  Stream<int> get currentIndex => _currentIndexBehaviorSubject.stream;
  StreamSink<int> get onSelected => _currentIndexBehaviorSubject.sink;

  final _periodBehaviorSubject = BehaviorSubject<GrowthPeriod>.seeded(GrowthPeriod.oneYear);
  Stream<GrowthPeriod> get period => _periodBehaviorSubject.stream;

  final _statisticsDataStreamController = StreamController<GrowthStatisticsData>();
  Stream<GrowthStatisticsData> get statisticsData => _statisticsDataStreamController.stream;

  final _growthChartDataStreamController = StreamController<GrowthChartData>();
  Stream<GrowthChartData> get growthChartData => _growthChartDataStreamController.stream;

  GrowthChartViewModel(this.babyStream, this.recordRepository) {
    _babySubscription = babyStream.listen((baby) {
      final growthStatisticsScheme = MHLWGrowthStatisticsScheme();
      final growthStatisticsSet = baby.sex == Sex.female ? growthStatisticsScheme.femaleSet : growthStatisticsScheme.maleSet;
    });
  }

  @override
  void dispose() {
    super.dispose();

    _currentIndexSubscription.cancel();
    _babySubscription.cancel();

    _currentIndexBehaviorSubject.close();
    _periodBehaviorSubject.close();
    _statisticsDataStreamController.close();
    _growthChartDataStreamController.close();
  }
}

enum GrowthPeriod {
  oneYear,
  threeYears,
  sixYears,
}

extension GrowthPeriodExtension on GrowthPeriod {
  int get months {
    switch (this) {
      case GrowthPeriod.oneYear:
        return 12;
      case GrowthPeriod.threeYears:
        return 36;
      case GrowthPeriod.sixYears:
        return 72;
      default:
        throw 'This line should not be reached.';
    }
  }

  static GrowthPeriod fromIndex(int index) {
    switch (index) {
      case 0:
        return GrowthPeriod.oneYear;
      case 1:
        return GrowthPeriod.threeYears;
      case 2:
        return GrowthPeriod.sixYears;
      default:
        throw 'This line should not be reached.';
    }
  }
}

class GrowthChartData {

}

class GrowthStatisticsData {

}