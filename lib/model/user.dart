
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:raisingchildrenrecord2/model/invitationCode.dart';

import 'authenticatedUser.dart';

class User {
  String id;
  String name;
  String photoUrl;
  String familyId;
  String invitationCode;
  SignInMethod signInMethod;

  User(this.id, this.name, this.photoUrl, this.familyId, this.signInMethod, { Key key, this.invitationCode });

  User.fromMap(Map map): this(
      map['id'],
      map['name'],
      map['photoUrl'],
      map['familyId'],
      SignInMethodExtension.fromRawValue(map['signInMethod']),
  );

  User.fromSnapshot(DocumentSnapshot snapshot) : this(
    snapshot['id'],
    snapshot['name'],
    snapshot['photoUrl'],
    snapshot['familyId'],
    SignInMethodExtension.fromRawValue(snapshot['signInMethod']),
  );

  User.fromAuthenticatedUser(AuthenticatedUser authenticatedUser, String familyId): this(
    authenticatedUser.id,
    authenticatedUser.name,
    authenticatedUser.photoUrl,
    familyId,
    authenticatedUser.signInMethod,
  );

  User.fromAuthenticatedUserAndInvitationCode(AuthenticatedUser authenticatedUser, InvitationCode invitationCode): this(
    authenticatedUser.id,
    authenticatedUser.name,
    authenticatedUser.photoUrl,
    invitationCode.familyId,
    authenticatedUser.signInMethod,
    invitationCode: invitationCode.code,
  );

  Map<String, dynamic> get map {
    Map<String, dynamic> map = {
      'id': id,
      'name': name,
      'photoUrl': photoUrl,
      'familyId': familyId,
      'signInMethod': signInMethod.rawValue,
    };

    if (invitationCode != null) {
      map['invitationCode'] = invitationCode;
    }

    return map;
  }
}