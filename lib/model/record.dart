
import 'package:cloud_firestore/cloud_firestore.dart';
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
}