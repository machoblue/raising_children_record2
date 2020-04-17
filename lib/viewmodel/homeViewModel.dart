
import 'dart:async';

import 'package:rxdart/rxdart.dart';

class HomeViewModel {
//  final _onToggledStreamController = BehaviorSubject<bool>.seeded(false);
//  get onToggled => _onToggledStreamController.sink;
//  get onToggledStream => _onToggledStreamController.stream;
  final _onButtonTappedStreamController = StreamController<void>();
  get onButtonTapped => _onButtonTappedStreamController.sink;
  
  final _expandStreamController = BehaviorSubject<bool>.seeded(false);
  get expand => _expandStreamController.stream;

  HomeViewModel() {
    _onButtonTappedStreamController.stream.listen((_) {
      print("### onButtonTapped");
      _expandStreamController.sink.add(!_expandStreamController.value);
    });
  }

  void dispose() {
    _onButtonTappedStreamController.close();
    _expandStreamController.close();
  }
}