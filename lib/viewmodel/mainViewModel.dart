import 'dart:async';
import 'package:rxdart/rxdart.dart';

class MainViewModel {

  // INPUT
  final _onTabItemTappedStreamController = StreamController<int>();
  final _onBabyButtonTappedStreamController = StreamController<void>();
  StreamSink<int> get onTabItemTapped => _onTabItemTappedStreamController.sink;
  StreamSink<void> get onBabyButtonTapped => _onBabyButtonTappedStreamController.sink;

  // OUTPUT
  final _babyIconImageURLStreamController = StreamController<String>();
  Stream<String> get babyIconImageURL => _babyIconImageURLStreamController.stream;

  final _selectedIndex = BehaviorSubject<int>.seeded(0);
  Stream<int> get selectedIndex => _selectedIndex.stream;

  MainViewModel() {
    _onTabItemTappedStreamController.stream.listen((index) {
      _selectedIndex.sink.add(index);
    });

    _onBabyButtonTappedStreamController.stream.listen((_) {
      print("### onTap");
    });
  }

  dispose() {
    _onTabItemTappedStreamController.close();
    _selectedIndex.close();
  }
}