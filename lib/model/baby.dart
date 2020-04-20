
import 'package:cloud_firestore/cloud_firestore.dart';

class Baby {
  String id;
  String name;
  DateTime birthday;
  String photoUrl;

  Baby(this.id, this.name, this.birthday, this.photoUrl);

  Baby.fromSnapshot(DocumentSnapshot snapshot): this(
      snapshot['id'].toString(),
      snapshot['name'].toString(),
      DateTime.fromMillisecondsSinceEpoch(snapshot['birthday']),
      snapshot['photoUrl'].toString(),
  );
}