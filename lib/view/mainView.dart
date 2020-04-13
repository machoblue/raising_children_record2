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
              return Scaffold(
                appBar: AppBar(
                  leading: Container(
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
                  ),
                  title: Text(_appBarTitles[snapshot.data ?? 0]),
                ),
                body: _widgetOptions.elementAt(snapshot.data ?? 0),
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
                  currentIndex: snapshot.data ?? 0,
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