
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:rxdart/rxdart.dart';

class HomePageViewModel {
  DateTime dateTime;
  BehaviorSubject<Baby> baby;

  HomePageViewModel(this.dateTime, this.baby) {
    baby.stream.listen((baby) {
      if (baby == null) {
        return;
      }

      // TODO: fetch records
    });
  }
}