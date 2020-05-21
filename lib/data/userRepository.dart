
import 'dart:async';

import 'package:raisingchildrenrecord2/data/FirestoreUtil.dart';
import 'package:raisingchildrenrecord2/data/firestoreErrorHandler.dart';
import 'package:raisingchildrenrecord2/model/user.dart';

class UserRepository {
  Future<void> createOrUpdateUser(User user) {}
  Future<User> getUser(String userId) {}
  Future<void> createFamily(String familyId, User user) {}
  Future<void> joinFamily(String familyId, User user) {}
  Future<void> exitFamily(String familyId, String userId) {}
  Future<void> deleteUser(String userId) {}
}

class FirestoreUserRepository with FirestoreErrorHandler, FirestoreUtil implements UserRepository {

  final String users = 'users';
  final String families = 'families';

  Future<void> createOrUpdateUser(User user) {
    return rootRef
        .collection(users)
        .document(user.id)
        .setData(user.map)
        .catchError(handleError);
  }

  Future<User> getUser(String userId) {
    return rootRef
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

  Future<void> createFamily(String familyId, User user) {
    return rootRef
      .collection(families)
      .document(user.familyId)
      .collection(users)
      .document(user.id)
      .setData(user.map)
      .then((_) {
        return rootRef
          .collection(families)
          .document(user.familyId)
          .setData({ 'createdBy': user.id });
      })
      .catchError(handleError);
  }

  Future<void> joinFamily(String familyId, User user) {
    return rootRef
        .collection(families)
        .document(user.familyId)
        .collection(users)
        .document(user.id)
        .setData(user.map)
        .catchError(handleError);
  }

  Future<void> exitFamily(String familyId, String userId) {
    return rootRef
        .collection(families)
        .document(familyId)
        .collection(users)
        .document(userId)
        .delete()
        .catchError(handleError);
  }

  Future<void> deleteUser(String userId) {
    return rootRef
        .collection(users)
        .document(userId)
        .delete()
        .catchError(handleError);
  }
}