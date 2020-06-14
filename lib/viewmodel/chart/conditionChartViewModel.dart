
import 'package:raisingchildrenrecord2/data/recordRepository.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/viewmodel/baseViewModel.dart';

class ConditionChartViewModel with ViewModelErrorHandler implements ViewModel {

  final Stream<Baby> babyStream;
  final RecordRepository recordRepository;

  ConditionChartViewModel(this.babyStream, this.recordRepository) {
  }

  @override
  void dispose() {
    super.dispose();
  }
}