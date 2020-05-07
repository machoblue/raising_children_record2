
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raisingchildrenrecord2/model/user.dart';

class UserRepository {
  Future<void> createUser(User user) {}
}

class FirestoreUserRepository implements UserRepository {

  final String users = 'users';
  final String families = 'families';

  Future<void> createUser(User user) {
    return Firestore.instance
        .collection(users)
        .document(user.id)
        .setData(user.map);
  }

  Future<User> getUser(String userId) {
    Firestore.instance
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

  Future<void> createFamilyOrJoinFamily(String familyId, User user) {
    return Firestore.instance
        .collection(families)
        .document(user.familyId)
        .collection(users)
        .document(user.id)
        .setData(user.map);
  }
}