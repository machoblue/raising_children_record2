
import 'dart:async';
import 'package:raisingchildrenrecord2/data/recordRepository.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:raisingchildrenrecord2/viewmodel/baseViewModel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BaseRecordViewModel<R extends Record> with ViewModelErrorHandler implements ViewModel {
  BehaviorSubject<R> recordBehaviorSubject;
  User user;
  Baby baby;
  RecordRepository recordRepository;

  Stream<String> get assetName => recordBehaviorSubject.stream.map((record) => record.type.assetName);
  Stream<String> get title => recordBehaviorSubject.stream.map((record) => record.type.localizedName);

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

  BaseRecordViewModel(R record, this.user, this.baby, this.recordRepository, { bool isNew = false }) {
    recordBehaviorSubject = BehaviorSubject.seeded(record);

    if (isNew) {
      _applyDefaultValues(baby.id, record).then((record) {
        recordBehaviorSubject.add(record);
      });
    }

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
    recordRepository
      .save(user.familyId, baby.id, record)
      .catchError(handleError);

    _saveDefaultValues(baby.id, record);

    _onSaveCompleteStreamController.sink.add(null);
  }

  void _delete(Record record) async {
    recordRepository
      .delete(user.familyId, baby.id, record)
      .catchError(handleError);

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

  void _saveDefaultValues(String babyId, Record record) {
    // record_default_${baby.id}_${recordType.string}_${fieldName}
    SharedPreferences.getInstance().then((sharedPreference) {
      switch (record.runtimeType) {
        case MothersMilkRecord:
          final mothersMilkRecord = record as MothersMilkRecord;
          sharedPreference.setInt('record_default_${babyId}_${RecordType.mothersMilk.string}_leftMilliseconds', mothersMilkRecord.leftMilliseconds);
          sharedPreference.setInt('record_default_${babyId}_${RecordType.mothersMilk.string}_rightMilliseconds', mothersMilkRecord.rightMilliseconds);
          break;
        case MilkRecord:
          final milkRecord = record as MilkRecord;
          sharedPreference.setInt('record_default_${babyId}_${RecordType.milk.string}_amount', milkRecord.amount);
          break;
        case HeightRecord:
          final heightRecord = record as HeightRecord;
          sharedPreference.setDouble('record_default_${babyId}_${RecordType.height.string}_height', heightRecord.height);
          break;
        case WeightRecord:
          final weightRecord = record as WeightRecord;
          sharedPreference.setDouble('record_default_${babyId}_${RecordType.weight.string}_weight', weightRecord.weight);
          break;
        default:
          break; // do nothing
      }
    });
  }

  Future<R> _applyDefaultValues(String babyId, R record) {
    return SharedPreferences.getInstance().then((sharedPreference) {
      switch (record.runtimeType) {
        case MothersMilkRecord:
          MothersMilkRecord mothersMilkRecord = record as MothersMilkRecord;
          mothersMilkRecord.leftMilliseconds = sharedPreference.getInt('record_default_${babyId}_${RecordType.mothersMilk.string}_leftMilliseconds');
          mothersMilkRecord.rightMilliseconds = sharedPreference.getInt('record_default_${babyId}_${RecordType.mothersMilk.string}_rightMilliseconds');
          break;
        case MilkRecord:
          MilkRecord milkRecord = record as MilkRecord;
          milkRecord.amount = sharedPreference.getInt('record_default_${babyId}_${RecordType.milk.string}_amount');
          break;
        case HeightRecord:
          final heightRecord = record as HeightRecord;
          heightRecord.height = sharedPreference.getDouble('record_default_${babyId}_${RecordType.height.string}_height') ?? 50.0;
          break;
        case WeightRecord:
          final weightRecord = record as WeightRecord;
          weightRecord.weight = sharedPreference.getDouble('record_default_${babyId}_${RecordType.weight.string}_weight') ?? 5.0;
          break;
        default:
          break; // do nothing
      }

      return record;
    });
  }
}