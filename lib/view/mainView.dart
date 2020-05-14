import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/data/BabyRepository.dart';
import 'package:raisingchildrenrecord2/data/UserRepository.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/view/loginView.dart';

import 'package:raisingchildrenrecord2/viewmodel/mainViewModel.dart';
import 'package:raisingchildrenrecord2/view/setting/settingsView.dart';
import 'package:raisingchildrenrecord2/view/homeView.dart';
import 'package:raisingchildrenrecord2/viewmodel/setting/settingsViewModel.dart';

class MainView extends StatefulWidget {
  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {

  @override
  Widget build(BuildContext context) {
    return Provider<MainViewModel>(
      create: (_) => MainViewModel(FirestoreUserRepository(), FirestoreBabyRepository()),
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

  MainViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<MainViewModel>(context, listen: false);
    _viewModel.onInitState.add(null);
    _viewModel.logoutComplete.listen((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => LoginView()
        ),
      );
    });
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
            leading: selectedIndex == 0 ? _babyButton() : null,
            title: Text(_appBarTitles[selectedIndex]),
          ),
          body: _buildContent(selectedIndex),
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

  Widget _babyButton() {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 8, 0, 8),

      child: StreamBuilder(
        stream: _viewModel.babies,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data.isEmpty) {
            return StreamBuilder(
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
                }
            );
          }

          final List<Baby> babies = snapshot.data;

          return PopupMenuButton<Baby>(
            onSelected: (baby) => _viewModel.onBabySelected.add(baby),
            itemBuilder: (context) {
              return babies
                  .map((baby) {
                return PopupMenuItem<Baby>(
                  value: baby,
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.fitHeight,
                              image: CachedNetworkImageProvider(baby.photoUrl) ?? AssetImage("assets/default_baby_icon.png"),
                            )
                        ),
                      ),
                      Container(width: 8),
                      Text(baby.name),
                    ],
                  ),
                );
              })
                  .toList();
            },
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
          );
        },
      ),
    );
  }

  Widget _buildContent(int selectedIndex) {
    switch (selectedIndex) {
      case 0: {
        return HomeView();
      }
      case 1: {
        return Provider<SettingsViewModel>(
          create: (_) => SettingsViewModel(
            Provider.of<MainViewModel>(context).userBehaviorSubject.value,
            FirestoreUserRepository(),
            FirestoreBabyRepository(),
          ),
          child: SettingsView(),
        );
      }
      default: {
        throw('This line shouldn\'t be reached.');
      }
    }
  }
}