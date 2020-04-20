import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
//    return _HomeContainer();
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

  HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = Provider.of<HomeViewModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {

    return Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Expanded(
              child: PageView.builder(
                controller: PageController(
                  initialPage: _pageOffset,
                ),
                itemBuilder: (context, position) => _buildPage(context, position - _pageOffset),
              )
            ),
            StreamBuilder(
              stream: _viewModel.expand,
              builder: (context, snapshot) {
                final expand = snapshot.data ?? false;
                return AnimatedSize(
                  curve: Curves.easeInOut,
                  vsync: this,
                  duration: Duration(milliseconds: 150),
                  child: ConstrainedBox(
                    constraints: BoxConstraints.expand(height: expand ? 200 : 100),
                    child: Container(
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
                      child: Column(
                        children: <Widget>[
                          FlatButton(
                            child: Text(expand ? "▼" : "▲"),
                            onPressed: () => _viewModel.onButtonTapped.add(null),
                          ),
                          Expanded(
                              child: SingleChildScrollView(
                                  child: Text('a\na\na\na\na\na\na\na\na\na\na\na\na\na\n')
                              )
                          )
                        ]
                      )
                    )
                  )
                );
              }
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
                      return ListTile(
                        title: Text(records[index].type ?? ''),
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
}