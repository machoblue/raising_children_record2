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

class _HomeContainerState extends State<_HomeContainer> {

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
              child: Column(
                  children: <Widget>[
                    Text("aaa"),
                    Expanded(
                        child: ListView.builder(
                          itemBuilder: (context, int) {
                            return ListTile(
                              title: Text("AAA"),
                            );
                          },
                        )
                    )
                  ]
              ),
            ),
            StreamBuilder(
              stream: _viewModel.expand,
              builder: (context, snapshot) {
                final expand = snapshot.data ?? false;
                return  ConstrainedBox(
                    constraints: BoxConstraints.expand(height: expand ? 200 : 100),
                    child: Column(
                        children: <Widget>[
//                  Text("aaa"),
                          RaisedButton(
                            child: Text("▲"),
                            onPressed: () => _viewModel.onButtonTapped.add(null),
                          ),
                          Expanded(
                              child: SingleChildScrollView(
                                  child: Text('a\na\na\na\na\na\na\na\na\na\na\na\na\na\na\na\n')
                              )
                          )
                        ]
                    ),
                  );
              }
            )

          ],
        )
    );
  }
}