
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raisingchildrenrecord2/data/firestoreErrorHandler.dart';
import 'package:raisingchildrenrecord2/model/invitationCode.dart';

class FamilyRepository {
  Future<void> createInvitationCode(InvitationCode invitationCode, String familyId) {}
}

class FirestoreFamilyRepository with FirestoreErrorHandler implements FamilyRepository {
  static final String families = 'families';
  static final String invitationCodes = 'invitationCodes';

  Future<void> createInvitationCode(InvitationCode invitationCode, String familyId) {
    return Firestore.instance
      .collection(families)
      .document(familyId)
      .collection(invitationCodes)
      .document(invitationCode.code)
      .setData(invitationCode.map)
      .catchError(handleError);
  }
}