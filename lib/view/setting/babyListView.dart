
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/viewmodel/setting/babyListViewModel.dart';

class BabyListView extends StatefulWidget {
  @override
  _BabyListViewState createState() => _BabyListViewState();
}

class _BabyListViewState extends State<BabyListView> {
  BabyListViewModel _viewModel;
  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<BabyListViewModel>(context, listen: false);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.of(context).babyListTitle),
      ),
      body: StreamBuilder(
        stream: _viewModel.babiesStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data.length == 0) {
            return Container();
          }

          List<Baby> babies = snapshot.data;

          return ListView.builder(
            itemCount: babies.length,
            itemBuilder: (context, index) {
              final Baby baby = babies[index];
              return Text(baby.name);
            },
          );
        }
      )
    );
  }
}