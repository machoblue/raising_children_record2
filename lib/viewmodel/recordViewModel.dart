
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:rxdart/rxdart.dart';

class RecordViewModel {
  BehaviorSubject<Record> recordBehaviorSubject;
  User user;
  Baby baby;
  L10n l10n;

  Stream<String> get assetName => recordBehaviorSubject.stream.map((record) => record.assetName);
  Stream<String> get title => recordBehaviorSubject.stream.map((record) => record.title(l10n));

  final StreamController<void> _onSaveButtonTappedStreamController = StreamController<void>();
  StreamSink<void> get onSaveButtonTapped => _onSaveButtonTappedStreamController.sink;

  Stream<DateTime> get dateTime => recordBehaviorSubject.stream.map((record) => record.dateTime);
  final StreamController<DateTime> _onDateTimeSelectedStreamController = StreamController<DateTime>();
  StreamSink<DateTime> get onDateTimeSelected => _onDateTimeSelectedStreamController.sink;

  Stream<String> get note => recordBehaviorSubject.stream.map((record) => record.note);
  final StreamController<String> _onNoteChangedStreamController = StreamController<String>();
  StreamSink<String> get onNoteChanged => _onNoteChangedStreamController.sink;

  final StreamController<void> _onSaveCompleteStreamController = StreamController<void>();
  Stream<void> get onSaveComplete => _onSaveCompleteStreamController.stream;

  final StreamController<void> _onDeleteButtonTappedStreamController = StreamController<void>();
  StreamSink<void> get onDeleteButtonTapped => _onDeleteButtonTappedStreamController.sink;

  RecordViewModel(record, this.user, this.baby, this.l10n) {
    print("### record.note: ${record.note}");
    recordBehaviorSubject = BehaviorSubject.seeded(record);

    _onDateTimeSelectedStreamController.stream.listen((date) {
      Record record = recordBehaviorSubject.value;
      record.dateTime = date;
      recordBehaviorSubject.add(record);
    });

    _onNoteChangedStreamController.stream.listen((note) {
      Record record = recordBehaviorSubject.value;
      record.note = note;
      recordBehaviorSubject.add(record);
    });

    CombineLatestStream.combine2(
        recordBehaviorSubject,
        _onSaveButtonTappedStreamController.stream,
            (record, _) => record
    )
    .listen((record) => _save(record));

    CombineLatestStream.combine2(
      recordBehaviorSubject,
      _onDeleteButtonTappedStreamController.stream,
      (record, _) => record
    )
    .listen((record) => _delete(record));
  }

  void _save(Record record) async {
    print("### save $record");
    Firestore.instance
        .collection('families')
        .document(user.familyId)
        .collection("babies")
        .document(baby.id)
        .collection("records")
        .document(record.id)
        .setData(record.map);

    _onSaveCompleteStreamController.sink.add(null);
  }

  void _delete(Record record) async {
    Firestore.instance
        .collection('families')
        .document(user.familyId)
        .collection("babies")
        .document(baby.id)
        .collection("records")
        .document(record.id)
        .delete();

    _onSaveCompleteStreamController.sink.add(null);
  }

  void dispose() {
    recordBehaviorSubject.close();
    _onSaveButtonTappedStreamController.close();
    _onDateTimeSelectedStreamController.close();
    _onNoteChangedStreamController.close();
    _onSaveCompleteStreamController.close();
    _onDeleteButtonTappedStreamController.close();
  }
}