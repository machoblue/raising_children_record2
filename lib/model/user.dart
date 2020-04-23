
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id;
  String name;
  String photoUrl;

  User(this.id, this.name, this.photoUrl);

  User.fromMap(Map map): this(
      map['id'],
      map['name'],
      map['photoUrl']
  );

  User.fromSnapshot(DocumentSnapshot snapshot) : this(
    snapshot['id'],
    snapshot['name'],
    snapshot['photoUrl'],
  );

  Map get map {
    return {
      'id': id,
      'name': name,
      'photoUrl': photoUrl,
    };
  }
}