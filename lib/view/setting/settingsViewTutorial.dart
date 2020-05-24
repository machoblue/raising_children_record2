
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
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
    L10n l10n = L10n.of(context);
    TutorialCoachMark(
      context,
      targets: targets,
      colorShadow: Colors.black,
      textSkip: l10n.tutorialSkip,
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
                  Intl.message('You can change order of record buttons in home screen.', name: 'editRecordButtonsOrderTutorial'),
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
                  Intl.message('You can edit and add Baby.', name: 'editBabyInfoTutorial'),
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