
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:rxdart/rxdart.dart';

class RecordViewModel {
  DateFormat _dateFormat = DateFormat().add_yMd().add_Hms();

  User user;
  Baby baby;

  final StreamController<void> _onSaveButtonTappedStreamController = StreamController<void>();
  StreamSink<void> get onSaveButtonTapped => _onSaveButtonTappedStreamController.sink;

  final StreamController<DateTime> _dateTimeStreamController = BehaviorSubject.seeded(DateTime.now());
  StreamSink<DateTime> get onDateTimeSelected => _dateTimeStreamController.sink;
  Stream<DateTime> get dateTime => _dateTimeStreamController.stream;

  final StreamController<String> _noteStreamController = BehaviorSubject.seeded("");
  StreamSink<String> get onNoteChanged => _noteStreamController.sink;
  Stream<String> get note => _noteStreamController.stream;

  final StreamController<void> _onSaveCompleteStreamController = StreamController<void>();
  Stream<void> get onSaveComplete => _onSaveButtonTappedStreamController.stream;

  RecordViewModel(this.user, this.baby) {
    CombineLatestStream.combine3(
      _onSaveButtonTappedStreamController.stream,
      _dateTimeStreamController.stream,
      _noteStreamController.stream,
      (_, dateTime, note) => MilkRecord.newInstance(dateTime, note, user, 0),
    )
    .listen(_save);
  }

  void _save(MilkRecord milkRecord) async {
    print("### save $milkRecord");
  }

  void dispose() {
    _onSaveButtonTappedStreamController.close();
    _dateTimeStreamController.close();
    _noteStreamController.close();
    _onSaveCompleteStreamController.close();
  }
}