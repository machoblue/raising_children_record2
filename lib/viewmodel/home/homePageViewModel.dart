
import 'dart:async';

import 'package:raisingchildrenrecord2/data/recordRepository.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:raisingchildrenrecord2/viewmodel/baseViewModel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

class HomePageViewModel with ViewModelErrorHandler, ViewModelInfoMessageHandler implements ViewModel {
  DateTime dateTime;
  BehaviorSubject<User> userBehaviorSubject;
  BehaviorSubject<Baby> babyBehaviorSubject;
  final RecordRepository recordRepository;

  StreamSubscription<List<Record>> _subscription;

  // Input
  final StreamController _initStateStreamController = StreamController<void>();
  StreamSink<void> get initState => _initStateStreamController.sink;

  final _editRecordStreamController = StreamController<Record>();
  StreamSink<Record> get editRecord => _editRecordStreamController.sink;

  // Output
  final StreamController _recordsStreamController = BehaviorSubject<List<Record>>.seeded([]);
  Stream<List<Record>> get records => _recordsStreamController.stream;

  final _navigationToEditRecordStreamController = StreamController<Tuple3<Record, User, Baby>>();
  Stream<Tuple3<Record, User, Baby>> get navigationToEditRecord => _navigationToEditRecordStreamController.stream;

  HomePageViewModel(this.dateTime, this.userBehaviorSubject, this.babyBehaviorSubject, this.recordRepository) {
    _bindInputAndOutput();
  }

  void _bindInputAndOutput() {
    CombineLatestStream.combine2(
      babyBehaviorSubject,
      _initStateStreamController.stream,
      (baby, _) => baby
    ).listen((baby) => _fetchRecords(baby));

    _editRecordStreamController.stream.listen((record) {
      _navigateToEditRecord(Tuple3<Record, User, Baby>(record, userBehaviorSubject.value, babyBehaviorSubject.value));
    });
  }

  void _fetchRecords(Baby baby) async {
    if (baby == null) {
      return;
    }

    final sharedPreference = await SharedPreferences.getInstance();
    final familyId = sharedPreference.getString("familyId");
    final fromDateTime = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final toDateTime = DateTime.fromMillisecondsSinceEpoch(fromDateTime.millisecondsSinceEpoch + 1000 * 60 * 60 * 24);

    _subscription = recordRepository
      .observeRecords(familyId, baby.id, from: fromDateTime, to: toDateTime)
      .listen(_recordsStreamController.sink.add);
  }

  void _navigateToEditRecord(Tuple3<Record, User, Baby> tuple3) {
    _navigationToEditRecordStreamController.sink.add(tuple3);
  }

  void dispose() {
    super.dispose();
    _initStateStreamController.close();
    _recordsStreamController.close();
    _editRecordStreamController.close();
    _navigationToEditRecordStreamController.close();
    _subscription.cancel();
  }
}