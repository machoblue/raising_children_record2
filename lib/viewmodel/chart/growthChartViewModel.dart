
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
  GrowthStaticsSet get maleSet {}
  GrowthStaticsSet get femaileSet {}
}

class GrowthStaticsSet {
  final GrowthStatics heightStatics;
  final GrowthStatics widthStatics;
  GrowthStaticsSet({ this.heightStatics, this.widthStatics });
}

class GrowthStatics {
  final List<GrowthData> ceilDataList;
  final List<GrowthData> floorDataList;
  GrowthStatics({ this.ceilDataList, this.floorDataList });
}

class GrowthData {
  final double month;
  final double value;
  GrowthData(this.month, this.value);
}

class MHLWGrowthStaticsGroup implements GrowthStaticsGroup { // 厚生労働省
  String get localizedName => '厚生労働省'; // TODO: internationalize
  GrowthStaticsSet get maleSet => _maleSet;
  GrowthStaticsSet get femaileSet => _femaleSet;

  final _maleSet = GrowthStaticsSet(
    heightStatics: GrowthStatics(
      ceilDataList: [
      ],
      floorDataList: [
      ],
    ),
    widthStatics: GrowthStatics(
      ceilDataList: [
      ],
      floorDataList: [
      ],
    ),
  );

  final _femaleSet = GrowthStaticsSet(
    heightStatics: GrowthStatics(
      ceilDataList: [
      ],
      floorDataList: [
      ],
    ),
    widthStatics: GrowthStatics(
      ceilDataList: [
      ],
      floorDataList: [
      ],
    ),
  );
}