
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raisingchildrenrecord2/data/firestoreErrorHandler.dart';
import 'package:raisingchildrenrecord2/model/user.dart';

class UserRepository {
  Future<void> createOrUpdateUser(User user) {}
  Future<User> getUser(String userId) {}
  Future<void> createOrJoinFamily(String familyId, User user) {}
  Future<void> exitFamily(String familyId, String userId) {}
  Future<void> deleteUser(String userId) {}
}

class FirestoreUserRepository with FirestoreErrorHandler implements UserRepository {

  final String users = 'users';
  final String families = 'families';

  Future<void> createOrUpdateUser(User user) {
    return Firestore.instance
        .collection(users)
        .document(user.id)
        .setData(user.map)
        .catchError(handleError);
  }

  Future<User> getUser(String userId) {
    return Firestore.instance
        .collection(users)
        .document(userId)
        .get()
        .then((documentSnapshot) {
          final bool userExists = documentSnapshot?.exists ?? false;
          if (!userExists) {
            return null;
          }

          return User.fromSnapshot(documentSnapshot);
        })
        .catchError(handleError);
  }

  Future<void> createOrJoinFamily(String familyId, User user) {
    return Firestore.instance
        .collection(families)
        .document(user.familyId)
        .collection(users)
        .document(user.id)
        .setData(user.map)
        .catchError(handleError);
  }

  Future<void> exitFamily(String familyId, String userId) {
    return Firestore.instance
        .collection(families)
        .document(familyId)
        .collection(users)
        .document(userId)
        .delete()
        .catchError(handleError);
  }

  Future<void> deleteUser(String userId) {
    return Firestore.instance
        .collection(users)
        .document(userId)
        .delete()
        .catchError(handleError);
  }
}