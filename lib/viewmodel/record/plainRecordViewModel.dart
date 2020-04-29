
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:raisingchildrenrecord2/viewmodel/record/baseRecordViewModel.dart';

class PlainRecordViewModel extends BaseRecordViewModel<Record> {
  PlainRecordViewModel(Record record, User user, Baby baby): super(record, user, baby);
}