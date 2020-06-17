
import 'package:raisingchildrenrecord2/data/recordRepository.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/viewmodel/baseViewModel.dart';

class GrowthChartViewModel with ViewModelErrorHandler implements ViewModel {

  Stream<Baby> babyStream;
  RecordRepository recordRepository;

  GrowthChartViewModel(this.babyStream, this.recordRepository) {
  }

  @override
  void dispose() {
    super.dispose();
  }
}