
import 'package:flutter/material.dart';

class SimpleSegmentedControl extends StatelessWidget {
  final int currentIndex;
  final List<String> labels;
  final void Function(int index) onSelect;

  SimpleSegmentedControl({ Key key, this.currentIndex, this.labels, this.onSelect }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _buildChildren(labels),
    );
  }

  List<Widget> _buildChildren(List<String> labels) {
    List<Widget> buttons = [];
    for (int i = 0; i < labels.length; i++) {
      String label = labels[i];
      buttons.add(
        FlatButton(
          child: Text(label),
          textColor: i == currentIndex ? Colors.blue : Colors.grey,
          onPressed: () => _onButtonTapped(i),
        )
      );
    }
    return buttons;
  }

  void _onButtonTapped(int index) {
    onSelect(index);
  }
}