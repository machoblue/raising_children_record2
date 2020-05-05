
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class User {
  String id;
  String name;
  String photoUrl;
  String familyId;
  String invitationCode;

  User(this.id, this.name, this.photoUrl, this.familyId, { Key key, this.invitationCode });

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

  Map<String, dynamic> get map {
    Map<String, dynamic> map = {
      'id': id,
      'name': name,
      'photoUrl': photoUrl,
      'familyId': familyId,
    };

    if (invitationCode != null) {
      map['invitationCode'] = invitationCode;
    }

    return map;
  }
}