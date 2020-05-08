
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raisingchildrenrecord2/model/user.dart';

class UserRepository {
  Future<void> createOrUpdateUser(User user) {}
  Future<User> getUser(String userId) {}
  Future<void> createOrJoinFamily(String familyId, User user) {}
}

class FirestoreUserRepository implements UserRepository {

  final String users = 'users';
  final String families = 'families';

  Future<void> createOrUpdateUser(User user) {
    return Firestore.instance
        .collection(users)
        .document(user.id)
        .setData(user.map);
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
        });
  }

  Future<void> createOrJoinFamily(String familyId, User user) {
    return Firestore.instance
        .collection(families)
        .document(user.familyId)
        .collection(users)
        .document(user.id)
        .setData(user.map);
  }
}