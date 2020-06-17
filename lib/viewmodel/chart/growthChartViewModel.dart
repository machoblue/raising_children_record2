
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

class GrowthStaticsGroup {
  String get localizedName {}
  GrowthStatics get heightGrowthStatics {}
  GrowthStatics get weightGrowthStatics {}
}

class GrowthStatics {
  final List<GrowthData> ceilDataList;
  final List<GrowthData> floorDataList;
  GrowthStatics({ this.ceilDataList, this.floorDataList });
}

class GrowthData {
  final int month;
  final double value;
  GrowthData(this.month, this.value);
}

class MHLWGrowthStaticsGroup implements GrowthStaticsGroup { // 厚生労働省
  String get localizedName => '厚生労働省'; // TODO: internationalize
  GrowthStatics get heightGrowthStatics => _heightGrowthStatics;
  GrowthStatics get weightGrowthStatics => _widthGrowthStatics;

  final _heightGrowthStatics = GrowthStatics(
    ceilDataList: [
    ],
    floorDataList: [
    ],
  );

  final _widthGrowthStatics = GrowthStatics(
    ceilDataList: [
    ],
    floorDataList: [
    ],
  );
}