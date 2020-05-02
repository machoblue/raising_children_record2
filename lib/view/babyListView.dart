
import 'package:flutter/material.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';

class BabyListView extends StatefulWidget {
  @override
  _BabyListViewState createState() => _BabyListViewState();
}

class _BabyListViewState extends State<BabyListView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text(L10n.of(context).babyListTitle),
      ),
      body: Text('BabyListView')
    );
  }
}