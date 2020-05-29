
import 'dart:ffi';

import 'package:flutter/material.dart';

class SimpleDropdownButton<T> extends StatefulWidget {
  T value;
  List<T> items;
  String Function(T) itemLabel;
  void Function(T) onChanged;

  SimpleDropdownButton({ Key key, this.value, this.items, this.itemLabel, this.onChanged }): super(key: key);

  @override
  _SimpleDropdownButtonState<T> createState() => _SimpleDropdownButtonState<T>();
}

class _SimpleDropdownButtonState<T> extends State<SimpleDropdownButton> {
  final _listItemFont = const TextStyle(fontSize: 20.0);

  Widget build(BuildContext context) {
    return DropdownButton<T>(
      value: widget.value,
      items: widget.items.map((item) {
        return DropdownMenuItem<T>(
            value: item,
            child: Container(
                padding: EdgeInsets.fromLTRB(20, 0, 12, 0),
                child: Text(
                  widget.itemLabel(item),
                  style: _listItemFont,
                )
            )
        );
      }).toList(),
      icon: Icon(Icons.expand_more),
      iconSize: 24,
      elevation: 16,
      underline: Container(
        height: 2,
        color: Colors.black54,
      ),
      onChanged: widget.onChanged,
    );
  }
}