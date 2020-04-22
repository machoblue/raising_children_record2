import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/viewmodel/homePageViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/homeViewModel.dart';
import 'package:intl/intl.dart';
import 'package:raisingchildrenrecord2/viewmodel/mainViewModel.dart';

class HomeView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Provider<HomeViewModel>(
      create: (_) => HomeViewModel(Provider.of<MainViewModel>(context).baby),
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

    _animationController = AnimationController(duration: Duration(milliseconds: 250), vsync: this);
    _animation = IntTween(begin: 1, end: 25).animate(_animationController);
    _animation.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {

    return Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 5,
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
//                      child: SingleChildScrollView(
//                          child: Text('a\na\na\na\na\na\na\na\na\na\na\na\na\na\n')
//                      ),
                      child: GridView.count(
                        crossAxisCount: 4,
                        children: <Widget>[

//                          Container(
//                            decoration: BoxDecoration(
//                              shape: BoxShape.circle,
//                              image: DecorationImage(
//                                fit: BoxFit.fitHeight,
//                                image: AssetImage("assets/milk_icon.png"),
//                              ),
//                            ),
//                            height: 48,
//                            width: 48,
//                          ),
                          FlatButton(
                            child: Image.asset(
                              "assets/milk_icon.png",
                              width: 64,
                              height: 64,
                            ),
                            onPressed: () {
                            },
                          ),
                        ],
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
      create: (_) => HomePageViewModel(dateTime, Provider.of<MainViewModel>(context).baby),
      child: _Page(dateTime: dateTime),
    );
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
  HomePageViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<HomePageViewModel>(context, listen: false);
    _viewModel.initState.add(null);
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
                      return _RecordListTile(record, l10n);
                    },
                  );
                },
              )
            )
          ],
        )
    );
  }
}

class _RecordListTile extends StatelessWidget {
  final _titleFont = TextStyle(fontSize: 22, fontWeight: FontWeight.normal,);
  final _descriptionFont = TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: Color(0x0088000000));
  final _userNameFont = TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Color(0x0088000000));

  Record record;
  L10n l10n;

  _RecordListTile(this.record, this.l10n);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 0.25, color: Color(0x0064000000)),
        ),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.fitHeight,
                    image: AssetImage(record.assetName),
                  ),
                ),
                height: 48,
                width: 48,
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                  child: Text(
                    record.title(l10n),
                    style: _titleFont,
                  ),
                )
              ),
              Expanded(
                flex: 3,
                child: Text(
                  record.description,
                  style: _descriptionFont,
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.start,
          ),
          Row(
            children: <Widget>[
              Spacer(flex: 2),
              Expanded(
                flex: 1,
                child: Row(
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
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.end,
          ),
        ],
      ),
    );
  }
}