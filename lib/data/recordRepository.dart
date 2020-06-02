
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:raisingchildrenrecord2/data/FirestoreUtil.dart';
import 'package:raisingchildrenrecord2/data/firestoreErrorHandler.dart';
import 'package:raisingchildrenrecord2/model/record.dart';

class RecordRepository {
  Stream<List<Record>> observeRecords(String familyId, String babyId, {DateTime from, DateTime to}) {}
  Future<void> save(String familyId, String babyId, Record record) {}
  Future<void> delete(String familyId, String babyId, Record record) {}
  Future<List<Record>> getRecords(String familyId, String babyId, {RecordType recordType, DateTime from, DateTime to}) {}
}

class FirestoreRecordRepository with FirestoreErrorHandler, FirestoreUtil implements RecordRepository {
  static final families = 'families';
  static final babies = 'babies';
  static final records = 'records';
  Stream<List<Record>> observeRecords(String familyId, String babyId, {DateTime from, DateTime to }) {
    final fromTimeStamp = Timestamp.fromDate(from);
    final toTimeStamp = Timestamp.fromDate(to);
    return rootRef
      .collection(families)
      .document(familyId)
      .collection(babies)
      .document(babyId)
      .collection(records)
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
    return rootRef
        .collection(families)
        .document(familyId)
        .collection(babies)
        .document(babyId)
        .collection(records)
        .document(record.id)
        .setData(record.map);
  }

  Future<void> delete(String familyId, String babyId, Record record) {
    return rootRef
        .collection(families)
        .document(familyId)
        .collection(babies)
        .document(babyId)
        .collection(records)
        .document(record.id)
        .delete();
  }

  Future<List<Record>> getRecords(String familyId, String babyId, {RecordType recordType, DateTime from, DateTime to}) {
    final type = recordType.string;
    final fromTimeStamp = Timestamp.fromDate(from);
    final toTimeStamp = Timestamp.fromDate(to);
    return rootRef
      .collection(families)
      .document(familyId)
      .collection(babies)
      .document(babyId)
      .collection(records)
      .where('dateTime', isGreaterThanOrEqualTo: fromTimeStamp, isLessThan: toTimeStamp)
      .where('type', isEqualTo: type)
      .getDocuments()
      .then((querySnapshot) {
        List<DocumentSnapshot> snapshots = querySnapshot.documents;
        return snapshots
          .map((snapshot) => Record.fromSnapshot(snapshot))
          .where((record) => record != null)
          .toList();
      })
      .catchError(handleError);
  }
}