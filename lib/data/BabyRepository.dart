
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BabyRepository {
  Future<List<Baby>> getBabies(String familyId) {}
  Future<Baby> getBaby(String familyId, String babyId) {}
  Future<void> createOrUpdateBaby(String familyId, Baby baby) {}
  void observeBabies(String familyId, Function(List<Baby>) onBabiesUpdated) {}
}

class FirestoreBabyRepository implements BabyRepository {
  static final String families = 'families';
  static final String babies = 'babies';

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
        });
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
        });
  }

  Future<void> createOrUpdateBaby(String familyId, Baby baby) async {
    return Firestore.instance
        .collection(families)
        .document(familyId)
        .collection(babies)
        .document(baby.id)
        .setData(baby.map);
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
}