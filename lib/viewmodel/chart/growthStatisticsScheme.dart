import 'package:raisingchildrenrecord2/l10n/l10n.dart';

class GrowthStatisticsScheme {
  String localizedName(L10n l10n) {}
  GrowthStatisticsSet get maleSet {}
  GrowthStatisticsSet get femaleSet {}
}

class GrowthStatisticsSet {
  final GrowthStatistics heightStatistics;
  final GrowthStatistics weightStatistics;
  GrowthStatisticsSet({ this.heightStatistics, this.weightStatistics });
}

class GrowthStatistics {
  final List<GrowthData> ceilDataList;
  final List<GrowthData> floorDataList;
  GrowthStatistics({ this.ceilDataList, this.floorDataList });
}

class GrowthData {
  final double month;
  final double value;
  GrowthData(this.month, this.value);
}

class MHLWGrowthStatisticsScheme implements GrowthStatisticsScheme { // 厚生労働省
  GrowthStatisticsSet get maleSet => _maleSet;
  GrowthStatisticsSet get femaleSet => _femaleSet;

  String localizedName(L10n l10n) => '厚生労働省'; // TODO: localize

  final _maleSet = GrowthStatisticsSet(
    heightStatistics: GrowthStatistics(
      ceilDataList: [
      ],
      floorDataList: [
      ],
    ),
    weightStatistics: GrowthStatistics(
      ceilDataList: [
      ],
      floorDataList: [
      ],
    ),
  );

  final _femaleSet = GrowthStatisticsSet(
    heightStatistics: GrowthStatistics(
      ceilDataList: [
      ],
      floorDataList: [
      ],
    ),
    weightStatistics: GrowthStatistics(
      ceilDataList: [
      ],
      floorDataList: [
      ],
    ),
  );
}