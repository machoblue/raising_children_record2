
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:raisingchildrenrecord2/view/baseState.dart';
import 'package:raisingchildrenrecord2/view/record/milkRecordView.dart';
import 'package:raisingchildrenrecord2/view/record/plainRecordView.dart';
import 'package:raisingchildrenrecord2/viewmodel/homePageViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/record/milkRecordViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/record/plainRecordViewModel.dart';

class HomePageView extends StatefulWidget {
  final _biggerFont = const TextStyle(fontSize: 24.0);

  HomePageView({Key key, this.dateTime}) : super(key: key);

  final DateTime dateTime;

  @override
  State<StatefulWidget> createState() {
    return _HomePageViewState();
  }
}

class _HomePageViewState extends BaseState<HomePageView, HomePageViewModel> {
  final TextStyle _emptyMessageFont = TextStyle(fontSize: 14, color: Color(0x00FFAAAAAA));
  final DateFormat _timeFormat = DateFormat().add_Hm();

  @override
  void initState() {
    super.initState();
    viewModel.initState.add(null);
    viewModel.navigationToEditRecord.listen((tuple3) => _editRecord(tuple3.item1, tuple3.item2, tuple3.item3));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Container(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10),
              child: Text(
                DateFormat().add_yMd().format(widget.dateTime),
                style: widget._biggerFont,
              ),
            ),
            Expanded(
                child: StreamBuilder(
                  stream: viewModel.records,
                  builder: (context, snapshot) {
                    final List<Record> records = snapshot.data ?? [];
                    return records.isEmpty
                        ? Container(
                        padding: EdgeInsets.all(16),
                        alignment: Alignment.topCenter,
                        child: Text(
                          l10n.emptyMessage,
                          style: _emptyMessageFont,
                        )
                    )
                        : ListView.builder(
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        final record = records[index];
                        return GestureDetector(
                          onTap: () => viewModel.editRecord.add(record),
                          child: _RecordListTile(record, l10n, _timeFormat),
                        );
                      },
                    );
                  },
                )
            )
          ],
        )
    );
  }

  void _editRecord(Record record, User user, Baby baby) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) {
              return _buildRecordView(record, user, baby);
            }
        )
    );
  }

  Widget _buildRecordView(Record record, User user, Baby baby) {
    switch(record.runtimeType) {
      case MilkRecord: {
        return Provider<MilkRecordViewModel>(
          create: (_) => MilkRecordViewModel(record, user, baby),
          child: MilkRecordView(),
        );
      }
      case SnackRecord: {
        return Provider<PlainRecordViewModel>(
          create: (_) => PlainRecordViewModel(record, user, baby),
          child: PlainRecordView(),
        );
      }
      case BabyFoodRecord: {
        return Provider<PlainRecordViewModel>(
          create: (_) => PlainRecordViewModel(record, user, baby),
          child: PlainRecordView(),
        );
      }
      default: {
        throw("This line shouldn't be reached.");
      }
    }
  }
}

class _RecordListTile extends StatelessWidget {
  final _timeFont = TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: Color(0x0088000000));
  final _mainDescriptionFont = TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0x0088000000));
  final _subDescriptionFont = TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Color(0x0088000000));
  final _userNameFont = TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Color(0x0088000000));

  Record record;
  L10n l10n;
  DateFormat timeFormat;

  _RecordListTile(this.record, this.l10n, this.timeFormat);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 0.25, color: Color(0x0064000000)),
        ),
      ),
      child: Row(
          children: <Widget>[
            Text(
              timeFormat.format(record.dateTime),
              style: _timeFont,
            ),
            Container(
              width: 16,
            ),
            Column(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.fitHeight,
                      image: AssetImage(record.type.assetName),
                    ),
                  ),
                  height: 48,
                  width: 48,
                ),
                Text(
                  record.type.localizedName,
                )
              ],
            ),
            Container(
                width: 16
            ),
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      record.mainDescription,
                      style: _mainDescriptionFont,
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      record.subDescription ?? "",
                      style: _subDescriptionFont,
                      textAlign: TextAlign.start,
                    ),
                    Row(
                      children: <Widget>[
                        Spacer(flex: 2),
                        Row(
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  fit: BoxFit.fitHeight,
                                  image: CachedNetworkImageProvider(record.user.photoUrl),
                                ),
                              ),
                              height: 24,
                              width: 24,
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                              child: Text(
                                record.user.name,
                                style: _userNameFont,
                              ),
                            ),
                          ],
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.end,
                    ),
                  ],
                )
            ),
          ]
      ),
    );
  }
}