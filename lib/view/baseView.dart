
import 'package:flutter/material.dart';
import 'package:raisingchildrenrecord2/viewmodel/baseViewModel.dart';

class BaseView<VM extends ViewModel> extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    throw 'This method must be implemented.';
  }
}

class BaseViewState<V extends BaseView, VM extends ViewModel> extends State<V> {
  @override
  Widget build(BuildContext context) {
    throw 'This method must be implemented.';
  }
}