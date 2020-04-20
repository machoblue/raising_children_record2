
import 'dart:async';

import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:rxdart/rxdart.dart';

class HomeViewModel {

  Stream<Baby> baby;

  final _onButtonTappedStreamController = StreamController<void>();
  get onButtonTapped => _onButtonTappedStreamController.sink;
  
  final _expandStreamController = BehaviorSubject<bool>.seeded(false);
  get expand => _expandStreamController.stream;

  HomeViewModel(this.baby) {
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