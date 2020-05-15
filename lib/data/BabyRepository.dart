
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raisingchildrenrecord2/data/firestoreErrorHandler.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/shared/collectionReferenceExtension.dart';

class BabyRepository {
  Future<List<Baby>> getBabies(String familyId) {}
  Future<Baby> getBaby(String familyId, String babyId) {}
  Future<void> createOrUpdateBaby(String familyId, Baby baby) {}
  void observeBabies(String familyId, Function(List<Baby>) onBabiesUpdated) {}
  Future<void> deleteAllBabies(String familyId) {}
}

class FirestoreBabyRepository with FirestoreErrorHandler implements BabyRepository {
  static final String families = 'families';
  static final String babies = 'babies';
  static final String records = 'records';

  Future<List<Baby>> getBabies(String familyId) async {
    return Firestore.instance
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
    return Firestore.instance
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
    return Firestore.instance
        .collection(families)
        .document(familyId)
        .collection(babies)
        .document(baby.id)
        .setData(baby.map)
        .catchError(handleError);
  }

  void observeBabies(String familyId, Function(List<Baby>) onBabiesUpdated) async {
    Firestore.instance
        .collection(families)
        .document(familyId)
        .collection(babies)
        .snapshots()
        .listen((querySnapshot) {
          final List<DocumentSnapshot> snapshots = querySnapshot.documents;
          final List<Baby> babies = snapshots
              .map((snapshot) => Baby.fromSnapshot(snapshot))
              .where((baby) => baby != null)
              .toList();

          onBabiesUpdated(babies);
        });
  }

  Future<void> deleteAllBabies(String familyId) {
    final babiesReference = Firestore.instance
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
}