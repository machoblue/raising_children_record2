
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:raisingchildrenrecord2/view/homeView.dart';
import 'package:raisingchildrenrecord2/view/mainView.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/animated_focus_light.dart';
import 'package:tutorial_coach_mark/target_focus.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

mixin MainViewTutorial on State<MainView> {

  final GlobalKey appBarBabyButtonKey = GlobalKey();

  void initState() {
    print("### mainViewTUtorial.initState");
    super.initState();

    _configureTutorialIfNeeded();
  }

  List<TargetFocus> targets = [];

  void _configureTutorialIfNeeded() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getBool('mainViewTutorialCompleted') ?? false) {
      return;
    }

    _prepareTutorial();
  }

  void showTutorial() {
    Future.delayed(Duration(milliseconds: 500), () {
      _showTutorial();
    });
  }

  void _showTutorial() {
    TutorialCoachMark(
      context,
      targets: targets,
      colorShadow: Colors.black,
      textSkip: 'スキップ',
      paddingFocus: 10,
      opacityShadow: 0.8,
      finish: () {
        SharedPreferences.getInstance().then((sharedPreferences) {
          sharedPreferences.setBool('mainViewTutorialCompleted', true);
        });
      },
      clickTarget: (target) {},
      clickSkip: () {},
    ).show();
  }

  void _prepareTutorial() {
    this.targets = [
      TargetFocus(
        identify: 'Baby Button',
        keyTarget: appBarBabyButtonKey,
        shape: ShapeLightFocus.Circle,
        contents: [
          ContentTarget(
            align: AlignContent.bottom,
            child: Column(
              children: <Widget>[
                Text(
                  'このアイコンをタップすると、赤ちゃんを切り替えることができます。',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 24.0,
                  ),
                ),
                Container(height: 8),
                Text(
                  '赤ちゃんの追加・編集は右下の設定からできます。',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    ];
  }
}