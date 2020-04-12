import 'dart:async';

class MainViewModel {

  final _onTabItemTappedStreamController = StreamController<int>();
  final _onBabyButtonTappedStreamController = StreamController<void>();
  StreamSink<int> get onTabItemTapped => _onTabItemTappedStreamController.sink;
  StreamSink<void> get onBabyButtonTapped => _onBabyButtonTappedStreamController.sink;

  final _selectedIndexStreamController = StreamController<int>();
  final _babyIconImageURLStreamController = StreamController<String>();
  Stream<int> get selectedIndex => _selectedIndexStreamController.stream;
  Stream<String> get babyIconImageURL => _babyIconImageURLStreamController.stream;

  MainViewModel() {
    _onTabItemTappedStreamController.stream.listen((index) {
      _selectedIndexStreamController.sink.add(index);
    });

    _onBabyButtonTappedStreamController.stream.listen((_) {
      print("### onTap");
    });
  }

  dispose() {
    _onTabItemTappedStreamController.close();
    _selectedIndexStreamController.close();
  }
}