import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/data/recordRepository.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:raisingchildrenrecord2/view/baseState.dart';
import 'package:raisingchildrenrecord2/view/homePageView.dart';
import 'package:raisingchildrenrecord2/view/homeViewTutorial.dart';
import 'package:raisingchildrenrecord2/view/record/mothersMilkRecordView.dart';
import 'package:raisingchildrenrecord2/view/record/plainRecordView.dart';
import 'package:raisingchildrenrecord2/view/record/milkRecordView.dart';
import 'package:raisingchildrenrecord2/viewmodel/homePageViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/homeViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/mainViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/record/milkRecordViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/record/mothersMilkRecordViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/record/plainRecordViewModel.dart';

class HomeView extends StatefulWidget {

  final void Function() onComplete;

  HomeView({Key key, this.onComplete}): super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends BaseState<HomeView, HomeViewModel> with TickerProviderStateMixin, HomeViewTutorial {
  final _pageOffset = 1000; // value enough big
  AnimationController _animationController;
  Animation _animation;

  @override
  void initState() {
    super.initState();

    viewModel = Provider.of<HomeViewModel>(context, listen: false);
    viewModel.navigationToAddRecord.listen((tuple3) => _addRecord(tuple3.item1, tuple3.item2, tuple3.item3));

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
                      child: StreamBuilder(
                        stream: viewModel.recordTypes,
                        builder: (context, snapshot) {
                          return !snapshot.hasData
                            ? Container()
                            : GridView.count(
                              crossAxisCount: 4,
                              children: _buildGridItems(snapshot.data),
                            );
                        }
                      ),
                    ),
                  ],
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
        return HomePageViewModel(dateTime, mainViewModel.userBehaviorSubject, mainViewModel.babyBehaviorSubject, FirestoreRecordRepository());
      },
      child: HomePageView(dateTime: dateTime),
    );
  }

  List<Widget> _buildGridItems(List<RecordType> recordTypes) {
    List<Widget> items = [];
    for (int i = 0; i < recordTypes.length; i++) {
      RecordType recordType = recordTypes[i];
      items.add(RecordButton(
        key: i == 0 ? firstRecordButtonKey : null,
        recordType: recordType,
        onPressed: () => viewModel.addRecord.add(recordType),
      ));
    }
    return items;
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
      case RecordType.milk:
        MilkRecord record = MilkRecord.newInstance(DateTime.now(), null, user, 0);
        return Provider<MilkRecordViewModel>(
          create: (_) => MilkRecordViewModel(record, user, baby, FirestoreRecordRepository()),
          child: MilkRecordView(
            isNew: true,
            onComplete: widget.onComplete,
          ),
        );
      case RecordType.snack:
        SnackRecord record = SnackRecord.newInstance(DateTime.now(), null, user);
        return _buildPlainRecordView(record, user, baby);
      case RecordType.babyFood:
        BabyFoodRecord record = BabyFoodRecord.newInstance(DateTime.now(), null, user);
        return _buildPlainRecordView(record, user, baby);
      case RecordType.mothersMilk:
        MothersMilkRecord record = MothersMilkRecord.newInstance(DateTime.now(), null, user);
        return Provider<MothersMilkRecordViewModel>(
          create: (_) => MothersMilkRecordViewModel(record, user, baby, FirestoreRecordRepository()),
          child: MothersMilkRecordView(
            isNew: true,
            onComplete: widget.onComplete,
          ),
        );
      case RecordType.vomit:
        VomitRecord record = VomitRecord.newInstance(DateTime.now(), null, user);
        return _buildPlainRecordView(record, user, baby);
      case RecordType.cough:
        CoughRecord record = CoughRecord.newInstance(DateTime.now(), null, user);
        return _buildPlainRecordView(record, user, baby);
      case RecordType.rash:
        RashRecord record = RashRecord.newInstance(DateTime.now(), null, user);
        return _buildPlainRecordView(record, user, baby);
      case RecordType.medicine:
        MedicineRecord record = MedicineRecord.newInstance(DateTime.now(), null, user);
        return _buildPlainRecordView(record, user, baby);
      case RecordType.pee:
        PeeRecord record = PeeRecord.newInstance(DateTime.now(), null, user);
        return _buildPlainRecordView(record, user, baby);
      case RecordType.etc:
        EtcRecord record = EtcRecord.newInstance(DateTime.now(), null, user);
        return _buildPlainRecordView(record, user, baby);
      case RecordType.sleep:
        SleepRecord record = SleepRecord.newInstance(DateTime.now(), null, user);
        return _buildPlainRecordView(record, user, baby);
      case RecordType.awake:
        AwakeRecord record = AwakeRecord.newInstance(DateTime.now(), null, user);
        return _buildPlainRecordView(record, user, baby);
      default:
        throw("This line shouldn't be reached.");
    }
  }

  Widget _buildPlainRecordView(Record record, User user, Baby baby) {
    return Provider<PlainRecordViewModel>(
      create: (_) => PlainRecordViewModel(record, user, baby, FirestoreRecordRepository()),
      child: PlainRecordView(
        isNew: true,
        onComplete: widget.onComplete,
      ),
    );
  }
}

class RecordButton extends StatefulWidget {
  final RecordType recordType;
  final void Function() onPressed;

  RecordButton({ Key key, this.recordType, this.onPressed }): super(key: key);

  @override
  RecordButtonState createState() => RecordButtonState();
}

class RecordButtonState extends State<RecordButton> {
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            widget.recordType.assetName,
            width: 64,
            height: 64,
          ),
          Text(
            widget.recordType.localizedName,
            style: TextStyle(
              fontSize: min(12, 12 / (widget.recordType.localizedName.length / 10)),
              color: Color(0x00FF888888),
            ),
          )
        ],
      ),
      onPressed: widget.onPressed,
    );
  }
}