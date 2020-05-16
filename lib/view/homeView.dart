import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:raisingchildrenrecord2/view/baseState.dart';
import 'package:raisingchildrenrecord2/view/homePageView.dart';
import 'package:raisingchildrenrecord2/view/record/plainRecordView.dart';
import 'package:raisingchildrenrecord2/view/record/milkRecordView.dart';
import 'package:raisingchildrenrecord2/viewmodel/homePageViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/homeViewModel.dart';
import 'package:intl/intl.dart';
import 'package:raisingchildrenrecord2/viewmodel/mainViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/record/milkRecordViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/record/plainRecordViewModel.dart';

class HomeView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends BaseState<HomeView, HomeViewModel> with TickerProviderStateMixin {
  final _pageOffset = 1000; // value enough big
  final _buttonLabelFont = TextStyle(fontSize: 12, color: Color(0x00FF888888));
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
        return HomePageViewModel(dateTime, mainViewModel.userBehaviorSubject, mainViewModel.babyBehaviorSubject);
      },
      child: HomePageView(dateTime: dateTime),
    );
  }

  List<Widget> _buildGridItems(List<RecordType> recordTypes) {
    return recordTypes.map((recordType) {
      return FlatButton(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              recordType.assetName,
              width: 64,
              height: 64,
            ),
            Text(
              recordType.localizedName,
              style: _buttonLabelFont,
            )
          ],
        ),
        onPressed: () => viewModel.addRecord.add(recordType),
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
        return Provider<MilkRecordViewModel>(
          create: (_) => MilkRecordViewModel(record, user, baby),
          child: MilkRecordView(isNew: true),
        );
      }
      case RecordType.snack: {
        SnackRecord record = SnackRecord.newInstance(DateTime.now(), null, user);
        return Provider<PlainRecordViewModel>(
          create: (_) => PlainRecordViewModel(record, user, baby),
          child: PlainRecordView(isNew: true),
        );
      }
      case RecordType.babyFood: {
        BabyFoodRecord record = BabyFoodRecord.newInstance(DateTime.now(), null, user);
        return Provider<PlainRecordViewModel>(
          create: (_) => PlainRecordViewModel(record, user, baby),
          child: PlainRecordView(isNew: true),
        );
      }
      default: {
        throw("This line shouldn't be reached.");
      }
    }
  }
}

