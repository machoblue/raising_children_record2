
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id;
  String name;
  String photoUrl;
  String familyId;

  User(this.id, this.name, this.photoUrl, this.familyId);

  User.fromMap(Map map): this(
      map['id'],
      map['name'],
      map['photoUrl'],
      map['familyId'],
  );

  User.fromSnapshot(DocumentSnapshot snapshot) : this(
    snapshot['id'],
    snapshot['name'],
    snapshot['photoUrl'],
    snapshot['familyId'],
  );

  Map get map {
    return {
      'id': id,
      'name': name,
      'photoUrl': photoUrl,
    };
  }
}