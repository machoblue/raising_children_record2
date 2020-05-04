
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class Baby {
  String id;
  String name;
  DateTime birthday;
  String photoUrl;

  Baby(this.id, this.name, this.birthday, this.photoUrl);

  Baby.newInstance(): this(Uuid().v1(), 'Baby', DateTime.now(), defaultBabyIconUrl);

  Baby.fromSnapshot(DocumentSnapshot snapshot): this(
      snapshot['id'].toString(),
      snapshot['name'].toString(),
      DateTime.fromMillisecondsSinceEpoch((snapshot['birthday'] as Timestamp).millisecondsSinceEpoch),
      snapshot['photoUrl'].toString(),
  );

  Map<String, dynamic> get map {
    return {
      'id': id,
      'name': name,
      'birthday': birthday,
      'photoUrl': photoUrl,
    };
  }

  static String get defaultBabyIconUrl => 'https://firebasestorage.googleapis.com/v0/b/raisingchildrenrecord2.appspot.com/o/icon.png?alt=media&token=ce8d2ab5-98bf-42b3-9090-d3dc1459054a';
}