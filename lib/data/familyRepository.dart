
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raisingchildrenrecord2/data/BabyRepository.dart';
import 'package:raisingchildrenrecord2/data/firestoreErrorHandler.dart';
import 'package:raisingchildrenrecord2/model/invitationCode.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:raisingchildrenrecord2/shared/collectionReferenceExtension.dart';

class FamilyRepository {
  Future<void> createInvitationCode(InvitationCode invitationCode, String familyId) {}
  Future<void> deleteFamily(String familyId) {}
  Future<List<User>> getMembers(String familyId) {}
}

class FirestoreFamilyRepository with FirestoreErrorHandler implements FamilyRepository {
  static final String families = 'families';
  static final String invitationCodes = 'invitationCodes';
  static final String users = 'users';

  Future<void> createInvitationCode(InvitationCode invitationCode, String familyId) {
    return Firestore.instance
      .collection(families)
      .document(familyId)
      .collection(invitationCodes)
      .document(invitationCode.code)
      .setData(invitationCode.map)
      .catchError(handleError);
  }

  Future<void> deleteFamily(String familyId) {
    DocumentReference familyReference = Firestore.instance
      .collection(families)
      .document(familyId);

    return familyReference.collection(invitationCodes).deleteAll().then((_) {
      return FirestoreBabyRepository().deleteAllBabies(familyId).then((_) {
        return familyReference.delete().then((_) {
          return familyReference.collection(users).deleteAll();
        });
      });
    })
    .catchError(handleError);
  }

  Future<List<User>> getMembers(String familyId) {
    return Firestore.instance
      .collection(families)
      .document(familyId)
      .collection(users)
      .getDocuments()
      .then((querySnapshot) {
        return querySnapshot
          .documents
          .map((documentSnapshot) => User.fromSnapshot(documentSnapshot))
          .where((user) => user != null)
          .toList();
      })
      .catchError(handleError);
  }
}