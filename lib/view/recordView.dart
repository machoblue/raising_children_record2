
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:raisingchildrenrecord2/model/record.dart';

class RecordView extends StatefulWidget {
  String recordType;
  Record record;

  RecordView({ Key key, this.recordType, this.record }): super(key: key);

  @override
  _RecordViewState createState() => _RecordViewState();
}

class _RecordViewState extends State<RecordView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.record == null ? "新規追加" : "編集"),
      ),
      body: Container(),
    );
  }
}