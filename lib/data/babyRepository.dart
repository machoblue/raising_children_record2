
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raisingchildrenrecord2/data/FirestoreUtil.dart';
import 'package:raisingchildrenrecord2/data/firestoreErrorHandler.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/data/collectionReferenceExtension.dart';

class BabyRepository {
  Future<List<Baby>> getBabies(String familyId) {}
  Future<Baby> getBaby(String familyId, String babyId) {}
  Future<void> createOrUpdateBaby(String familyId, Baby baby) {}
  Stream<List<Baby>> observeBabies(String familyId) {}
  Future<void> deleteAllBabies(String familyId) {}
  Future<void> deleteBaby(String familyId, String babyId) {}
}

class FirestoreBabyRepository with FirestoreErrorHandler, FirestoreUtil implements BabyRepository {
  static final String families = 'families';
  static final String babies = 'babies';
  static final String records = 'records';

  Future<List<Baby>> getBabies(String familyId) async {
    return rootRef
        .collection(families)
        .document(familyId)
        .collection(babies)
        .getDocuments()
        .then((querySnapshot) {
          List<DocumentSnapshot> snapshots = querySnapshot.documents;
          return snapshots
              .map((snapshot) => Baby.fromSnapshot(snapshot))
              .where((baby) => baby != null)
              .toList();
        })
        .catchError(handleError);
  }

  Future<Baby> getBaby(String familyId, String babyId) async {
    return rootRef
        .collection(families)
        .document(familyId)
        .collection(babies)
        .document(babyId)
        .get()
        .then((documentSnapshot) {
          if (!(documentSnapshot?.exists ?? false)) {
            return null;
          }

          return Baby.fromSnapshot(documentSnapshot);
        })
        .catchError(handleError);
  }

  Future<void> createOrUpdateBaby(String familyId, Baby baby) async {
    return rootRef
        .collection(families)
        .document(familyId)
        .collection(babies)
        .document(baby.id)
        .setData(baby.map)
        .catchError(handleError);
  }

  Stream<List<Baby>> observeBabies(String familyId) {
    return rootRef
      .collection(families)
      .document(familyId)
      .collection(babies)
      .snapshots()
      .map((querySnapshot) {
        return querySnapshot.documents
          .map((snapshot) => Baby.fromSnapshot(snapshot))
          .where((baby) => baby != null)
          .toList();
      });
  }

  Future<void> deleteAllBabies(String familyId) {
    final babiesReference = rootRef
      .collection(families)
      .document(familyId)
      .collection(babies);

    return babiesReference
      .getDocuments().then((querySnapshot) async {
        List<DocumentSnapshot> snapshots = querySnapshot.documents;
        for (final snapshot in snapshots) {
          final babyReference = babiesReference.document(snapshot['id']);
          await babyReference
              .collection(records)
              .deleteAll()
              .catchError(handleError);
          await babyReference
              .delete()
              .catchError(handleError);
        }
        return;
      })
      .catchError(handleError);
  }

  Future<void> deleteBaby(String familyId, String babyId) {
    return rootRef
        .collection(families)
        .document(familyId)
        .collection(babies)
        .document(babyId)
        .delete()
        .catchError(handleError);
  }
}