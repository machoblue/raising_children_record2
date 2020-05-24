
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:raisingchildrenrecord2/view/homeView.dart';
import 'package:raisingchildrenrecord2/view/setting/settingsView.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/animated_focus_light.dart';
import 'package:tutorial_coach_mark/target_focus.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

mixin SettingsViewTutorial on State<SettingsView> {
  GlobalKey editRecordButtonsOrderKey = GlobalKey();
  GlobalKey editBabyInfoKey = GlobalKey();

  void initState() {
    super.initState();

    _configureTutorialIfNeeded();
  }

  List<TargetFocus> targets = [];

  void _configureTutorialIfNeeded() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getBool('settingsTutorialCompleted') ?? false) {
      return;
    }

    _prepareTutorial();
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
  }

  void _afterLayout(_) {
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
          sharedPreferences.setBool('settingsTutorialCompleted', true);
        });
      },
      clickTarget: (target) {},
      clickSkip: () {},
    ).show();
  }

  void _prepareTutorial() {
    this.targets = [
      TargetFocus(
        identify: 'Edit Record Buttons Order',
        keyTarget: editRecordButtonsOrderKey,
        shape: ShapeLightFocus.RRect,
        contents: [
          ContentTarget(
            align: AlignContent.bottom,
            child: Column(
              children: <Widget>[
                Text(
                  'ホーム画面の記録ボタンの順番を変更できます。',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 24.0,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      TargetFocus(
        identify: 'Edit Baby Info Key',
        keyTarget: editBabyInfoKey,
        shape: ShapeLightFocus.RRect,
        contents: [
          ContentTarget(
            align: AlignContent.bottom,
            child: Column(
              children: <Widget>[
                Text(
                  '赤ちゃんの追加・編集ができます。',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 24.0,
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