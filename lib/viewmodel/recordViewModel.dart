
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

class RecordViewModel {
  DateFormat _dateFormat = DateFormat().add_yMd().add_Hms();

  final StreamController<void> _onSaveButtonTappedStreamController = StreamController<void>();
  StreamSink<void> get onSaveButtonTapped => _onSaveButtonTappedStreamController.sink;
  Stream<void> get save => _onSaveButtonTappedStreamController.stream;

  // OUTPUT
  final StreamController<DateTime> _dateTimeStreamController = BehaviorSubject.seeded(DateTime.now());
  StreamSink<DateTime> get onDateTimeSelected => _dateTimeStreamController.sink;
  Stream<DateTime> get dateTime => _dateTimeStreamController.stream;

  RecordViewModel() {
    save.listen((_) => print("### save"));
  }

  void dispose() {
    _onSaveButtonTappedStreamController.close();

  }
}