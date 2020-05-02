

import 'package:flutter/material.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';

class BabyEditView extends StatefulWidget {
  Baby baby;

  BabyEditView(this.baby);

  @override
  _BabyEditViewState createState() => _BabyEditViewState();
}

class _BabyEditViewState extends State<BabyEditView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Baby")
      ),
      body: Text("Edit baby"),
    );
  }
}