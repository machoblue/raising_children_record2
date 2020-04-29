
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:raisingchildrenrecord2/view/record/baseRecordView.dart';
import 'package:raisingchildrenrecord2/viewmodel/record/plainRecordViewModel.dart';

class PlainRecordView extends BaseRecordView<PlainRecordViewModel> {

  PlainRecordView({ Key key, bool isNew }): super(key: key, isNew: isNew);

  @override
  Widget buildContent(BuildContext context) {
    return Container();
  }
}
