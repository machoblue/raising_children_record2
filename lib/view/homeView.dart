import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:raisingchildrenrecord2/view/record/plainRecordView.dart';
import 'package:raisingchildrenrecord2/view/record/milkRecordView.dart';
import 'package:raisingchildrenrecord2/viewmodel/homePageViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/homeViewModel.dart';
import 'package:intl/intl.dart';
import 'package:raisingchildrenrecord2/viewmodel/mainViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/record/plainRecordViewModel.dart';

class HomeView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Provider<HomeViewModel>(
      create: (_) {
        MainViewModel mainViewModel = Provider.of<MainViewModel>(context);
        return HomeViewModel(mainViewModel.user, mainViewModel.baby);
      },
      child: _HomeContainer(),
    );
  }
}

class _HomeContainer extends StatefulWidget {
  @override
  _HomeContainerState createState() => _HomeContainerState();
}

class _HomeContainerState extends State<_HomeContainer> with TickerProviderStateMixin {
  final _pageOffset = 1000; // value enough big
  AnimationController _animationController;
  Animation _animation;

  HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = Provider.of<HomeViewModel>(context, listen: false);
    _viewModel.navigationToAddRecord.listen((tuple3) => _addRecord(tuple3.item1, tuple3.item2, tuple3.item3));

    _animationController = AnimationController(duration: Duration(milliseconds: 250), vsync: this);
    _animation = IntTween(begin: 1, end: 4).animate(_animationController);
    _animation.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {

    return Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: PageView.builder(
                controller: PageController(
                  initialPage: _pageOffset,
                ),
                itemBuilder: (context, position) => _buildPage(context, position - _pageOffset),
              )
            ),
            Expanded(
              flex: _animation.value,
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    FlatButton(
                      child: Image(
                        height: 14,
                        width: 80,
                        image: AssetImage(_animation.value == 1 ? "assets/open.png" : "assets/close.png"),
                        color: Color.fromARGB(36, 0, 0, 0),
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onPressed: () {
                        if (_animation.value == 1) {
                          _animationController.forward();
                        } else {
                          _animationController.reverse();
                        }
                      },

                    ),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 4,
                        children: _buildGridItems(),
                      )
                    )

                  ]
                ),
                padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 20.0,
                      spreadRadius: 5.0,
                      offset: Offset(
                        10.0,
                        10.0,
                      ),
                    )
                  ],
                ),
              )
            )
          ],
        )
    );
  }

  Widget _buildPage(context, position) {
    final DateTime dateTime = DateTime.now().add(Duration(days: position));
    return Provider(
      create: (_) {
        MainViewModel mainViewModel = Provider.of<MainViewModel>(context);
        return HomePageViewModel(dateTime, mainViewModel.user, mainViewModel.baby);
      },
      child: _Page(dateTime: dateTime),
    );
  }

  List<Widget> _buildGridItems() {
    return RecordType.values.map((recordType) {
      return FlatButton(
        child: Image.asset(
          recordType.assetName,
          width: 64,
          height: 64,
        ),
        onPressed: () => _viewModel.addRecord.add(recordType),
      );
    }).toList();
  }

  void _addRecord(RecordType recordType, User user, Baby baby) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return _buildRecordView(recordType, user, baby);
        }
      )
    );
  }

  Widget _buildRecordView(RecordType recordType, User user, Baby baby) {
    switch (recordType) {
      case RecordType.milk: {
        MilkRecord record = MilkRecord.newInstance(DateTime.now(), null, user, 0);
        return MilkRecordView(record: record, user: user, baby: baby, isNew: true);
      }
      case RecordType.snack: {
        SnackRecord record = SnackRecord.newInstance(DateTime.now(), null, user);
        return Provider(
          create: (_) => PlainRecordViewModel(record, user, baby),
          child: PlainRecordView<PlainRecordViewModel>(isNew: true),
        );
      }
      default: {
        throw("This line shouldn't be reached.");
      }
    }
  }
}

class _Page extends StatefulWidget {
  final _biggerFont = const TextStyle(fontSize: 24.0);

  _Page({Key key, this.dateTime}) : super(key: key);

  final DateTime dateTime;

  @override
  State<StatefulWidget> createState() {
    return _PageState();
  }
}


class _PageState extends State<_Page> {
  final DateFormat _timeFormat = DateFormat().add_Hm();
  HomePageViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<HomePageViewModel>(context, listen: false);
    _viewModel.initState.add(null);
    _viewModel.navigationToEditRecord.listen((tuple3) => _editRecord(tuple3.item1, tuple3.item2, tuple3.item3));
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
                stream: _viewModel.records,
                builder: (context, snapshot) {
                  final List<Record> records = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      return GestureDetector(
                        onTap: () => _viewModel.editRecord.add(record),
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
        return MilkRecordView(record: record, user: user, baby: baby);
      }
      case SnackRecord: {
//        return PlainRecordView(record: record, user: user, baby: baby);
        return Provider(
          create: (_) => PlainRecordViewModel(record, user, baby),
          child: PlainRecordView<PlainRecordViewModel>(),
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
//      child: Column(
//        children: <Widget>[
//          Row(
//            children: <Widget>[
//              Container(
//                decoration: BoxDecoration(
//                  shape: BoxShape.circle,
//                  image: DecorationImage(
//                    fit: BoxFit.fitHeight,
//                    image: AssetImage(record.assetName),
//                  ),
//                ),
//                height: 48,
//                width: 48,
//              ),
//              Expanded(
//                  flex: 2,
//                  child: Container(
//                    padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
//                    child: Text(
//                      record.title(l10n),
//                      style: _titleFont,
//                    ),
//                  )
//              ),
//              Expanded(
//                flex: 3,
//                child: Text(
//                  record.description,
//                  style: _descriptionFont,
//                ),
//              ),
//            ],
//            mainAxisAlignment: MainAxisAlignment.start,
//          ),
//          Row(
//            children: <Widget>[
//              Spacer(flex: 2),
//              Expanded(
//                flex: 1,
//                child: Row(
//                  children: <Widget>[
//                    Container(
//                      decoration: BoxDecoration(
//                        shape: BoxShape.circle,
//                        image: DecorationImage(
//                          fit: BoxFit.fitHeight,
//                          image: CachedNetworkImageProvider(record.user.photoUrl),
//                        ),
//                      ),
//                      height: 24,
//                      width: 24,
//                    ),
//                    Container(
//                      padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
//                      child: Text(
//                        record.user.name,
//                        style: _userNameFont,
//                      ),
//                    ),
//                  ],
//                ),
//              ),
//            ],
//            mainAxisAlignment: MainAxisAlignment.end,
//          ),
//        ],
//      ),
    );
  }
}