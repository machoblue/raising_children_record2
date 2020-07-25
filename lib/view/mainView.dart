import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:raisingchildrenrecord2/data/babyRepository.dart';
import 'package:raisingchildrenrecord2/data/familyRepository.dart';
import 'package:raisingchildrenrecord2/data/recordRepository.dart';
import 'package:raisingchildrenrecord2/data/userRepository.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/shared/authenticator.dart';
import 'package:raisingchildrenrecord2/view/baseState.dart';
import 'package:raisingchildrenrecord2/view/chart/conditionChartView.dart';
import 'package:raisingchildrenrecord2/view/chart/excretionChartView.dart';
import 'package:raisingchildrenrecord2/view/chart/growthChartView.dart';
import 'package:raisingchildrenrecord2/view/chart/milkChartView.dart';
import 'package:raisingchildrenrecord2/view/chart/sleepChartView.dart';
import 'package:raisingchildrenrecord2/view/loginView.dart';
import 'package:raisingchildrenrecord2/view/mainViewTutorial.dart';
import 'package:raisingchildrenrecord2/view/shared/widget/circleImage.dart';
import 'package:raisingchildrenrecord2/viewmodel/chart/conditionChartViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/chart/excretionChartViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/chart/growthChartViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/chart/milkChartViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/chart/sleepChartViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/home/homeViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/loginViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/mainViewModel.dart';
import 'package:raisingchildrenrecord2/view/setting/settingsView.dart';
import 'package:raisingchildrenrecord2/view/home/homeView.dart';
import 'package:raisingchildrenrecord2/viewmodel/setting/settingsViewModel.dart';

class MainView extends StatefulWidget {
  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends BaseState<MainView, MainViewModel> with MainViewTutorial, SingleTickerProviderStateMixin {

  final chartTabs = <Tab>[
    Tab(text: Intl.message('Milk', name: 'milkTab')),
    Tab(text: Intl.message('Sleep', name: 'sleepTab')),
    Tab(text: Intl.message('Excretion', name: 'excretionTab')),
    Tab(text: Intl.message('Condition', name: 'conditionTab')),
    Tab(text: Intl.message('Growth', name: 'growthTab')),
  ];

  TabController _chartTabController;

  StreamSubscription _logoutCompleteSubscription;

  @override
  void initState() {
    super.initState();
    viewModel.onInitState.add(null);
    _logoutCompleteSubscription = viewModel.logoutComplete.listen((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Provider(
            create: (_) => LoginViewModel(GoogleAuthenticator(), FirestoreUserRepository(), FirestoreBabyRepository()),
            child: LoginView(),
          ),
        ),
      );
    });

    _chartTabController = TabController(vsync: this, length: chartTabs.length);
  }

  @override
  void dispose() {
    _logoutCompleteSubscription.cancel();
    _chartTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final appBarTitles = [l10n.homeTitle, l10n.chartTitle, l10n.settingsTitle];

    return StreamBuilder(
      stream: viewModel.selectedIndex,
      builder: (context, snapshot) {
        final selectedIndex = snapshot.data ?? 0;
        return Scaffold(
          appBar: AppBar(
            leading: selectedIndex != 2 ? _babyButton() : null,
            title: Text(appBarTitles[selectedIndex]),
            bottom: selectedIndex == 1 ? _buildTabBar() : null,
          ),
          body: _buildContent(selectedIndex),
          bottomNavigationBar: _buildBottomNavigation(selectedIndex),
        );
      },
    );
  }

  Widget _babyButton() {
    return Container(
      key: appBarBabyButtonKey,
      padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: StreamBuilder(
        stream: viewModel.babies,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data.isEmpty) {
            return StreamBuilder(
                stream: Provider.of<MainViewModel>(context).babyIconImageProvider,
                builder: (context, snapshot) {
                  return CircleImage(snapshot.data ?? AssetImage('assets/default_baby_icon.png'));
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
                      CircleImage(
                        CachedNetworkImageProvider(baby.photoUrl) ?? AssetImage("assets/default_baby_icon.png"),
                        width: 28,
                        height: 28,
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
                return CircleImage(snapshot.data ?? AssetImage('assets/default_baby_icon.png'));
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _chartTabController,
      tabs: chartTabs,
      isScrollable: true,
    );
  }

  Widget _buildContent(int selectedIndex) {
    switch (selectedIndex) {
      case 0: {
        return Provider<HomeViewModel>(
          create: (_) => HomeViewModel(viewModel.userBehaviorSubject, viewModel.babyBehaviorSubject),
          child: HomeView(
            onCreateRecordComplete: showTutorial,
          ),
        );
      }
      case 1: {
        return TabBarView(
          controller: _chartTabController,
          children: <Widget>[
            Provider<MilkChartViewModel>(
              create: (_) => MilkChartViewModel(viewModel.baby, FirestoreRecordRepository()),
              child: MilkChartView(),
            ),
            Provider<SleepChartViewModel>(
              create: (_) => SleepChartViewModel(viewModel.baby, FirestoreRecordRepository()),
              child: SleepChartView(),
            ),
            Provider<ExcretionChartViewModel>(
              create: (_) => ExcretionChartViewModel(viewModel.baby, FirestoreRecordRepository()),
              child: ExcretionChartView(),
            ),
            Provider<ConditionChartViewModel>(
              create: (_) => ConditionChartViewModel(viewModel.baby, FirestoreRecordRepository()),
              child: ConditionChartView(),
            ),
            Provider<GrowthChartViewModel>(
              create: (_) => GrowthChartViewModel(viewModel.baby, FirestoreRecordRepository()),
              child: GrowthChartView(),
            ),
          ],
        );
      }
      case 2: {
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
          icon: Icon(Icons.show_chart),
          title: Text(l10n.chartTitle),
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