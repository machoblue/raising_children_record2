import 'package:raisingchildrenrecord2/l10n/l10n.dart';

class Period {
  final DateTime from;
  final DateTime to;
  final PeriodType type;
  Period(this.from, this.to, this.type);
}

enum PeriodType {
  oneWeek, threeWeeks, threeMonths,
}

extension PeriodTypeExtension on PeriodType {
  String getLabel(L10n l10n) {
    switch (this) {
      case PeriodType.oneWeek: return l10n.oneWeek;
      case PeriodType.threeWeeks: return l10n.threeWeeks;
      case PeriodType.threeMonths: return l10n.threeMonths;
      default: throw 'This line shouldn\'t be reached';
    }
  }

  int get days {
    switch (this) {
      case PeriodType.oneWeek: return 7;
      case PeriodType.threeWeeks: return 21;
      case PeriodType.threeMonths: return 90;
      default: throw 'This line shouldn\'t be reached';
    }
  }

  int get unitDays {
    switch (this) {
      case PeriodType.oneWeek: return 1;
      case PeriodType.threeWeeks: return 7;
      case PeriodType.threeMonths: return 7;
      default: throw 'This line shouldn\'t be reached';
    }
  }

  bool isScaleBoundDay(DateTime dateTime) {
    switch (this) {
      case PeriodType.oneWeek: return dateTime.hour == 0 && dateTime.minute == 0;
      case PeriodType.threeWeeks: return dateTime.weekday == DateTime.monday;
      case PeriodType.threeMonths: return dateTime.weekday == DateTime.monday;
      default: throw 'This line shouldn\'t be reached';
    }
  }

  static PeriodType fromIndex(int index) {
    switch (index) {
      case 0: return PeriodType.oneWeek;
      case 1: return PeriodType.threeWeeks;
      case 2: return PeriodType.threeMonths;
      default: throw 'This line shouldn\'t be reached';
    }
  }
}