
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/data/babyRepository.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/storage/storageUtil.dart';
import 'package:raisingchildrenrecord2/view/baseState.dart';
import 'package:raisingchildrenrecord2/view/setting/babyEditView.dart';
import 'package:raisingchildrenrecord2/viewmodel/setting/babyEditViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/setting/babyListViewModel.dart';

class BabyListView extends StatefulWidget {
  @override
  _BabyListViewState createState() => _BabyListViewState();
}

class _BabyListViewState extends BaseState<BabyListView, BabyListViewModel> {
  final TextStyle _emptyMessageFont = TextStyle(fontSize: 14, color: Color(0x00FFAAAAAA));

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.of(context).babyListTitle),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _openBabyEditView(null),
          ),
        ]
      ),
      body: StreamBuilder(
        stream: viewModel.babiesStream,
        builder: (context, snapshot) {
          List<Baby> babies = snapshot.data ?? [];
          return babies.isEmpty
            ? Container(
              padding: EdgeInsets.all(16),
              alignment: Alignment.topCenter,
              child: Text(
                l10n.emptyMessage,
                style: _emptyMessageFont,
              )
            )
            : ListView.builder(
              itemCount: babies.length,
              itemBuilder: (context, index) => _babyListItem(babies[index]),
            );
        }
      )
    );
  }

  Widget _babyListItem(Baby baby) {
    return GestureDetector(
      onTap: () => _openBabyEditView(baby),
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 16, 24, 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(width: 0.25, color: Color(0x0064000000)),
            bottom: BorderSide(width: 0.25, color: Color(0x0064000000)),
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.fitHeight,
                    image: CachedNetworkImageProvider(baby.photoUrl) ?? AssetImage("assets/default_baby_icon.png"),
                  )
              ),
            ),
            Container(width: 8),
            Expanded(
              child: Text(baby.name),
            ),
            Icon(
              Icons.chevron_right
            ),
          ],
        )
      ),
    );
  }

  void _openBabyEditView(Baby baby) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) {
              return Provider<BabyEditViewModel>(
                create: (_) => BabyEditViewModel(baby, FirestoreBabyRepository(), FirebaseStorageUtil()),
                child: BabyEditView(baby),
              );
            }
        )
    );
  }
}