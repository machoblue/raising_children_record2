
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';

class BabyRepository {
  Future<List<Baby>> getBabies() {}
  Future<Baby> getBaby(String babyId) {}
  Future<void> createOrUpdateBaby(Baby baby) {}
  void observeBabies(Function(List<Baby>) onBabiesUpdated) {}
}

class FirestoreBabyRepository {
  static final String families = 'families';
  static final String babies = 'babies';

  final String familyId;

  FirestoreBabyRepository(this.familyId);

  Future<List<Baby>> getBabies() async {
    QuerySnapshot querySnapshot = await Firestore.instance
        .collection(families)
        .document(familyId)
        .collection(babies)
        .getDocuments();

    List<DocumentSnapshot> snapshots = querySnapshot.documents;

    return snapshots
        .map((snapshot) => Baby.fromSnapshot(snapshot))
        .where((baby) => baby != null)
        .toList();
  }

  Future<Baby> getBaby(String babyId) {}

  Future<void> createOrUpdateBaby(Baby baby) {
    return Firestore.instance
        .collection(families)
        .document(familyId)
        .collection(babies)
        .document(baby.id)
        .setData(baby.map);
  }

  void observeBabies(Function(List<Baby>) onBabiesUpdated) {
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