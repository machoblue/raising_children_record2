
import 'dart:async';

import 'package:raisingchildrenrecord2/viewmodel/baseViewModel.dart';
import 'package:rxdart/rxdart.dart';

class MilkChartViewModel with ViewModelErrorHandler implements ViewModel {
  BehaviorSubject<int> _currentIndexBehaviorSubject = BehaviorSubject.seeded(0);
  Stream<int> get currentIndex => _currentIndexBehaviorSubject.stream;
  StreamSink<int> get onSelected => _currentIndexBehaviorSubject.sink;

  @override
  void dispose() {
    super.dispose();
    _currentIndexBehaviorSubject.close();
  }
}