import 'dart:async';

class MainViewModel {
  final List<String> appBarTitles = ["Home", "Settings"];

  final _onTabItemTappedStreamController = StreamController<int>();
  StreamSink<int> get onTabItemTapped => _onTabItemTappedStreamController.sink;

  final _selectedIndexStreamController = StreamController<int>();
  Stream<int> get selectedIndex => _selectedIndexStreamController.stream;
  final _appBarTitleStreamController = StreamController<String>();
  Stream<String> get appBarTitle => _appBarTitleStreamController.stream;

  MainViewModel() {
    _onTabItemTappedStreamController.stream.listen((index) {
      _selectedIndexStreamController.sink.add(index);
      _appBarTitleStreamController.sink.add(appBarTitles[index]);
    });
  }

  dispose() {
    _onTabItemTappedStreamController.close();
    _selectedIndexStreamController.close();
    _appBarTitleStreamController.close();
  }
}