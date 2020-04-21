
import 'dart:async';

import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:rxdart/rxdart.dart';

class HomeViewModel {

  BehaviorSubject<Baby> baby;

  HomeViewModel(this.baby) {
  }

  void dispose() {
  }
}