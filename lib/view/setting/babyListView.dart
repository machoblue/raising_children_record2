
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/view/setting/babyEditView.dart';
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
            itemBuilder: (context, index) => _babyListItem(babies[index]),
          );
        }
      )
    );
  }

  Widget _babyListItem(Baby baby) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return BabyEditView(baby);
            }
          )
        );
      },
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
}