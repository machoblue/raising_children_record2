import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/data/babyRepository.dart';
import 'package:raisingchildrenrecord2/data/familyRepository.dart';
import 'package:raisingchildrenrecord2/data/userRepository.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/view/baseState.dart';
import 'package:raisingchildrenrecord2/view/loginView.dart';
import 'package:raisingchildrenrecord2/viewmodel/homeViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/loginViewModel.dart';

import 'package:raisingchildrenrecord2/viewmodel/mainViewModel.dart';
import 'package:raisingchildrenrecord2/view/setting/settingsView.dart';
import 'package:raisingchildrenrecord2/view/homeView.dart';
import 'package:raisingchildrenrecord2/viewmodel/setting/settingsViewModel.dart';

class MainView extends StatefulWidget {
  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends BaseState<MainView, MainViewModel> {

  List<String> _appBarTitles;

  @override
  void initState() {
    super.initState();
    viewModel.onInitState.add(null);
    viewModel.logoutComplete.listen((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Provider(
            create: (_) => LoginViewModel(FirestoreUserRepository(), FirestoreBabyRepository()),
            child: LoginView(),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    _appBarTitles = [l10n.homeTitle, l10n.settingsTitle];

    return StreamBuilder(
      stream: viewModel.selectedIndex,
      builder: (context, snapshot) {
        final selectedIndex = snapshot.data ?? 0;
        return Scaffold(
          appBar: AppBar(
            leading: selectedIndex == 0 ? _babyButton() : null,
            title: Text(_appBarTitles[selectedIndex]),
          ),
          body: _buildContent(selectedIndex),
          bottomNavigationBar: _buildBottomNavigation(selectedIndex),
        );
      },
    );
  }

  Widget _babyButton() {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 8, 0, 8),

      child: StreamBuilder(
        stream: viewModel.babies,
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
            onSelected: (baby) => viewModel.onBabySelected.add(baby),
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
        return Provider<HomeViewModel>(
          create: (_) => HomeViewModel(viewModel.userBehaviorSubject, viewModel.babyBehaviorSubject),
          child: HomeView(),
        );
      }
      case 1: {
        return Provider<SettingsViewModel>(
          create: (_) => SettingsViewModel(
            Provider.of<MainViewModel>(context).userBehaviorSubject.value,
            FirestoreUserRepository(),
            FirestoreBabyRepository(),
            FirestoreFamilyRepository(),
          ),
          child: SettingsView(),
        );
      }
      default: {
        throw('This line shouldn\'t be reached.');
      }
    }
  }

  Widget _buildBottomNavigation(int selectedIndex) {
    L10n l10n = L10n.of(context);
    return BottomNavigationBar(
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
      onTap: viewModel.onTabItemTapped.add,
    );
  }
}