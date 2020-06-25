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
        GrowthData(0, 52.6),
        GrowthData(1, 57.4),
        GrowthData(1.5, 59.6),
        GrowthData(2.5, 63.2),
        GrowthData(3.5, 66.1),
        GrowthData(4.5, 68.5),
        GrowthData(5.5, 70.5),
        GrowthData(6.5, 72.1),
        GrowthData(7.5, 73.6),
        GrowthData(8.5, 75.0),
        GrowthData(9.5, 76.2),
        GrowthData(10.5, 77.4),
        GrowthData(11.5, 78.5),
        GrowthData(12.0, 79.1), // workaround

        GrowthData(12.5, 79.6),
        GrowthData(13.5, 80.6),
        GrowthData(14.5, 81.7),
        GrowthData(15.5, 82.8),
        GrowthData(16.5, 83.8),
        GrowthData(17.5, 84.8),
        GrowthData(18.5, 85.9),
        GrowthData(19.5, 86.9),
        GrowthData(20.5, 87.9),
        GrowthData(21.5, 88.8),
        GrowthData(22.5, 89.8),
        GrowthData(23.5, 90.7),

        GrowthData(27.0, 92.5),
        GrowthData(33.0, 97.4),
        GrowthData(36.0, 99.6), // workaround
        GrowthData(39.0, 101.8),
        GrowthData(45.0, 105.8),
        GrowthData(51.0, 109.5),
        GrowthData(57.0, 113.0),
        GrowthData(63.0, 116.5),
        GrowthData(69.0, 119.9),
        GrowthData(72.0, 121.9), // workaround
        GrowthData(75.0, 123.6),
      ],
      floorDataList: [
        GrowthData(0, 44.0),
        GrowthData(1, 48.7),
        GrowthData(1.5, 50.9),
        GrowthData(2.5, 54.5),
        GrowthData(3.5, 57.5),
        GrowthData(4.5, 59.9),
        GrowthData(5.5, 61.9),
        GrowthData(6.5, 63.6),
        GrowthData(7.5, 65.0),
        GrowthData(8.5, 66.3),
        GrowthData(9.5, 67.4),
        GrowthData(10.5, 68.4),
        GrowthData(11.5, 69.4),
        GrowthData(12.0, 69.9), // workaround

        GrowthData(12.5, 70.3),
        GrowthData(13.5, 71.2),
        GrowthData(14.5, 72.1),
        GrowthData(15.5, 73.0),
        GrowthData(16.5, 73.9),
        GrowthData(17.5, 74.8),
        GrowthData(18.5, 75.6),
        GrowthData(19.5, 76.5),
        GrowthData(20.5, 77.3),
        GrowthData(21.5, 78.1),
        GrowthData(22.5, 78.9),
        GrowthData(23.5, 79.7),

        GrowthData(27.0, 81.1),
        GrowthData(33.0, 85.2),
        GrowthData(36.0, 87.0), // workaround
        GrowthData(39.0, 88.8),
        GrowthData(45.0, 92.0),
        GrowthData(51.0, 95.0),
        GrowthData(57.0, 97.8),
        GrowthData(63.0, 100.5),
        GrowthData(69.0, 103.3),
        GrowthData(72.0, 104.8), // workaround
        GrowthData(75.0, 106.2),
      ],
    ),
    weightStatistics: GrowthStatistics(
      ceilDataList: [
        GrowthData(0, 3.76),
        GrowthData(1, 5.17),
        GrowthData(1.5, 5.96),
        GrowthData(2.5, 7.18),
        GrowthData(3.5, 8.07),
        GrowthData(4.5, 8.72),
        GrowthData(5.5, 9.20),
        GrowthData(6.5, 9.57),
        GrowthData(7.5, 9.87),
        GrowthData(8.5, 10.14),
        GrowthData(9.5, 10.37),
        GrowthData(10.5, 10.59),
        GrowthData(11.5, 10.82),
        GrowthData(12.0, 10.93), // workaroud

        GrowthData(12.5, 11.04),
        GrowthData(13.5, 11.28),
        GrowthData(14.5, 11.51),
        GrowthData(15.5, 11.75),
        GrowthData(16.5, 11.98),
        GrowthData(17.5, 12.23),
        GrowthData(18.5, 12.47),
        GrowthData(19.5, 12.71),
        GrowthData(20.5, 12.96),
        GrowthData(21.5, 13.20),
        GrowthData(22.5, 13.45),
        GrowthData(23.5, 13.69),

        GrowthData(27.0, 14.55),
        GrowthData(33.0, 16.01),
        GrowthData(36.0, 16.72),
        GrowthData(39.0, 17.43),
        GrowthData(45.0, 18.82),
        GrowthData(51.0, 20.24),
        GrowthData(57.0, 21.72),
        GrowthData(63.0, 23.15),
        GrowthData(69.0, 24.33),
        GrowthData(72.0, 24.79), // workaround
        GrowthData(75.0, 25.25),
      ],
      floorDataList: [
        GrowthData(0, 2.10),
        GrowthData(1, 3.00),
        GrowthData(1.5, 3.53),
        GrowthData(2.5, 4.41),
        GrowthData(3.5, 5.12),
        GrowthData(4.5, 5.67),
        GrowthData(5.5, 6.10),
        GrowthData(6.5, 6.44),
        GrowthData(7.5, 6.73),
        GrowthData(8.5, 6.96),
        GrowthData(9.5, 7.16),
        GrowthData(10.5, 7.34),
        GrowthData(11.5, 7.51),
        GrowthData(12.0, 7.59), // workaroud

        GrowthData(12.5, 7.68),
        GrowthData(13.5, 7.85),
        GrowthData(14.5, 8.02),
        GrowthData(15.5, 8.19),
        GrowthData(16.5, 8.36),
        GrowthData(17.5, 8.53),
        GrowthData(18.5, 8.70),
        GrowthData(19.5, 8.86),
        GrowthData(20.5, 9.03),
        GrowthData(21.5, 9.19),
        GrowthData(22.5, 9.36),
        GrowthData(23.5, 9.52),

        GrowthData(27.0, 10.06),
        GrowthData(33.0, 10.94),
        GrowthData(36.0, 11.33), // workaround
        GrowthData(39.0, 11.72),
        GrowthData(45.0, 12.42),
        GrowthData(51.0, 13.07),
        GrowthData(57.0, 13.71),
        GrowthData(63.0, 14.37),
        GrowthData(69.0, 15.03),
        GrowthData(72.0, 15.27), // workaround
        GrowthData(75.0, 15.55),
      ],
    ),
  );

  final _femaleSet = GrowthStatisticsSet(
    heightStatistics: GrowthStatistics(
      ceilDataList: [
        GrowthData(0, 52.6),
        GrowthData(1, 57.4),
        GrowthData(1.5, 59.6),
        GrowthData(2.5, 63.2),
        GrowthData(3.5, 66.1),
        GrowthData(4.5, 68.5),
        GrowthData(5.5, 70.5),
        GrowthData(6.5, 72.1),
        GrowthData(7.5, 73.6),
        GrowthData(8.5, 75.0),
        GrowthData(9.5, 76.2),
        GrowthData(10.5, 77.4),
        GrowthData(11.5, 78.5),
        GrowthData(12.0, 79.1), // workaround

        GrowthData(12.5, 79.6),
        GrowthData(13.5, 80.6),
        GrowthData(14.5, 81.7),
        GrowthData(15.5, 82.8),
        GrowthData(16.5, 83.8),
        GrowthData(17.5, 84.8),
        GrowthData(18.5, 85.9),
        GrowthData(19.5, 86.9),
        GrowthData(20.5, 87.9),
        GrowthData(21.5, 88.8),
        GrowthData(22.5, 89.8),
        GrowthData(23.5, 90.7),

        GrowthData(27.0, 92.5),
        GrowthData(33.0, 97.4),
        GrowthData(36.0, 99.6), // workaround
        GrowthData(39.0, 101.8),
        GrowthData(45.0, 105.8),
        GrowthData(51.0, 109.5),
        GrowthData(57.0, 113.0),
        GrowthData(63.0, 116.5),
        GrowthData(69.0, 119.9),
        GrowthData(72.0, 121.9), // workaround
        GrowthData(75.0, 123.6),
      ],
      floorDataList: [
        GrowthData(0, 44.0),
        GrowthData(1, 48.7),
        GrowthData(1.5, 50.9),
        GrowthData(2.5, 54.5),
        GrowthData(3.5, 57.5),
        GrowthData(4.5, 59.9),
        GrowthData(5.5, 61.9),
        GrowthData(6.5, 63.6),
        GrowthData(7.5, 65.0),
        GrowthData(8.5, 66.3),
        GrowthData(9.5, 67.4),
        GrowthData(10.5, 68.4),
        GrowthData(11.5, 69.4),
        GrowthData(12.0, 69.9), // workaround

        GrowthData(12.5, 70.3),
        GrowthData(13.5, 71.2),
        GrowthData(14.5, 72.1),
        GrowthData(15.5, 73.0),
        GrowthData(16.5, 73.9),
        GrowthData(17.5, 74.8),
        GrowthData(18.5, 75.6),
        GrowthData(19.5, 76.5),
        GrowthData(20.5, 77.3),
        GrowthData(21.5, 78.1),
        GrowthData(22.5, 78.9),
        GrowthData(23.5, 79.7),

        GrowthData(27.0, 81.1),
        GrowthData(33.0, 85.2),
        GrowthData(36.0, 87.0), // workaround
        GrowthData(39.0, 88.8),
        GrowthData(45.0, 92.0),
        GrowthData(51.0, 95.0),
        GrowthData(57.0, 97.8),
        GrowthData(63.0, 100.5),
        GrowthData(69.0, 103.3),
        GrowthData(72.0, 104.8), // workaround
        GrowthData(75.0, 106.2),
      ],
    ),
    weightStatistics: GrowthStatistics(
      ceilDataList: [
        GrowthData(0, 3.76),
        GrowthData(1, 5.17),
        GrowthData(1.5, 5.96),
        GrowthData(2.5, 7.18),
        GrowthData(3.5, 8.07),
        GrowthData(4.5, 8.72),
        GrowthData(5.5, 9.20),
        GrowthData(6.5, 9.57),
        GrowthData(7.5, 9.87),
        GrowthData(8.5, 10.14),
        GrowthData(9.5, 10.37),
        GrowthData(10.5, 10.59),
        GrowthData(11.5, 10.82),
        GrowthData(12.0, 10.93), // workaroud

        GrowthData(12.5, 11.04),
        GrowthData(13.5, 11.28),
        GrowthData(14.5, 11.51),
        GrowthData(15.5, 11.75),
        GrowthData(16.5, 11.98),
        GrowthData(17.5, 12.23),
        GrowthData(18.5, 12.47),
        GrowthData(19.5, 12.71),
        GrowthData(20.5, 12.96),
        GrowthData(21.5, 13.20),
        GrowthData(22.5, 13.45),
        GrowthData(23.5, 13.69),

        GrowthData(27.0, 14.55),
        GrowthData(33.0, 16.01),
        GrowthData(36.0, 16.72),
        GrowthData(39.0, 17.43),
        GrowthData(45.0, 18.82),
        GrowthData(51.0, 20.24),
        GrowthData(57.0, 21.72),
        GrowthData(63.0, 23.15),
        GrowthData(69.0, 24.33),
        GrowthData(72.0, 24.79), // workaround
        GrowthData(75.0, 25.25),
      ],
      floorDataList: [
        GrowthData(0, 2.10),
        GrowthData(1, 3.00),
        GrowthData(1.5, 3.53),
        GrowthData(2.5, 4.41),
        GrowthData(3.5, 5.12),
        GrowthData(4.5, 5.67),
        GrowthData(5.5, 6.10),
        GrowthData(6.5, 6.44),
        GrowthData(7.5, 6.73),
        GrowthData(8.5, 6.96),
        GrowthData(9.5, 7.16),
        GrowthData(10.5, 7.34),
        GrowthData(11.5, 7.51),
        GrowthData(12.0, 7.59), // workaroud

        GrowthData(12.5, 7.68),
        GrowthData(13.5, 7.85),
        GrowthData(14.5, 8.02),
        GrowthData(15.5, 8.19),
        GrowthData(16.5, 8.36),
        GrowthData(17.5, 8.53),
        GrowthData(18.5, 8.70),
        GrowthData(19.5, 8.86),
        GrowthData(20.5, 9.03),
        GrowthData(21.5, 9.19),
        GrowthData(22.5, 9.36),
        GrowthData(23.5, 9.52),

        GrowthData(27.0, 10.06),
        GrowthData(33.0, 10.94),
        GrowthData(36.0, 11.33), // workaround
        GrowthData(39.0, 11.72),
        GrowthData(45.0, 12.42),
        GrowthData(51.0, 13.07),
        GrowthData(57.0, 13.71),
        GrowthData(63.0, 14.37),
        GrowthData(69.0, 15.03),
        GrowthData(72.0, 15.27), // workaround
        GrowthData(75.0, 15.55),
      ],
    ),
  );
}