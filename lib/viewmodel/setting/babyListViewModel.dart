
import 'package:raisingchildrenrecord2/model/baby.dart';

class BabyListViewModel {

  Stream<List<Baby>> babiesStream;

  BabyListViewModel(this.babiesStream);

  void dispose() {
  }
}