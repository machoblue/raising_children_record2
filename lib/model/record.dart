
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/model/user.dart';

class Record {
  String id;
  DateTime dateTime;
  String type;
  int option1;
  String note;
  User user;

  Record(this.id, this.dateTime, this.type, this.option1, this.note, this.user);

  Record.fromSnapshot(DocumentSnapshot snapshot): this(
      snapshot['id'],
      DateTime.fromMillisecondsSinceEpoch(snapshot['dateTime']),
      snapshot['type'],
      snapshot['option1'],
      snapshot['note'],
      User.fromMap(snapshot['user'])
  );

  String get assetName {
    switch (type) {
      case 'milk': {
        print("### milk");
        return "assets/milk_icon.png";
      }
      break;
      default: {
        print("### default");
        return null;
      }
      break;
    }
  }

  String title(L10n l10n) {
    switch (type) {
      case 'milk': {
        print("### milk");
        return l10n.milkLabel;
      }
      break;
      default: {
        print("### default");
        return null;
      }
      break;
    }
  }

  String get description {
    switch (type) {
      case 'milk': {
        print("### milk");
        return "$option1 ml";
      }
      break;
      default: {
        print("### default");
        return null;
      }
      break;
    }
  }
}