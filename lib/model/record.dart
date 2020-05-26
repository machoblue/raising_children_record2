
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

enum RecordType {
  milk,
  snack,
  babyFood,
  mothersMilk,
  vomit,
  cough,
  rash,
  medicine,
  pee,
  etc,
}

extension RecordTypeExtension on RecordType {
  String get string {
    final string = this.toString();
    return string.substring(string.indexOf(".") + 1);
  }

  String get assetName {
    return "assets/${string}_icon.png";
  }

  String get localizedName {
    return Intl.message('$string', name: '${string}Label');
  }

  static RecordType fromString(String string) {
    return RecordType.values.firstWhere((value) => value.string == string);
  }

  static RecordType fromModel(Record record) {
    switch(record.runtimeType) {
      case MilkRecord: return RecordType.milk;
      case SnackRecord: return RecordType.snack;
      case BabyFoodRecord: return RecordType.babyFood;
      case MothersMilkRecord: return RecordType.mothersMilk;
      case VomitRecord: return RecordType.vomit;
      case CoughRecord: return RecordType.cough;
      case RashRecord: return RecordType.rash;
      case MedicineRecord: return RecordType.medicine;
      case PeeRecord: return RecordType.pee;
      case EtcRecord: return RecordType.etc;
      default: throw('This line should not be reached.');
    }
  }
}

abstract class Record {
  String id;
  DateTime dateTime;
  String note;
  User user;

  Record(this.id, this.dateTime, this.note, this.user);

  Record.newInstance(this.dateTime, this.note, this.user) {
    this.id = Uuid().v1();
  }

  factory Record.fromSnapshot(DocumentSnapshot snapshot) {
    final String id = snapshot['id'];
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch((snapshot['dateTime'] as Timestamp).millisecondsSinceEpoch);
    final String type = snapshot['type'];
    final String note = snapshot['note'];
    final User user = User.fromMap(snapshot['user']);
    switch (RecordTypeExtension.fromString(type)) {
      case RecordType.milk:
        final int amount = (snapshot['details'] as Map)['amount'];
        return MilkRecord(id, dateTime, note, user, amount);
      case RecordType.snack:
        return SnackRecord(id, dateTime, note, user);
      case RecordType.babyFood:
        return BabyFoodRecord(id, dateTime, note, user);
      case RecordType.mothersMilk:
        final int leftMilliseconds = (snapshot['details'] as Map)['leftMilliseconds'];
        final int rightMilliseconds = (snapshot['details'] as Map)['rightMilliseconds'];
        return MothersMilkRecord(id, dateTime, note, user, leftMilliseconds, rightMilliseconds);
      case RecordType.vomit:
        return VomitRecord(id, dateTime, note, user);
      case RecordType.cough:
        return CoughRecord(id, dateTime, note, user);
      case RecordType.rash:
        return RashRecord(id, dateTime, note, user);
      case RecordType.medicine:
        return MedicineRecord(id, dateTime, note, user);
      case RecordType.pee:
        return PeeRecord(id, dateTime, note, user);
      case RecordType.etc:
        return EtcRecord(id, dateTime, note, user);
      default:
        if (kReleaseMode) {
          return null;
        } else {
          throw "This line shouldn't be reached.";
        }
    }
  }

  RecordType get type => RecordTypeExtension.fromModel(this);
  String get mainDescription;
  String get subDescription;

  Map<String, dynamic> get map {
    Map<String, dynamic> map = {
      'id': id,
      'dateTime': dateTime,
      'type': RecordTypeExtension.fromModel(this).string,
      'note': note,
      'user': user.map,
    };
    return map;
  }
}

class MilkRecord extends Record {
  int amount;

  MilkRecord(
      String id,
      DateTime dateTime,
      String note,
      User user,
      this.amount): super(id, dateTime, note, user);

  MilkRecord.newInstance(DateTime dateTime, String note, User user, this.amount): super.newInstance(dateTime, note, user);

  @override
  Map<String, dynamic> get map {
    Map superMap = super.map;
    Map<String, dynamic> detailsMap = { 'amount': amount };
    superMap['details'] = detailsMap;
    return superMap;
  }

  @override
  String get mainDescription => "${this.amount}ml";

  @override
  String get subDescription => note;
}

class SnackRecord extends Record {

  @override
  String get mainDescription => note ?? "";

  @override
  String get subDescription => "";

  SnackRecord(
      String id,
      DateTime dateTime,
      String note,
      User user): super(id, dateTime, note, user);

  SnackRecord.newInstance(DateTime dateTime, String note, User user): super.newInstance(dateTime, note, user);
}

class BabyFoodRecord extends Record {

  @override
  String get mainDescription => note ?? "";

  @override
  String get subDescription => "";

  BabyFoodRecord(
      String id,
      DateTime dateTime,
      String note,
      User user): super(id, dateTime, note, user);

  BabyFoodRecord.newInstance(DateTime dateTime, String note, User user): super.newInstance(dateTime, note, user);
}

class MothersMilkRecord extends Record {
  int leftMilliseconds;
  int rightMilliseconds;

  MothersMilkRecord(
      String id,
      DateTime dateTime,
      String note,
      User user,
      this.leftMilliseconds,
      this.rightMilliseconds): super(id, dateTime, note, user);

  MothersMilkRecord.newInstance(DateTime dateTime, String note, User user): super.newInstance(dateTime, note, user);

  @override
  Map<String, dynamic> get map {
    Map superMap = super.map;
    Map<String, dynamic> detailsMap = { 'leftMilliseconds': leftMilliseconds, 'rightMilliseconds': rightMilliseconds };
    superMap['details'] = detailsMap;
    return superMap;
  }

  @override
  String get mainDescription {
    int leftMinutes = ((leftMilliseconds ?? 0) / (1000 * 60)).round();
    String leftMinutesString = Intl.message(
      '${Intl.plural(leftMinutes, one: 'a minute', other: '$leftMinutes minutes')}',
      name: 'minuteUnit',
      args: [leftMinutes],
    );
    int rightMinutes = ((rightMilliseconds ?? 0) / (1000 * 60)).round();
    String rightMinutesString = Intl.message(
      '${Intl.plural(rightMinutes, one: 'a minute', other: '$rightMinutes minutes')}',
      name: 'minuteUnit',
      args: [rightMinutes],
    );
    return '$leftMinutesString / $rightMinutesString';
  }

  @override
  String get subDescription => note ?? "";
}

class VomitRecord extends Record {

  @override
  String get mainDescription => note ?? "";

  @override
  String get subDescription => "";

  VomitRecord(
      String id,
      DateTime dateTime,
      String note,
      User user): super(id, dateTime, note, user);

  VomitRecord.newInstance(DateTime dateTime, String note, User user): super.newInstance(dateTime, note, user);
}

class CoughRecord extends Record {

  @override
  String get mainDescription => note ?? "";

  @override
  String get subDescription => "";

  CoughRecord(
      String id,
      DateTime dateTime,
      String note,
      User user): super(id, dateTime, note, user);

  CoughRecord.newInstance(DateTime dateTime, String note, User user): super.newInstance(dateTime, note, user);
}

class RashRecord extends Record {

  @override
  String get mainDescription => note ?? "";

  @override
  String get subDescription => "";

  RashRecord(
      String id,
      DateTime dateTime,
      String note,
      User user): super(id, dateTime, note, user);

  RashRecord.newInstance(DateTime dateTime, String note, User user): super.newInstance(dateTime, note, user);
}

class MedicineRecord extends Record {

  @override
  String get mainDescription => note ?? "";

  @override
  String get subDescription => "";

  MedicineRecord(
      String id,
      DateTime dateTime,
      String note,
      User user): super(id, dateTime, note, user);

  MedicineRecord.newInstance(DateTime dateTime, String note, User user): super.newInstance(dateTime, note, user);
}

class PeeRecord extends Record {

  @override
  String get mainDescription => note ?? "";

  @override
  String get subDescription => "";

  PeeRecord(
      String id,
      DateTime dateTime,
      String note,
      User user): super(id, dateTime, note, user);

  PeeRecord.newInstance(DateTime dateTime, String note, User user): super.newInstance(dateTime, note, user);
}

class EtcRecord extends Record {

  @override
  String get mainDescription => note ?? "";

  @override
  String get subDescription => "";

  EtcRecord(
      String id,
      DateTime dateTime,
      String note,
      User user): super(id, dateTime, note, user);

  EtcRecord.newInstance(DateTime dateTime, String note, User user): super.newInstance(dateTime, note, user);
}
