import 'dart:math';
import 'package:app_review/app_review.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/data/recordRepository.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:raisingchildrenrecord2/view/baseState.dart';
import 'package:raisingchildrenrecord2/view/home/homePageView.dart';
import 'package:raisingchildrenrecord2/view/home/homeViewTutorial.dart';
import 'package:raisingchildrenrecord2/view/home/record/bodyTemperatureRecordView.dart';
import 'package:raisingchildrenrecord2/view/home/record/heightRecordView.dart';
import 'package:raisingchildrenrecord2/view/home/record/mothersMilkRecordView.dart';
import 'package:raisingchildrenrecord2/view/home/record/plainRecordView.dart';
import 'package:raisingchildrenrecord2/view/home/record/milkRecordView.dart';
import 'package:raisingchildrenrecord2/view/home/record/poopRecordView.dart';
import 'package:raisingchildrenrecord2/view/home/record/weightRecordView.dart';
import 'package:raisingchildrenrecord2/view/shared/utils.dart';
import 'package:raisingchildrenrecord2/viewmodel/home/homePageViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/home/homeViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/mainViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/home/record/bodyTemperatureRecordViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/home/record/heightRecordViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/home/record/milkRecordViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/home/record/mothersMilkRecordViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/home/record/plainRecordViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/home/record/poopMilkRecordViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/home/record/weightRecordViewModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeView extends StatefulWidget {

  final void Function() onCreateRecordComplete;

  HomeView({Key key, this.onCreateRecordComplete}): super(key: key);

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
            onComplete: _onCreateRecordComplete,
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
          create: (_) => MothersMilkRecordViewModel(record, user, baby, FirestoreRecordRepository(), isNew: true),
          child: MothersMilkRecordView(
            isNew: true,
            onComplete: _onCreateRecordComplete,
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
      case RecordType.poop:
        PoopRecord record = PoopRecord.newInstance(DateTime.now(), null, user);
        return Provider<PoopRecordViewModel>(
          create: (_) => PoopRecordViewModel(record, user, baby, FirestoreRecordRepository()),
          child: PoopRecordView(
            isNew: true,
            onComplete: _onCreateRecordComplete,
          ),
        );
      case RecordType.bodyTemperature:
        BodyTemperatureRecord record = BodyTemperatureRecord.newInstance(DateTime.now(), null, user, 36.5);
        return Provider<BodyTemperatureRecordViewModel>(
          create: (_) => BodyTemperatureRecordViewModel(record, user, baby, FirestoreRecordRepository()),
          child: BodyTemperatureRecordView(
            isNew: true,
            onComplete: _onCreateRecordComplete,
          ),
        );
      case RecordType.height:
        HeightRecord record = HeightRecord.newInstance(DateTime.now(), null, user, 50.0);
        return Provider<HeightRecordViewModel>(
          create: (_) => HeightRecordViewModel(record, user, baby, FirestoreRecordRepository()),
          child: HeightRecordView(
            isNew: true,
            onComplete: _onCreateRecordComplete,
          ),
        );
      case RecordType.weight:
        WeightRecord record = WeightRecord.newInstance(DateTime.now(), null, user, 5.0);
        return Provider<WeightRecordViewModel>(
          create: (_) => WeightRecordViewModel(record, user, baby, FirestoreRecordRepository()),
          child: WeightRecordView(
            isNew: true,
            onComplete: _onCreateRecordComplete,
          ),
        );
      default:
        throw("This line shouldn't be reached.");
    }
  }

  Widget _buildPlainRecordView(Record record, User user, Baby baby) {
    return Provider<PlainRecordViewModel>(
      create: (_) => PlainRecordViewModel(record, user, baby, FirestoreRecordRepository()),
      child: PlainRecordView(
        isNew: true,
        onComplete: _onCreateRecordComplete,
      ),
    );
  }

  void _onCreateRecordComplete() {
    widget.onCreateRecordComplete();
    _requestReviewIfNeeded();
  }

  void _requestReviewIfNeeded() {
    SharedPreferences.getInstance().then((sharedPreferences) {
      final bool reviewRequestComplete = sharedPreferences.getBool('review_request_complete') ?? false;
      if (reviewRequestComplete) {
        return;
      }

      final int count = (sharedPreferences.getInt('record_count') ?? 0) + 1;
      sharedPreferences.setInt('record_count', count);
      if (count > 99) {
        L10n l10n = L10n.of(context);
        showSimpleDialog(
          context,
          title: l10n.requestReviewDialogTitle,
          content: l10n.requestReviewDialogContent,
          leftButtonTitle: l10n.requestReviewDialogNo,
          onLeftButtonPressed: () {
            sharedPreferences.setBool('review_request_complete', true);
            Navigator.pop(context);
          },
          rightButtonTitle: l10n.requestReviewDialogOK,
          onRightButtonPressed: () {
            AppReview.requestReview.then((value) {
              sharedPreferences.setBool('review_request_complete', true);
              Navigator.pop(context);
            });
          },
        );
      }
    });
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