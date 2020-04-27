
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

enum RecordType {
  milk,
  snack,
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
      case MilkRecord: {
        return RecordType.milk;
      }
      case SnackRecord: {
        return RecordType.snack;
      }
      default: {
        return null;
      }
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
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(snapshot['dateTime']);
    final String type = snapshot['type'];
    final String note = snapshot['note'];
    final User user = User.fromMap(snapshot['user']);
    switch (type) {
      case 'milk': {
        final int amount = (snapshot['details'] as Map)['amount'];
        return MilkRecord(id, dateTime, note, user, amount);
      }
      break;
      case 'snack': {
        return SnackRecord(id, dateTime, note, user);
      }
      break;
      default: {
        return null;
      }
    }
  }

  RecordType get type => RecordTypeExtension.fromModel(this);
  String get mainDescription;
  String get subDescription;

  Map<String, dynamic> get map {
    Map<String, dynamic> map = {
      'id': id,
      'dateTime': dateTime.millisecondsSinceEpoch,
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