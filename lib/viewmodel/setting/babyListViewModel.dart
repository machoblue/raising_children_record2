
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/viewmodel/baseViewModel.dart';

class BabyListViewModel with ViewModelErrorHandler, ViewModelInfoMessageHandler implements ViewModel {

  Stream<List<Baby>> babiesStream;

  BabyListViewModel(this.babiesStream);

  void dispose() {
    super.dispose();
  }
}