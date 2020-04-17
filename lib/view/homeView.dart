import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/viewmodel/homeViewModel.dart';

class HomeView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
//    return _HomeContainer();
    return Provider<HomeViewModel>(
      create: (_) => HomeViewModel(),
      child: _HomeContainer(),
    );
  }
}

class _HomeContainer extends StatefulWidget {
  @override
  _HomeContainerState createState() => _HomeContainerState();
}

class _HomeContainerState extends State<_HomeContainer> with TickerProviderStateMixin {

  HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = Provider.of<HomeViewModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {

    return Container(
        decoration: BoxDecoration(color: Colors.yellow),
        child: Column(
          children: <Widget>[
            Expanded(
//              child: Column(
//                  children: <Widget>[
//                    Text("aaa"),
//                    Expanded(
//                        child: ListView.builder(
//                          itemBuilder: (context, int) {
//                            return ListTile(
//                              title: Text("AAA"),
//                            );
//                          },
//                        )
//                    )
//                  ]
//              ),
              child: PageView.builder(
                itemBuilder: _buildPage,
              )
            ),
            StreamBuilder(
              stream: _viewModel.expand,
              builder: (context, snapshot) {
                final expand = snapshot.data ?? false;
                return AnimatedSize(
                  curve: Curves.easeInOut,
                  vsync: this,
                  duration: Duration(milliseconds: 200),
                  child: Container(
                    height: expand ? 200 : 100,
                    child: Column(
                      children: <Widget>[
                        FlatButton(
                          child: Text("▲"),
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
                );
              }
            )

          ],
        )
    );
  }

  Widget _buildPage(context, position) {
    print("### _buildPage");
    final value = Random().nextInt(5);
    final colors = <Color>[Colors.red, Colors.yellow, Colors.blue, Colors.green, Colors.orange];
    return Container(
      color: colors[value],
    );
  }

}
