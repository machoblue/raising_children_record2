
import 'package:cloud_firestore/cloud_firestore.dart';

class Baby {
  String id;
  String name;
  DateTime birthday;
  String photoUrl;

  Baby(this.id, this.name, this.birthday);
  Baby.fromSnapshot(DocumentSnapshot snapshot) {
    this.id = snapshot['id'].toString();
    this.name = snapshot['name'].toString();
    this.photoUrl = snapshot['photoUrl'].toString();
    this.birthday = DateTime.fromMillisecondsSinceEpoch(snapshot['birthday']); // snapshot['birthday']はObject型だけど、int型に自動でキャストされるっぽい。静的に型安全でじゃなくてイマイチに感じる
  }
}