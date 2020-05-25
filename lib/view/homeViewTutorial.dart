
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/view/homeView.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/animated_focus_light.dart';
import 'package:tutorial_coach_mark/target_focus.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

mixin HomeViewTutorial on State<HomeView> {

  static final String recordButtonTutorialCompleted = 'recordButtonTutorialCompleted';
  final GlobalKey<RecordButtonState> firstRecordButtonKey = GlobalKey();

  void initState() {
    super.initState();

    _configureTutorialIfNeeded();
  }

  List<TargetFocus> targets = [];

  void _configureTutorialIfNeeded() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getBool(recordButtonTutorialCompleted) ?? false) {
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
          sharedPreferences.setBool(recordButtonTutorialCompleted, true);
        });
      },
      clickTarget: (target) {},
      clickSkip: () {},
    ).show();
  }

  void _prepareTutorial() {
    this.targets = [
      TargetFocus(
        identify: 'First Record Button',
        keyTarget: firstRecordButtonKey,
        shape: ShapeLightFocus.Circle,
        contents: [
          ContentTarget(
            align: AlignContent.top,
            child: Column(
              children: <Widget>[
                Text(
                  Intl.message('First, Let\'s creating a record.', name: 'recordButtonTutorial'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 24.0,
                  ),
                ),
                Container(height: 8),
                Text(
                  Intl.message('NOTE: These buttons order can be changed from Settings at the bottom right.', name: 'recordButtonTutorialDescription'),
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