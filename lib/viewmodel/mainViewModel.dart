import 'dart:async';

class MainViewModel {

  final _onTabItemTappedStreamController = StreamController<int>();
  StreamSink<int> get onTabItemTapped => _onTabItemTappedStreamController.sink;

  final _selectedIndexStreamController = StreamController<int>();
  Stream<int> get selectedIndex => _selectedIndexStreamController.stream;

  MainViewModel() {
    _onTabItemTappedStreamController.stream.listen((index) {
      _selectedIndexStreamController.sink.add(index);
    });
  }

  dispose() {
    _onTabItemTappedStreamController.close();
    _selectedIndexStreamController.close();
  }
}