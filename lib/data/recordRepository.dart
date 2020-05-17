
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:raisingchildrenrecord2/data/firestoreErrorHandler.dart';
import 'package:raisingchildrenrecord2/model/record.dart';

class RecordRepository {
  Stream<List<Record>> observeRecords(String familyId, String babyId, { Key key, DateTime from, DateTime to}) {}
  Future<void> save(String familyId, String babyId, Record record) {}
  Future<void> delete(String familyId, String babyId, Record record) {}
}


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

  Future<void> save(String familyId, String babyId, Record record) {
    return Firestore.instance
        .collection('families')
        .document(familyId)
        .collection("babies")
        .document(babyId)
        .collection("records")
        .document(record.id)
        .setData(record.map);
  }

  Future<void> delete(String familyId, String babyId, Record record) {
    Firestore.instance
        .collection('families')
        .document(familyId)
        .collection("babies")
        .document(babyId)
        .collection("records")
        .document(record.id)
        .delete();
  }
}