import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:raisingchildrenrecord2/viewmodel/mainViewModel.dart';
import 'package:raisingchildrenrecord2/view/settingsView.dart';
import 'package:raisingchildrenrecord2/view/homeView.dart';

class MainView extends StatefulWidget {
  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  List<String> _appBarTitles = ["Home", "Settings"];
  List<Widget> _widgetOptions = <Widget>[
    HomeView(),
    SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Provider<MainViewModel>(
      create: (_) => MainViewModel(),
      child: Builder(
        builder: (context) {
          return StreamBuilder(
            stream: Provider.of<MainViewModel>(context).selectedIndex,
            builder: (context, snapshot) {
              final selectedIndex = snapshot.data ?? 0;
              return Scaffold(
                appBar: AppBar(
                  leading: selectedIndex == 0 ? Container(
                    padding: EdgeInsets.fromLTRB(8, 0, 0, 8),
                    child: GestureDetector(
                      onTap: () => Provider.of<MainViewModel>(context).onBabyButtonTapped.add(null),
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
                  items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      title: Text('Home'),
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.settings),
                      title: Text('Settings'),
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
      )
    );
  }
}