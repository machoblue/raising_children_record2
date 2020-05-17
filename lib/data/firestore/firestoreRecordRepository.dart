
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:raisingchildrenrecord2/data/RecordRepository.dart';
import 'package:raisingchildrenrecord2/data/firestoreErrorHandler.dart';
import 'package:raisingchildrenrecord2/model/record.dart';

class FirestoreRecordRepository with FirestoreErrorHandler implements RecordRepository {
  Stream<List<Record>> observeRecords(String familyId, String babyId, { Key key, DateTime from, DateTime to }) {
    final fromTimeStamp = Timestamp.fromDate(from);
    final toTimeStamp = Timestamp.fromDate(to);
    return Firestore.instance
      .collection('families')
      .document(familyId)
      .collection('babies')
      .document(babyId)
      .collection('records')
      .where('dateTime', isGreaterThanOrEqualTo: fromTimeStamp, isLessThan: toTimeStamp)
      .snapshots()
      .map((recordsQuerySnapshot) {
        return recordsQuerySnapshot.documents
          .map((snapshot) => Record.fromSnapshot(snapshot))
          .where((record) => record != null)
          .toList();
      });
  }
}