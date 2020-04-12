import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:raisingchildrenrecord2/viewmodel/mainViewModel.dart';

class MainView extends StatefulWidget {
  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    HomePage2(),
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
                  title: StreamBuilder(
                    stream: Provider.of<MainViewModel>(context).appBarTitle,
                    builder: (context, snapshot) => Text(snapshot.hasData ? snapshot.data : ""),
                  ),
                ),
                body: _widgetOptions.elementAt(snapshot.hasData ? snapshot.data : 0),
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
                  currentIndex: snapshot.hasData ? snapshot.data : 0,
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

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Text('home body');
  }
}

class HomePage2 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState2();
}

class _HomePageState2 extends State<HomePage2> {
  @override
  Widget build(BuildContext context) {
    return Text('home body2');
  }
}