
import 'package:cloud_firestore/cloud_firestore.dart';

extension CollectionReferenceExtension on CollectionReference {
  Future<void> deleteAll() {
    return this.getDocuments()
      .then((querySnapshot) async {
        List<DocumentSnapshot> snapshotList = querySnapshot.documents;
        for (var snapshot in snapshotList) {
            await this.document(snapshot['id']).delete();
        }
        return;
    });
  }
}