
import 'package:flutter/material.dart';
import 'package:raisingchildrenrecord2/view/homeView.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/animated_focus_light.dart';
import 'package:tutorial_coach_mark/target_focus.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

mixin HomeViewTutorial on State<HomeView> {

  final GlobalKey<RecordButtonState> firstRecordButtonKey = GlobalKey();

  void initState() {
    super.initState();

    _configureTutorialIfNeeded();
  }

  List<TargetFocus> targets = [];

  void _configureTutorialIfNeeded() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getBool('recordButtonTutorialCompleted') ?? false) {
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
    print("### showtutorial");
    TutorialCoachMark(
      context,
      targets: targets,
      colorShadow: Colors.black,
      textSkip: 'スキップ',
      paddingFocus: 10,
      opacityShadow: 0.8,
      finish: () {
        SharedPreferences.getInstance().then((sharedPreferences) {
          sharedPreferences.setBool('recordButtonTutorialCompleted', true);
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
            child: Text(
              'まずは、記録してみましょう！',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 24.0,
              ),
            ),
          )
        ],
      ),
    ];
  }
}