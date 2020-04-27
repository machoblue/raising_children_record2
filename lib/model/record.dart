
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:uuid/uuid.dart';

abstract class Record {
  String id;
  DateTime dateTime;
  String type;
  String note;
  User user;

  Record(this.id, this.dateTime, this.type, this.note, this.user);

  Record.newInstance(this.dateTime, this.type, this.note, this.user) {
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
        return MilkRecord(id, dateTime, type, note, user, amount);
      }
      break;
      case 'snack': {
        return SnackRecord(id, dateTime, type, note, user);
      }
      break;
      default: {
        return null;
      }
    }
  }

  String get assetName;
  String typeName(L10n l10n);
  String get mainDescription;
  String get subDescription;

  Map<String, dynamic> get map {
    Map<String, dynamic> map = {
      'id': id,
      'dateTime': dateTime.millisecondsSinceEpoch,
      'type': type,
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
      String type,
      String note,
      User user,
      this.amount): super(id, dateTime, type, note, user);

  MilkRecord.newInstance(DateTime dateTime, String note, User user, this.amount): super.newInstance(dateTime, "milk", note, user);

  @override
  Map<String, dynamic> get map {
    Map superMap = super.map;
    Map<String, dynamic> detailsMap = { 'amount': amount };
    superMap['details'] = detailsMap;
    return superMap;
  }

  @override
  String get assetName => "assets/milk_icon.png";

  @override
  String typeName(L10n l10n) => l10n.milkLabel;

  @override
  String get mainDescription => "${this.amount}ml";

  @override
  String get subDescription => note;
}

class SnackRecord extends Record {
  @override
  String get assetName => "assets/snack_icon.png";

  @override
  String get mainDescription => note ?? "";

  @override
  String get subDescription => "";

  @override
  String typeName(L10n l10n) {
    return l10n.snackLabel;
  }

  SnackRecord(
      String id,
      DateTime dateTime,
      String type,
      String note,
      User user): super(id, dateTime, type, note, user);

  SnackRecord.newInstance(DateTime dateTime, String note, User user): super.newInstance(dateTime, "snack", note, user);
}