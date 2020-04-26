
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:rxdart/rxdart.dart';

class RecordViewModel {
  BehaviorSubject<Record> recordBehaviorSubject;
  User user;
  Baby baby;

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

  RecordViewModel(record, this.user, this.baby) {
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

  void dispose() {
    recordBehaviorSubject.close();
    _onSaveButtonTappedStreamController.close();
    _onDateTimeSelectedStreamController.close();
    _onNoteChangedStreamController.close();
    _onSaveCompleteStreamController.close();
  }
}