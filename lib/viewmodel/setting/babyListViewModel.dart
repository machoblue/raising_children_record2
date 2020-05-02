
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:rxdart/rxdart.dart';

class BabyListViewModel {

  Stream<List<Baby>> babiesStream;

  BabyListViewModel(this.babiesStream);

  void dispose() {
  }
}