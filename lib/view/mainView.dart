import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';

import 'package:raisingchildrenrecord2/viewmodel/mainViewModel.dart';
import 'package:raisingchildrenrecord2/view/settingsView.dart';
import 'package:raisingchildrenrecord2/view/homeView.dart';

class MainView extends StatefulWidget {
  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {

  @override
  Widget build(BuildContext context) {
    return Provider<MainViewModel>(
      create: (_) => MainViewModel(),
      child: _MainScaffold()
    );
  }
}

class _MainScaffold extends StatefulWidget {
  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<_MainScaffold> {

  List<String> _appBarTitles;
  List<Widget> _widgetOptions = <Widget>[
    HomeView(),
    SettingsView(),
  ];

  MainViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<MainViewModel>(context, listen: false);
    _viewModel.onInitState.add(null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    _appBarTitles = [l10n.homeTitle, l10n.settingsTitle];

    return StreamBuilder(
      stream: _viewModel.selectedIndex,
      builder: (context, snapshot) {
        final selectedIndex = snapshot.data ?? 0;
        return Scaffold(
          appBar: AppBar(
            leading: selectedIndex == 0 ? Container(
                padding: EdgeInsets.fromLTRB(8, 0, 0, 8),
                child: GestureDetector(
                  onTap: () => _viewModel.onBabyButtonTapped.add(null),
                  child: StreamBuilder(
                    stream: Provider.of<MainViewModel>(context).babyIconImageProvider,
                    builder: (context, snapshot) {
                      return Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.fitHeight,
                              image: snapshot.data ?? AssetImage("assets/default_baby_icon.png"),
                            )
                        ),
                      );
                    },
                  ),
                )
            ) : Container(),
            title: Text(_appBarTitles[selectedIndex]),
          ),
          body: _widgetOptions.elementAt(selectedIndex),
          bottomNavigationBar: BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  title: Text(l10n.homeTitle),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  title: Text(l10n.settingsTitle),
                ),
              ],
              currentIndex: selectedIndex,
              selectedItemColor: Colors.amber[800],
              onTap: (index) {
                print("### $index");
                Provider
                    .of<MainViewModel>(context)
                    .onTabItemTapped
                    .add(index);
              }
          ),
        );
      },
    );
  }
}